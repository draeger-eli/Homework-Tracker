import 'package:flutter/material.dart';

import '../presenters/assignment_presenter.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentPresenter _presenter = AssignmentPresenter();

  // ---- Lab 5: added ----
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    await _presenter.loadAssignments();
    setState(() => _isLoading = false);
  }
  // ---- end Lab 5 ----

  void _showAddAssignmentDialog() {
    String newAssignmentTitle = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Assignment'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter assignment title',
            ),
            onChanged: (value) {
              newAssignmentTitle = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              // ---- Lab 5: changed ----
              onPressed: () async {
                if (newAssignmentTitle.trim().isNotEmpty) {
                  await _presenter.addAssignment(newAssignmentTitle.trim());
                  setState(() {});
                }
                Navigator.pop(context);
              },
              // ---- end Lab 5 ----
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignments = _presenter.assignments;

    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      // ---- Lab 5: changed ----
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return CheckboxListTile(
                  title: Text(assignment.title),
                  value: assignment.isCompleted,
                  onChanged: (_) async {
                    await _presenter.toggleCompleted(index);
                    setState(() {});
                  },
                );
              },
            ),
      // ---- end Lab 5 ----
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssignmentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
