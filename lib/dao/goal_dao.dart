import 'package:daily_goals/model/database_result.dart';
import 'package:daily_goals/model/goal_database_result.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../model/goal.dart';
import '../persistence/database.dart';
import '../persistence/database_column.dart';
import '../persistence/database_table.dart';

class GoalDao {

  GoalDao();

  Future<DatabaseResult> addOrUpdateGoal(Goal goal) async {
    try {
      Database db = await (DBProvider.db.database);
      int insertedId = await db.insert(
          DatabaseTable.goal,
          goal.toPersistence(),
          conflictAlgorithm: ConflictAlgorithm.replace
      );
      return DatabaseResult(succeeded: true, newOrUpdatedId: insertedId);

    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error adding or replacing goal");
        print(e.toString());
      }
      return DatabaseResult(succeeded: false, newOrUpdatedId: -1, message: e.toString());
    }
  }


  Future<GoalDatabaseResult> getAllGoals({required String date}) async {
    try {
      Database db = await DBProvider.db.database;
      List<Map<String, dynamic>> dbGoals = await db.query(
        DatabaseTable.goal,
        where: "${DatabaseColumn.date} = ?",
        whereArgs: [date],
        orderBy: "${DatabaseColumn.goalId} ASC",

      );
      List<Goal> appGoals = [];
      if(dbGoals.isNotEmpty) {
        appGoals = List.generate(dbGoals.length, (index) {
          return Goal.fromPersistence(dbGoals[index]);
        });
      }
      return GoalDatabaseResult(goals: appGoals, succeeded: true);
    } catch(e) {
      if (kDebugMode) {
        print("Error in get all goals");
        print(e.toString());
      }
      return GoalDatabaseResult(succeeded: false, message: e.toString());
    }
  }

  Future<DatabaseResult> deleteGoal({required int goalId}) async {
    if(goalId <= 0) {
      return DatabaseResult(succeeded: false, message: "Cannot attempt to delete goal with ID less than 0");
    }

    Database db = await DBProvider.db.database;
    try {
      int deletedCount = await db.delete(DatabaseTable.goal, where: "${DatabaseColumn.goalId} = ?", whereArgs: [goalId]);
      if (kDebugMode) {
        if (deletedCount > 0) {
          print("Count of deleted goals: $deletedCount");
        }
      }
      return DatabaseResult(succeeded: true, rowsAffected: deletedCount);
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error deleting goal with id: $goalId");
        print(e);
      }
      return DatabaseResult(succeeded: false, message: e.toString());
    }

  }


}