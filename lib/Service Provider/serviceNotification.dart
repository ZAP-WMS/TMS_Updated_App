import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ticket_management_system/provider/filter_provider.dart';
import 'package:ticket_management_system/utils/colors.dart';
import '../screens/splash_service.dart';

int globalIndex = 0;

class NotificationScreen_service extends StatefulWidget {
  String userId;

  NotificationScreen_service({super.key, required this.userId});

  @override
  State<NotificationScreen_service> createState() =>
      _NotificationScreen_serviceState();
}

class _NotificationScreen_serviceState
    extends State<NotificationScreen_service> {
  List<dynamic> ticketList = [];
  List<dynamic> ticketListData = [];
  int notificationNum = 0;

  final String imagePath = 'Images/';
  List<String> _imageUrls = [];
  bool _isLoading = true;
  final SplashService _splashService = SplashService();
  FilterProvider? filterProvider;
  String? userId;

  Future<void> fetchImageUrls() async {
    ListResult result = await FirebaseStorage.instance.ref('Images/').listAll();
    List<String> urls = await Future.wait(
      result.items.map((ref) => ref.getDownloadURL()).toList(),
    );
    _imageUrls = urls;
  }

  // Future<void> initialize() async {
  //   userId = await _splashService.getUserID();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context);

    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appColor,
          title: const Text('Notification'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .doc(widget.userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Document does not exist.'));
            }

            // Get the data from the document
            Map<String, dynamic>? data =
                snapshot.data!.data() as Map<String, dynamic>;

            if (data == null || !data.containsKey('notifications')) {
              return const Center(child: Text('No notifications field found.'));
            }

            List<dynamic> notifications = data['notifications'];

            if (notifications.isEmpty) {
              return const Center(child: Text('No notifications found.'));
            }
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> notification =
                    notifications[index] as Map<String, dynamic>;
                Timestamp timestamp = notification['timestamp'];
                String username = notification['userName'];
                String ticketId = notification['TicketId'];

                filterProvider.addTicketId(ticketId);

                String message =
                    'Ticket has been raised by $username for your immediate attention.'; // Convert Timestamp to DateTime
                DateTime notificationTime = timestamp.toDate();

                DateFormat formatter = DateFormat('yyyy-MM-dd – hh:mm a');
                DateFormat dateformat = DateFormat('dd-MM-yyyy');
                String formattedDate = formatter.format(notificationTime);
                String date = dateformat.format(notificationTime);

                return GestureDetector(
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (context) {
                    //     return NotificationTicket(
                    //       userId: userId,
                    //       date: date.toString(),
                    //       ticketNo: notification['TicketId'],
                    //     );
                    //     //  pendingstatus_service();

                    //     // pending(userID: userId!);
                    //   },
                    // ));
                  },
                  child: notificaionCard(
                      formattedDate, notification['TicketId'], message),
                );
              },
            );
          },
        ));
  }

  Future<void> getNotificationScreen() async {
    try {
      ticketList.clear();
      QuerySnapshot monthQuery =
          await FirebaseFirestore.instance.collection("raisedTickets").get();
      List<dynamic> dateList = monthQuery.docs.map((e) => e.id).toList();
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
        // ticketList = ticketList + temp;

        if (temp.isNotEmpty) {
          ticketList.addAll(temp);
          for (int k = 0; k < temp.length; k++) {
            DocumentSnapshot ticketDataQuery = await FirebaseFirestore.instance
                .collection("raisedTickets")
                .doc(dateList[j])
                .collection('tickets')
                .doc(temp[k])
                .get();
            if (ticketDataQuery.exists) {
              Map<String, dynamic> mapData =
                  ticketDataQuery.data() as Map<String, dynamic>;

              // serviceprovider = mapData['serviceProvider'].toString();
              ticketListData.add(mapData);
              // print('$mapData abc');
            }
          }
        }
      }
    } catch (e) {
      print("Error Fetching tickets: $e");
    }
  }

  Widget ticketCard(
      IconData icons, String title, String ticketListData, int index) {
    return Row(
      children: [
        Icon(icons, color: Colors.deepPurple),
        const SizedBox(width: 20),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        Text(ticketListData ?? "N/A")
      ],
    );
  }

  Widget listCard(
      IconData icons, String title, List<dynamic> ticketData, int index) {
    return Row(
      children: [
        Icon(icons, color: Colors.deepPurple),
        const SizedBox(width: 20),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        Column(
          children: List.generate(
              ticketData.length, (index) => Text(ticketData[index])),
        )
        // Text(ticketData ?? "N/A")
      ],
    );
  }

  Widget notificaionCard(String time, String ticketId, String message) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.all(10),
      child: Container(
          height: 80,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 15,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    ticketId,
                    style: TextStyle(
                        fontSize: 15,
                        color: blackColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Text(message)
            ],
          )),
    );
  }
}
