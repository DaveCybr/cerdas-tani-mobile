import 'package:fertilizer_calculator/core/assets/assets.gen.dart';
import 'package:fertilizer_calculator/presentation/calculator/models/fertilizer_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FertilizerDatabase {
  static final FertilizerDatabase instance = FertilizerDatabase._init();

  static Database? _database;

  FertilizerDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('fertilizers.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const doubleType = 'DOUBLE NOT NULL';

    await db.execute('''
    CREATE TABLE fertilizers (
      id $idType,
      image $textType,
      name $textType,
      category $textType,
      price $intType,
      weight $doubleType,
      type $textType,
      macro $textType,
      micro $textType
    )
    ''');

    // Seed the database
    await seedDatabase(db);
  }

  Future<void> seedDatabase(Database db) async {
    await db.insert('fertilizers', {
      'image': Assets.images.calnit.path,
      'name': 'Calnit',
      'category': 'Indonesia',
      'price': 13000,
      'weight': 25,
      'type': 'A',
      'macro': '{"N": 15.5, "P": 0, "K": 0, "Mg": 0, "Ca": 18.6, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.kalinitra.path,
      'name': 'Kalinitra',
      'category': 'Indonesia',
      'price': 35000,
      'weight': 25,
      'type': 'A',
      'macro': '{"N": 13, "P": 0, "K": 38.2, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.map.path,
      'name': 'MAP',
      'category': 'Indonesia',
      'price': 45000,
      'weight': 25,
      'type': 'A',
      'macro': '{"N": 12, "P": 26.6, "K": 0, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.mkp.path,
      'name': 'MKP',
      'category': 'Indonesia',
      'price': 52000,
      'weight': 25,
      'type': 'A',
      'macro': '{"N": 0, "P": 22.7, "K": 28.2, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.sop.path,
      'name': 'SOP',
      'category': 'Indonesia',
      'price': 22000,
      'weight': 25,
      'type': 'A',
      'macro': '{"N": 0, "P": 0, "K": 41.5, "Mg": 0, "Ca": 0, "S": 17}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.magS.path,
      'name': 'Mag-S',
      'category': 'Indonesia',
      'price': 12000,
      'weight': 25,
      'type': 'A',
      'macro': '{"N": 0, "P": 0, "K": 0, "Mg": 9.6, "Ca": 0, "S": 13}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.fe13.path,
      'name': 'Fe 13%',
      'category': 'Indonesia',
      'price': 170000,
      'weight': 25,
      'type': 'B',
      'macro': '{"N": 0, "P": 0, "K": 0, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 13, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.mn13.path,
      'name': 'Mn 13%',
      'category': 'Indonesia',
      'price': 150000,
      'weight': 25,
      'type': 'B',
      'macro': '{"N": 0, "P": 0, "K": 0, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 13, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.zn15.path,
      'name': 'Zn 15%',
      'category': 'Indonesia',
      'price': 170000,
      'weight': 25,
      'type': 'B',
      'macro': '{"N": 0, "P": 0, "K": 0, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 15, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.cu15.path,
      'name': 'Cu 15%',
      'category': 'Indonesia',
      'price': 200000,
      'weight': 25,
      'type': 'B',
      'macro': '{"N": 0, "P": 0, "K": 0, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 15, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.vitaflex.path,
      'name': 'Vitaflex',
      'category': 'Indonesia',
      'price': 220000,
      'weight': 25,
      'type': 'B',
      'macro': '{"N": 0, "P": 0, "K": 0, "Mg": 0, "Ca": 0, "S": 0}',
      'micro':
          '{"Fe": 7.5, "Mn": 1.5, "Zn": 1.65, "B": 1, "Cu": 1.6, "Mo": 0.25}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.cn.path,
      'name': 'Calsium Nitrate (ag grade)',
      'category': 'Internasional',
      'price': 79300,
      'weight': 25,
      'type': 'A',
      'macro': '{"N": 15.5, "P": 0, "K": 0, "Mg": 0, "Ca": 19, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.amp.path,
      'name': 'Ammonium Monobasic Phosphate',
      'category': 'Internasional',
      'price': 771400,
      'weight': 25,
      'type': 'A',
      'macro': '{"N": 12, "P": 26.6, "K": 0, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.pn.path,
      'name': 'Potassium Nitrate',
      'category': 'Internasional',
      'price': 220460,
      'weight': 25,
      'type': 'A',
      'macro': '{"N": 13.856, "P": 0, "K": 38.67, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.pmp.path,
      'name': 'Pottasium Monobasic Phosphate',
      'category': 'Internasional',
      'price': 440700,
      'weight': 25,
      'type': 'A',
      'macro': '{"N": 0, "P": 22.758, "K": 28.732, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.ps.path,
      'name': 'Potassium Sulfate',
      'category': 'Internasional',
      'price': 198200,
      'weight': 25,
      'type': 'A',
      'macro': '{"N": 0, "P": 0, "K": 44.873, "Mg": 0, "Ca": 0, "S": 18.402}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.ms.path,
      'name': 'Magnesium Sulfate (Heptahydrate)',
      'category': 'Internasional',
      'price': 20700,
      'weight': 25,
      'type': 'A',
      'macro': '{"N": 0, "P": 0, "K": 0, "Mg": 9.86, "Ca": 0, "S": 13.01}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.ie.path,
      'name': 'Iron EDDHA',
      'category': 'Internasional',
      'price': 596100,
      'weight': 25,
      'type': 'B',
      'macro': '{"N": 0, "P": 0, "K": 0, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 6, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.mne.path,
      'name': 'Mn EDTA',
      'category': 'Internasional',
      'price': 550900,
      'weight': 25,
      'type': 'B',
      'macro': '{"N": 0, "P": 0, "K": 0, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 13, "Zn": 0, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.zne.path,
      'name': 'Zn EDTA',
      'category': 'Internasional',
      'price': 550900,
      'weight': 25,
      'type': 'B',
      'macro': '{"N": 0, "P": 0, "K": 0, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 14, "B": 0, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.ba.path,
      'name': 'Boric Acid',
      'category': 'Internasional',
      'price': 241400,
      'weight': 25,
      'type': 'B',
      'macro': '{"N": 0, "P": 0, "K": 0, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 17.482, "Cu": 0, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.ce.path,
      'name': 'Coppper EDTA',
      'category': 'Internasional',
      'price': 440800,
      'weight': 25,
      'type': 'B',
      'macro': '{"N": 0, "P": 0, "K": 0, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 14, "Mo": 0}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.smd.path,
      'name': 'Sodium Molydate (Dihydrate)',
      'category': 'Internasional',
      'price': 440700,
      'weight': 25,
      'type': 'B',
      'macro': '{"N": 0, "P": 0, "K": 0, "Mg": 0, "Ca": 0, "S": 0}',
      'micro': '{"Fe": 0, "Mn": 0, "Zn": 0, "B": 0, "Cu": 0, "Mo": 39.65}',
    });
    await db.insert('fertilizers', {
      'image': Assets.images.m.path,
      'name': 'Micronutrient Package',
      'category': 'Internasional',
      'price': 186000,
      'weight': 25,
      'type': 'B',
      'macro': '{"N": 0, "P": 0, "K": 0, "Mg": 0, "Ca": 0, "S": 0}',
      'micro':
          '{"Fe": 7.5, "Mn": 1.5, "Zn": 1.65, "B": 1, "Cu": 1.6, "Mo": 0.25}',
    });
  }

  Future<List<FertilizerModel>> getAllFertilizers() async {
    final db = await instance.database;

    final result = await db.query('fertilizers');

    return result.map((json) => FertilizerModel.fromMap(json)).toList();
  }

  Future<void> insertFertilizer(FertilizerModel fertilizer) async {
    final db = await instance.database;

    await db.insert('fertilizers', fertilizer.toMap());
  }
}
