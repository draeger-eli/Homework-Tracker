import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String name;
  final String? description;

  Course({required this.name, this.description});

  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<List<Course>> fetchCourses() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('courses')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Course(name: data['name'], description: data['description']);
    }).toList();
  }

  static Future<void> addCourse(String name, String? description) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('courses').add({
      'name': name,
      'description': description,
      'userId': userId,
    });
  }
}
