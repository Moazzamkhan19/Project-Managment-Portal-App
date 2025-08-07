import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:get/get.dart';

class UserController extends GetxController {

  final RxList<User> _user =<User>[].obs;
  final RxBool isRegistered = false.obs;   // GETX USED //

 /* static final UserController _instance = UserController._internal();
  final List<User> _user = [];

  factory UserController() {
    return _instance;
  }
    // user controller list and initialization
  UserController._internal();
  */ // userlist and initialization

  bool registerUser(User user) {
    for (var u in _user) {
      if (u.username == user.username) {
        return false;
      }
    }
    _user.add(user);
    return true;
  }
  //would check if any field is empty or not for sign up
  String? getValidationErrorSign_up(User user) {
    if (user.username.trim().isEmpty) return "Username is required";
    if (user.password.trim().isEmpty) return "Password is required";
    if (user.password.trim().length<8) return "Password should be 8 characters long";
    if (user.email.trim().isEmpty) return "Email is required";
    if (!isValidEmailFormat(user.email)) return "Email Format is not correct";
    if (user.firstName.trim().isEmpty) return "First name is required";
    if (user.lastName.trim().isEmpty) return "Last name is required";
    if (user.phoneNumber.trim().isEmpty) return "Phone number is required";
    return null;
  }
  //would check fields in login page
  String? getValidationErrorLogin(User user)
  {
    if (user.username.trim().isEmpty) return "Username is required";
    if (user.password.trim().isEmpty) return "Password is required";
    return null;
  }
  Future<bool> login(String username, String password) async {
    final savedUser = await loadUserFromPrefs();
    if (savedUser == null) return false;

    return savedUser.username == username && savedUser.password == password;
  }

  //would check email format
  bool isValidEmailFormat(String email)
  {
    final emailRegex=RegExp( r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",);
    return emailRegex.hasMatch(email.trim());
  }
  //Storage of user
  Future<void> saveUserToPrefs(User user)  async
  {
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toMap());
    await prefs.setString('registeredUser',userJson);
  }
  Future<User?> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('registeredUser');
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      return User.fromMap(userMap);
    }
    return null;
  }
  List<User> getUsers() => _user; // For debugging
Future<void> deleteUsers() async
{
  var collection = FirebaseFirestore.instance.collection('users');
  var snapshot = await collection.get();
  for ( var doc in snapshot.docs)
    {
      await doc.reference.set({},SetOptions(merge: false));
    }
}
}
