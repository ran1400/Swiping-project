import 'package:flutter/material.dart';
import 'package:swiping_project/view_model/utils/view_model_in_the_tab_layout.dart';

Widget loadingPage()
{
  return const Scaffold(
    body: Center(
      child: CircularProgressIndicator(color: Colors.red),
    ),
  );
}

Widget errorPage(ErrorPageDS error)
{
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error.msg,
            style: TextStyle(color: Colors.red, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (error.retryBtn != null)
            ElevatedButton(
              onPressed: error.retryBtn,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text(
                'נסה לטעון שוב',
                style: TextStyle(color: Colors.white),
              ),
            )
        ],
      ),
    ),
  );
}
