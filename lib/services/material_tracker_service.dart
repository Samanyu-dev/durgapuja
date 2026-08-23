import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_service.dart';

class MaterialTrackerService {
  static const String _materialsTableName = 'materials';
  static const String _priceHistoryTableName = 'price_history';
  static const String _materialUsageTableName = 'material_usage';

  static Future<void> _initMaterialTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_materialsTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        unit TEXT NOT NULL,
        current_rate REAL NOT NULL,
        min_rate REAL,
        max_rate REAL,
        last_updated TEXT NOT NULL,
        supplier TEXT,
        quality_rating INTEGER DEFAULT 5
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_priceHistoryTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        material_id INTEGER NOT NULL,
        rate REAL NOT NULL,
        date TEXT NOT NULL,
        source TEXT,
        FOREIGN KEY (material_id) REFERENCES $_materialsTableName (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_materialUsageTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        material_id INTEGER NOT NULL,
        quantity REAL NOT NULL,
        unit_cost REAL NOT NULL,
        total_cost REAL NOT NULL,
        project_id TEXT,
        date TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (material_id) REFERENCES $_materialsTableName (id)
      )
    ''');
  }

  static Future<void> addMaterial({
    required String name,
    required String category,
    required String unit,
    required double currentRate,
    String? supplier,
    double? minRate,
    double? maxRate,
  }) async {
    final db = await DatabaseService.getDatabase();
    await _initMaterialTables(db);

    final result = await db.insert(
      _materialsTableName,
      {
        'name': name,
        'category': category,
        'unit': unit,
        'current_rate': currentRate,
        'min_rate': minRate,
        'max_rate': maxRate,
        'last_updated': DateTime.now().toIso8601String(),
        'supplier': supplier,
      },
    );

    // Add to price history
    await db.insert(
      _priceHistoryTableName,
      {
        'material_id': result,
        'rate': currentRate,
        'date': DateTime.now().toIso8601String(),
        'source': 'Manual Entry',
      },
    );
  }

  static Future<void> updateMaterial({
    required int materialId,
    required String name,
    required String category,
    required String unit,
    required double currentRate,
    String? supplier,
  }) async {
    final db = await DatabaseService.getDatabase();

    await db.update(
      _materialsTableName,
      {
        'name': name,
        'category': category,
        'unit': unit,
        'current_rate': currentRate,
        'supplier': supplier,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [materialId],
    );

    // Add to price history
    await db.insert(
      _priceHistoryTableName,
      {
        'material_id': materialId,
        'rate': currentRate,
        'date': DateTime.now().toIso8601String(),
        'source': 'Manual Update',
      },
    );
  }

  static Future<void> updateMaterialRate(int materialId, double newRate) async {
    final db = await DatabaseService.getDatabase();
    
    await db.update(
      _materialsTableName,
      {
        'current_rate': newRate,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [materialId],
    );

    // Add to price history
    await db.insert(
      _priceHistoryTableName,
      {
        'material_id': materialId,
        'rate': newRate,
        'date': DateTime.now().toIso8601String(),
        'source': 'Manual Update',
      },
    );
  }

  static Future<void> recordMaterialUsage({
    required int materialId,
    required double quantity,
    required String unit,
    String? projectId,
    String? description,
  }) async {
    final db = await DatabaseService.getDatabase();
    
    // Get current rate
    final materialResult = await db.query(
      _materialsTableName,
      where: 'id = ?',
      whereArgs: [materialId],
    );

    if (materialResult.isEmpty) return;

    final currentRate = materialResult.first['current_rate'] as double;
    final totalCost = quantity * currentRate;

    await db.insert(
      _materialUsageTableName,
      {
        'material_id': materialId,
        'quantity': quantity,
        'unit_cost': currentRate,
        'total_cost': totalCost,
        'project_id': projectId,
        'date': DateTime.now().toIso8601String(),
        'description': description,
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getMaterials() async {
    final db = await DatabaseService.getDatabase();
    final result = await db.query(_materialsTableName);
    return result;
  }

  static Future<List<Map<String, dynamic>>> getPriceHistory(int materialId) async {
    final db = await DatabaseService.getDatabase();
    final result = await db.query(
      _priceHistoryTableName,
      where: 'material_id = ?',
      whereArgs: [materialId],
      orderBy: 'date DESC',
    );
    return result;
  }

  static Future<List<Map<String, dynamic>>> getMaterialUsage(int materialId) async {
    final db = await DatabaseService.getDatabase();
    final result = await db.query(
      _materialUsageTableName,
      where: 'material_id = ?',
      whereArgs: [materialId],
      orderBy: 'date DESC',
    );
    return result;
  }

  static Future<Map<String, dynamic>> getMaterialAnalytics() async {
    final db = await DatabaseService.getDatabase();
    
    // Get total materials
    final totalMaterialsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_materialsTableName'
    );
    final totalMaterials = totalMaterialsResult.first['count'] as int;

    // Get total usage cost
    final totalUsageResult = await db.rawQuery(
      'SELECT SUM(total_cost) as total FROM $_materialUsageTableName'
    );
    final totalUsageCost = (totalUsageResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Get most expensive material
    final expensiveMaterialResult = await db.rawQuery('''
      SELECT name, current_rate 
      FROM $_materialsTableName 
      ORDER BY current_rate DESC 
      LIMIT 1
    ''');
    final expensiveMaterial = expensiveMaterialResult.isNotEmpty 
        ? expensiveMaterialResult.first['name'] as String 
        : 'N/A';

    // Get category-wise spending
    final categorySpendingResult = await db.rawQuery('''
      SELECT m.category, SUM(mu.total_cost) as total_spent
      FROM $_materialUsageTableName mu
      JOIN $_materialsTableName m ON mu.material_id = m.id
      GROUP BY m.category
      ORDER BY total_spent DESC
    ''');

    return {
      'totalMaterials': totalMaterials,
      'totalUsageCost': totalUsageCost,
      'expensiveMaterial': expensiveMaterial,
      'categorySpending': categorySpendingResult,
    };
  }

  static Future<List<Map<String, dynamic>>> getTrendingMaterials() async {
    final db = await DatabaseService.getDatabase();
    
    // Get materials with price changes in last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
    
    final result = await db.rawQuery('''
      SELECT m.name, m.category, m.current_rate, m.last_updated,
             ph.rate as previous_rate,
             ((m.current_rate - ph.rate) / ph.rate * 100) as change_percent
      FROM $_materialsTableName m
      JOIN $_priceHistoryTableName ph ON m.id = ph.material_id
      WHERE ph.date >= ?
      AND ph.id = (
        SELECT MAX(id) 
        FROM $_priceHistoryTableName 
        WHERE material_id = m.id 
        AND date < ?
      )
      ORDER BY ABS(change_percent) DESC
      LIMIT 10
    ''', [thirtyDaysAgo, thirtyDaysAgo]);

    return result;
  }

  static Future<void> deleteMaterial(int materialId) async {
    final db = await DatabaseService.getDatabase();
    
    await db.delete(
      _materialsTableName,
      where: 'id = ?',
      whereArgs: [materialId],
    );
    
    await db.delete(
      _priceHistoryTableName,
      where: 'material_id = ?',
      whereArgs: [materialId],
    );
    
    await db.delete(
      _materialUsageTableName,
      where: 'material_id = ?',
      whereArgs: [materialId],
    );
  }
}

class MaterialCategory {
  static const String CLAY = 'Clay';
  static const String PAINT = 'Paint';
  static const String BAMBOO = 'Bamboo';
  static const String STRAW = 'Straw';
  static const String FIBER = 'Fiber';
  static const String DECORATION = 'Decoration';
  static const String TOOLS = 'Tools';
  static const String OTHERS = 'Others';
}

class MaterialUnit {
  static const String KG = 'kg';
  static const String LITER = 'liter';
  static const String PIECE = 'piece';
  static const String BUNDLE = 'bundle';
  static const String METER = 'meter';
  static const String BOX = 'box';
  static const String PACKET = 'packet';
}