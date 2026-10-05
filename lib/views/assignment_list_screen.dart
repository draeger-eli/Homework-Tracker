import 'package:flutter/material.dart';

import '../presenters/assignment_presenter.dart';

// Enhancement #2: filter options
enum AssignmentFilter { all, incomplete, completed }

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

  // ---- Enhancement #2: filter ----
  AssignmentFilter _filter = AssignmentFilter.all;

  bool _matchesFilter(bool isCompleted) {
    return switch (_filter) {
      AssignmentFilter.all => true,
      AssignmentFilter.incomplete => !isCompleted,
      AssignmentFilter.completed => isCompleted,
    };
  }
  // ---- end Enhancement #2 ----

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

    // Enhancement #2: positions in the FULL list of assignments that pass the filter.
    // Toggle and delete must receive full-list positions, because the model
    // finds the matching Firebase entry by its position in the full list.
    final visibleIndexes = [
      for (var i = 0; i < assignments.length; i++)
        if (_matchesFilter(assignments[i].isCompleted)) i,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Enhancement #2: filter control
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SegmentedButton<AssignmentFilter>(
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<AssignmentFilter>>[
                      ButtonSegment<AssignmentFilter>(
                        value: AssignmentFilter.all,
                        label: Text('All'),
                      ),
                      ButtonSegment<AssignmentFilter>(
                        value: AssignmentFilter.incomplete,
                        label: Text('Incomplete'),
                      ),
                      ButtonSegment<AssignmentFilter>(
                        value: AssignmentFilter.completed,
                        label: Text('Completed'),
                      ),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (selection) {
                      setState(() => _filter = selection.first);
                    },
                  ),
                ),
                Expanded(
                  child: visibleIndexes.isEmpty
                      ? const Center(child: Text('No assignments to show'))
                      : ListView.builder(
                          itemCount: visibleIndexes.length,
                          itemBuilder: (context, i) {
                            final index = visibleIndexes[i];
                            final assignment = assignments[index];
                            return CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(assignment.title),
                              value: assignment.isCompleted,
                              onChanged: (_) async {
                                await _presenter.toggleCompleted(index);
                                setState(() {});
                              },
                              // Enhancement #1: delete button
                              secondary: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Delete assignment',
                                onPressed: () async {
                                  await _presenter.deleteAssignment(index);
                                  setState(() {});
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssignmentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}