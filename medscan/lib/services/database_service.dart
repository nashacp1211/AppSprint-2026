import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicine.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'smartmed.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE medicines(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            dosage TEXT,
            time TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertMedicine(Medicine medicine) async {
    final db = await database;
    return await db.insert('medicines', medicine.toMap());
  }

  Future<List<Medicine>> getMedicines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('medicines');
    return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
  }
}
