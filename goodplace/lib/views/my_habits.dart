import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goodplace/models/habit.dart';

class MyHabits extends StatefulWidget {
  const MyHabits({super.key});

  @override
  State<MyHabits> createState() => _MyHabitsState();
}

IconData doneIcon = Icons.check_box_outline_blank;

Stream<List<Habit>> habitStream() {
  final user = FirebaseAuth.instance.currentUser;
  return FirebaseFirestore.instance
      .collection('habits')
      .where('userId', isEqualTo: user?.uid) // Descending order
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
        title: Text('My Habits'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Habit>>(
        stream: habitStream(), // Verileri dinleyen stream fonksiyonu
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
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Card(
                    color: Color(0xffE6E6FA),
                    child: ListTile(
                      onTap: () {
                        //
                      },
                      title: Text(snapshot.data![index].title),
                      trailing: ElevatedButton.icon(
                        icon: Icon(Icons.access_time),
                        onPressed: () {},
                        label: Text('I did it!'),
                      ),
                      subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(snapshot.data![index].purpose),
                            Row(
                              children: [
                                Icon(
                                  Icons.whatshot,
                                  color: Colors.orange,
                                ),
                                Text(snapshot.data![index].streakCount
                                    .toString()),
                              ],
                            ),
                            Text(snapshot.data![index].formattedDate),
                          ]),
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
}
