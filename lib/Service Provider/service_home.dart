import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticket_management_system/Login/login.dart';
import 'package:ticket_management_system/Service%20Provider/pendingstatus_service.dart';
import 'package:ticket_management_system/Service%20Provider/serviceNotification.dart';
import 'package:ticket_management_system/screens/filter_report.dart';
import 'package:ticket_management_system/screens/profile.dart';
import 'package:ticket_management_system/screens/split_Screen.dart';
import '../provider/filter_provider.dart';

class Homeservice extends StatefulWidget {
  Homeservice({super.key, required this.userID});
  String userID;

  @override
  State<Homeservice> createState() => HomeserviceState();
}

class HomeserviceState extends State<Homeservice>
    with SingleTickerProviderStateMixin {
  int notificationNum = 0;
  List<dynamic> ticketList = [];
  List<String> buttons = [
    //  'Raise Ticket',
    'Pending Tickets',
    'Reports',
    'Profile',
  ];

  List<Widget Function(String)> screens = [
    // () => Raise(),
    (userID) => pendingstatus_service(
        ticketNumber: 'ticketNumber',
        openDate: 'openDate',
        asset: 'asset',
        building: 'building',
        floor: 'floor',
        remark: 'remark',
        room: 'room',
        serviceprovider: 'serviceprovider',
        user: 'user',
        work: 'work',
        month: 'month',
        year: 'year'),

    // service_pending(),
    (userID) => FilteredReport(
          userID: userID,
        ),
    // (userID) => serviceProfile(
    //       userID: userID,
    //     ),
    (userID) => profile(userID: userID)
    // serviceProfile(
    //       userID: userID,
    //     ),
  ];
  late final FilterProvider filterProvider;
  @override
  void initState() {
    filterProvider = Provider.of<FilterProvider>(context, listen: false);

    super.initState();
    // getNotification().whenComplete(() {
    //   setState(() {});
    // });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<FilterProvider>(context, listen: false)
        .fetchNotificationData(widget.userID);

    Provider.of<FilterProvider>(context, listen: false)
        .getServiceNotificatioLength(widget.userID);

    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: const Text(
            'T.🅼.S',
            style: TextStyle(
                color: Color.fromARGB(255, 141, 36, 41), fontSize: 30),
          ),
          leading: Stack(children: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationScreen_service(
                                userId: widget.userID,
                              ))).whenComplete(() {
                    filterProvider
                        .updateServiceUserSeen(widget.userID)
                        .whenComplete(() {
                      Provider.of<FilterProvider>(context, listen: false)
                          .getServiceNotificatioLength(widget.userID);
                    });
                  });
                },
                icon: const Icon(
                  Icons.notifications_active,
                  color: Color.fromARGB(255, 141, 36, 41),
                  size: 30,
                )),
            Positioned(
                top: 0,
                right: 0,
                child: Consumer<FilterProvider>(
                  builder: (context, value, child) {
                    return CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          filterProvider.serviceProviderSeen.length.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    );
                  },
                ))
          ]),
          actions: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                color: const Color.fromARGB(255, 197, 66, 73),
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.2,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                splitScreen(userID: widget.userID)));
                  },
                  child: const Center(
                    child: Text(
                      'S.P',
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
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (route) => false);
                },
                icon: const Icon(
                  Icons.power_settings_new,
                  color: Color.fromARGB(255, 141, 36, 41),
                  size: 30,
                )),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: GridView.builder(
                            itemCount: buttons.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 10.0),
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Card(
                                    elevation: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  screens[index](widget.userID),
                                            ),
                                          );
                                        },
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
                                              screens[index](widget.userID),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      buttons[index],
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              );
                            })),
                  ],
                ),
              ],
            ),
          ),
        ));
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
            .where('status', isEqualTo: 'Open')
            .where('isSeen', isEqualTo: true)
            .get();
        temp = ticketQuery.docs.map((e) => e.id).toList();
        notificationNum = notificationNum + temp.length;
        print('this is temp $temp');
      }
    } catch (e) {
      print("Error Fetching ticket length: $e");
    }
  }
}

Widget getIcon(String iconName) {
  switch (iconName) {
    case "Reports":
      return const Icon(
        Icons.report_sharp,
        size: 85,
        color: Color.fromARGB(255, 141, 36, 41),
      );
    case "Profile":
      return const Icon(
        Icons.person_outlined,
        size: 85,
        color: Color.fromARGB(255, 141, 36, 41),
      );

    default:
      return const Icon(
        Icons.pending_actions_outlined,
        size: 85,
        color: Color.fromARGB(255, 141, 36, 41),
      );
  }
}