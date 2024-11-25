class Goal {
  int? id;
  late String date;
  late String content;
  late int complete;
  late int deleted;

  Goal({this.id, required this.date, required this.content, this.complete = 0, this.deleted = 0});
}