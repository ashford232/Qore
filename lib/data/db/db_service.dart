import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:study/data/models/qore_model.dart';

class DBService {
  static final DBService instance = DBService._init();
  static Database? _database;

  DBService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');

    await db.execute('''
    CREATE TABLE qore(
      id TEXT PRIMARY KEY,
      title TEXT,
      description TEXT,
      createdAt TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE texts(
      id TEXT PRIMARY KEY,
      text TEXT,
      createdAt TEXT,
      tags TEXT,
      qoreId TEXT,
      FOREIGN KEY(qoreId) REFERENCES qore(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE audios(
      id TEXT PRIMARY KEY,
      filePath TEXT,
      text TEXT,
      createdAt TEXT,
      tags TEXT,
      qoreId TEXT,
      FOREIGN KEY(qoreId) REFERENCES qore(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE images(
      id TEXT PRIMARY KEY,
      filePath TEXT,
      text TEXT,
      createdAt TEXT,
      tags TEXT,
      qoreId TEXT,
      FOREIGN KEY(qoreId) REFERENCES qore(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE users(
      id TEXT PRIMARY KEY,
      name TEXT,
      avater TEXT,
      streak TEXT
    )
  ''');
  }

  Future<void> insertUser(UserModel user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser() async {
    final db = await database;
    await db.delete('users');
  }

  Future<void> insertQore(
    QoreDbModel qore,
    List<TextModel> texts,
    List<AudioModel> audios,
    List<ImageModel> images,
  ) async {
    final db = await database;
    final batch = db.batch();
    batch.insert(
      'qore',
      qore.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    for (TextModel text in texts) {
      batch.insert(
        'texts',
        text.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    for (AudioModel audio in audios) {
      batch.insert(
        'audios',
        audio.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    for (ImageModel image in images) {
      batch.insert(
        'images',
        image.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<List<QoreModel>> getAllQore() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'qore',
      orderBy: 'createdAt DESC',
    );

    return await Future.wait(
      maps.map((qo) async {
        final qoresDb = QoreDbModel.fromMap(qo);

        final images = await getImages(qoresDb.id);
        final audios = await getAudios(qoresDb.id);
        final texts = await getTexts(qoresDb.id);

        return QoreModel(
          id: qoresDb.id,
          title: qoresDb.title,
          description: qoresDb.description,
          createdAt: qoresDb.createdAt,
          images: images,
          audios: audios,
          texts: texts,
        );
      }),
    );
  }

  Future<List<QoreModel>> getQoresBySearchQuery(String query) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'qore',
      where:
          'title LIKE ? OR id IN (SELECT qoreId FROM texts WHERE text LIKE ?)',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return await Future.wait(
      maps.map((qo) async {
        final qoresDb = QoreDbModel.fromMap(qo);

        final images = await getImages(qoresDb.id);
        final audios = await getAudios(qoresDb.id);
        final texts = await getTexts(qoresDb.id);

        return QoreModel(
          id: qoresDb.id,
          title: qoresDb.title,
          description: qoresDb.description,
          createdAt: qoresDb.createdAt,
          images: images,
          audios: audios,
          texts: texts,
        );
      }),
    );
  }

  Future<List<ImageModel>> getImages(String qoreId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'images',
      where: 'qoreId = ?',
      whereArgs: [qoreId],
    );
    return maps.map((map) => ImageModel.fromMap(map)).toList();
  }

  Future<List<AudioModel>> getAudios(String qoreId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'audios',
      where: 'qoreId = ?',
      whereArgs: [qoreId],
    );
    return maps.map((map) => AudioModel.fromMap(map)).toList();
  }

  Future<List<TextModel>> getTexts(String qoreId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'texts',
      where: 'qoreId = ?',
      orderBy: 'createdAt ASC',
      whereArgs: [qoreId],
    );
    return maps.map((map) => TextModel.fromMap(map)).toList();
  }

  Future<void> insertText(TextModel text) async {
    final db = await database;
    await db.insert(
      'texts',
      text.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteText(TextModel text) async {
    final db = await database;
    await db.delete('texts', where: 'id = ?', whereArgs: [text.id]);
  }

  Future<void> insertImage(ImageModel image) async {
    final db = await database;
    await db.insert(
      'images',
      image.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteImage(String id) async {
    final db = await database;
    await db.delete('images', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertAudio(AudioModel audio) async {
    final db = await database;
    await db.insert(
      'audios',
      audio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<QoreModel> getQoreById(String id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'qore',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      throw Exception('Qore not found');
    }

    final qoreDb = QoreDbModel.fromMap(maps.first);

    final images = await getImages(id);
    final audios = await getAudios(id);
    final texts = await getTexts(id);

    return QoreModel(
      id: qoreDb.id,
      title: qoreDb.title,
      description: qoreDb.description,
      createdAt: qoreDb.createdAt,
      images: images,
      audios: audios,
      texts: texts,
    );
  }

  Future<void> updateQore(QoreModel qore) async {
    final db = await database;
    await db.update(
      'qore',
      qore.toMap(),
      where: 'id = ?',
      whereArgs: [qore.id],
    );
  }

  Future<void> deleteQore(String id) async {
    final db = await database;

    final batch = db.batch();
    batch.delete('qore', where: 'id = ?', whereArgs: [id]);
    batch.delete('texts', where: 'qoreId = ?', whereArgs: [id]);
    batch.delete('images', where: 'qoreId = ?', whereArgs: [id]);
    batch.delete('audios', where: 'qoreId = ?', whereArgs: [id]);
    await batch.commit();
  }

  Future<void> deleteAll() async {
    final db = await database;

    final batch = db.batch();
    batch.delete('users');
    batch.delete('qore');
    batch.delete('texts');
    batch.delete('images');
    batch.delete('audios');
    await batch.commit();
  }
}
