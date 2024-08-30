import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/models/habit.dart';

class MyHabits extends StatefulWidget {
  const MyHabits({super.key});

  @override
  State<MyHabits> createState() => _MyHabitsState();
}

IconData doneIcon = Icons.check_box_outline_blank;
final CollectionReference habitsCollection =
    FirebaseFirestore.instance.collection("habits");

Stream<List<Habit>> habitStream() {
  final user = FirebaseAuth.instance.currentUser;
  return FirebaseFirestore.instance
      .collection('habits')
      .where('userId', isEqualTo: user?.uid)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList();
  });
}

class _MyHabitsState extends State<MyHabits> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(mainPageRoute);
          },
          icon: Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.amber,
        title: const Text('My Habits'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Habit>>(
        stream: habitStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No habits found.'));
          } else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final habit = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Card(
                    color: Color(0xffE6E6FA),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            snapshot.data![index].imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            final habit = snapshot.data![index];
                            Navigator.of(context).pushNamed(
                                updateHabitViewRoute,
                                arguments: habit);
                          },
                          title: Text(snapshot.data![index].title),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: !habit.isStreakIncrement,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.access_time),
                                  onPressed: () async {
                                    final habit = snapshot.data![index];
                                    habit.incrementStreakIfValid();
                                    await _updateHabitInFirestore(habit);
                                  },
                                  label: Text('I did it!'),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await habitsCollection
                                      .doc(snapshot.data![index].id)
                                      .delete();
                                },
                                icon: const Icon(
                                  Icons.delete,
                                ),
                                color: Colors.red,
                              )
                            ],
                          ),
                          subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(snapshot.data![index].purpose),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.whatshot,
                                      color: Colors.orange,
                                    ),
                                    Text(snapshot.data![index].streak
                                        .toString()),
                                  ],
                                ),
                                Text(snapshot.data![index].formattedDate),
                              ]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _updateHabitInFirestore(Habit habit) async {
    try {
      await habitsCollection.doc(habit.id).update({
        'streakCount': habit.streakCount,
        'lastUpdatedDate': Timestamp.fromDate(habit.lastUpdatedDate),
        'highStreakCount': habit.highStreakCount,
        'isStreakIncrement':
            habit.isStreakIncrement, // Firestore'da yeni alanı güncelle
      });
    } catch (e) {
      print('Error updating habit: $e');
    }
  }
}
