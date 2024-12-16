import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticket_management_system/screens/splash_service.dart';
import 'package:ticket_management_system/widget/loading_page.dart';

import '../provider/filter_provider.dart';

class NotificationTicket extends StatefulWidget {
  String? userId;
  String? date;
  String? ticketNo;
  NotificationTicket(
      {super.key,
      required this.userId,
      required this.date,
      required this.ticketNo});

  @override
  State<NotificationTicket> createState() => _NotificationTicketState();
}

class _NotificationTicketState extends State<NotificationTicket> {
  List<dynamic> ticketList = [];
  bool _isLoading = true;
  late final FilterProvider filterProvider;
  String? userId;
  final SplashService _splashService = SplashService();
  @override
  void initState() {
    initialize().whenComplete(() {
      filterProvider = Provider.of<FilterProvider>(context, listen: false);
      Provider.of<FilterProvider>(context, listen: false).fetchAllData(userId!);
      getPendingTicket().whenComplete(() async {
        setState(() {
          _isLoading = false;
        });
      });
    });

    super.initState();
  }

  Future<void> initialize() async {
    userId = await _splashService.getUserID();
    setState(() {});
  }

  String work = '';
  String building = '';
  String floor = '';
  String room = '';
  String asset = '';
  String remark = '';
  List<dynamic> serviceprovider = [];
  List<dynamic> titles = [];
  List<dynamic> icons = [];
  List<dynamic> message = [];
  List<dynamic> ticketListData = [];
  @override
  Widget build(BuildContext context) {
    icons = [
      Icons.work,
      Icons.business,
      Icons.layers,
      Icons.room,
      Icons.account_balance,
      Icons.comment,
      Icons.design_services
    ];
    titles = [
      'Work',
      'Building',
      'Floor',
      'Room',
      'Assets',
      'Remark',
      'Service Provider'
    ];
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromARGB(255, 141, 36, 41),
          title: const Text(
            'Tickets Details',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: _isLoading
            ? const Center(child: LoadingPage())
            : ticketListData.isNotEmpty
                ? ListView.builder(
                    itemCount: ticketListData.length,
                    itemBuilder: (context, index) {
                      return Card(
                          margin: const EdgeInsets.all(10),
                          color: Color.fromARGB(255, 190, 235, 192),
                          elevation: 10,
                          shadowColor: Color.fromARGB(255, 172, 231, 174),
                          child: Container(
                              height: 280,
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                children: [
                                  Text(ticketListData[index]['tickets'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  Expanded(
                                    child: ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: titles.length, //* 2 - 1,
                                        itemBuilder:
                                            (BuildContext context, int index2) {
                                          // List<dynamic> imageFilePaths =
                                          //     ticketListData[index]['imageFilePaths'];
                                          // if (index.isOdd) {
                                          //   return Divider();
                                          // }
                                          //final itemIndex = index ~/ 3;
                                          message = [
                                            ticketListData[index]['work'],
                                            ticketListData[index]['building'],
                                            ticketListData[index]['floor'],
                                            ticketListData[index]['room'],
                                            ticketListData[index]['asset'],
                                            ticketListData[index]['remark']
                                                .toString(),
                                            ticketListData[index]
                                                ['serviceProvider'],
                                          ];

                                          return customCard(icons[index2],
                                              titles[index2], message[index2]);
                                          // Padding(
                                          //   padding: const EdgeInsets.all(8.0),
                                          //   child: Card(
                                          //     elevation: 5,
                                          //     child: Padding(
                                          //       padding: const EdgeInsets.all(8.0),
                                          //       child: Column(
                                          //         children: [
                                          //           Text('Ticket ${ticketList[index]}',
                                          //               style: const TextStyle(
                                          //                   color: Color.fromARGB(255, 141, 36, 41),
                                          //                   fontWeight: FontWeight.bold,
                                          //                   fontSize: 15)),
                                          //           const SizedBox(
                                          //             height: 10,
                                          //           ),
                                          //           Row(
                                          //             children: [
                                          //               ticketCard(
                                          //                   Icons.work,
                                          //                   "Work: ",
                                          //                   ticketListData[index]['work'] ?? "N/A",
                                          //                   index)
                                          //             ],
                                          //           ),
                                          //           const SizedBox(
                                          //             height: 10,
                                          //           ),
                                          //           Row(
                                          //             children: [
                                          //               ticketCard(
                                          //                   Icons.business,
                                          //                   'Building;',
                                          //                   ticketListData[index]['building'] ??
                                          //                       "N/A",
                                          //                   index)
                                          //             ],
                                          //           ),
                                          //           const SizedBox(
                                          //             height: 10,
                                          //           ),
                                          //           Row(
                                          //             children: [
                                          //               ticketCard(
                                          //                   Icons.layers,
                                          //                   "Floor: ",
                                          //                   ticketListData[index]['floor']
                                          //                       .toString(),
                                          //                   index)
                                          //               // const Icon(Icons.layers,
                                          //               //     color: Color.fromARGB(255, 141, 36, 41)),
                                          //               // const SizedBox(width: 20),
                                          //               // const Text(
                                          //               //   'Floor: ',
                                          //               //   style: TextStyle(fontWeight: FontWeight.bold),
                                          //               // ),
                                          //               // const SizedBox(width: 10),
                                          //               // Text(ticketListData[index]['floor'] ?? "N/A")
                                          //             ],
                                          //           ),
                                          //           const SizedBox(
                                          //             height: 10,
                                          //           ),
                                          //           Row(
                                          //             children: [
                                          //               ticketCard(
                                          //                   Icons.room,
                                          //                   'Room: ',
                                          //                   ticketListData[index]['room'] ?? "N/A",
                                          //                   index)
                                          //             ],
                                          //           ),
                                          //           const SizedBox(height: 10),
                                          //           Row(
                                          //             children: [
                                          //               ticketCard(
                                          //                   Icons.account_balance,
                                          //                   "Asset:",
                                          //                   ticketListData[index]['asset'] ?? "N/A",
                                          //                   index)
                                          //             ],
                                          //           ),
                                          //           const SizedBox(height: 10),
                                          //           Row(children: [
                                          //             ticketCard(
                                          //                 Icons.comment,
                                          //                 'Remark: ',
                                          //                 ticketListData[index]['remark'] ?? "N/A",
                                          //                 index)
                                          //           ]),
                                          //           const SizedBox(height: 10),

                                          //           Row(children: [
                                          //             ticketCard(
                                          //                 Icons.design_services,
                                          //                 'Service Provider: ',
                                          //                 ticketListData[index]
                                          //                         ['serviceProvider'] ??
                                          //                     "N/A",
                                          //                 index)
                                          //           ]),
                                          //           const SizedBox(
                                          //             height: 10,
                                          //           ),
                                          //           SizedBox(
                                          //             height: 50,
                                          //             child: ListView.builder(
                                          //                 itemCount: imageFilePaths.length,
                                          //                 scrollDirection: Axis.horizontal,
                                          //                 itemBuilder: (context, index2) =>
                                          //                     Container(
                                          //                         height: 80,
                                          //                         width: 60,
                                          //                         child: GestureDetector(
                                          //                           onTap: () {
                                          //                             Navigator.push(
                                          //                                 context,
                                          //                                 MaterialPageRoute(
                                          //                                     builder: (context) =>
                                          //                                         ImageScreen(
                                          //                                           pageTitle:
                                          //                                               'pendingPage',
                                          //                                           imageFiles:
                                          //                                               imageFilePaths,
                                          //                                           initialIndex:
                                          //                                               index2,
                                          //                                           imageFile:
                                          //                                               imageFilePaths[
                                          //                                                   index2],
                                          //                                           ticketId:
                                          //                                               ticketList[
                                          //                                                   index],
                                          //                                         )));
                                          //                           },
                                          //                           child: Image.network(
                                          //                             imageFilePaths[index2],
                                          //                           ),
                                          //                         ))),
                                          //           )
                                          //           // customCard('Work', work, Icons.work),
                                          //           // customCard('Building', building, Icons.business),
                                          //           // customCard('Floor', floor, Icons.layers),
                                          //           // customCard('Room', room, Icons.room),
                                          //           // customCard('Asset', asset, Icons.account_balance),
                                          //           // customCard('Remark', remark, Icons.comment),
                                          //           // customCard(
                                          //           //     'Serviceprovider', serviceprovider, Icons.build),
                                          //           // imageFilePaths.isNotEmpty
                                          //           //     ? displayImages()
                                          //           //     : Container(
                                          //           //         // color: Colors.red,
                                          //           //         // height: MediaQuery.of(context).size.height * 0.9,
                                          //           //         // width: MediaQuery.of(context).size.width * 0.8,
                                          //           //         ),
                                          //         ],
                                          //       ),
                                          //     ),
                                          //   ),
                                          // );

                                          // ListTile(
                                          //   title: Text('Ticket ${ticketList[index]}'),
                                          //   trailing: ElevatedButton(
                                          //       onPressed: () {
                                          //         Navigator.push(
                                          //             context,
                                          //             MaterialPageRoute(
                                          //                 builder: (context) => pendingstatus(
                                          //                       Number: ticketList[index],
                                          //                     )
                                          //                 // TicketScreen(
                                          //                 //       Number: ticketList[index],
                                          //                 //       showResolvedTickets: false,
                                          //                 //     )
                                          //                 ));
                                          //       },
                                          //       child: const Text('Open')),
                                          //   onTap: () {
                                          //     Navigator.pushReplacement(
                                          //         context,
                                          //         MaterialPageRoute(
                                          //             builder: (context) => // NotificationScreen()
                                          //                 pendingstatus(
                                          //                   Number: ticketList[index],
                                          //                 )));
                                          //   },
                                          // );
                                        }),
                                  ),
                                ],
                              )));
                    },
                  )
                : Center(
                    child: Text('No Tickets Avilable'),
                  ));
  }

  Future<void> getPendingTicket() async {
    try {
      ticketList.clear();
      QuerySnapshot monthQuery =
          await FirebaseFirestore.instance.collection("raisedTickets").get();
      // List<dynamic> dateList = monthQuery.docs.map((e) => e.id).toList();
      // for (int j = 0; j < dateList.length; j++) {
      List<dynamic> temp = [];
      QuerySnapshot ticketQuery = await FirebaseFirestore.instance
          .collection("raisedTickets")
          .doc(widget.date)
          .collection('tickets')
          .where('user', isEqualTo: widget.userId)
          // .where('status', isEqualTo: 'Open')
          .get();
      temp = ticketQuery.docs.map((e) => e.id).toList();
      // ticketList = ticketList + temp;

      if (temp.isNotEmpty) {
        ticketList.addAll(temp);
        ticketList = ticketList.reversed.toList();
        // for (int k = 0; k < temp.length; k++) {
        DocumentSnapshot ticketDataQuery = await FirebaseFirestore.instance
            .collection("raisedTickets")
            .doc(widget.date)
            .collection('tickets')
            .doc(widget.ticketNo)
            .get();
        if (ticketDataQuery.exists) {
          Map<String, dynamic> mapData =
              ticketDataQuery.data() as Map<String, dynamic>;
          asset = mapData['asset'].toString();
          building = mapData['building'].toString();
          floor = mapData['floor'].toString();
          remark = mapData['remark'].toString();
          room = mapData['room'].toString();
          work = mapData['work'].toString();
          // serviceprovider = mapData['serviceProvider'].toString();
          ticketListData.add(mapData);
          ticketListData = ticketListData.reversed.toList();
          // print('$mapData abc');
        }
        //  }
        // }
      }
    } catch (e) {
      print("Error Fetching tickets: $e");
    }
  }

  Widget customCard(IconData icons, String title, String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icons, color: Color.fromARGB(255, 197, 66, 73)),
              SizedBox(width: 10),
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 100,
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
