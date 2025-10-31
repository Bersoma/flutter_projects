//import 'package:aparte/pages/detail_page.dart';
//import 'package:aparte/pages/bottomnav.dart';
//import 'package:aparte/hotelowner/hotel.detail.dart';
import 'package:aparte/hotelowner/owner_home.dart';
import 'package:aparte/pages/onboarding.dart';
import 'package:aparte/services/constant.dart';
//import 'package:aparte/pages/login.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

//import 'package:aparte/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:aparte/pages/login.dart';
//import 'package:aparte/pages/signup.dart';
//import 'package:aparte/pages/home.dart';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    providerAndroid: AndroidDebugProvider(),
  );
  Stripe.publishableKey = publishablekey;
  await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: OwnerHome(),
    );
  }
}
