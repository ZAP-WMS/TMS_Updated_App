import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ticket_management_system/Homescreen.dart';
import 'package:ticket_management_system/Login/login.dart';
import 'package:ticket_management_system/screens/splash_service.dart';

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
  late final FilterProvider filterProvider;
  @override
  void initState() {
    filterProvider = Provider.of<FilterProvider>(context, listen: false);

    super.initState();
    Timer(Duration(seconds: 3), () async {
      isLogin = await _splashService.checkLoginStatus(context);
      userId = await _splashService.getUserID();
      if (isLogin) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                      userID: userId,
                    )));
      } else {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //       colors: [Colors.blue, Colors.purple],
        //       begin: Alignment.topRight,
        //       end: Alignment.bottomLeft),
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Spacer(
              flex: 3,
            ),
            CircleAvatar(
              radius: 75,
              backgroundImage: AssetImage('assets/flameicon.jpg'),
            ),
            Spacer(
              flex: 1,
            ),
            Text(
              'Ticket Management System',
              style: TextStyle(
                  color: Color.fromARGB(223, 97, 4, 4),
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
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
