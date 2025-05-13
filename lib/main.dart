import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pixora/app.dart';
import 'package:pixora/config/firebase_options.dart';


void main() async {
  //firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  //runApp
  runApp( MyApp());
}

  
