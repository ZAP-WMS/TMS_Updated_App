import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticket_management_system/Service%20Provider/pendingstatus_service.dart';

class service_pending extends StatefulWidget {
  service_pending({super.key});

  @override
  State<service_pending> createState() => _service_pendingState();
}

class _service_pendingState extends State<service_pending> {
  List<dynamic> ticketList = [];
  List<dynamic> ticketListData = [];

  String work = '';
  String building = '';
  String floor = '';
  String room = '';
  String asset = '';
  String remark = '';
  String status = '';
  String dates = '';
  String month = '';
  String year = '';
  String user = '';
  String serviceProvider = '';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getPendingTicket().whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 141, 36, 41),
        title: const Text('Pending Tickets'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: ticketList.length, //* 2 - 1,
              itemBuilder: (BuildContext context, int index) {
                // if (index.isOdd) {
                //   return Divider();
                // }
                //final itemIndex = index ~/ 3;

                return ListTile(
                  title: Text('Ticket ${ticketList[index]}'),
                  trailing: Text(status),
                  onTap: () {
                    print("onTapData : $ticketListData");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return pendingstatus_service(
                        ticketNumber: ticketList[index],
                        year: ticketListData[index]['year'].toString(),
                        month: ticketListData[index]['month'] ?? '',
                        openDate: ticketListData[index]['date'] ?? '',
                        asset: ticketListData[index]['asset'] ?? '',
                        building: ticketListData[index]['building'] ?? '',
                        floor: ticketListData[index]['floor'] ?? '',
                        room: ticketListData[index]['room'] ?? '',
                        work: ticketListData[index]['work'] ?? '',
                        remark: ticketListData[index]['remark'] ?? '',
                        serviceprovider:
                            ticketListData[index]['serviceProvider'] ?? '',
                        user: ticketListData[index]['user'] ?? '',
                      );
                    }));
                  },
                );
              },
            ),
    );
  }

  Future<void> getPendingTicket() async {
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
              asset = mapData['asset'].toString();
              building = mapData['building'].toString();
              floor = mapData['floor'].toString();
              remark = mapData['remark'].toString();
              room = mapData['room'].toString();
              work = mapData['work'].toString();
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
}
