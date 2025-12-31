// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:swiping_project/model/data_structures/data_sets_from_server.dart';
import 'package:swiping_project/model/data_structures/user_preferences.dart';
import 'package:swiping_project/view/utils.dart';

import 'package:swiping_project/view_model/tab_layout_view_models/preferences_page_view_model.dart';

import 'package:swiping_project/view/tab_pages/view_in_the_tab_layout.dart';


class PreferencesPage extends StatefulWidget
{
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> with ViewInTheTabLayout
{
  final PreferencesPageViewModel _preferencesPageViewModel = GetIt.instance<PreferencesPageViewModel>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState()
  {
    super.initState();
    _preferencesPageViewModel.pageIsInit();
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
    PreferencesPageViewModel preferencesPageViewModel = context.watch<PreferencesPageViewModel>();
    initViewInTheTabLayout(context,preferencesPageViewModel);
    WidgetsBinding.instance.addPostFrameCallback((_){checkIfShowSnackBar();});
    if (preferencesPageViewModel.loading)
      return loadingPage();
    if (preferencesPageViewModel.error != null)
      return errorPage(preferencesPageViewModel.error!);
    UserPreferences userPreferences = preferencesPageViewModel.userPreferences!;

    return Scaffold(
        body: RefreshIndicator(
          onRefresh: () async => preferencesPageViewModel.getPreference(),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                const SizedBox(height: 30),

                _buildChoiceMultiple("אני מחפש",DataSetsFromServer.genders!,userPreferences.genderSearch,
                                    preferencesPageViewModel.searchGenderChange),

                  const SizedBox(height: 25),

                  const Text(
                    "טווח גילאים לחיפוש",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      _buildAgeInput(
                          "מקסימום",userPreferences.maxAge,
                          preferencesPageViewModel.maxAgeChanged
                      ),

                      const SizedBox(width: 20),

                      _buildAgeInput(
                          "מינימום",userPreferences.minAge,
                          preferencesPageViewModel.minAgeChanged
                      )

                    ]
                  ),

                  const SizedBox(height: 25),

                  _buildChoiceMultiple("אזורים לחיפוש",DataSetsFromServer.regions!,userPreferences.regionSearch,
                                      preferencesPageViewModel.regionSearchChanged),

                  const SizedBox(height: 40),

                  _buildSaveBtn(),
                  const SizedBox(height: 25),
                ],
              ),
            ),
      )
      )
    );
  }


  Widget _buildSaveBtn()
  {
    return ElevatedButton(
      onPressed: _preferencesPageViewModel.saveBtn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        minimumSize: const Size(250, 50),
      ),
      child: const Text("שמור", style: TextStyle(fontSize: 16),),
    );
  }


  Widget _buildAgeInput(String label, int? value, Function(int) onSelected)
  {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final selected = await showModalBottomSheet<int>(
              context: context,
              builder: (_) {
                return SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: 99,
                    itemBuilder: (context, index)
                    {
                      final numValue = index + 1;
                      return ListTile(
                        title: Text(numValue.toString()),
                        onTap: () => Navigator.pop(context, numValue),
                      );
                    },
                  ),
                );
              },
            );
            if (selected != null)
              onSelected(selected);
          },
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            alignment: Alignment.center,
            child: Text(
              value == null ? "בחר" : value.toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceMultiple(String label,List<String> options,
      Set<int> optionsSelected,Function(int,bool) onSelected)

  {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Directionality(
        textDirection: TextDirection.rtl, // Right-To-Left
        child:Wrap(
          spacing: 10,
          children: options.asMap().entries.map((option)
          {
            final selected = optionsSelected.contains(option.key);
            return ChoiceChip(
              label: Text(option.value),
              selected: selected,
              onSelected: (isSelected) {onSelected(option.key,isSelected);},
              selectedColor: Colors.green.shade400,
            );
          }).toList(),
        ),
        )],
    );
  }


}
