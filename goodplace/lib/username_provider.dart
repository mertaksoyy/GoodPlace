import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserNameProvider with ChangeNotifier {
  String? _userName;

  String? get getUserName => _userName;

  UserNameProvider() {
    _initializeUserName();
  }

  Future<void> _initializeUserName() async {
    final name = FirebaseAuth.instance.currentUser?.displayName;
    if (name != null) {
      setUserName(name);
    }
  }

  void setUserName(String userName) {
    _userName = userName;
    notifyListeners();
  }
}
