import 'package:flutter/material.dart';
import 'package:instagram_clone/model/user.dart';
import 'package:instagram_clone/services/authentication.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  Authentication _authentication = Authentication();

  User get user => _user!;

  Future refreshUser() async {
    _user = await _authentication.getUserDetails();
    notifyListeners();
  }
}
