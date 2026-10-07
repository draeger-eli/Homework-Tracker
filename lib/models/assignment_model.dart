import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Assignment {
  final String title;
  bool isCompleted;
  final String courseName;

  Assignment({
    required this.title,
    required this.courseName,
    this.isCompleted = false,
  });

  static final _db = FirebaseDatabase.instance.ref();
  static final _auth = FirebaseAuth.instance;

  static Future<List<Assignment>> fetchAssignments() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _db.child('assignments/$userId').get();
    final List<Assignment> assignments = [];

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value) {
        assignments.add(
          Assignment(
            title: value['title'],
            courseName: value['courseName'] ?? 'Unknown',
            isCompleted: value['isCompleted'],
          ),
        );
      });
    }
    return assignments;
  }

  static Future<void> addAssignment(String title, String courseName) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final newRef = _db.child('assignments/$userId').push();
    await newRef.set({
      'title': title,
      'courseName': courseName,
      'isCompleted': false,
    });
  }

  static Future<void> updateCompletionStatus(
    int index,
    List<Assignment> currentAssignments,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || index < 0 || index >= currentAssignments.length)
      return;

    final snapshot = await _db.child('assignments/$userId').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final entry = data.entries.elementAt(index);
      final ref = _db.child('assignments/$userId/${entry.key}');
      final updatedStatus = !currentAssignments[index].isCompleted;
      await ref.update({'isCompleted': updatedStatus});
    }
  }

  static Future<void> deleteAssignment(int index) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || index < 0) return;

    final snapshot = await _db.child('assignments/$userId').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      if (index >= data.length) return;
      final entry = data.entries.elementAt(index);
      await _db.child('assignments/$userId/${entry.key}').remove();
    }
  }
}