import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ticket_management_system/provider/getReport_provider.dart';
import 'package:ticket_management_system/provider/raisedata_provider.dart';
import 'package:ticket_management_system/screens/display_report.dart';
import 'package:ticket_management_system/screens/splash_service.dart';
import 'package:ticket_management_system/utils/colors.dart';
import '../utils/loading.dart';

class FilteredReport extends StatefulWidget {
  FilteredReport({super.key, required this.userID});
  String userID;
  @override
  State<FilteredReport> createState() => _FilteredReportState();
}

class _FilteredReportState extends State<FilteredReport> {
  TextEditingController assetController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController workController = TextEditingController();
  TextEditingController floorController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  TextEditingController buildingController = TextEditingController();
  TextEditingController ticketController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  List<String> buildingList = [];
  List<dynamic> filterData = [];
  List<String> floorList = [];
  List<String> roomList = [];
  List<String> assetList = [];
  List<String> userList = [];
  List<String> allTicketList = [];
  List<String> workList = [];
  List<String> uniqueFloorList = [];
  String? selectedAsset;
  String? selectedFloor;
  String? selectedRoom;
  String selectedStartDate = '';
  String selectedEndDate = '';
  String? selectedUser;
  String? selectedTicket;
  String? selectedbuilding;
  String? selectedWork;
  String? selectedStatus;

  List<String> floorNumberList = [];
  List<dynamic> allData = [];
  List<dynamic> serviceProviderList = [];
  String? selectedTicketNumber;
  List<String> allDateData = [];
  List<String> allTicketData = [];
  List<String> allAssetData = [];
  List<String> allUserData = [];
  List<String> buildingNumberList = [];
  List<String> allFloorData = [];
  List<String> allWorkData = [];
  List<String> allRoomData = [];
  List<String> allStatusData = ['Open', 'Close'];

  List<dynamic> ticketList = [];

  List<String> serviceProvider = [];
  List<String>? selectedSPList = [];

  String? selectedServiceProvider;
  List<String> roomNumberList = [];
  List<String> ticketNumberList = [];
  bool isLoading = true;
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime(2020, 01, 01),
    end: DateTime(2025, 01, 01),
  );

  DateTime rangeStartDate = DateTime.now();
  DateTime? rangeEndDate = DateTime.now();
  final SplashService _splashService = SplashService();
  late ReportProvider dataProvider = ReportProvider();
  List<String>? userRole = [];
  // String? userId;
  @override
  void initState() {
    dataProvider = Provider.of<ReportProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserRole();
      // Delayed execution of async methods after initial build
      initialize();
    });

    // initialize();

    super.initState();
  }

  TextEditingController ticketnumberController = TextEditingController();
  TextEditingController serviceProviderController = TextEditingController();

  Future initialize() async {
    dataProvider.resetSelections();
    await dataProvider.fetchFloorNumbers();
    await dataProvider.fetchTicketNumbers();
    await dataProvider.fetchBuildingNumbers();
    await dataProvider.fetchRoomNumbers();
    await dataProvider.fetchWorkList();
    await dataProvider.fetchServiceProvider();
    await dataProvider.fetchUser();
    await dataProvider.fetchAssets();
    // userId = await _splashService.getUserID();
  }

  getUserRole() async {
    userRole = await _splashService.getUserName(widget.userID);
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // dataProvider.fetchBuildingNumbers();
    // dataProvider.fetchRoomNumbers();
    // dataProvider.fetchWorkList();
    // dataProvider.fetchAssets();
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'All Tickets Report',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 141, 36, 41),

        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 20),
        //     child: IconButton(
        //         onPressed: () {
        //           signOut(context);
        //         },
        //         icon: const Icon(
        //           Icons.power_settings_new_outlined,
        //           size: 30,
        //           color: white,
        //         )),
        //   )
        // ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ReportProvider>(
              builder: (context, provider, child) {
                return Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                              elevation: 5,
                              child: SizedBox(
                                width: 345,
                                height: 70,
                                child: TextButton(
                                  onPressed: () {
                                    pickDateRange();
                                    setState(() {});
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      // Text(
                                      //   textAlign: TextAlign.justify,
                                      //   'Search Date: \n $selectedDate',
                                      //   style: const TextStyle(
                                      //       color: Colors.black,
                                      //       fontSize: 16),
                                      // ),
                                      child: RichText(
                                          text: TextSpan(
                                              text: 'Search Date: \n',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              children: [
                                            TextSpan(
                                                text: selectedStartDate
                                                        .isNotEmpty
                                                    ? " $selectedStartDate TO $selectedEndDate  "
                                                    : '',
                                                style: const TextStyle(
                                                    backgroundColor:
                                                        Colors.purple,
                                                    color: Colors.white)),
                                          ])),
                                    ),
                                  ),
                                ),
                              ))),
                      Row(
                        children: [
                          customDropDown(
                            customDropDownList: ['Open', 'Close'],
                            hintText: 'Search Status',
                            index: 0,
                            selectedValue: provider.selectedStatus,
                            onChanged: (value) {
                              provider.status(value.toString());
                            },
                            searchController: statusController,
                          ),
                          customDropDown(
                            customDropDownList: provider.floorNumberList,
                            hintText: 'Select Floor',
                            index: 0,
                            selectedValue: provider.selectedFloor,
                            onChanged: (value) {
                              provider.floor(value.toString());
                            },
                            searchController: floorController,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          customDropDown(
                            customDropDownList: provider.ticketNumberList,
                            hintText: 'Select Ticket',
                            index: 0,
                            selectedValue: provider.selectedTicket,
                            onChanged: (value) {
                              provider.ticket(value.toString());
                            },
                            searchController: ticketController,
                          ),
                          customDropDown(
                            customDropDownList: provider.roomNumberList,
                            hintText: 'Search Room',
                            index: 0,
                            selectedValue: provider.selectedRoom,
                            onChanged: (value) {
                              provider.room(value.toString());
                            },
                            searchController: roomController,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          customDropDown(
                            customDropDownList: provider.workNumberList,
                            hintText: 'Select Work',
                            index: 0,
                            selectedValue: provider.selectedWork,
                            onChanged: (value) {
                              provider.work(value.toString());
                              // setState(() {
                              //   // selectedValue = value;
                              // });
                            },
                            searchController: workController,
                          ),
                          customDropDown(
                            customDropDownList: provider.assetNumberList,
                            hintText: 'Search Asset',
                            index: 0,
                            selectedValue: provider.selectedAsset,
                            onChanged: (value) {
                              provider.asset(value.toString());
                            },
                            searchController: assetController,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          customDropDown(
                            customDropDownList: provider.buildingNumberList,
                            hintText: 'Search Building',
                            index: 0,
                            selectedValue: provider.selectedBuilding,
                            onChanged: (value) {
                              provider.building(value.toString());
                            },
                            searchController: buildingController,
                          ),
                          customDropDown(
                            customDropDownList: userRole!.isEmpty
                                ? provider.serviceProviders
                                : provider.users,
                            hintText: userRole!.isEmpty
                                ? 'Search Service Provider'
                                : 'Search Users',
                            index: 0,
                            selectedValue: userRole!.isEmpty
                                ? provider.selectedService
                                : provider.selectUser,
                            onChanged: (value) {
                              userRole!.isEmpty
                                  ? provider.serviceProvider(value.toString())
                                  : provider.usersName(value.toString());
                            },
                            searchController: serviceProviderController,
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.30,
                              height: MediaQuery.of(context).size.height * 0.08,
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: appColor),
                                    onPressed: () {
                                      showSavingDialog(context, 'Fetching...');
                                      Map<String, dynamic> selectedItemsMap = {
                                        'selectedStatus':
                                            provider.selectedStatus,
                                        'selectedTicket':
                                            provider.selectedTicket,
                                        'selectedWork': provider.selectedWork,
                                        'selectedBuilding':
                                            provider.selectedBuilding,
                                        'selectedFloor': provider.selectedFloor,
                                        'selectedRoom': provider.selectedRoom,
                                        'selectedAsset': provider.selectedAsset,
                                        'selectedServiceProvider':
                                            provider.selectedService,
                                        'selectedStartDate': selectedStartDate,
                                        'selectedEndDate': selectedEndDate,
                                      };

                                      bool atLeastOneAvailable =
                                          selectedItemsMap.values.any((value) {
                                        if (value == null) {
                                          return false; // Check if the value is null
                                        }
                                        if (value is String && value.isEmpty) {
                                          return false; // Check if the value is an empty string
                                        }
                                        return true; // Return true if the value is not null and not empty
                                      });

                                      if (atLeastOneAvailable) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                            return ReportDetails(
                                              userId: widget.userID,
                                              ticketList: ticketList,
                                              ticketData: filterData,
                                              filterFieldData: selectedItemsMap,
                                              userRole:userRole!
                                            );
                                          }),
                                        ).whenComplete(() {
                                          provider.resetSelections();
                                          // print('ticketList $ticketList');
                                          // print('filterData $filterData');
                                          // selectedWork = null;
                                          // selectedServiceProvider = null;
                                          // selectedStatus = null;
                                          // selectedAsset = null;
                                          // selectedUser = null;
                                          // selectedRoom = null;
                                          // selectedFloor = null;
                                          // selectedbuilding = null;
                                          // selectedTicket = null;
                                          // selectedStartDate = '';
                                          // selectedEndDate = '';
                                          // // ticketList.clear();
                                          // // filterData.clear();
                                          // setState(() {});
                                          Navigator.pop(context);
                                        });
                                      } else {
                                        Navigator.pop(context);
                                        popupAlertmessage(
                                            'Please select any filter');
                                      }
                                      //});
                                    },
                                    child: const Text('Get Report'),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  // ElevatedButton(
                                  //   onPressed: () {
                                  //     Navigator.push(
                                  //             context,
                                  //             MaterialPageRoute(
                                  //                 builder: (context) =>
                                  //                     const Refreshscreen()))
                                  //         .whenComplete(() {
                                  //       selectedWork = null;
                                  //       selectedServiceProvider = null;
                                  //       selectedStatus = null;
                                  //       selectedAsset = null;
                                  //       selectedUser = null;
                                  //       selectedRoom = null;
                                  //       selectedFloor = null;
                                  //       selectedbuilding = null;
                                  //       selectedTicket = null;
                                  //       selectedStartDate = '';
                                  //       selectedEndDate = '';
                                  //       ticketList.clear();
                                  //       filterData.clear();
                                  //       setState(() {});
                                  //     });
                                  //   },
                                  //   child: const Text('Refresh'),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }

  void popupAlertmessage(String msg) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: AlertDialog(
              content: Text(
                msg,
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.black),
                    ))
              ],
            ),
          );
        });
  }

  Future<void> fetchUser() async {
    List<String> tempData = [];
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('members').get();

    if (querySnapshot.docs.isNotEmpty) {
      tempData = querySnapshot.docs.map((e) => e.id).toList();
    }
    for (var i = 0; i < tempData.length; i++) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('members')
          .doc(tempData[i])
          .get();
      if (documentSnapshot.data() != null) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        // String fullName = data['fullName'] + " " + data['userId'];
        String fullName = data['userId'];
        // print(fullName);
        userList.add(fullName);
      }
    }

    setState(() {});
  }

  Future<void> fetchServiceProvider() async {
    List<String> tempData = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('members')
        .where('role', isNotEqualTo: null)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      tempData = querySnapshot.docs.map((e) => e.id).toList();
    }
    for (var i = 0; i < tempData.length; i++) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('members')
          .doc(tempData[i])
          .get();
      if (documentSnapshot.data() != null) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        serviceProvider.add(data['fullName']);
      }
    }
    setState(() {});
  }

  Future<void> getTicketList() async {
    // final provider = Provider.of<AllRoomProvider>(context, listen: false);
    // provider.setBuilderList([]);
    try {
      ticketList.clear();
      int currentYear = DateTime.now().year;

      QuerySnapshot dateQuery =
          await FirebaseFirestore.instance.collection("raisedTickets").get();

      List<dynamic> dateList = dateQuery.docs.map((e) => e.id).toList();
      for (int j = 0; j < dateList.length; j++) {
        List<String> temp = [];
        QuerySnapshot ticketQuery = await FirebaseFirestore.instance
            .collection("raisedTickets")
            .doc(dateList[j])
            .collection('tickets')
            .get();
        temp = ticketQuery.docs.map((e) => e.id).toList();
        ticketList = ticketList + temp;
      }
    } catch (e) {
      print(e);
    }
    setState(() {});
  }

  Future<void> getBuilding() async {
    // final provider = Provider.of<AllBuildingProvider>(context, listen: false);
    // provider.setBuilderList([]);
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('buildingNumbers').get();
    if (querySnapshot.docs.isNotEmpty) {
      List<String> tempData = querySnapshot.docs.map((e) => e.id).toList();
      buildingNumberList = tempData;
      // provider.setBuilderList(buildingNumberList);
    }
    setState(() {});
  }

  Future<void> getFloor() async {
    // final provider = Provider.of<AllFloorProvider>(context, listen: false);
    // provider.setBuilderList([]);
    for (var i = 0; i < buildingNumberList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('buildingNumbers')
          .doc(buildingNumberList[i])
          .collection('floorNumbers')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        List<String> tempData = querySnapshot.docs.map((e) => e.id).toList();

        uniqueFloorList.addAll(tempData);
        Set<String> set = uniqueFloorList.toSet();
        floorNumberList = set.toList();
        // provider.setBuilderList(floorNumberList);
      }
    }
    print(floorNumberList);
    setState(() {});
  }

  Future<void> getRoom() async {
    List<String> uniqueRoomList = [];
    // final provider = Provider.of<AllRoomProvider>(context, listen: false);
    // provider.setBuilderList([]);
    for (var i = 0; i < buildingNumberList.length; i++) {
      for (var j = 0; j < floorNumberList.length; j++) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('buildingNumbers')
            .doc(buildingNumberList[i])
            .collection('floorNumbers')
            .doc(floorNumberList[j])
            .collection('roomNumbers')
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          List<String> tempData = querySnapshot.docs.map((e) => e.id).toList();
          uniqueRoomList.addAll(tempData);
          Set<String> set = uniqueRoomList.toSet();
          roomNumberList = set.toList();
          // provider.setBuilderList(roomNumberList);
        }
      }
    }

    print(roomNumberList);
    setState(() {});
  }

  Future<void> getAsset() async {
    List<String> uniqueAssetsList = [];
    // final provider = Provider.of<AllAssetProvider>(context, listen: false);
    // provider.setBuilderList([]);
    for (var i = 0; i < buildingNumberList.length; i++) {
      for (var j = 0; j < floorNumberList.length; j++) {
        for (var k = 0; k < roomNumberList.length; k++) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('buildingNumbers')
              .doc(buildingNumberList[i])
              .collection('floorNumbers')
              .doc(floorNumberList[j])
              .collection('roomNumbers')
              .doc(roomNumberList[k])
              .collection('assets')
              .get();
          if (querySnapshot.docs.isNotEmpty) {
            List<String> tempData =
                querySnapshot.docs.map((e) => e.id).toList();
            uniqueAssetsList.addAll(tempData);
            Set<String> set = uniqueAssetsList.toSet();
            assetList = set.toList();
            // provider.setBuilderList(assetList);
          }
        }
        setState(() {});
      }
    }
  }

  Future<void> getWorkList() async {
    // final provider = Provider.of<AllWorkProvider>(context, listen: false);
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('works').get();
    if (querySnapshot.docs.isNotEmpty) {
      List<String> tempData = querySnapshot.docs.map((e) => e.id).toList();
      allWorkData = tempData;
    }

    // provider.setBuilderList(allWorkData);
    setState(() {});
  }

  Widget customDropDown({
    // required String title,
    required List<String> customDropDownList,
    required String hintText,
    required int index,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    required TextEditingController searchController,
  }) {
    return Expanded(
      child: Card(
        elevation: 5.0,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: Text(
                    hintText,
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                  ),
                  items: customDropDownList
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ))
                      .toList(),
                  value: selectedValue,
                  onChanged: onChanged,
                  buttonStyleData: const ButtonStyleData(
                    decoration: BoxDecoration(),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 50,
                    width: double.infinity,
                  ),
                  dropdownStyleData: const DropdownStyleData(
                    maxHeight: 200,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                  ),
                  dropdownSearchData: DropdownSearchData(
                    searchController: searchController,
                    searchInnerWidgetHeight: 50,
                    searchInnerWidget: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          hintText: hintText,
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    searchMatchFn: (item, searchValue) {
                      return item.value.toString().contains(searchValue);
                    },
                  ),
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {
                      searchController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,

      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      saveText: "OK",
      // initialEntryMode: DatePickerEntryMode.input,
    );
    if (newDateRange == null) return;
    setState(() {
      dateRange = newDateRange;
      rangeStartDate = dateRange.start;
      rangeEndDate = dateRange.end;

      selectedStartDate = DateFormat('dd-MM-yyyy').format(rangeStartDate);
      // "${rangeStartDate.day.toString().padLeft(2, '0')}-${rangeStartDate.month.toString().padLeft(2, '0')}-${rangeStartDate.year.toString()} ";
      selectedEndDate = DateFormat('dd-MM-yyyy').format(rangeEndDate!);
      // "${rangeEndDate!.day.toString().padLeft(2, '0')}-${rangeEndDate!.month.toString().padLeft(2, '0')}-${rangeEndDate!.year.toString()} ";
      print('$selectedStartDate to $selectedEndDate');
    });
  }

  Future<void> filterTickets(String userID) async {
    // print('before $selectedUser');
    // selectedUser = selectedUser.toString().split(' ')[2];
    // print('selectedUse123r $selectedUser');
    try {
      // filterData.clear();
      // ticketList.clear();
      int currentYear = DateTime.now().year;

      QuerySnapshot monthQuery =
          await FirebaseFirestore.instance.collection("raisedTickets").get();
      List<dynamic> dateList = monthQuery.docs.map((e) => e.id).toList();
      for (int i = 0; i < dateList.length; i++) {
        if (selectedStartDate.isNotEmpty && selectedEndDate.isNotEmpty) {
          for (DateTime date = dateRange.start;
              date.isBefore(dateRange.end.add(Duration(days: 1)));
              date = date.add(Duration(days: 1))) {
            String currentDate = DateFormat('dd-MM-yyyy').format(date);

            List<dynamic> temp = [];
            QuerySnapshot ticketQuery = await FirebaseFirestore.instance
                .collection("raisedTickets")
                .doc(currentDate)
                .collection('tickets')
                .where('user', isEqualTo: widget.userID)
                .where('date', isEqualTo: currentDate.trim())
                // .where('date', isLessThanOrEqualTo: selectedEndDate.trim())
                .get();

            temp = ticketQuery.docs.map((e) => e.id).toList();
            // ticketList = ticketList + temp;

            if (temp.isNotEmpty) {
              ticketList = ticketList + temp;
              for (int k = 0; k < temp.length; k++) {
                DocumentSnapshot ticketDataQuery = await FirebaseFirestore
                    .instance
                    .collection("raisedTickets")
                    .doc(currentDate)
                    .collection('tickets')
                    .doc(temp[k])
                    .get();
                if (ticketDataQuery.exists) {
                  Map<String, dynamic> mapData =
                      ticketDataQuery.data() as Map<String, dynamic>;
                  filterData.add(mapData);
                  print('$mapData filtered data');
                }
              }
            }
          }
        } else {
          QuerySnapshot dateQuery = await FirebaseFirestore.instance
              .collection("raisedTickets")
              .get();
          List<dynamic> dateList = dateQuery.docs.map((e) => e.id).toList();
          for (int j = 0; j < dateList.length; j++) {
            List<dynamic> temp = [];
            Query query = FirebaseFirestore.instance
                .collection("raisedTickets")
                .doc(dateList[j])
                .collection('tickets');
            if (selectedStatus != null) {
              query = query.where('status', isEqualTo: selectedStatus);
            }
            if (selectedFloor != null) {
              query = query.where('floor', isEqualTo: selectedFloor);
            }
            if (selectedTicket != null) {
              query = query.where('tickets', isEqualTo: selectedTicket);
            }
            if (selectedRoom != null) {
              query = query.where('room', isEqualTo: selectedRoom);
            }
            if (selectedWork != null) {
              query = query.where('work', isEqualTo: selectedWork);
            }
            if (selectedAsset != null) {
              query = query.where('asset', isEqualTo: selectedAsset);
            }
            if (selectedbuilding != null) {
              query = query.where('building', isEqualTo: selectedbuilding);
            }
            if (selectedServiceProvider != null) {
              query = query.where('serviceProvider',
                  isEqualTo: selectedServiceProvider);
            }
            QuerySnapshot ticketQuery = await query.get();
            //await FirebaseFirestore.instance
            //     .collection("raisedTickets")
            //     .doc(currentYear.toString())
            //     .collection('months')
            //     .doc(months[i])
            //     .collection('date')
            //     .doc(dateList[j])
            //     .collection('tickets')
            //     .where('work', isEqualTo: selectedWork) // Filter by work
            //     .where('status', isEqualTo: selectedStatus) // Filter by work
            //     .where('serviceProvider',
            //         isEqualTo: selectedServiceProvider) // Filter by work
            //     .where('building',
            //         isEqualTo: selectedbuilding) // Filter by work
            //     .where('floor', isEqualTo: selectedFloor) // Filter by work
            //     .where('room', isEqualTo: selectedRoom) // Filter by work
            //     .where('asset', isEqualTo: selectedAsset) // Filter by work
            //     .where('tickets', isEqualTo: selectedTicket) // Filter by work
            //     .get();

            temp = ticketQuery.docs.map((e) => e.id).toList();
            // ticketList = ticketList + temp;
            print('Temp String $temp');

            if (temp.isNotEmpty) {
              ticketList = ticketList + temp;
              for (int k = 0; k < temp.length; k++) {
                DocumentSnapshot ticketDataQuery = await FirebaseFirestore
                    .instance
                    .collection("raisedTickets")
                    .doc(dateList[j])
                    .collection('tickets')
                    .doc(temp[k])
                    .get();
                if (ticketDataQuery.exists) {
                  Map<String, dynamic> mapData =
                      ticketDataQuery.data() as Map<String, dynamic>;

                  filterData.add(mapData);
                  print('$mapData abc');
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error Fetching tickets: $e");
    }
  }
}
