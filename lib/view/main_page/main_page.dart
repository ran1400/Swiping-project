

// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:swiping_project/model/data_structures/login_user.dart';
import 'package:swiping_project/view/main_page/tab_layout.dart';
import 'package:swiping_project/view_model/main_page_view_model.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget
{
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
{
  MainPageViewModel mainPageViewModel = GetIt.instance<MainPageViewModel>();

  @override
  initState() /////-----for test------//////
  {
    super.initState();
    //doTest();
  }

  void _showSnackBar({int durationSeconds = 3})
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mainPageViewModel.snackBar!,
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: durationSeconds),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80, //because the navigation bar
                                left: 20,right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    mainPageViewModel.theSnackBarIsOnScreen();
  }

  void _checkIfShowSnackBar()
  {
    if (mainPageViewModel.snackBar != null)
      _showSnackBar();
  }

  @override
  Widget build(BuildContext context)
  {
    MainPageViewModel mainPageViewModel = context.watch<MainPageViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_){_checkIfShowSnackBar();});
    return Scaffold(
                 body : SafeArea(child: mainPageViewModel.pageToShow == PageToShow.loginPage
                                ? mainPageViewModel.createLoginPage()
                                : TabLayout()
                                )
           );
  }



  void doTest()
  {
    MainPageViewModel mainPageViewModel = GetIt.instance<MainPageViewModel>();
    LoginUser.userId = 1;
    LoginUser.uuid = "";
    LoginUser.userMail ="";
    LoginUser.completeProfile = false;
    LoginUser.visible = false;
    LoginUser.completePreferences = false;
    mainPageViewModel.checkWhereToMove();
  }

}


