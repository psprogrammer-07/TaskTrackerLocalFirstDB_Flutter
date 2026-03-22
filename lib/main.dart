import 'package:crud_elf/db/dataBaseServices.dart';
import 'package:crud_elf/screens/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
   await dotenv.load(fileName:".env");
   await Hive.initFlutter();
   Hive.registerAdapter(TaskAdapter());
   var box=await Hive.openBox('tasksBox');
   
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
      
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Homescreen(),
    );
  }
}
