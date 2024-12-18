import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ticket_management_system/widget/loading_page.dart';

void showSavingDialog(BuildContext context, String title) {
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
                width: 50,
                child: Center(
                  child: LoadingPage(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                    color: Color.fromARGB(255, 151, 64, 69),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    ),
  );
}
