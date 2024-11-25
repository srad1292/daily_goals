import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'enum/goal_action.dart';
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
    });
  }

  String _getDateString(DateTime dateTime) {
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
                _loadGoals(selectedDate.subtract(const Duration(days: 1)));
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
                  _loadGoals(selectedDate.add(const Duration(days: 1)));
                },
                icon: const Icon(Icons.chevron_right)
            ),
          ],
        ),
        centerTitle: true,
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

  List<Widget> _buildGoalsList() {
    List<Widget> result = goals
        .where((e) => e.deleted == 0)
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
                  value: e.complete == 1,
                  onChanged: (bool? value) {
                    setState(() {
                      e.complete = (value ?? false) ? 1 : 0;
                    });
                  }),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(e.content),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Todo add a confirmation dialog here
                    setState(() {
                      e.deleted = 1;
                    });
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
            decoration: const InputDecoration(
              hintText: "New Goal",
            ),
            keyboardType: TextInputType.text,
          ),
        ),
        IconButton(
          onPressed: () {
            if(newGoalController.text.trim().isNotEmpty) {
              goals.add(Goal(date: _getDateString(selectedDate), content: newGoalController.text.trim()));
              setState(() {
                newGoalController.text = '';
              });
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