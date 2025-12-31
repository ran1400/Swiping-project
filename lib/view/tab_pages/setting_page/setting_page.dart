
// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:swiping_project/view/tab_pages/view_in_the_tab_layout.dart';

import 'package:swiping_project/view_model/tab_layout_view_models/setting_page_view_model.dart';

import 'package:swiping_project/view/utils.dart';

import 'package:swiping_project/model/data_structures/user_setting.dart';

class SettingPage extends StatefulWidget
{
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}


class _SettingPageState extends State<SettingPage> with ViewInTheTabLayout
{

  final SettingPageViewModel _settingPageViewModel = GetIt.instance<SettingPageViewModel>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState()
  {
    super.initState();
    _settingPageViewModel.pageIsInit();
  }

  @override
  void dispose()
  {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    SettingPageViewModel settingPageViewModel = context.watch<SettingPageViewModel>();
    initViewInTheTabLayout(context,settingPageViewModel);
    WidgetsBinding.instance.addPostFrameCallback((_) { checkIfShowSnackBar(); });

    if (settingPageViewModel.loading)
      return loadingPage();

    if (settingPageViewModel.error != null)
      return errorPage(settingPageViewModel.error!);


    return Scaffold(
        body: RefreshIndicator(
          onRefresh: () async => settingPageViewModel.getUserSettingFromTheServer(),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end,
                    children: [Padding(padding: const EdgeInsets.only(right: 15,top: 10),child: _buildSignOutButton())]
                ),
                const SizedBox(height: 25),
                _buildShowMyProfileCheckBox(),
                _buildGetUpdatesCheckBox(),
                const SizedBox(height: 25),
                _buildGetMailAreaWrapper(),
                const SizedBox(height: 25),
                _buildSaveBtn(),
                const SizedBox(height: 25),
              ],
            ),
            ),
          ),
        )
        );
  }

  Widget _buildSaveBtn()
  {
    return ElevatedButton(
      onPressed: _settingPageViewModel.saveBtnPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        minimumSize: const Size(150, 50),
      ),
      child: const Text("שמור", style: TextStyle(fontSize: 16),),
    );
  }

  Widget _buildGetMailAreaWrapper()
  {
    return Stack(
      children: [
        _buildGetMailArea(),

        if (! _settingPageViewModel.userWantToGetUpdates)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _settingPageViewModel.showSnackBar("קודם צריך לאשר קבלת עדכונים"),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
      ],
    );

  }

  Widget _buildGetMailArea()
  {
      return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildChooseMailEditText(),
              const SizedBox(height: 12),
              const Text('כל יום'),
              const SizedBox(height: 6),
             _buildChooseDayDropDown(),
              const SizedBox(height: 12),
              const Text('בשעה'),
              const SizedBox(height: 6),
              _buildChooseHourDropDown()
            ],
          ),
        ),
    );
  }

  Widget _buildChooseMailEditText()
  {
    return TextFormField(
      initialValue: _settingPageViewModel.mail,
      keyboardType: TextInputType.emailAddress,
      textDirection: TextDirection.ltr,
      decoration: const InputDecoration(
        labelText: 'המייל שלך',
        border: OutlineInputBorder(),
      ),
      onChanged: _settingPageViewModel.setMail,
    );
  }

  Widget _buildChooseDayDropDown()
  {
    return  DropdownButtonFormField<int>(
      initialValue: _settingPageViewModel.selectedDay,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items:  DayOfWeek.values.map((day) =>
              DropdownMenuItem(
                value: day.serverCode,
                child: Text(day.name),
              )).toList(),
      onChanged: _settingPageViewModel.setDay,
    );
  }

  Widget _buildChooseHourDropDown()
  {
    return DropdownButtonFormField<int>(
      initialValue: _settingPageViewModel.selectedHour,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: UserSetting.getHoursMap().entries.map((hour)
      {
        return DropdownMenuItem(value: hour.key, child: Text(hour.value));
      }).toList(),
      onChanged: _settingPageViewModel.setHour,
      validator: (v) => v == null ? 'יש לבחור שעה' : null,
    );
  }

  Widget _buildGetUpdatesCheckBox()
  {
    String label = "אני רוצה לקבל עדכונים למייל";
    bool value = _settingPageViewModel.userWantToGetUpdates;
    Function(bool) onChanged = _settingPageViewModel.userWantGetUpdatesChanged;
    return _buildCheckBox(label, onChanged, value);
  }

  Widget _buildShowMyProfileCheckBox()
  {
    String label = "הצג את הפרופיל שלי למשתמשים אחרים";
    bool value = _settingPageViewModel.showProfileChecked;
    Function(bool) onChanged = _settingPageViewModel.showMyProfilePressed;
    return _buildCheckBox(label, onChanged, value);
  }


  Widget _buildCheckBox(String label,Function(bool) onChanged, bool value)
  {
    return SizedBox(
      width: 300,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(label),
            Checkbox(
              value: value,
              onChanged: (checked) => onChanged(checked!),
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildSignOutButton()
  {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: _settingPageViewModel.logoutBtnPressed,
      child: const Text("התנתק"),
    );
  }

}