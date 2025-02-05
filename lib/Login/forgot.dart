import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ticket_management_system/utils/colors.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  TextEditingController numberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appColor,
        title: Text(
          "Forgot Passowrd",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.09),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Card(
            elevation: 30,
            child: Form(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: numberController,
                    decoration: InputDecoration(
                        labelText: 'Enter Your Register Mobile No.',
                        hintText: 'Enter your UserID',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your UserID';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: appColor),
                    onPressed: () {
                      retrivePassword(numberController.text, context);
                    },
                    child: const Text(
                      "Retrive Password",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ))
              ],
            )),
          ),
        ),
      ),
    );
  }

  Future<void> retrivePassword(
      String mobileNumber, BuildContext context) async {
    try {
      final userDoc = await firestore
          .collection('members')
          .where('mobile', isEqualTo: mobileNumber)
          .get();
      // .doc(userID).get();
      if (userDoc.docs.isNotEmpty) {
        final mobileNo = userDoc.docs[0]['mobile'];
        if (numberController.text == mobileNo) {
          SnackBar snackBar = const SnackBar(
            backgroundColor: Colors.green,
            content: Center(
              child: Text(
                  'Your Password has been sent to your Register Mobile no.'),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        SnackBar snackBar = const SnackBar(
          backgroundColor: Colors.red,
          content: Center(
            child: Text(
                'Entered Mobile Number Not Registered Please Contact Your Admin'),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print('Error: $e');
      SnackBar snackBar = const SnackBar(
          backgroundColor: Colors.red,
          content: Center(
            child: Text('An error occured. Please try again.'),
          ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
