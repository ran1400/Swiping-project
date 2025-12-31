
// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:swiping_project/view/tab_pages/profile_page/profile_page_utils.dart';
import 'package:swiping_project/view/utils.dart';
import 'package:swiping_project/view/tab_pages/profile_page/preview_card.dart';
import 'package:swiping_project/view_model/tab_layout_view_models/profile_page_view_model.dart';
import 'package:provider/provider.dart';
import 'package:swiping_project/view/tab_pages/view_in_the_tab_layout.dart';


import 'image_crop_screen.dart';


class ProfilePage extends StatefulWidget
{
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<ProfilePage> with ViewInTheTabLayout
{
    final ProfilePageViewModel _profilePageViewModel = GetIt.instance<ProfilePageViewModel>();
    final ScrollController _scrollController = ScrollController();


    @override
    void initState()
    {
      super.initState();
      _profilePageViewModel.pageIsInit();
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
      ProfilePageViewModel profilePageViewModel = context.watch<ProfilePageViewModel>();
      initViewInTheTabLayout(context,profilePageViewModel);
      WidgetsBinding.instance.addPostFrameCallback((_){checkIfShowSnackBar();});

      if (profilePageViewModel.loading)
        return loadingPage();

      if (profilePageViewModel.error != null)
        return errorPage(profilePageViewModel.error!);

      if (profilePageViewModel.showStaticLoadingView != null)
        return _buildStaticLoadingWidget(profilePageViewModel.showStaticLoadingView!);

      if (profilePageViewModel.imageToCrop != null)
        return ImageCropScreen(profilePageViewModel: profilePageViewModel);

      final InputStep currentStep = profilePageViewModel.getCurrentStep();

      return Scaffold(
          body: RefreshIndicator(
              onRefresh: () async => profilePageViewModel.getUserProfile(),
              child: Scrollbar(controller: _scrollController, thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Text(
                    currentStep.explainToUser,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  switch (currentStep)
                  {

                    TextInputStep() =>
                        _buildTextField(currentStep.textEditingController,currentStep.numberOfLines,currentStep.doWithInput),

                    ButtonInputStep() =>
                        ElevatedButton(
                            onPressed: currentStep.onPressed,
                            child: Text(currentStep.btnText),
                            ),

                    ChoiceMultipleOptionsInputStep() =>
                        _buildChooseFiled(currentStep),

                    DateInputStep() =>
                        ElevatedButton(
                          onPressed: () => ProfilePageUtils.handleDatePicker(context,currentStep.doWithInput),
                          child: Text("בחר תאריך"),
                        ),

                  },

                  const SizedBox(height: 20),
                  _buildStepsNavigation(profilePageViewModel.steps),
                  const SizedBox(height: 20),
                  _buildSaveBtn(),
                  const SizedBox(height: 40),
                  const Text("תצוגה מקדימה", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ConstrainedBox(constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 100),
                    child: PreviewCard(),
                  ),
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
        onPressed: _profilePageViewModel.saveBtn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50),
        ),
        child: const Text("שמור"),
      );
    }


    Widget _buildTextField(TextEditingController controller,int maxLines,Function(String) doWithInput)
    {
      return SizedBox(
        width: 300,
        child: AutoDirection(
          text: controller.text,
          child: TextField(
          controller: controller,
          onChanged: doWithInput,
          textAlign: TextAlign.center,
          maxLines: maxLines,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'הקלד כאן',
          ),
        ),
      )
      );
    }

    Widget _buildChooseFiled(ChoiceMultipleOptionsInputStep choiceInputStep)
    {
      return Directionality(textDirection: TextDirection.rtl, // Right-To-Left
            child:Wrap(
            spacing: 10,
            alignment: WrapAlignment.center,
            children: choiceInputStep.values.map((value)
            {
              final selected = choiceInputStep.isSelected(value);
              return ChoiceChip(
                label: Text(choiceInputStep.options[value]),
                selected: selected,
                onSelected: (isSelected) {choiceInputStep.itemChoose(value,isSelected);},
                selectedColor: Colors.green.shade400,
              );
            }).toList(),
          )
          );
    }


    Widget _buildNavigationButton(int index, bool filled, bool isCurrent)
    {
      return Expanded(child: GestureDetector(
        onTap: () => _profilePageViewModel.setCurrentStep(index),
        child: Container(height: 30, margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: filled ? Colors.green : Colors.grey[300],
            borderRadius: BorderRadius.circular(5),
            border: isCurrent ? Border.all(color: Colors.black, width: 2) : null,
          ),
          child: Center(
            child: Text((index+1).toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      );
    }


    List<Widget> _buildListOfNavigationButtons(List<InputStep> steps)
    {
        List<Widget> widgets = [];
        int index = 0;
        for (InputStep step in steps)
        {
          final bool filled = step.isFilled();
          final bool isCurrent = index == _profilePageViewModel.currentStep;
          Widget widget = _buildNavigationButton(index, filled, isCurrent);
          widgets.add(widget);
          index++;
        }
        return widgets;
      }

      Widget _buildStepsNavigation(List<InputStep> steps)
      {
        return Directionality(
            textDirection: TextDirection.rtl, // Right-To-Left
            child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                            IconButton(
                                      onPressed: _profilePageViewModel.decreaseCurrentStep,
                                      icon: const Icon(Icons.arrow_back),
                            ),
                            SizedBox(
                                     width: MediaQuery.of(context).size.width * 0.5,
                                      child: Row(children: _buildListOfNavigationButtons(steps)),
                            ),
                            IconButton(
                                       onPressed: _profilePageViewModel.increaseCurrentStep,
                                       icon: const Icon(Icons.arrow_forward),
                            ),
                  ],
            )
        );
      }

      Widget _buildStaticLoadingWidget(String text)
      {
        return Scaffold(
          appBar: AppBar(
            title: Center(child:Text(text)),
          ),
        );
      }

}




