import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import 'dart:convert';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/sync_queue.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  sqflite.Database? _database;

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sqflite.Database> _initDatabase() async {
    String path = join(await sqflite.getDatabasesPath(), 'inventory.db');
    return await sqflite.openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY,
            data TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY,
            data TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY,
            data TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT,
            entity TEXT,
            data TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveProduct(Product product) async {
    final db = await database;
    await db.insert('products', {
      'id': product.id,
      'data': jsonEncode(product.toJson()),
    }, conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return maps.map((m) => Product.fromJson(jsonDecode(m['data']))).toList();
  }

  Future<void> saveTransaction(Transaction transaction) async {
    final db = await database;
    await db.insert('transactions', {
      'id': transaction.id,
      'data': jsonEncode(transaction.toJson()),
    }, conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    return maps
        .map((m) => Transaction.fromJson(jsonDecode(m['data'])))
        .toList();
  }

  Future<void> saveCategory(Category category) async {
    final db = await database;
    await db.insert('categories', {
      'id': category.id,
      'data': jsonEncode(category.toJson()),
    }, conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map((m) => Category.fromJson(jsonDecode(m['data']))).toList();
  }

  Future<void> addToSyncQueue(SyncQueue queue) async {
    final db = await database;
    await db.insert('sync_queue', queue.toJson());
  }

  Future<List<SyncQueue>> getSyncQueue() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sync_queue');
    return maps.map((m) => SyncQueue.fromJson(m)).toList();
  }

  Future<void> clearSyncQueue(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveCategories(List<Category> categories) async {
    final db = await database;
    final batch = db.batch();
    for (var category in categories) {
      batch.insert('categories', {
        'id': category.id,
        'data': jsonEncode(category.toJson()),
      }, conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> removeSyncQueueItem(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  /// Vide toutes les données de la base de données
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('products');
    await db.delete('transactions');
    await db.delete('categories');
    await db.delete('sync_queue');
  }
}
