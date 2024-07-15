import 'package:palmear_application/domain/entities/user_model.dart';
import 'package:palmear_application/data/services/firestore_services/database_helper.dart';

class UserRepositoryMapbox {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<void> addUser(UserModel user) async {
    await dbHelper.insertOrUpdate('users', user.toJson());
  }

  Future<UserModel?> getUser(String uid) async {
    final db = await dbHelper.database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromJson(maps.first);
    }
    return null;
  }
}
