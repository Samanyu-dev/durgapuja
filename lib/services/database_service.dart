import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'idolkaker';
  static const String _transactionsTableName = 'transactions';
  static const String _ordersTableName = 'orders';
  static const String _samitiFundsTableName = 'samiti_funds';
  static const String _workerFundsTableName = 'worker_funds';
  static const String _workerPaymentsTableName = 'worker_payments';

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'idolkaker.db');
    return await openDatabase(
      path,
      version: 6,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY,
            total_income REAL NOT NULL DEFAULT 0,
            total_expenses REAL NOT NULL DEFAULT 0
          )
        ''');
        // Insert single row with id = 1
        await db.insert(_tableName, {
          'id': 1,
          'total_income': 0.0,
          'total_expenses': 0.0,
        });

        await db.execute('''
          CREATE TABLE $_transactionsTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            source_text TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $_ordersTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_name TEXT NOT NULL,
            phone_number TEXT,
            idol_name TEXT,
            amount_received REAL,
            delivery_date TEXT,
            payment_date TEXT,
            payment_method TEXT,
            special_requirements TEXT,
            whatsapp_link TEXT,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $_samitiFundsTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $_workerFundsTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idol_type TEXT NOT NULL,
            worker_type TEXT NOT NULL,
            amount_paid REAL NOT NULL,
            amount_total REAL NOT NULL,
            amount_remaining REAL NOT NULL,
            amount_due REAL NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE $_workerPaymentsTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            worker_name TEXT,
            worker_type TEXT NOT NULL,
            idol_type TEXT,
            amount REAL NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE $_transactionsTableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              type TEXT NOT NULL,
              amount REAL NOT NULL,
              sourceText TEXT NOT NULL,
              createdAt INTEGER NOT NULL
            )
          ''');
        }

        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $_ordersTableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              customer_name TEXT NOT NULL,
              phone_number TEXT,
              idol_name TEXT,
              amount_received REAL,
              delivery_date TEXT,
              payment_date TEXT,
              payment_method TEXT,
              special_requirements TEXT,
              whatsapp_link TEXT,
              created_at TEXT NOT NULL
            )
          ''');
          
          // Migrate existing orders table if needed
          try {
            await db.execute('ALTER TABLE $_ordersTableName ADD COLUMN customer_name TEXT');
            await db.execute('ALTER TABLE $_ordersTableName ADD COLUMN phone_number TEXT');
            await db.execute('ALTER TABLE $_ordersTableName ADD COLUMN created_at TEXT');
            // Copy existing name to customer_name if exists
            await db.execute('UPDATE $_ordersTableName SET customer_name = name WHERE customer_name IS NULL');
            await db.execute('UPDATE $_ordersTableName SET phone_number = phone WHERE phone_number IS NULL');
            await db.execute('UPDATE $_ordersTableName SET created_at = datetime("now") WHERE created_at IS NULL');
          } catch (_) {
            // Migration already done or columns exist
          }

          await db.execute('''
            CREATE TABLE IF NOT EXISTS $_samitiFundsTableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              amount REAL NOT NULL,
              date TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS $_workerFundsTableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              idol_type TEXT NOT NULL,
              worker_type TEXT NOT NULL,
              amount_paid REAL NOT NULL,
              amount_total REAL NOT NULL,
              amount_remaining REAL NOT NULL
            )
          ''');
        }

        if (oldVersion < 4) {
          // ---- transactions migration to new schema ----
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ${_transactionsTableName}_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              type TEXT NOT NULL,
              amount REAL NOT NULL,
              category TEXT NOT NULL,
              source_text TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');

          try {
            final oldRows = await db.query(_transactionsTableName);
            for (final row in oldRows) {
              final createdAtMs = (row['createdAt'] as num?)?.toInt();
              final createdAtIso = createdAtMs == null
                  ? DateTime.now().toIso8601String()
                  : DateTime.fromMillisecondsSinceEpoch(createdAtMs)
                      .toIso8601String();
              await db.insert('${_transactionsTableName}_new', {
                'id': row['id'],
                'type': row['type'],
                'amount': row['amount'],
                'category': 'other',
                'source_text': row['sourceText'] ?? '',
                'created_at': createdAtIso,
              });
            }
            await db.execute('DROP TABLE IF EXISTS $_transactionsTableName');
            await db.execute(
              'ALTER TABLE ${_transactionsTableName}_new RENAME TO $_transactionsTableName',
            );
          } catch (_) {
            // If the old table isn't compatible, just ensure the new schema exists.
            await db.execute('DROP TABLE IF EXISTS ${_transactionsTableName}_new');
            await db.execute('''
              CREATE TABLE IF NOT EXISTS $_transactionsTableName (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                type TEXT NOT NULL,
                amount REAL NOT NULL,
                category TEXT NOT NULL,
                source_text TEXT NOT NULL,
                created_at TEXT NOT NULL
              )
            ''');
          }

          // ---- ensure samiti_funds exists ----
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $_samitiFundsTableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              amount REAL NOT NULL,
              date TEXT NOT NULL
            )
          ''');

          // ---- ensure worker_funds exists + add amount_due ----
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $_workerFundsTableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              idol_type TEXT NOT NULL,
              worker_type TEXT NOT NULL,
              amount_paid REAL NOT NULL,
              amount_total REAL NOT NULL,
              amount_remaining REAL NOT NULL
            )
          ''');
          try {
            await db.execute(
              'ALTER TABLE $_workerFundsTableName ADD COLUMN amount_due REAL NOT NULL DEFAULT 0',
            );
          } catch (_) {
            // Column probably already exists.
          }
        }

        if (oldVersion < 5) {
          // Migrate orders table schema
          try {
            await db.execute('ALTER TABLE $_ordersTableName ADD COLUMN customer_name TEXT');
            await db.execute('ALTER TABLE $_ordersTableName ADD COLUMN phone_number TEXT');
            await db.execute('ALTER TABLE $_ordersTableName ADD COLUMN created_at TEXT');
            // Copy existing name to customer_name if exists
            await db.execute(
                'UPDATE $_ordersTableName SET customer_name = name WHERE customer_name IS NULL');
            await db.execute(
                'UPDATE $_ordersTableName SET phone_number = phone WHERE phone_number IS NULL');
            await db.execute(
                'UPDATE $_ordersTableName SET created_at = datetime("now") WHERE created_at IS NULL');
          } catch (_) {
            // Migration already done or columns exist
          }
        }

        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $_workerPaymentsTableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              worker_name TEXT,
              worker_type TEXT NOT NULL,
              idol_type TEXT,
              amount REAL NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  static Future<Map<String, dynamic>> getFinanceData() async {
    final db = await getDatabase();
    final result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [1],
    );

    if (result.isEmpty) {
      // If row doesn't exist, create it
      await db.insert(_tableName, {
        'id': 1,
        'total_income': 0.0,
        'total_expenses': 0.0,
      });
      return {'total_income': 0.0, 'total_expenses': 0.0};
    }

    return {
      'total_income': result.first['total_income'] as double,
      'total_expenses': result.first['total_expenses'] as double,
    };
  }

  static Future<void> updateIncome(double amount) async {
    final db = await getDatabase();
    await db.rawUpdate(
      'UPDATE $_tableName SET total_income = total_income + ? WHERE id = 1',
      [amount],
    );
  }

  static Future<void> updateExpenses(double amount) async {
    final db = await getDatabase();
    await db.rawUpdate(
      'UPDATE $_tableName SET total_expenses = total_expenses + ? WHERE id = 1',
      [amount],
    );
  }

  static Future<void> insertTransaction({
    required String type, // "income" | "expense" | "worker_payment" | ...
    required double amount,
    required String category, // "samiti" | "worker" | "other"
    required String sourceText, // original English sentence
  }) async {
    final db = await getDatabase();
    await db.insert(
      _transactionsTableName,
      {
        'type': type,
        'amount': amount,
        'category': category,
        'source_text': sourceText,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Latest [limit] transactions, ordered by created_at DESC.
  static Future<List<Map<String, dynamic>>> getRecentTransactions({
    int limit = 3,
  }) async {
    final db = await getDatabase();
    final rows = await db.query(
      _transactionsTableName,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<Map<String, dynamic>?> getTransactionById(int id) async {
    final db = await getDatabase();
    final rows = await db.query(
      _transactionsTableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  static Future<void> deleteTransaction(int id) async {
    final db = await getDatabase();
    await db.delete(
      _transactionsTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Reverses the transaction effect and deletes it. Atomic (all or nothing).
  static Future<void> undoTransaction(int id) async {
    final t = await getTransactionById(id);
    if (t == null) return;
    final type = t['type'] as String? ?? '';
    final category = t['category'] as String? ?? '';
    final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
    if (amount <= 0) return;

    final db = await getDatabase();
    await db.execute('BEGIN TRANSACTION');
    try {
      if (type == 'income') {
        await updateIncome(-amount);
        if (category == 'samiti') {
          final samiti = await db.query(
            _samitiFundsTableName,
            where: 'amount = ?',
            whereArgs: [amount],
            orderBy: 'id DESC',
            limit: 1,
          );
          if (samiti.isNotEmpty) {
            await db.delete(
              _samitiFundsTableName,
              where: 'id = ?',
              whereArgs: [samiti.first['id']],
            );
          }
        }
      } else if (type == 'expense') {
        await updateExpenses(-amount);
      } else if (type == 'worker_payment') {
        await updateExpenses(-amount);
        final wp = await db.query(
          _workerPaymentsTableName,
          where: 'amount = ?',
          whereArgs: [amount],
          orderBy: 'id DESC',
          limit: 1,
        );
        if (wp.isNotEmpty) {
          await db.delete(
            _workerPaymentsTableName,
            where: 'id = ?',
            whereArgs: [wp.first['id']],
          );
        }
        final wf = await db.query(
          _workerFundsTableName,
          where: 'amount_paid = ?',
          whereArgs: [amount],
          orderBy: 'id DESC',
          limit: 1,
        );
        if (wf.isNotEmpty) {
          final row = wf.first;
          final currentPaid = (row['amount_paid'] as num?)?.toDouble() ?? 0.0;
          final total = (row['amount_total'] as num?)?.toDouble() ?? 0.0;
          final newPaid = (currentPaid - amount).clamp(0.0, total);
          if (newPaid <= 0) {
            await db.delete(
              _workerFundsTableName,
              where: 'id = ?',
              whereArgs: [row['id']],
            );
          } else {
            await db.update(
              _workerFundsTableName,
              {
                'amount_paid': newPaid,
                'amount_remaining': total - newPaid,
              },
              where: 'id = ?',
              whereArgs: [row['id']],
            );
          }
        }
      }
      await deleteTransaction(id);
      await db.execute('COMMIT');
    } catch (e) {
      await db.execute('ROLLBACK');
      rethrow;
    }
  }

  static Future<void> insertWorkerPayment({
    required String workerName,
    required String workerType,
    String? idolType,
    required double amount,
  }) async {
    final db = await getDatabase();
    await db.insert(
      _workerPaymentsTableName,
      {
        'worker_name': workerName,
        'worker_type': workerType,
        'idol_type': idolType,
        'amount': amount,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Returns total amount paid for a given worker_type (e.g. "clay", "painting").
  static Future<double> getWorkerPaymentsTotalByType(String workerType) async {
    final db = await getDatabase();
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $_workerPaymentsTableName WHERE worker_type = ?',
      [workerType],
    );
    final value = result.isNotEmpty ? result.first['total'] as num? : null;
    return value?.toDouble() ?? 0.0;
  }

  static Future<void> insertOrder({
    required String customerName,
    String? phoneNumber,
    String? idolName,
    double? amountReceived,
    String? deliveryDate,
    String? paymentDate,
    String? paymentMethod,
    String? specialRequirements,
    String? whatsappLink,
  }) async {
    final db = await getDatabase();
    await db.insert(
      _ordersTableName,
      {
        'customer_name': customerName,
        'phone_number': phoneNumber,
        'idol_name': idolName,
        'amount_received': amountReceived,
        'delivery_date': deliveryDate,
        'payment_date': paymentDate,
        'payment_method': paymentMethod,
        'special_requirements': specialRequirements,
        'whatsapp_link': whatsappLink,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
    // NOTE: Orders do NOT affect idolmaker income automatically
  }

  static Future<void> insertSamitiFund({
    required String name,
    required double amount,
    required String date,
    bool updateIdolMakerTotals = true,
  }) async {
    final db = await getDatabase();
    await db.insert(
      _samitiFundsTableName,
      {
        'name': name,
        'amount': amount,
        'date': date,
      },
    );
    // Optionally increment total income
    if (updateIdolMakerTotals) {
      await updateIncome(amount);
    }
  }

  /// Manual entry: Insert Samiti Fund with transaction log
  /// Follows rule: transaction -> update totals
  static Future<void> insertSamitiFundManual({
    required String name,
    required double amount,
    required String date,
  }) async {
    // 1) Insert into transactions
    await insertTransaction(
      type: 'income',
      amount: amount,
      category: 'samiti',
      sourceText: 'Manual Samiti Entry',
    );

    // 2) Insert into samiti_funds
    await insertSamitiFund(
      name: name,
      amount: amount,
      date: date,
      updateIdolMakerTotals: false, // Already handled by transaction
    );

    // 3) Update idolmaker totals
    await updateIncome(amount);
  }

  static Future<void> insertWorkerFund({
    required String idolType,
    required String workerType,
    required double amountPaid,
    required double amountTotal,
  }) async {
    final db = await getDatabase();
    final remaining = amountTotal - amountPaid;
    final due = amountTotal - amountPaid;
    await db.insert(
      _workerFundsTableName,
      {
        'idol_type': idolType,
        'worker_type': workerType,
        'amount_paid': amountPaid,
        'amount_total': amountTotal,
        'amount_remaining': remaining,
        'amount_due': due,
      },
    );
  }

  /// Manual entry: Insert Worker Fund with transaction log
  /// Follows rule: transaction -> update totals
  static Future<void> insertWorkerFundManual({
    required String idolType,
    required String workerType,
    required double amountPaid,
    double amountTotal = 0,
  }) async {
    // 1) Insert into transactions
    await insertTransaction(
      type: 'expense',
      amount: amountPaid,
      category: 'worker',
      sourceText: 'Manual Worker Payment',
    );

    // 2) Insert into worker_funds
    await insertWorkerFund(
      idolType: idolType,
      workerType: workerType,
      amountPaid: amountPaid,
      amountTotal: amountTotal,
    );

    // 3) Update idolmaker totals
    await updateExpenses(amountPaid);
  }

  /// Update a worker fund payment by adding [additionalPaid] to amount_paid.
  /// Also increments idolmaker total_expenses by [additionalPaid].
  static Future<void> updateWorkerPayment({
    required int id,
    required double additionalPaid,
  }) async {
    if (additionalPaid <= 0) return;

    final db = await getDatabase();
    final result = await db.query(
      _workerFundsTableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return;

    final row = result.first;
    final currentPaid = (row['amount_paid'] as num?)?.toDouble() ?? 0.0;
    final total = (row['amount_total'] as num?)?.toDouble() ?? 0.0;
    final newPaid = currentPaid + additionalPaid;
    final remaining = total - newPaid;

    await db.update(
      _workerFundsTableName,
      {
        'amount_paid': newPaid,
        'amount_remaining': remaining,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    // Also increment total expenses
    await updateExpenses(additionalPaid);
  }

  static Future<void> deleteOrdersByCustomerName(String customerName) async {
    final db = await getDatabase();
    await db.delete(
      _ordersTableName,
      where: 'customer_name = ?',
      whereArgs: [customerName],
    );
  }

  static Future<void> updateOrder({
    required int id,
    String? customerName,
    String? phoneNumber,
    String? idolName,
    double? amountReceived,
    String? deliveryDate,
    String? paymentDate,
    String? paymentMethod,
    String? specialRequirements,
    String? whatsappLink,
  }) async {
    final db = await getDatabase();
    Map<String, dynamic> updates = {};
    if (customerName != null) updates['customer_name'] = customerName;
    if (phoneNumber != null) updates['phone_number'] = phoneNumber;
    if (idolName != null) updates['idol_name'] = idolName;
    if (amountReceived != null) updates['amount_received'] = amountReceived;
    if (deliveryDate != null) updates['delivery_date'] = deliveryDate;
    if (paymentDate != null) updates['payment_date'] = paymentDate;
    if (paymentMethod != null) updates['payment_method'] = paymentMethod;
    if (specialRequirements != null) updates['special_requirements'] = specialRequirements;
    if (whatsappLink != null) updates['whatsapp_link'] = whatsappLink;

    if (updates.isNotEmpty) {
      await db.update(
        _ordersTableName,
        updates,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  static Future<void> updateClientDetails({
    required String oldCustomerName,
    required String newCustomerName,
    String? phoneNumber,
  }) async {
    final db = await getDatabase();
    Map<String, dynamic> updates = {'customer_name': newCustomerName};
    if (phoneNumber != null) updates['phone_number'] = phoneNumber;

    await db.update(
      _ordersTableName,
      updates,
      where: 'customer_name = ?',
      whereArgs: [oldCustomerName],
    );
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
