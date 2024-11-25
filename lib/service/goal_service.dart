import '../dao/goal_dao.dart';
import '../model/database_result.dart';
import '../model/goal.dart';
import '../model/goal_database_result.dart';

class GoalService {

  GoalService();

  Future<DatabaseResult> addOrUpdateGoal(Goal goal) async {
    GoalDao goalDao = GoalDao();
    return await goalDao.addOrUpdateGoal(goal);
  }

  Future<GoalDatabaseResult> getAllGoals({required String date}) async {
    GoalDao goalDao = GoalDao();
    return await goalDao.getAllGoals(date: date);
  }

  Future<DatabaseResult> deleteGoal({required goalId}) async {
    GoalDao goalDao = GoalDao();
    return await goalDao.deleteGoal(goalId: goalId);
  }
  
}