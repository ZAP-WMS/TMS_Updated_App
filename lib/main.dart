import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:ticket_management_system/provider/filter_provider.dart';
import 'package:ticket_management_system/provider/getReport_provider.dart';
import 'package:ticket_management_system/provider/notification_provider.dart';
import 'package:ticket_management_system/provider/pieChart_provider.dart';
import 'package:ticket_management_system/provider/raisedata_provider.dart';
import 'package:ticket_management_system/screens/splash.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyA6-g-Dbb6c5B_hFhGvANlznlixlPgKx6k",
        authDomain: "tmsapp-53ebc.firebaseapp.com",
        projectId: "tmsapp-53ebc",
        storageBucket: "tmsapp-53ebc.appspot.com",
        messagingSenderId: "190167031121",
        appId: "1:190167031121:android:f2cd05b74edb7dd581c770",
        measurementId: "G-88TQTEM40C"),
  );

  await FlutterDownloader.initialize(
      debug: true // Set this to false in production
      );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PiechartProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => FilterProvider()),
        ChangeNotifierProvider(create: (context) => RaiseDataProvider()),
        ChangeNotifierProvider(create: (context) => ReportProvider()),
      ],
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        debugShowCheckedModeBanner: false,
        title: 'TMS APP',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home:
            //Report2(),
            // Report1(),
            // Imagepick(),
            //PieChartWidget(),
            //     pendingstatus(
            //   Number: '#1077',
            // ),
            // pending(),
            //     Raise(
            //   userID: '',
            // ),
            //report1(),
            //     pendingstatus(
            //   Number: '',
            //   key: Key(''),
            // )
            //HomeScreen(userID: 'AX3265'),
            //     spliScreen(
            //   userID: 'RT0969',
            // )
            // const FilteredReport(),
            // dash(),
            //     Homeservice(
            //   userID: '',
            // ),
            //     ReportTicketScreen(
            //   asset: '',
            //   work: '',
            //   building: '',
            //   floor: '',
            //   remark: '',
            //   room: '',
            //   ticketNo: '',
            // ),
            // pendingstatus_service(
            //   Number: '68',
            // ),
            //service_pending(),
            // LoginService()
            //serviceSignup()
            //const LoginPage(),
            // SignupPage(),
            SpalashScreen(),
      ),
    );
  }
}
