import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_management_system/provider/raisedata_provider.dart';
import 'package:ticket_management_system/screens/image.dart';
import '../provider/filter_provider.dart';
import '../utils/colors.dart';
import 'package:http/http.dart' as http;

class Raise extends StatefulWidget {
  Raise({super.key, required this.userID});
  String userID;

  @override
  State<Raise> createState() => _RaiseState();
}

class _RaiseState extends State<Raise> {
  final workController = TextEditingController();
  final buildingController = TextEditingController();
  final floorController = TextEditingController();
  final roomController = TextEditingController();
  final assetController = TextEditingController();
  final remarkController = TextEditingController();

  String serviceProviders = 'N/A';
  String? serviceProvidersId;
  List<String> workOptions = [];
  List<String> buildingOptions = [];
  List<String> floorOptions = [];
  List<String> roomOptions = [];
  List<String> assetOptions = [];
  //List<String> serviceOptions = [];

  String? selectedServiceProvider;
  String? _selectedWork;
  String? _selectedBuilding;
  String? _selectedFloor;
  String? _selectedRoom;
  String? _selectedAsset;
  String ticketID = '';
  String? selectedBuildingNo = '';
  String? selectedFloorNo = '';
  // List<Asset> images = <Asset>[];
  final _formKey = GlobalKey<FormState>();
  FilePickerResult? result;
  List<String>? Imagenames = [];
  XFile? file;
  List<File>? filepath = [];
  List<String> images = [];
  late final FilterProvider filterProvider;

  @override
  void initState() {
    filterProvider = Provider.of<FilterProvider>(context, listen: false);
    // getBuilding().whenComplete(() {
    //   getFloor().whenComplete(() {
    //     getRoom().whenComplete(() {
    //       getAsset().whenComplete(() {
    //         setState(() {});
    //       });
    //     });
    //   });
    // });
    // super.initState();
    // getWork();
    // fetchServiceProvider();
    //getService();
  }

  @override
  void dispose() {
    workController.dispose();
    buildingController.dispose();
    floorController.dispose();
    roomController.dispose();
    assetController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<RaiseDataProvider>(context);

    // Fetch data when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataProvider.fetchData();
    });
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Raise Ticket',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              _getCurrentDate(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 197, 66, 73),
      ),
      body: Consumer<RaiseDataProvider>(
        builder: (context, provider, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              bool isLandscape = constraints.maxWidth > constraints.maxHeight;
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              elevation: 3,
                              margin: const EdgeInsets.all(4.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: DropdownButtonFormField(
                                        value: provider.selectedWork,
                                        items: provider.workData
                                            .map((String option) {
                                          return DropdownMenuItem<String>(
                                            value: option,
                                            child: Text(option),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          _selectedWork = value;
                                          provider.setSelectedWork(
                                              value.toString());

                                          filterProvider.fetchFcmID(
                                              provider.selectedWork.toString());
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Work',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'This field is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: DropdownButtonFormField(
                                        value: provider.selectedBuilding,
                                        items: provider.buildingOption
                                            .map((String option) {
                                          return DropdownMenuItem<String>(
                                            value: option,
                                            child: Text(option),
                                          );
                                        }).toList(),
                                        onChanged: (value) async {
                                          floorOptions.clear();
                                          selectedBuildingNo = value;
                                          _selectedBuilding = value;
                                          provider.setSelectedBuilding(
                                              selectedBuildingNo.toString());
                                          // setState(() {
                                          //   _selectedBuilding = value;
                                          //   getFloor();
                                          // });
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Building',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'This field is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: DropdownButtonFormField(
                                        value: provider.selectedFloor,
                                        items: provider.floorOption
                                            .map((String option) {
                                          return DropdownMenuItem<String>(
                                            value: option,
                                            child: Text(option),
                                          );
                                        }).toList(),
                                        onChanged: (value) async {
                                          _selectedFloor = value;
                                          provider.setSelectedFloor(
                                              _selectedFloor.toString());
                                          // setState(() {
                                          //   _selectedFloor = value;
                                          //   getRoom();
                                          // });
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Floor',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'This field is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: DropdownButtonFormField(
                                        value: provider.selectedRoom,
                                        items: provider.roomOption
                                            .map((String option) {
                                          return DropdownMenuItem<String>(
                                            value: option,
                                            child: Text(option),
                                          );
                                        }).toList(),
                                        onChanged: (value) async {
                                          roomOptions.clear;
                                          _selectedRoom = value;
                                          provider.setSelectedRoom(
                                              _selectedRoom.toString());
                                          // setState(() {
                                          //   _selectedRoom = value;
                                          //   getAsset();
                                          // });
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Room',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'This field is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: DropdownButtonFormField(
                                        value: provider.selectedAsset,
                                        items: provider.assetOption
                                            .map((String option) {
                                          return DropdownMenuItem<String>(
                                            value: option,
                                            child: Text(option),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          _selectedAsset = value;
                                          provider.setSelectedAsset(
                                              _selectedAsset.toString());
                                          // setState(() {
                                          //   _selectedAsset = value;
                                          // });
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Asset',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'This field is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: TextField(
                                        maxLength: 60,
                                        controller: remarkController,
                                        maxLines: null,
                                        decoration: InputDecoration(
                                          hintText: 'Remarks',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      height: constraints.maxHeight / 3,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (Imagenames != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Center(
                                      child: Text(
                                        'Selected file:',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      height: 100,
                                      width: 500,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount: Imagenames!.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ImageScreen(
                                                              pageTitle:
                                                                  'raisePage',
                                                              imageFile:
                                                                  Imagenames![
                                                                      index],
                                                              imageFiles:
                                                                  Imagenames!,
                                                              initialIndex:
                                                                  index,
                                                              ticketId:
                                                                  ticketID,
                                                            )));
                                              },
                                              child: Center(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.blue),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Image.file(
                                                      File(Imagenames![index])),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: appColor,
                                      ),
                                      onPressed: () async {
                                        result = await FilePicker.platform
                                            .pickFiles(
                                                withData: true,
                                                type: FileType.any,
                                                allowMultiple: true);
                                        if (result == null) {
                                          print('No file selected');
                                        } else {
                                          result?.files.forEach((element) {
                                            print(element.name);

                                            Imagenames!
                                                .add(element.path.toString());
                                            var filedata =
                                                File(element.path.toString());
                                            filepath!.add(filedata);
                                          });
                                          setState(() {});
                                        }
                                      },
                                      child: const Text('Pick Images')),
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: appColor,
                                    ),
                                    onPressed: () async {
                                      final ImagePicker picker = ImagePicker();
                                      file = await picker.pickImage(
                                          source: ImageSource.camera);

                                      if (file != null) {
                                        setState(() {
                                          Imagenames!.add(file!.path);
                                          var filedata = File(file!.path);
                                          filepath!.add(filedata);
                                          //  filepath = File(Imagenames[0]);
                                        });
                                      }
                                    },
                                    child: const Text('Capture Images')),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: appColor,
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (context) =>
                                              CupertinoAlertDialog(
                                            content: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: const [
                                                SizedBox(
                                                  height: 50,
                                                  width: 50,
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    151,
                                                                    64,
                                                                    69)),
                                                  ),
                                                ),
                                                Text(
                                                  'Saving...',
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 151, 64, 69),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.center,
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                        await generateTicketID();
                                        fetchServiceProvider()
                                            .whenComplete(() async {
                                          await uploadFile(ticketID);
                                          await storeRaisedTicket(ticketID)
                                              .whenComplete(() async {
                                            sendNotificationViaGet(
                                                'https://dalmia-yppj.onrender.com/not',
                                                filterProvider.tokenId
                                                    .toString(),
                                                'hii abdul',
                                                'api is working');

                                            provider.resetSelections();
                                            remarkController.clear();
                                            images.clear();
                                            Imagenames!.clear();

                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    backgroundColor: appColor,
                                                    content: const Text(
                                                        'Your ticket has been raised successfully!!!')));
                                          });
                                        });
                                      }
                                    },
                                    child: const Text('Save'))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return '${now.year}-${_addLeadingZero(now.month)}-${_addLeadingZero(now.day)}';
  }

  String _addLeadingZero(int number) {
    return number.toString().padLeft(2, '0');
  }

  Future<String> generateTicketID() async {
    String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    int currentYear = DateTime.now().year;

    String currentMonth = DateFormat('MMM').format(DateTime.now());

    QuerySnapshot doc = await FirebaseFirestore.instance
        .collection("raisedTickets")
        // .doc(currentYear.toString())
        // .collection('months')
        // .doc(currentMonth.toString())
        // .collection('date')
        .doc(date)
        .collection('tickets')
        .get();

    int lastTicketID = 1;
    if (doc.docs.isNotEmpty) {
      lastTicketID = doc.docs.length + 1;
    }

    DateTime now = DateTime.now();

    String formattedDate = "${now.year.toString().padLeft(4, '0')}"
        "${now.month.toString().padLeft(2, '0')}"
        "${now.day.toString().padLeft(2, '0')}";

    String formattedTicketNumber = lastTicketID.toString().padLeft(2, '0');

    // Generate the next ticket ID
    // int nextTicketID = lastTicketID + 1;
    // String ticketID = '#$nextTicketID';

    // int timestamp = DateTime.now().millisecondsSinceEpoch;
    // int random = Random().nextInt(9999);
    ticketID = "$formattedDate.$formattedTicketNumber";
    return ticketID;
  }

  Future<void> getBuilding() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('buildingNumbers').get();
    if (querySnapshot.docs.isNotEmpty) {
      List<String> tempData = querySnapshot.docs.map((e) => e.id).toList();
      setState(() {
        buildingOptions = tempData;
      });
    }
  }

  Future<void> getFloor() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('buildingNumbers')
        .doc(_selectedBuilding)
        .collection('floorNumbers')
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      List<String> tempData = querySnapshot.docs.map((e) => e.id).toList();
      setState(() {
        floorOptions = tempData;
      });
      print(floorOptions);
    }
  }

  Future<void> getRoom() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('buildingNumbers')
        .doc(_selectedBuilding)
        .collection('floorNumbers')
        .doc(_selectedFloor)
        .collection('roomNumbers')
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      List<String> tempData = querySnapshot.docs.map((e) => e.id).toList();
      setState(() {
        roomOptions = tempData;
      });
      print(roomOptions);
    }
  }

  Future<void> getAsset() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('buildingNumbers')
        .doc(_selectedBuilding)
        .collection('floorNumbers')
        .doc(_selectedFloor)
        .collection('roomNumbers')
        .doc(_selectedRoom)
        .collection('assets')
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      List<String> tempData = querySnapshot.docs.map((e) => e.id).toList();
      setState(() {
        assetOptions = tempData;
      });
    }
  }

  Future<void> getWork() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('works').get();
    if (querySnapshot.docs.isNotEmpty) {
      List<String> tempData = querySnapshot.docs.map((e) => e.id).toList();
      setState(() {
        workOptions = tempData;
      });
    }
    setState(() {});
  }

  Future<void> fetchServiceProvider() async {
    List<String> tempData = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('members')
        .where('role', arrayContains: _selectedWork)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      tempData = querySnapshot.docs.map((e) => e.id).toList();
      serviceProviders = tempData[0];

      try {
        // Fetch the document from Firestore
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('members')
            .doc(serviceProviders)
            .get();

        if (documentSnapshot.exists) {
          // Extract data from the document
          Map<String, dynamic>? data =
              documentSnapshot.data() as Map<String, dynamic>?;

          if (data != null) {
            // Access specific fields from the data map
            serviceProvidersId = data['userId'];
            print('Name: $serviceProvidersId');
            // Handle other fields as needed
          } else {
            print('Document data is null');
          }
        } else {
          print('Document does not exist');
        }
      } catch (e) {
        print('Error fetching document: $e');
      }
    }

    setState(() {});
  }

  Future<void> storeRaisedTicket(String ticketID) async {
    String userName = await fetchName(widget.userID);
    // fetchServiceProvider();
    String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    int currentYear = DateTime.now().year;

    String currentMonth = DateFormat('MMM').format(DateTime.now());

    List<String> imageFilePaths =
        await _saveImagesToPersistentStorage(Imagenames!);

    await FirebaseFirestore.instance
        .collection("raisedTickets")
        // .doc(currentYear.toString())
        // .collection('months')
        // .doc(currentMonth.toString())
        // .collection('date')
        .doc(date)
        .collection('tickets')
        .doc(ticketID)
        .set({
      "month": currentMonth,
      "year": currentYear,
      "work": _selectedWork,
      "building": _selectedBuilding,
      "floor": _selectedFloor,
      "room": _selectedRoom,
      "asset": _selectedAsset,
      "remark": remarkController.text,
      "serviceProvider": serviceProviders,
      "serviceProviderId": serviceProvidersId,
      "imageFilePaths": images,
      "date": date,
      "user": widget.userID,
      'status': 'Open',
      "tickets": ticketID,
      "isSeen": true,
      "name": userName
    }).whenComplete(() {
      addNotification(
          widget.userID,
          filterProvider.serviceProviderId.toString(),
          userName,
          filterProvider.serviceProviderName.toString(),
          ticketID,
          DateTime.now().toString());
      print("Data Stored Successfully");
    });
    await FirebaseFirestore.instance.collection("raisedTickets").doc(date).set({
      "raisedTickets": date,
    });
    // await FirebaseFirestore.instance
    //     .collection("raisedTickets")
    //     .doc(date)
    //     .collection('tickets')
    //     .doc(ticketID.toString())
    //     .set({
    //   "months": currentMonth,
    // });
  }

  Future<String> fetchName(String userID) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("members")
        .where('userId', isEqualTo: userID)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      List<dynamic> tempData = querySnapshot.docs.map((e) => e.id).toList();
      return tempData[0];
    } else {
      return '';
    }
  }

  Future<void> uploadFile(String id) async {
    try {
      String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      int currentYear = DateTime.now().year;

      String currentMonth = DateFormat('MMM').format(DateTime.now());
      TaskSnapshot taskSnapshot;
      // ignore: duplicate_ignore
      if (filepath != null) {
        List<String> url = [];
        for (int i = 0; i < filepath!.length; i++) {
          taskSnapshot = await FirebaseStorage.instance
              .ref('Images/')
              .child(id)
              .child(filepath![i].path.split('/').last)
              .putData(filepath![i].readAsBytesSync());

          final downloadURL = await taskSnapshot.ref.getDownloadURL();
          images.add(downloadURL);
          url.add(downloadURL);
        }

        await FirebaseFirestore.instance
            .collection("raisedTickets")
            .doc(currentYear.toString())
            .collection('months')
            .doc(currentMonth.toString())
            .collection('date')
            .doc(date)
            .collection('tickets')
            .doc(id)
            .update({
          "imageFilePaths": url,
        });
      } else {
        throw Exception('File bytes are null');
      }
    } on FirebaseException catch (e) {
      print('Failed to upload PDF file: $e');
    }
  }

  Future<List<String>> _saveImagesToPersistentStorage(
      List<String> imagePaths) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    List<String> savedPaths = [];
    for (String path in imagePaths) {
      File tempfile = File(path);
      String fileName = path.split('/').last;
      String newPath = '$appDocPath/$fileName';
      await tempfile.copy(newPath);
      savedPaths.add(newPath);
    }
    return savedPaths;
  }

  Future<bool> _requestGalleryPermission() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery permission denied')),
      );
      return false;
    }
    return true;
  }

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission denied')),
      );
      return false;
    }
    return true;
  }

  Future<void> popupmessage(String msg) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: AlertDialog(
              content: Text(
                msg,
                style: const TextStyle(fontSize: 14, color: Colors.green),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => HomeScreen(
                      //               userID: widget.userID,
                      //             )));
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.green),
                    ))
              ],
            ),
          );
        });
  }

  void clearData() {
    _selectedWork = null;
    _selectedBuilding = null;
    _selectedFloor = null;
    _selectedRoom = null;
    _selectedAsset = null;
    remarkController.clear();
    _selectedFloor = null;
    images.clear();
    Imagenames!.clear();
  }

  Future<void> sendNotificationViaGet(
      String url, String token, String title, String message) async {
    // Define the query parameters
    final queryParameters = {
      'token': token,
      'title': title,
      'message': message,
    };

    // Construct the URI with query parameters
    final uri = Uri.parse(url).replace(queryParameters: queryParameters);
    print(uri);

    try {
      // Perform the GET request with headers
      final response = await http.get(uri);
      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the response body if needed
        final data = response.body;
        print('Response data: $data');
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> addNotification(String userId, String serviceId, String userName,
      String serviceName, String ticketId, String timeStamp) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Generate the timestamp on the client side
    DateTime now = DateTime.now();
    Timestamp timestamp = Timestamp.fromDate(now);

    // Define the new notification data
    Map<String, dynamic> newNotification = {
      'userID': userId,
      'serviceProviderId': serviceId,
      'isServiceProviderSeen': true,
      'userName': userName,
      'serviceProviderName': serviceName,
      'TicketId': ticketId,
      'timestamp': timestamp,
    };

    // Reference to the Firestore document
    DocumentReference userDoc =
        firestore.collection('notifications').doc(userId);

    // Add the new notification to the array
    try {
      await userDoc.set({
        'notifications': FieldValue.arrayUnion([newNotification])
      }, SetOptions(merge: true));
      print('Notification added successfully');
    } catch (e) {
      print('Failed to add notification: $e');
    }
  }
}
