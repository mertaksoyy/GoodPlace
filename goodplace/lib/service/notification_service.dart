import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  void setupFirebaseMessaging() {
    // Bildirim izinlerini al (iOS için gerekli)
    messaging.requestPermission();

    // Gelen mesajları dinleyin
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Bildirim Başlığı: ${message.notification!.title}');
        print('Bildirim Mesajı: ${message.notification!.body}');
      }
    });

    // Mesaj ID'sini al
    messaging.getToken().then((String? token) {
      print("FCM Token: $token");
    });
  }
}
