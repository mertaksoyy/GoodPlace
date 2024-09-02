import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/models/habit.dart';
import 'package:confetti/confetti.dart';

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
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

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
        backgroundColor: Color(0xff8E97FD),
        title: const Text('My Habits'),
        centerTitle: true,
      ),
      body: Container(
        color: Color(0xff8E97FD),
        child: Stack(
          children: [
            StreamBuilder<List<Habit>>(
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
                        child: Stack(children: [
                          Card(
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
                                  title: Text(
                                    snapshot.data![index].title,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Visibility(
                                        visible: !habit.isStreakIncrement,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.access_time),
                                          onPressed: () async {
                                            // Trigger the confetti animation first
                                            _confettiController.play();

                                            // Delay for a short time to ensure the animation starts
                                            await Future.delayed(const Duration(
                                                milliseconds: 1000));

                                            // Now update the state and Firestore
                                            habit.incrementStreakIfValid();
                                            await _updateHabitInFirestore(
                                                habit);
                                            setState(() {});
                                          },
                                          label: Text('I did!'),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(snapshot.data![index].purpose,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w900)),
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
                                        Text(snapshot
                                            .data![index].formattedDate),
                                      ]),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      );
                    },
                  );
                }
              },
            ),
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ], // optional, will use the default colors if omitted
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateHabitInFirestore(Habit habit) async {
    try {
      await habitsCollection.doc(habit.id).update({
        'streakCount': habit.streakCount,
        'lastUpdatedDate': Timestamp.fromDate(habit.lastUpdatedDate),
        'highStreakCount': habit.highStreakCount,
        'isStreakIncrement': habit.isStreakIncrement,
      });
    } catch (e) {
      print('Error updating habit: $e');
    }
  }
}
