import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite数据库服务类
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  static Database? _database;

  DatabaseService._internal();

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'recite_tool.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE documents(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        created_at TEXT
      )
    ''');
  }

  /// 保存文档到本地数据库
  Future<int> saveDocument(String title, String content) async {
    final db = await database;
    return await db.insert('documents', {
      'title': title,
      'content': content,
      'created_at': DateTime.now().toString(),
    });
  }

  /// 获取所有文档
  Future<List<Map<String, dynamic>>> getAllDocuments() async {
    final db = await database;
    return await db.query('documents');
  }

  /// 删除文档
  Future<int> deleteDocument(int id) async {
    final db = await database;
    return await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }
}