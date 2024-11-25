import '../persistence/database_column.dart';

class Goal {
  int? id;
  late String date;
  late String content;
  late bool complete;

  Goal({this.id, required this.date, required this.content, this.complete = false});

  Goal.fromGoal(Goal goal) {
    id = goal.id;
    date = goal.date;
    content = goal.content;
    complete = goal.complete;
  }

  Goal.fromPersistence(Map<String, dynamic> json) {
    id = json[DatabaseColumn.goalId];
    date = json[DatabaseColumn.date];
    content = json[DatabaseColumn.content];
    complete = json[DatabaseColumn.complete] == 1;
  }

  Map<String, dynamic> toPersistence() =>
      {
        DatabaseColumn.goalId: id,
        DatabaseColumn.date: date,
        DatabaseColumn.content: content,
        DatabaseColumn.complete: complete ? 1 : 0,
      };
}