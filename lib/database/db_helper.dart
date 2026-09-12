import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/project_model.dart';

/// SQLite helper — single table storing all project fields flat.
/// Call [DbHelper.instance] to access it.
class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'home_rebuild.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  /// Runs when the DB version on disk is older than [version].
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add columns that were missing from the v1 schema
      await db.execute(
        "ALTER TABLE projects ADD COLUMN selectedCalculators TEXT NOT NULL "
        "DEFAULT 'flooring,paint,tiles,ceiling,doors_windows,furniture,electrical,plumbing'",
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        city TEXT NOT NULL,
        propertyType TEXT NOT NULL,
        projectArea REAL,
        description TEXT,
        selectedRoom TEXT NOT NULL,
        roomLength REAL NOT NULL,
        roomWidth REAL NOT NULL,
        roomHeight REAL NOT NULL,
        unit TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        flooringCost REAL NOT NULL DEFAULT 0,
        paintCost REAL NOT NULL DEFAULT 0,
        tilesCost REAL NOT NULL DEFAULT 0,
        ceilingCost REAL NOT NULL DEFAULT 0,
        doorsWindowsCost REAL NOT NULL DEFAULT 0,
        furnitureCost REAL NOT NULL DEFAULT 0,
        electricalCost REAL NOT NULL DEFAULT 45000,
        plumbingCost REAL NOT NULL DEFAULT 25000,
        selectedFlooringMaterial TEXT NOT NULL,
        flooringWastage REAL NOT NULL DEFAULT 10,
        paintWallHeight REAL NOT NULL DEFAULT 10,
        paintType TEXT NOT NULL,
        paintCoats REAL NOT NULL DEFAULT 2,
        paintCoverage REAL NOT NULL DEFAULT 160,
        tilesType TEXT NOT NULL,
        tileSize TEXT NOT NULL,
        tilesWastage REAL NOT NULL DEFAULT 10,
        tilePrice REAL NOT NULL DEFAULT 150,
        ceilingType TEXT NOT NULL,
        ceilingRatePerSqFt REAL NOT NULL DEFAULT 200,
        mainDoors INTEGER NOT NULL DEFAULT 1,
        roomDoors INTEGER NOT NULL DEFAULT 2,
        bathroomDoors INTEGER NOT NULL DEFAULT 1,
        windows INTEGER NOT NULL DEFAULT 2,
        ventilators INTEGER NOT NULL DEFAULT 1,
        furnitureItems TEXT NOT NULL DEFAULT '',
        selectedCalculators TEXT NOT NULL DEFAULT 'flooring,paint,tiles,ceiling,doors_windows,furniture,electrical,plumbing'
      )
    ''');
  }

  // ── CRUD ────────────────────────────────────────────────────────────────────

  /// Insert a new project. If it already exists, replaces it.
  Future<void> insertProject(ProjectModel project) async {
    final db = await database;
    await db.insert(
      'projects',
      project.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing project.
  Future<void> updateProject(ProjectModel project) async {
    final db = await database;
    await db.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  /// Delete project by id.
  Future<void> deleteProject(String id) async {
    final db = await database;
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  /// Load all projects, newest first.
  Future<List<ProjectModel>> getProjects() async {
    final db = await database;
    final rows = await db.query('projects', orderBy: 'createdAt DESC');
    return rows.map((r) => ProjectModel.fromMap(r)).toList();
  }

  /// Load a single project by id.
  Future<ProjectModel?> getProjectById(String id) async {
    final db = await database;
    final rows = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ProjectModel.fromMap(rows.first);
  }
}
