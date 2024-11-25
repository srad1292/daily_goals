class DatabaseResult {
  bool succeeded;
  int newOrUpdatedId;
  int rowsAffected;
  String message;

  DatabaseResult({this.succeeded = false, this.newOrUpdatedId = -1, this.rowsAffected = 0, this.message = ''});
}