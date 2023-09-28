import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart'  as sql;

class SQLHelper{
  static Future <void> createTables(sql.Database database) async {

    await database.execute(
""" CREATE TABLE product(

  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  name TEXT,
  description TEXT,
  price DOUBLE,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)"""

    );
  }
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'ecommercedb.db',
      version: 2,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createproduct(String? name, String? descrption, double? price) async {
    final db = await SQLHelper.db();

    final data = {'name': name, 'description': descrption,'price': price};
    final id = await db.insert('product', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getproduct() async {
    final db = await SQLHelper.db();
    return db.query('product', orderBy: "id");
  }

  //static Future<List<Map<String, dynamic>>> getItem(int id) async {
  //  final db = await SQLHelper.db();
  //  return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  //}

  static Future<int> updateproduct(
      int id, String? name, String? descrption, double? price) async {
    final db = await SQLHelper.db();

    final data = {
      'name': name,
      'description': descrption,
      'price': price,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('product', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteproduct(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("product", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}