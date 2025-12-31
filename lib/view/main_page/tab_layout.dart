import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:swiping_project/view_model/main_page_view_model.dart';



class TabLayout extends StatefulWidget
{
  const TabLayout({super.key});

  @override
  State<TabLayout> createState() => _TabLayoutState();

}

class _TabLayoutState extends State<TabLayout>
{
  late MainPageViewModel mainPageViewModel;


  void _onItemTapped(int index)
  {
    HapticFeedback.selectionClick();
    PageToShow moveToPage = PageToShow.fromInt(index);
    mainPageViewModel.moveToPage(moveToPage);
  }

  @override
  Widget build(BuildContext context)
  {
    mainPageViewModel = context.watch<MainPageViewModel>();

    return Scaffold(resizeToAvoidBottomInset: false
                    ,body:
                        switch(mainPageViewModel.pageToShow)
                        {
                          PageToShow.matchesPage => mainPageViewModel.createMatchesPage(),
                          PageToShow.preferencesPage => mainPageViewModel.createPreferencesPage(),
                          PageToShow.profilePage => mainPageViewModel.createProfilePage(),
                          PageToShow.settingPage => mainPageViewModel.createSettingPage(),
                          _ => mainPageViewModel.createSwipePage(),
                        },
                        bottomNavigationBar: _buildNavigationBar()
                  );
  }

  Widget _buildNavigationBar()
  {
      return BottomNavigationBar(
        currentIndex: mainPageViewModel.pageToShow.value,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Ionicons.heart_outline),
            label: 'מאצים',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.swap_horizontal_outline),
            label: 'Swipe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.person_circle_outline),
            label: 'פרופיל',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.options_outline),
            label: 'העדפות',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.settings_outline),
            label: 'הגדרות',
          ),
        ],
      );
  }

}

