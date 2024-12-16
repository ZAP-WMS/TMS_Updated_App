import 'package:flutter/material.dart';
import 'package:ticket_management_system/Homescreen.dart';
import 'package:ticket_management_system/Service%20Provider/service_home.dart';
import 'package:ticket_management_system/screens/splash_service.dart';
import 'package:ticket_management_system/widget/loading_page.dart';

import '../utils/colors.dart';

class splitScreen extends StatefulWidget {
  splitScreen({super.key, required this.userID});
  String userID;

  @override
  State<splitScreen> createState() => _splitScreenState();
}

class _splitScreenState extends State<splitScreen> {
  final SplashService _splashService = SplashService();
  List<String>? userRole = [];
  bool _isLoading = true;
  @override
  void initState() {
    getUserRole();
    super.initState();
  }

  getUserRole() async {
    userRole = await _splashService.getUserName(widget.userID);
    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: LoadingPage(
            ))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (userRole!.isEmpty) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                    userID: widget.userID,
                                  )));
                    } else {
                      SnackBar snackBar = const SnackBar(
                          backgroundColor: Colors.red,
                          content: Center(
                            child: Text('You are not User'),
                          ));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => HomeScreen(
                    //               userID: widget.userID,
                    //             )));
                  },
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      width: MediaQuery.of(context).size.width * 0.5,
                      color: userRole!.isNotEmpty
                          ? Colors.grey
                          : const Color.fromARGB(255, 197, 66, 73),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 60,
                          ),
                          Text(
                            "User",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    if (userRole!.isNotEmpty) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Homeservice(
                                    userID: widget.userID,
                                  )));
                    } else {
                      SnackBar snackBar = const SnackBar(
                          backgroundColor: Colors.red,
                          content: Center(
                            child: Text('You are not Service Provider'),
                          ));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.20,
                        width: MediaQuery.of(context).size.width * 0.5,
                        color: userRole!.isEmpty
                            ? Colors.grey
                            : const Color.fromARGB(255, 141, 36, 41),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Icon(
                              Icons.webhook_rounded,
                              color: Colors.white,
                              size: 60,
                            ),
                            Text(
                              'Service Provider',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
