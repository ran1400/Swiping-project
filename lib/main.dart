

// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:swiping_project/view/main_page/main_page.dart';
import 'package:swiping_project/view_model/main_page_view_model.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';



void main() async
{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    MainPageViewModel mainPageViewModel = MainPageViewModel();
    GetIt.instance.registerSingleton(mainPageViewModel);
    runApp( ChangeNotifierProvider.value(value : mainPageViewModel, child: MyApp()) );
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test swiping app',

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.pinkAccent,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.pinkAccent,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.pinkAccent,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.pinkAccent,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
        ),
      ),

      home: MainPage(),
    );
  }
}