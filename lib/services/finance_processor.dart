import 'database_service.dart';

class FinanceProcessor {
  /// GPT JSON -> insert into transactions -> route to samiti_funds/worker_funds (if applicable)
  /// -> update idolmaker totals.
  ///
  /// Does NOT touch UI.
  static Future<void> processGptResult({
    required Map<String, dynamic> gptJson,
    required String englishText,
  }) async {
    final intent = gptJson['intent'] as String?;
    final amount = (gptJson['amount'] as num?)?.toDouble() ?? 0.0;
    final categoryRaw = gptJson['category'];
    final category =
        (categoryRaw is String && categoryRaw.isNotEmpty) ? categoryRaw : 'other';

    if (amount <= 0) return;
    if (intent == null || intent == 'unknown') return;

    // Determine transaction type and category for transaction log
    String transactionType = 'other';
    String transactionCategory = category;

    // Handle worker_payment intent (new structured format)
    if (intent == 'worker_payment') {
      final workerNameRaw = gptJson['worker_name'] as String?;
      final workerTypeRaw = gptJson['worker_type'] as String?;
      final idolTypeRaw = gptJson['idol_type'] as String?;

      // Map worker_type to database format
      String workerTypeDisplay = 'Unknown';
      String workerTypeKey = 'other';
      if (workerTypeRaw != null) {
        switch (workerTypeRaw.toLowerCase()) {
          case 'clay':
            workerTypeDisplay = 'Claymaking';
            workerTypeKey = 'clay';
            break;
          case 'painting':
            workerTypeDisplay = 'Painting';
            workerTypeKey = 'painting';
            break;
          case 'decoration':
            workerTypeDisplay = 'Decoration';
            workerTypeKey = 'decoration';
            break;
          case 'transport':
            workerTypeDisplay = 'Transport';
            workerTypeKey = 'transport';
            break;
          default:
            workerTypeDisplay = 'Unknown';
            workerTypeKey = 'other';
        }
      }

      // Map idol_type to database format
      String idolType = 'Unknown';
      if (idolTypeRaw != null && idolTypeRaw.toLowerCase() != 'unknown') {
        idolType = idolTypeRaw.substring(0, 1).toUpperCase() +
            idolTypeRaw.substring(1).toLowerCase();
      }

      // 1) Insert into transactions (type="worker_payment" as specified)
      await DatabaseService.insertTransaction(
        type: 'worker_payment',
        amount: amount,
        category: 'worker',
        sourceText: englishText,
      );

      // 2) Insert into worker_funds
      await DatabaseService.insertWorkerFund(
        idolType: idolType,
        workerType: workerTypeDisplay,
        amountPaid: amount,
        amountTotal: 0,
      );

      // 2b) Insert into worker_payments (for summarized Worker Funds UI)
      await DatabaseService.insertWorkerPayment(
        workerName: workerNameRaw ?? 'Unknown',
        workerType: workerTypeKey,
        idolType: idolTypeRaw,
        amount: amount,
      );

      // 3) Update idolmaker totals
      await DatabaseService.updateExpenses(amount);
      return; // Early return for worker_payment
    }

    // Handle samiti_fund intent
    if (intent == 'samiti_fund') {
      transactionType = 'income';
      transactionCategory = 'samiti';

      // 1) Insert into transactions
      await DatabaseService.insertTransaction(
        type: transactionType,
        amount: amount,
        category: transactionCategory,
        sourceText: englishText,
      );

      // 2) Insert into samiti_funds
      final today = DateTime.now().toIso8601String().split('T').first;
      await DatabaseService.insertSamitiFund(
        name: 'Unknown',
        amount: amount,
        date: today,
        updateIdolMakerTotals: false, // totals updated below
      );

      // 3) Update idolmaker totals
      await DatabaseService.updateIncome(amount);
      return; // Early return for samiti_fund
    }

    // Handle order_payment intent (informational, doesn't affect totals automatically)
    if (intent == 'order_payment') {
      // For now, treat as income but don't auto-update totals
      // This can be extended later to insert into orders table
      await DatabaseService.insertTransaction(
        type: 'income',
        amount: amount,
        category: 'other',
        sourceText: englishText,
      );
      // Note: order_payment doesn't automatically update totals per requirements
      return;
    }

    // Handle legacy income/expense intents (backward compatibility)
    if (intent == 'income' || intent == 'expense') {
      transactionType = intent;

      // 1) Insert into transactions
      await DatabaseService.insertTransaction(
        type: transactionType,
        amount: amount,
        category: category,
        sourceText: englishText,
      );

      // 2) Route to samiti_funds / worker_funds if applicable (backward compatibility)
      final today = DateTime.now().toIso8601String().split('T').first;

      if (intent == 'income' && category == 'samiti') {
        await DatabaseService.insertSamitiFund(
          name: 'Unknown',
          amount: amount,
          date: today,
          updateIdolMakerTotals: false, // totals updated below
        );
      }

      if (intent == 'expense' && category == 'worker') {
        await DatabaseService.insertWorkerFund(
          idolType: 'Unknown',
          workerType: 'Unknown',
          amountPaid: amount,
          amountTotal: 0,
        );
      }

      // 3) Update idolmaker totals
      if (intent == 'income') {
        await DatabaseService.updateIncome(amount);
      } else if (intent == 'expense') {
        await DatabaseService.updateExpenses(amount);
      }
    }
  }
}

