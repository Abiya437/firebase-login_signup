import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBIZxkWw9_N6zu21cvdBPuyb8m3It7uCl8',
        appId: "1:473908382113:android:4a151a162afb5a6f9463e0",
        projectId: "treegreentask",
        messagingSenderId: '473908382113',
        storageBucket: "gs://treegreentask.appspot.com",
      ));
  runApp(const MyApp());
}

