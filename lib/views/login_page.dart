import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_managment_fb/views/sign_up.dart';
import '../controllers/user_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UserController _userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOGIN'),
        centerTitle: true,
        backgroundColor:Colors.purple[100],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // email
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(hintText: 'Email Address'),
                ),
                const SizedBox(height: 10),
                // Password
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Password'),
                ),
                const SizedBox(height: 20),
                // Login Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Step 1: Create User object (for validation)
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          // Step 2: Validate login fields // checks if fields are empty or not for login
                          if(email.isEmpty || password.isEmpty)
                            {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter both email and password.'),
                              backgroundColor: Colors.redAccent,),
                              );
                              return;
                            }
                          try
                          {
                            await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('isLoggedIn', true);
                            Get.offNamed('/home');
                          }
                          catch (e) {
                            String errorMessage = 'Login Failed';
                            if (e is FirebaseAuthException) {
                              switch (e.code) {
                                case 'user-not-found':
                                  errorMessage = 'No user found for that email.';
                                  break;
                                case 'wrong-password':
                                  errorMessage = 'Wrong password provided.';
                                  break;
                                default:
                                  errorMessage = 'Error: ${e.message}';
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent),
                            );
                          }

                        },
                        child: const Text('Log In'),
                          // Step 3: Attempt login
                        /*  final success = await _userController.login(
                            loginUser.username,
                            loginUser.password,
                          );


                          if (success){
                            //shared preference code here and after on pressed
                            SharedPreferences prefs= await SharedPreferences.getInstance();
                            await prefs.setBool('isLoggedIn', true);
                            Navigator.pushReplacementNamed(context, '/home');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid Credentials"),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                        child: const Text('Log In'),*/
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        /*Navigator.pushNamed(context, '/sign_up');*/
                        Get.to(
                              () => SignUp(), // Replace with your signup page widget
                          transition: Transition.native,
                          duration: const Duration(milliseconds: 800),
                        );
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


