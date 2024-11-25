import 'package:daily_goals/model/database_result.dart';

import 'goal.dart';

class GoalDatabaseResult extends DatabaseResult {

  late List<Goal> goals;

  GoalDatabaseResult({this.goals = const [], super.succeeded, super.message}) : super();

}