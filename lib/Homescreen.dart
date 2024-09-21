import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_management_system/Login/login.dart';
import 'package:ticket_management_system/provider/filter_provider.dart';
import 'package:ticket_management_system/provider/pieChart_provider.dart';
import 'package:ticket_management_system/responsive/responsive.dart';
import 'package:ticket_management_system/screens/filter_report.dart';
import 'package:ticket_management_system/screens/notification.dart';
import 'package:ticket_management_system/screens/pending.dart';
import 'package:ticket_management_system/screens/profile.dart';
import 'package:ticket_management_system/screens/raise.dart';
import 'package:ticket_management_system/screens/splash_service.dart';
import 'package:ticket_management_system/screens/split_Screen.dart';
import 'package:ticket_management_system/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key, required this.userID});
  String userID;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  bool isLoading = true;
  int notificationNum = 0;
  String? notiLength = '0';

  List<String> buttons = [
    'Raise Ticket',
    'Pending Tickets',
    'Reports',
    'Profile',
  ];

  List<Widget Function(String)> screens = [
    (userID) => Raise(
          userID: userID,
        ),
    //Pending(),
    (userID) => pending(
          userID: userID,
        ),
    (userID) => FilteredReport(
          userID: userID,
        ),
    (userID) => profile(
          userID: userID,
        ),
  ];

  int resolvedTicketLen = 0;
  int pendingTicketLen = 0;
  late final FilterProvider filterProvider;
  Map<String, dynamic>? data;
  @override
  void initState() {
    Provider.of<FilterProvider>(context, listen: false)
        .updateUserSeen(widget.userID);
    _firebaseMessaging.requestPermission();
    filterProvider = Provider.of<FilterProvider>(context, listen: false);
    notiLength = filterProvider.closeticketLength.toString();
    _checkAndGenerateFcmToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message while in the foreground!');
      if (message.notification != null) {
        print('Notification Title: ${message.notification!.title}');
        print('Notification Body: ${message.notification!.body}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      if (message.notification != null) {
        print('Notification Title: ${message.notification!.title}');
        print('Notification Body: ${message.notification!.body}');
      }
    });

    // filterProvider = Provider.of<FilterProvider>(context, listen: false);

    // getPendingTicket().whenComplete(() async {
    //   await getNotification();
    //   isLoading = false;
    //   setState(() {});
    // });
    super.initState();
  }

  Future<void> _checkAndGenerateFcmToken() async {
    // Ensure Firebase is initialized
    await Firebase.initializeApp();

    // Get the current user

    if (widget.userID != null) {
      // Check Firestore for an existing token
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('FcmToken')
          .doc(widget.userID)
          .get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        _fcmToken = data['fcmToken'];
        if (_fcmToken != null) {
          await _storeTokenLocally(_fcmToken!);
          print("FCM Token already exists: $_fcmToken");
          return;
        }
      }

      // Generate a new token if none exists
      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        setState(() {
          _fcmToken = token;
        });
        print("Generated FCM Token: $_fcmToken");

        // Store the token in Firestore
        await FirebaseFirestore.instance
            .collection('FcmToken')
            .doc(widget.userID)
            .set({
          'fcmToken': _fcmToken,
          'lastUpdated': Timestamp.now(), // Optional
        }, SetOptions(merge: true)).then((_) {
          print("FCM Token stored successfully.");
        }).catchError((error) {
          print("Failed to store FCM token: $error");
        });
      } else {
        print("Failed to generate FCM token");
      }
    } else {
      print("No user is currently logged in.");
    }
  }

  Future<void> _storeTokenLocally(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmToken', token);
    print("FCM Token stored locally.");
  }
  // void _setupTokenRefresh() {
  //   FirebaseMessaging.onTokenRefresh.listen((newToken) async {
  //     print("Refreshed FCM Token: $newToken");
  //     setState(() {
  //       _fcmToken = newToken;
  //     });

  //     // Update the token in Firestore
  //     User? user = FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
  //         'fcmToken': _fcmToken,
  //         'lastUpdated': Timestamp.now(), // Optional
  //       }, SetOptions(merge: true)).then((_) {
  //         print("FCM Token updated successfully.");
  //       }).catchError((error) {
  //         print("Failed to update FCM token: $error");
  //       });
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PiechartProvider>(context, listen: false);
    Provider.of<FilterProvider>(context, listen: false)
        .fetchAllData(widget.userID);

    // Provider.of<FilterProvider>(context, listen: false)
    //     .updateUserSeen(widget.userID);

    var screenSize = MediaQuery.of(context).size;
    return ReponsiveWidget(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: const Text(
            'T.🅼.S',
            style: TextStyle(
                color: Color.fromARGB(255, 141, 36, 41), fontSize: 30),
          ),
          leading: Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(
                        userID: widget.userID,
                      ),
                    ),
                  ).whenComplete(() {
                    Provider.of<FilterProvider>(context, listen: false)
                        .updateUserSeen(widget.userID);
                  });
                  // .whenComplete(() {
                  //   getNotification().whenComplete(() {
                  //     setState(() {});
                  //   });
                  // });
                },
                icon: const Icon(
                  size: 30,
                  Icons.notifications_active,
                  color: Color.fromARGB(255, 141, 36, 41),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Consumer<FilterProvider>(
                    builder: (context, value, child) {
                      return CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          filterProvider.userSeen.length.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      );
                    },
                  ))
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Color.fromARGB(255, 197, 66, 73),
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.2,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => spliScreen(
                                  userID: widget.userID,
                                )));
                  },
                  child: const Center(
                    child: Text(
                      'User',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 19),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  SplashService().removeLogin(context);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (route) => false);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const LoginPage()),
                  // );
                },
                icon: const Icon(
                  Icons.power_settings_new,
                  color: Color.fromARGB(255, 141, 36, 41),
                  size: 30,
                )),
          ],
        ),
        body: Consumer<FilterProvider>(
          builder: (context, value, child) {
            final openTicketlength = value.openData.length;

            return value.openLoading
                ? Center(
                    child: CircularProgressIndicator(
                    color: appColor,
                  ))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      bool isLandscape =
                          constraints.maxWidth > constraints.maxHeight;
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Column(
                            children: [
                              SizedBox(
                                width: screenSize.width * 0.95,
                                height: screenSize.height * 0.5,
                                child: GridView.builder(
                                  itemCount: buttons.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isLandscape ? 4 : 2,
                                    childAspectRatio: isLandscape ? 1.2 : 1,
                                    crossAxisSpacing: 4.0,
                                  ),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Card(
                                          elevation: 10,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      screens[index](
                                                          widget.userID),
                                                ),
                                              ).whenComplete(() {
                                                getPendingTicket()
                                                    .whenComplete(() {
                                                  provider.reloadWidget(true);
                                                  // print("Hello Worlds");
                                                });
                                              }),
                                              child: getIcon(buttons[index]),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    screens[index](
                                                        widget.userID),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            buttons[index],
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(10.0),
                                child: Card(
                                  elevation: 10.0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(5.0),
                                        child: const Text(
                                          'Ticket Overview',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 20),
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 15),
                                                RichText(
                                                  text: TextSpan(children: [
                                                    WidgetSpan(
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .only(
                                                          left: 5.0,
                                                        ),
                                                        child: CircleAvatar(
                                                            radius: 12,
                                                            backgroundColor:
                                                                const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    141,
                                                                    36,
                                                                    41),
                                                            child: Text(
                                                              openTicketlength
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )),
                                                      ),
                                                    ),
                                                    const WidgetSpan(
                                                      child: SizedBox(
                                                        width: 10,
                                                      ),
                                                    ),
                                                    const WidgetSpan(
                                                        child: Text(
                                                      'Pending Ticket',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ))
                                                  ]),
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                RichText(
                                                  text: TextSpan(children: [
                                                    WidgetSpan(
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .only(
                                                          left: 5.0,
                                                        ),
                                                        child: CircleAvatar(
                                                          radius: 12,
                                                          backgroundColor:
                                                              Colors.orange,
                                                          child: Text(
                                                            value
                                                                .closeticketLength
                                                                .toString(),
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const WidgetSpan(
                                                      child: SizedBox(
                                                        width: 10,
                                                      ),
                                                    ),
                                                    const WidgetSpan(
                                                      child: Text(
                                                        'Completed Ticket',
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    )
                                                  ]),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.2,
                                              child: PieChart(
                                                PieChartData(
                                                  centerSpaceRadius: 20,
                                                  sections: [
                                                    PieChartSectionData(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 141, 36, 41),
                                                      value: 40,
                                                      title: openTicketlength
                                                          .toString(),
                                                      titleStyle:
                                                          const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                      ),
                                                      radius: 40,
                                                    ),
                                                    PieChartSectionData(
                                                      color: Colors.orange,
                                                      value: 20,
                                                      title: value
                                                          .closeticketLength
                                                          .toString(),
                                                      titleStyle:
                                                          const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20),
                                                      radius: 40,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }

  Future getNotification() async {
    try {
      int currentYear = DateTime.now().year;
      QuerySnapshot dateQuery =
          await FirebaseFirestore.instance.collection("raisedTickets").get();
      List<dynamic> dateList = dateQuery.docs.map((e) => e.id).toList();
      for (int j = 0; j < dateList.length; j++) {
        List<dynamic> temp = [];
        QuerySnapshot ticketQuery = await FirebaseFirestore.instance
            .collection("raisedTickets")
            .doc(dateList[j])
            .collection('tickets')
            .where('status', isEqualTo: 'Close')
            .where('isUserSeen', isEqualTo: true)
            .get();
        temp = ticketQuery.docs.map((e) => e.id).toList();
        notificationNum = notificationNum + temp.length;
        print('this is temp $temp');
      }
    } catch (e) {
      print("Error Fetching ticket length: $e");
    }
  }

  Future getPendingTicket() async {
    try {
      pendingTicketLen = 0;
      resolvedTicketLen = 0;
      int currentYear = DateTime.now().year;
      QuerySnapshot dateQuery =
          await FirebaseFirestore.instance.collection("raisedTickets").get();
      List<dynamic> dateList = dateQuery.docs.map((e) => e.id).toList();
      for (int j = 0; j < dateList.length; j++) {
        List<dynamic> temp = [];
        QuerySnapshot pendingTicketQuery = await FirebaseFirestore.instance
            .collection("raisedTickets")
            .doc(dateList[j])
            .collection('tickets')
            .where('status', isEqualTo: 'Open')
            .where('user', isEqualTo: widget.userID)
            .get();
        QuerySnapshot completedTicketQuery = await FirebaseFirestore.instance
            .collection("raisedTickets")
            .doc(dateList[j])
            .collection('tickets')
            .where('status', isEqualTo: 'Close')
            .where('user', isEqualTo: widget.userID)
            .get();
        List<dynamic> pendingTicketData =
            pendingTicketQuery.docs.map((e) => e.id).toList();
        pendingTicketLen = pendingTicketLen + pendingTicketData.length;
        List<dynamic> completedTicketData =
            completedTicketQuery.docs.map((e) => e.id).toList();
        resolvedTicketLen = resolvedTicketLen + completedTicketData.length;
        // print(completedTicketData);
      }
    } catch (e) {
      print("Error Fetching tickets: $e");
    }
  }

  Future getResolvedTicket() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('resolvedTicket').get();

    List<dynamic> resolvedTicketData =
        querySnapshot.docs.map((e) => e.id).toList();
    resolvedTicketLen = resolvedTicketData.length;
  }

  Widget getIcon(String iconName) {
    switch (iconName) {
      case "Raise Ticket":
        return const Icon(
          Icons.receipt_long_rounded,
          size: 70,
          color: Color.fromARGB(255, 141, 36, 41),
        );
      case "Reports":
        return const Icon(
          Icons.report_sharp,
          size: 70,
          color: Color.fromARGB(255, 141, 36, 41),
        );
      case "Profile":
        return const Icon(
          Icons.person_outlined,
          size: 70,
          color: Color.fromARGB(255, 141, 36, 41),
        );
      default:
        return const Icon(
          Icons.pending_actions_outlined,
          size: 70,
          color: Color.fromARGB(255, 141, 36, 41),
        );
    }
  }

  Future storeCompletedTicket(
      String year, String month, String openDate, String ticketNumber) async {
    FirebaseFirestore.instance
        .collection("raisedTickets")
        .doc(year)
        .collection('months')
        .doc(month)
        .collection('date')
        .doc(openDate)
        .collection('tickets')
        .doc(ticketNumber)
        .update({
      "isUserSeen": false,
    });
  }
}
