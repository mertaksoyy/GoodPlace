import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Habit {
  final String title;
  final String purpose;
  final String? imagePath;
  final DateTime lastUpdatedDate;
  final int streakCount;

  Habit({
    required this.title,
    required this.purpose,
    this.imagePath,
    required this.lastUpdatedDate,
    required this.streakCount,
  });

  factory Habit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Habit(
      title: data['title'],
      purpose: data['purpose'],
      streakCount: data['streakCount'],
      lastUpdatedDate:
          (data['lastUpdatedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(lastUpdatedDate);
  }
}
