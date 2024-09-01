import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Habit {
  final String id;
  final String title;
  final String purpose;
  final String imagePath;
  DateTime lastUpdatedDate;
  int streakCount;
  int highStreakCount;
  bool isStreakIncrement;

  Habit({
    required this.id,
    required this.title,
    required this.purpose,
    required this.imagePath,
    required this.lastUpdatedDate,
    required this.streakCount,
    this.highStreakCount = 0,
    this.isStreakIncrement = false,
  });

  factory Habit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Habit(
      id: doc.id,
      title: data['title'],
      imagePath: data['imagePath'],
      purpose: data['purpose'],
      streakCount: data['streakCount'],
      lastUpdatedDate:
          (data['lastUpdatedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      highStreakCount: data['highStreakCount'] ?? 0,
      isStreakIncrement: data['isStreakIncrement'] ?? false,
    );
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(lastUpdatedDate);
  }

  void incrementStreakIfValid() {
    final now = DateTime.now();
    final differenceInDays = now.difference(lastUpdatedDate).inDays;

    if (differenceInDays == 0 && !isStreakIncrement) {
      // Eğer aynı gün artırılmamışsa artır
      streakCount += 1;
      lastUpdatedDate = now;
      isStreakIncrement = true; // Artırıldığını belirt
      if (streakCount > highStreakCount) {
        highStreakCount = streakCount;
      }
    } else if (differenceInDays == 1) {
      // Eğer tam bir sonraki günse, seriyi artır
      streakCount += 1;
      lastUpdatedDate = now;
      isStreakIncrement = true; // Artırıldığını belirt
      if (streakCount > highStreakCount) {
        highStreakCount = streakCount;
      }
    } else if (differenceInDays > 1) {
      // Eğer bir günden fazla geçmişse, seriyi sıfırla
      streakCount = 0;
      lastUpdatedDate = now;
      isStreakIncrement =
          false; // Yeni bir gün başladığında tekrar artırılabilir
    }
  }

  /// Returns the current streak count
  int get streak => streakCount;

  /// Returns the highest streak count achieved
  int get highStreak => highStreakCount;
}
