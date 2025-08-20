import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:project_managment_fb/Encryption/EncryptionServices.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart' as app_model;

class SignUp extends StatelessWidget {
  SignUp({super.key});

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phonenoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();

  final UserController _userController = Get.find<UserController>(); // GETX//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        title: const Text('SIGN UP'),
        centerTitle: true,
        backgroundColor: Colors.purple[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() => _userController.isRegistered.value   //GETX USED//
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Account created successfully!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.offNamed('/login'); //GETX USED//
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(hintText: 'First Name'),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(hintText: 'Last Name'),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phonenoController,
                decoration: const InputDecoration(hintText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(hintText: 'Password'),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: userNameController,
                decoration: const InputDecoration(hintText: 'Username'),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final newUser = app_model.User(
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    phoneNumber: phonenoController.text,
                    email: emailController.text,
                    username: userNameController.text,
                    password: passwordController.text,
                  );

                  final validationError = _userController.getValidationErrorSign_up(newUser);
                  if (validationError != null) {
                    Get.snackbar(
                      'Validation Error',
                      validationError,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  try {
                    final credential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: newUser.email.trim(),
                      password: newUser.password.trim(),
                    );

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(credential.user!.uid)
                        .set({
                      'firstName': newUser.firstName,
                      'lastName': newUser.lastName,
                      'phoneNumber': EncryptionHelper.encryptdata(newUser.phoneNumber),  //Encrypting data here
                      'username': newUser.username,
                      'email': newUser.email,
                    });

                    _userController.isRegistered.value = true;   //getx used//

                    // Optional: redirect after 2 seconds
                    Future.delayed(const Duration(seconds: 2), () {
                      Get.offNamed('/login');
                    });
                  } on FirebaseAuthException catch (e) {
                    String message;
                    if (e.code == 'email-already-in-use') {
                      message = 'This email is already registered.';
                    } else if (e.code == 'weak-password') {
                      message = 'Password is too weak';
                    } else {
                      message = 'Error: ${e.message}';
                    }

                    Get.snackbar(                                       //GETX USED//
                      'Signup Failed',
                      message,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );

                    _userController.isRegistered.value = false;
                  }
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

