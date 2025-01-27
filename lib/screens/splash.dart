import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ticket_management_system/Homescreen.dart';
import 'package:ticket_management_system/Login/login.dart';
import 'package:ticket_management_system/screens/splash_service.dart';

import '../Service Provider/service_home.dart';
import '../provider/filter_provider.dart';

class SpalashScreen extends StatefulWidget {
  const SpalashScreen({super.key});

  @override
  State<SpalashScreen> createState() => SpalashScreenState();
}

class SpalashScreenState extends State<SpalashScreen>
    with SingleTickerProviderStateMixin {
  final SplashService _splashService = SplashService();
  bool isLogin = false;
  String userId = '';
  bool checkRole = true;
  late final FilterProvider filterProvider;
  double? height, width;
  @override
  void initState() {
    filterProvider = Provider.of<FilterProvider>(context, listen: false);

    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String _message = '';

    super.initState();
    Timer(const Duration(seconds: 3), () async {
      isLogin = await _splashService.checkLoginStatus(context);
      userId = await _splashService.getUserID();
      _splashService.getUserName(userId);
      await checkUserRole(userId);
    });

    _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _message = message.notification?.title ?? 'No Title';
      });
    });
  }

  @override
  void dispose() {  
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  // Assuming you're calling the function from an async method
  checkUserRole(userId) async {
    try {
      checkRole = await _splashService.checkUserRole(userId);
      if (checkRole) {
        if (isLogin) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(userID: userId)));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()));
        }
      } else {
        if (isLogin) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Homeservice(userID: userId)));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()));
        }
      }
    } catch (e) {
      print("Error checking role: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //       colors: [Colors.blue, Colors.purple],
        //       begin: Alignment.topRight,
        //       end: Alignment.bottomLeft),
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(
              flex: 3,
            ),
            // const CircleAvatar(
            //   radius: 75,
            //   backgroundImage: AssetImage('assets/flameicon.jpg'),
            // ),
            Container(
                alignment: Alignment.center,
                height: height! * .2,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/logo.jpeg'),
                          fit: BoxFit.cover)),
                )),
            const Spacer(
              flex: 1,
            ),
            Column(
              mainAxisSize:
                  MainAxisSize.min, // Use min to avoid unnecessary height
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the text vertically
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center the text horizontally
              children: const [
                Text(
                  'Ticket',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromARGB(223, 97, 4, 4),
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0), // Padding between lines
                Text(
                  'Management',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromARGB(223, 97, 4, 4),
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0), // Padding between lines
                Text(
                  'System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(223, 97, 4, 4),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Spacer(
              flex: 3,
            ),
          ],
        ),
      ),
    );
  }
}
