const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendHabitReminder = functions.pubsub
    .schedule("every 24 hours")
    .onRun(async (context) => {
      const usersSnapshot = await admin
          .firestore()
          .collection("users")
          .get();

      usersSnapshot.forEach(async (userDoc) => {
        const userData = userDoc.data();
        const habitsSnapshot = await admin
            .firestore()
            .collection("habits")
            .where("userId", "==", userDoc.id)
            .get();

        const inactiveHabits = [];
        habitsSnapshot.forEach((habitDoc) => {
          const habitData = habitDoc.data();
          const lastUpdated = new Date(
              habitData.lastUpdatedDate.seconds * 1000,
          );
          const now = new Date();


          if (
            habitData.streakCount === 0 &&
          now - lastUpdated > 24 * 60 * 60 * 1000
          ) {
            inactiveHabits.push(habitData);
          }
        });

        if (inactiveHabits.length > 0) {
          const randomHabit = inactiveHabits[
              Math.floor(Math.random() * inactiveHabits.length)
          ];
          const payload = {
            notification: {
              title: "Hatırlatma: Alışkanlığınıza Devam Edin",
              body: `${randomHabit.name} alışkanlığınıza
               devam etmek için 
                     geç değil!`,
            },
          };

          await admin.messaging().sendToDevice(
              userData.fcmToken,
              payload,
          );
        }
      });

      return null;
    });
