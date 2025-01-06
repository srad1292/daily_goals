import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_column.dart';
import 'database_table.dart';

const int dbVersion = 1;

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  late Database _database;
  bool instanceMade = false;

  Future<Database> get database async {
    if(instanceMade) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'sradford_daily_notes_database.db');
    return await openDatabase(path,
      version: dbVersion,
      onOpen: (db) {},
      onCreate: _createCallback,
    );
  }

  void _createCallback(Database db, int version) async {
    await db.execute(_getGoalScheme());
  }

  String _getGoalScheme() {
    return "CREATE TABLE ${DatabaseTable.goal} ("
        "${DatabaseColumn.goalId} INTEGER PRIMARY KEY,"
        "${DatabaseColumn.content} TEXT,"
        "${DatabaseColumn.date} TEXT,"
        "${DatabaseColumn.complete} INTEGER"
        ");";
  }

}