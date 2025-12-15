import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../pages/expense_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'expenses.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            amount REAL,
            category TEXT,
            date TEXT,
            details TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertExpense(Expense e) async {
    final db = await database;
    final id = await db.insert(
        'expenses',
        e.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
    );
    e.id = id;
   }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final maps = await db.query('expenses');

    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateExpense(Expense e) async {
    final db = await database;
    await db.update(
        'expenses',
        e.toMap(),
        where: 'id = ?',
        whereArgs: [e.id],
    );
    }

}
