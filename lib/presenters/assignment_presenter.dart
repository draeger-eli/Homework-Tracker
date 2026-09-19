import '../models/assignment_model.dart';

class AssignmentPresenter {
  final List<Assignment> _assignments = [];

  List<Assignment> get assignments => _assignments;

  void addAssignment(String title) {
    _assignments.add(Assignment(title: title));
  }

  void toggleCompleted(int index) {
    _assignments[index].isCompleted = !_assignments[index].isCompleted;
  }
}