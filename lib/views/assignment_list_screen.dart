import 'package:flutter/material.dart';
import '../widgets/add_fab.dart';
import '../presenters/assignment_presenter.dart';
import '../presenters/course_presenter.dart';

enum AssignmentFilter { all, incomplete, completed }

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentPresenter _presenter = AssignmentPresenter();
  final CoursePresenter _coursePresenter = CoursePresenter();

  bool _isLoading = true;
  String? _selectedCourseFilter;
  String? _newAssignmentCourse;
  List<String> _courseNames = [];
  AssignmentFilter _filter = AssignmentFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _coursePresenter.loadCourses();
    await _presenter.loadAssignments();

    setState(() {
      _isLoading = false;
      _courseNames = _coursePresenter.courses.map((c) => c.name).toList();
    });
  }

  bool _matchesFilter(bool isCompleted) {
    return switch (_filter) {
      AssignmentFilter.all => true,
      AssignmentFilter.incomplete => !isCompleted,
      AssignmentFilter.completed => isCompleted,
    };
  }

  void _showAddAssignmentDialog() {
    String newAssignmentTitle = '';
    _newAssignmentCourse = _courseNames.isNotEmpty ? _courseNames.first : null;

    showDialog(
      context: context,
      builder: (context) {
        // Rebuild the dialog when its selected course changes.
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Assignment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter assignment title',
                    ),
                    onChanged: (value) => newAssignmentTitle = value,
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: _newAssignmentCourse,
                    items: _courseNames.map((name) {
                      return DropdownMenuItem(value: name, child: Text(name));
                    }).toList(),
                    onChanged: (value) =>
                        setDialogState(() => _newAssignmentCourse = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (newAssignmentTitle.trim().isNotEmpty &&
                        _newAssignmentCourse != null) {
                      await _presenter.addAssignment(
                        newAssignmentTitle.trim(),
                        _newAssignmentCourse!,
                      );
                      setState(() {});
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignments = _presenter.assignments;

    final displayedAssignments = _selectedCourseFilter == null
        ? assignments
        : assignments
              .where((a) => a.courseName == _selectedCourseFilter)
              .toList();

    // Keep the completion filter from the previous lab.
    final filteredAssignments = displayedAssignments
    .where((assignment) {
      return _matchesFilter(assignment.isCompleted) &&
          assignment.title.toLowerCase().contains(_searchQuery.toLowerCase());
    })
    .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          if (_courseNames.isNotEmpty)
            DropdownButton<String>(
              hint: const Text(
                'Filter by course',
                style: TextStyle(color: Colors.white),
              ),
              dropdownColor: Colors.blue[100],
              value: _selectedCourseFilter,
              onChanged: (value) {
                setState(() {
                  _selectedCourseFilter = value;
                });
              },
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Courses'),
                ),
                ..._courseNames.map(
                  (name) => DropdownMenuItem(value: name, child: Text(name)),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [Padding(
  padding: const EdgeInsets.all(8),
  child: TextField(
    decoration: const InputDecoration(
      labelText: 'Search assignments',
      prefixIcon: Icon(Icons.search),
      border: OutlineInputBorder(),
    ),
    onChanged: (value) {
      setState(() {
        _searchQuery = value.trim();
      });
    },
  ),
),
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
                  child: filteredAssignments.isEmpty
                      ? const Center(child: Text('No assignments to show'))
                      : ListView.builder(
                          itemCount: filteredAssignments.length,
                          itemBuilder: (context, index) {
                            final assignment = filteredAssignments[index];

                            // Use the assignment's position in the full list.
                            final originalIndex =
                                assignments.indexOf(assignment);

                            return CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(assignment.title),
                              subtitle: Text('Course: ${assignment.courseName}'),
                              value: assignment.isCompleted,
                              onChanged: (_) async {
                                await _presenter.toggleCompleted(originalIndex);
                                setState(() {});
                              },
                              secondary: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Delete assignment',
                                onPressed: () async {
                                  await _presenter.deleteAssignment(
                                    originalIndex,
                                  );
                                  setState(() {});
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: AddFAB(onPressed: _showAddAssignmentDialog),
    );
  }
}