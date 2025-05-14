import 'package:flutter/material.dart';
import 'package:talksy/model/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: '',
    username: '',
    email: '',
    password: '',
    confirmpas: '',
    token: '',
  );

  User get user => _user;

  void setUser(String user) {
    // Use a logging framework instead of print
    debugPrint("+++++");
    debugPrint(user);
    debugPrint("+++++");
    _user = User.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }
}
