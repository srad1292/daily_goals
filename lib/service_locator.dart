import 'package:get_it/get_it.dart';

import 'package:daily_goals/service/goal_service.dart';
import 'package:daily_goals/service/import_export_service.dart';

GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  serviceLocator.registerLazySingleton(() => GoalService());
  serviceLocator.registerLazySingleton(() => ImportExportService());
}