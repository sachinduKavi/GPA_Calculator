import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'dart:io' as io;

class SQLHelper {
  // Results database
  static Future<void> createTable(sql.Database database) async{
    await database.execute("""CREATE TABLE Result(
    course_id INTEGER PRIMARY KEY AUTOINCREMENT,
    module_name TEXT,
    credits INTEGER,
    grade TEXT,
    year_sem TEXT)
    """);

    await database.execute("""CREATE TABLE Scale(
    grade TEXT,
    scale REAL)""");
  }

  static Future<int> insertDegreeYear(int year, int sem) async {
    final db = await SQLHelper.db();

    var id = await db.insert("DegreeYear", {"year_no": year, "no_sem": sem});
    return id;
  }

  static Future<int> insertScale(String grade, double scale) async {
    final db = await SQLHelper.db();

    var id = await db.insert("Scale", {"grade": grade, "scale": scale});
    return id;
  }

  // Database executor
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'gpaData.db',
      version: 5,
      onCreate: (sql.Database database, int version) async {
        print('Creating a table...');
        await createTable(database);

      }
    );
  }

  static Future<int> createResult(String moduleName, int credits, String? grade, int sem, int year) async {
    final db = await SQLHelper.db();
    final data = {'module_name': moduleName, 'credits': credits, 'grade': grade, 'year_sem': '${year}_$sem'};
    final id = await db.insert('Result', data,
    conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getResults(int year, int sem) async {
    final db = await SQLHelper.db();
    return db.query('Result', orderBy: "course_id", where: 'year_sem = ?', whereArgs: ['${year}_$sem']);
  }
  
  static Future<List<Map<String, dynamic>>> getResultYear(int year) async {
    final db = await SQLHelper.db();
    return db.query("Result", where: "year_sem LIKE ?", whereArgs: ['$year%']);
  }

  static Future<List<Map<String, dynamic>>> getAllResults() async{
    final db = await SQLHelper.db();
    return db.query("Result");
  }

  static Future<List<Map<String, Object?>>> getScale() async{
    final db = await SQLHelper.db();
    return db.query("Scale");
  }

  static Future<void> deleteDatabase() async {
    final database = await SQLHelper.db();
    database.close();

    final databasePath = await sql.getDatabasesPath();
    final databaseFile = io.File(join(databasePath, 'gpaData.db'));

    if(await databaseFile.exists()) {
      await databaseFile.delete();
      print('Database Deletion successful');
    }
  }

  static Future<void> updateScale(String key, double value) async {
    final db = await SQLHelper.db();

    db.execute("UPDATE Scale SET scale = '$value' WHERE grade = '$key'").then((value) {
    print('Update Success');
    });
}


  // Sql query to delete record from the results
  static Future<void> deleteResult(int courseID) async{
    final db = await SQLHelper.db();
    try {
      await db.delete("Result", where: "course_id = ?", whereArgs: [courseID]);
      print('Deletion Success');
    } catch (error) {
      print('Something went wrong with deletion ... $error');
    }
  }

  static Future<void> deleteYear(int year) async{
    final db = await SQLHelper.db();
    try {
      await db.delete("Result", where: "year_sem LIKE ?", whereArgs: ['${year}_%']);
      print('Deletion successful');
    } catch (e) {
      print("Error occurs : $e");
    }
  }

}