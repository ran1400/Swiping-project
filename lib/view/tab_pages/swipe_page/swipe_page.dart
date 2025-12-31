import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:swiping_project/model/data_structures/user.dart';
import 'package:swiping_project/view/utils.dart';
import 'package:swiping_project/view/tab_pages/view_in_the_tab_layout.dart';
import 'package:swiping_project/view_model/tab_layout_view_models/swipe_page_view_model.dart';
import 'draggable_card.dart';


class SwipePage extends StatefulWidget
{
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with ViewInTheTabLayout
{

  SwipePageViewModel swipePageViewModel = GetIt.instance<SwipePageViewModel>();

  @override
  void initState()
  {
    super.initState();
    swipePageViewModel.pageIsInit();
  }

  @override
  Widget build(BuildContext context)
  {
    SwipePageViewModel swipePageViewModel = context.watch<SwipePageViewModel>();
    initViewInTheTabLayout(context,swipePageViewModel);
    WidgetsBinding.instance.addPostFrameCallback((_){checkIfShowSnackBar();});
    if (swipePageViewModel.loading)
        return loadingPage();
    if (swipePageViewModel.error != null)
      return errorPage(swipePageViewModel.error!);
    SwipeUser? crntUser = swipePageViewModel.getCrntUser();
    if (crntUser == null)
      return errorPage(swipePageViewModel.error!);

    return Scaffold(
      body: Center(
        child: DraggableCard(
          key: ValueKey(crntUser.userId),
          user: crntUser,
          onSwipeLeft: swipePageViewModel.swipeLeft,
          onSwipeRight: swipePageViewModel.swipeRight,
        ),
      ),
    );
  }
}

