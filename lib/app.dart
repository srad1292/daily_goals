import 'package:daily_goals/enum/info_dialog_type.dart';
import 'package:daily_goals/model/database_result.dart';
import 'package:daily_goals/model/goal_database_result.dart';
import 'package:daily_goals/service/goal_service.dart';
import 'package:daily_goals/service_locator.dart';
import 'package:daily_goals/widget/my_confirmation_dialog.dart';
import 'package:daily_goals/widget/my_info_dialog.dart';
import 'package:daily_goals/widget/my_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'enum/goal_action.dart';
import 'enum/goal_period.dart';
import 'model/goal.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DateTime selectedDate;
  List<Goal> goals = [];
  TextEditingController newGoalController = TextEditingController();
  GoalService goalService = serviceLocator.get<GoalService>();
  GoalPeriod period = GoalPeriod.day;
  List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 
    'May', 'Jun', 'Jul', 'Aug', 
    'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadGoals(selectedDate);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      _loadGoals(picked);
    }
  }

  Future<void> _loadGoals(DateTime dateTime) async {
    setState(() {
      selectedDate = dateTime;
      goals = [];
    });
    GoalDatabaseResult dbGoals = await goalService.getAllGoals(date: _getDateString(dateTime));
    if(dbGoals.succeeded) {
      setState(() {
        goals = List.from(dbGoals.goals);
      });
    } else {
      if(mounted) {
        showMyInfoDialog(
            context: context,
            dialogType: InfoDialogType.error,
            body: 'Error deleting goal: \n ${dbGoals.message}'
        );
      }
    }
  }

  String _getDateString(DateTime dateTime) {
    if(period == GoalPeriod.year) {
      return '${dateTime.year}';
    } else if(period == GoalPeriod.month) {
      return '${monthNames[dateTime.month-1]} ${dateTime.year}';
    }
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
    
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: _buildActionsMenu(),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                _loadGoals(_getPreviousDateTime(selectedDate));
              },
              icon: const Icon(Icons.chevron_left)
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(_getDateString(selectedDate)),
              ),
            ),
            IconButton(
                onPressed: () {
                  _loadGoals(_getNextDateTime(selectedDate));
                },
                icon: const Icon(Icons.chevron_right)
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          _buildPeriodChangeMenu()
        ],
      ),
      body:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ..._buildGoalsList(),
              const SizedBox(height: 20,),
              _buildGoalInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChangeMenu() {
    return PopupMenuButton(
      onSelected: (value) async {
        period = value;
        return _loadGoals(selectedDate);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<GoalPeriod>>[
        if(period != GoalPeriod.day)
          const PopupMenuItem<GoalPeriod>(
            value: GoalPeriod.day,
            child: Text("Day"),
          ),
        if(period != GoalPeriod.month)
          const PopupMenuItem<GoalPeriod>(
            value: GoalPeriod.month,
            child: Text("Month"),
          ),
        if(period != GoalPeriod.year)
          const PopupMenuItem<GoalPeriod>(
            value: GoalPeriod.year,
            child: Text("Year"),
          ),
      ],
    );

  }

  DateTime _getNextDateTime(DateTime dateTime) {
    if(period == GoalPeriod.month) {
      return addOneMonth(dateTime);
    } else if(period == GoalPeriod.year) {
      return addOneYear(dateTime);
    }
    return dateTime.add(const Duration(days: 1));
  }

  DateTime _getPreviousDateTime(DateTime dateTime) {
    if(period == GoalPeriod.month) {
      return subtractOneMonth(dateTime);
    } else if(period == GoalPeriod.year) {
      return subtractOneYear(dateTime);
    }
    return dateTime.subtract(const Duration(days: 1));

  }

  DateTime subtractOneMonth(DateTime date) {
    int newMonth = date.month - 1;
    int newYear = date.year;

    if (newMonth == 0) {
      newMonth = 12;
      newYear -= 1;
    }

    // Handle the case where the new date is invalid (e.g., February 30)
    int lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    int newDay = date.day <= lastDayOfNewMonth ? date.day : lastDayOfNewMonth;

    return DateTime(newYear, newMonth, newDay);
  }

  DateTime addOneMonth(DateTime date) {
    int newMonth = date.month + 1;
    int newYear = date.year;

    if (newMonth == 13) {
      newMonth = 1;
      newYear += 1;
    }

    // Handle the case where the new date is invalid (e.g., February 30)
    int lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    int newDay = date.day <= lastDayOfNewMonth ? date.day : lastDayOfNewMonth;

    return DateTime(newYear, newMonth, newDay);
  }


  DateTime subtractOneYear(DateTime date) {
    int newYear = date.year - 1;
    int newMonth = date.month;
    int newDay = date.day;

    // Handle leap year case (e.g., Feb 29 -> Feb 28)
    // if (newMonth == 2 && newDay == 29 && !DateTime.isLeapYear(newYear)) {
    //   newDay = 28;
    // }

    return DateTime(newYear, newMonth, newDay);
  }

  DateTime addOneYear(DateTime date) {
    int newYear = date.year + 1;
    int newMonth = date.month;
    int newDay = date.day;

    // Handle leap year case (e.g., Feb 29 -> Feb 28)
    // if (newMonth == 2 && newDay == 29 && !DateTime.isLeapYear(newYear)) {
    //   newDay = 28;
    // }

    return DateTime(newYear, newMonth, newDay);
  }



  List<Widget> _buildGoalsList() {
    List<Widget> result = goals
        .map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                  value: e.complete,
                  onChanged: (bool? value) async {
                    Goal updatedGoal = Goal.fromGoal(e);
                    updatedGoal.complete = (value ?? false);
                    DatabaseResult dbResult = await goalService.addOrUpdateGoal(updatedGoal);
                    if(dbResult.succeeded) {
                      setState(() {
                        e.complete = (value ?? false);
                      });
                    } else {
                      if(mounted) {
                        showMyInfoDialog(
                          context: context,
                          dialogType: InfoDialogType.error,
                          body: "Error updating completion state"
                        );
                      }
                    }

                  }),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: () async {
                        String? newText = await showMyInputDialog(context: context, currentText: e.content);
                        if(newText != null) {
                          Goal updatedGoal = Goal.fromGoal(e);
                          updatedGoal.content = (newText);
                          DatabaseResult dbResult = await goalService.addOrUpdateGoal(updatedGoal);
                          if(dbResult.succeeded) {
                            setState(() {
                              e.content = (newText);
                            });
                          } else {
                            if(mounted) {
                              showMyInfoDialog(
                                  context: context,
                                  dialogType: InfoDialogType.error,
                                  body: "Error updating contnet"
                              );
                            }
                          }
                        }
                      },
                      child: Text(e.content)
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if(mounted) {
                      bool confirmed = await showMyConfirmationDialog(context: context, body: "Are you sure you want to delete this item?");
                      if(confirmed) {
                        DatabaseResult deleteResult = await goalService.deleteGoal(goalId: e.id);
                        if(deleteResult.succeeded) {
                          setState(() {
                            goals.removeWhere((element) => element.id == e.id);
                          });
                        }
                        else {
                          if(mounted) {
                            showMyInfoDialog(
                                context: context,
                                dialogType: InfoDialogType.error,
                                body: 'Error deleting goal: \n ${deleteResult.message}'
                            );
                          }
                        }
                      }

                    }


                  },
                  icon: const Icon(Icons.delete)
                ),
              ],
            ),
          );
        })
        .toList();

    return result;
  }

  Widget _buildGoalInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: newGoalController,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: const InputDecoration(
              hintText: "New Goal",
            ),
            keyboardType: TextInputType.text,
          ),
        ),
        IconButton(
          onPressed: () async {
            if(newGoalController.text.trim().isNotEmpty) {
              Goal newGoal = Goal(date: _getDateString(selectedDate), content: newGoalController.text.trim());
              DatabaseResult dbResult = await goalService.addOrUpdateGoal(newGoal);
              if(dbResult.succeeded) {
                newGoal.id = dbResult.newOrUpdatedId;
                setState(() {
                  newGoalController.text = '';
                  goals.add(newGoal);
                });
              }
              else {
                if(mounted) {
                  showMyInfoDialog(
                      context: context,
                      dialogType: InfoDialogType.error,
                      body: 'Error creating goal: \n ${dbResult.message}'
                  );
                }
              }

            }
          },
          icon: const Icon(Icons.add)
        )
      ],
    );
  }

  Widget _buildActionsMenu() {
    return PopupMenuButton(
      icon: const Icon(Icons.menu),
      onSelected: (value) async {
        switch (value) {
          case GoalAction.import:
            return _importNotes();
          case GoalAction.export:
            return _exportSelected();
          default:
            throw UnimplementedError();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: GoalAction.import,
          child: Text(GoalAction.import),
        ),
        const PopupMenuItem<String>(
          value: GoalAction.export,
          child: Text(GoalAction.export),
        ),
      ],
    );

  }

  Future<void> _importNotes() async {
    // try {
    //   Result importResult = await _importExportService.importNotes(context: context);
    //   if(importResult.status == ResultStatus.failed && importResult.showedDialog == false) {
    //     showMyInfoDialog(context: context, dialogType: InfoDialogType.Error, body: "Failed to import selected notes");
    //   } else if(importResult.status == ResultStatus.succeeded) {
    //     showMyInfoDialog(context: context, dialogType: InfoDialogType.Info, body: "Imported ${importResult.dataCount} notes");
    //     _loadNotes(orderBy: _orderBy);
    //   }
    // } catch(e) {
    //   print("Note List Import Failed");
    //   print(e.toString());
    //   showMyInfoDialog(context: context, dialogType: InfoDialogType.Error, body: "Unexpected error occurred while importing notes");
    // }
  }

  Future<void> _exportSelected() async {
    // if(selectedCount == 0) {
    //   showMyInfoDialog(context: context, dialogType: InfoDialogType.Info, body: "You must select at least one note first.");
    //   return;
    // }
    //
    // try {
    //   List<int> noteIds = [];
    //   _selected.forEachIndexed((index, element) {
    //     if(element == true) {
    //       noteIds.add(_notes[index].noteId!);
    //     }
    //   });
    //
    //   Result exportResult = await _importExportService.exportNotes(context: context, noteIds: noteIds);
    //   if(exportResult.status == ResultStatus.failed && exportResult.showedDialog == false) {
    //     showMyInfoDialog(context: context, dialogType: InfoDialogType.Error, body: "Failed to export notes");
    //   } else if(exportResult.status == ResultStatus.succeeded) {
    //     showMyInfoDialog(context: context, dialogType: InfoDialogType.Info, body: "Exported ${noteIds.length} notes");
    //   }
    // } catch(e) {
    //   print("Note List Export Failed");
    //   print(e.toString());
    //   showMyInfoDialog(context: context, dialogType: InfoDialogType.Error, body: "Unexpected error occurred while exporting notes");
    // }


  }




}