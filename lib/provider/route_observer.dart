import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticket_management_system/provider/filter_provider.dart';

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  // void didPopNext() {
  //   // Trigger this when navigating back to the current page
  //   Provider.of<FilterProvider>(context, listen: false)
  //       .updateUserSeen(widget.userID);
  // }
}
