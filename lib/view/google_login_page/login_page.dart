
// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:provider/provider.dart';
import 'package:swiping_project/view/utils.dart';

import 'package:swiping_project/view_model/login_page_view_model.dart';

class LoginPage extends StatefulWidget
{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
{
  final LoginPageViewModel _loginPageViewModel = GetIt.instance<LoginPageViewModel>();

  void _showSnackBar({int durationSeconds = 2})
  {
    ScaffoldMessenger.of(context).showSnackBar
      (
      SnackBar(
        content: Text(_loginPageViewModel.msg!),
        duration: Duration(seconds: durationSeconds),
      ),
    );
    _loginPageViewModel.theMsgIsOnScreen();
  }

  void _checkIfShowSnackBar()
  {
    if (_loginPageViewModel.msg != null)
      _showSnackBar();
  }

  @override
  Widget build(BuildContext context)
  {
    LoginPageViewModel loginPageViewModel = context.watch<LoginPageViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_){_checkIfShowSnackBar();});
    if (loginPageViewModel.loading)
      return loadingPage();
    return Scaffold(
                  body: Center(
                                child:
                                      ElevatedButton(
                                        onPressed: loginPageViewModel.loginBtnPressed,
                                        child: const Text('התחבר עם גוגל'),
                                      )
                            ),
                  );
  }
}
