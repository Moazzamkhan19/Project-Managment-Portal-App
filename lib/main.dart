import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:project_managment_fb/controllers/user_controller.dart';
import 'package:project_managment_fb/views/AddTeam.dart';
import 'package:project_managment_fb/views/offline_page.dart';
import 'package:project_managment_fb/views/splash_page.dart';
import 'views/login_page.dart';
import 'views/sign_up.dart';
import 'views/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  await AwesomeNotifications().initialize(
    null, // icon for notification (null uses default app icon)
    [
      NotificationChannel(
        channelKey: 'task_channel',
        channelName: 'Task Notifications',
        channelDescription: 'Notification channel for task reminders',
        defaultColor: Colors.purple,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      )
    ],
    debug: true,
  );

 /* final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'app.db');
  await deleteDatabase(path);
  */
  Get.put(UserController());       // registering controller
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   /* return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User Auth APP',
      initialRoute: '/',
      routes:{
        '/':(context)=>const SplashPage(),
        '/login':(context)=>const LoginPage(),
        '/sign_up':(context)=>const SignUp(),
        '/home':(context)=> HomePage(),
        '/addTeam':(context)=>AddTeamPage(),
        '/offlinepage':(context)=>OfflinePage(),
      },
    );
    */ //material app
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Project Management Portal',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/login', page: ()=> const LoginPage()),
        GetPage(name: '/home', page: ()=> const HomePage()),
        GetPage(name: '/signup', page:()=> SignUp()),
        GetPage(name: '/addTeam', page:()=> AddTeamPage()),
        GetPage(name: '/', page:()=> const SplashPage()),
        GetPage(name: '/offlinepage', page:()=> OfflinePage()),
      ],
    );
  }
}
