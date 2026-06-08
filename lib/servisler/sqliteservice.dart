import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modeller/kullanicimodeli.dart';

class SqliteService {
  static Database? _db;

  Future<Database> _veritabaniAc() async {
    if (_db != null) return _db!;
    final dbYolu = await getDatabasesPath();
    final yol = join(dbYolu, 'kampus_connect.db');
    _db = await openDatabase(
      yol,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kullanici (
            id INTEGER PRIMARY KEY,
            ad TEXT,
            soyad TEXT,
            email TEXT,
            fotoUrl TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> kullaniciyiKaydet(KullaniciModeli kullanici) async {
    final db = await _veritabaniAc();
    final map = kullanici.toMap();
    map['id'] = 1;
    await db.insert(
      'kullanici',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<KullaniciModeli?> kullaniciGetir() async {
    final db = await _veritabaniAc();
    final sonuc = await db.query('kullanici', where: 'id = ?', whereArgs: [1]);
    if (sonuc.isEmpty) return null;
    return KullaniciModeli.fromMap(sonuc.first);
  }

  Future<void> fotoUrlGuncelle(String url) async {
    final db = await _veritabaniAc();
    await db.update(
      'kullanici',
      {'fotoUrl': url},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}
