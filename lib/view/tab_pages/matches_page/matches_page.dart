
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:swiping_project/model/data_structures/user.dart';
import 'package:swiping_project/view/tab_pages/view_in_the_tab_layout.dart';
import 'package:swiping_project/view_model/tab_layout_view_models/matches_page_view_model.dart';
import 'package:swiping_project/view/utils.dart';
import 'profile_card.dart';
import 'package:cached_network_image/cached_network_image.dart';


class MatchesPage extends StatefulWidget
{
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> with ViewInTheTabLayout
{
  final MatchesPageViewModel _matchesPageViewModel = GetIt.instance<MatchesPageViewModel>();


  @override
  void initState()
  {
    super.initState();
    _matchesPageViewModel.pageIsInit();
  }

  @override
  Widget build(BuildContext context)
  {
    MatchesPageViewModel matchesPageViewModel = context.watch<MatchesPageViewModel>();
    initViewInTheTabLayout(context,matchesPageViewModel);
    WidgetsBinding.instance.addPostFrameCallback((_){checkIfShowSnackBar();});
    if (matchesPageViewModel.loading)
      return loadingPage();
    if (matchesPageViewModel.error != null)
      return errorPage(matchesPageViewModel.error!);

    return RefreshIndicator(
        onRefresh: () async => matchesPageViewModel.getUsers(),
        child: ListView.separated(
      itemCount: matchesPageViewModel.users!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 25),
      itemBuilder: (context, index)
      {
        final MatchUser currentUser = matchesPageViewModel.users![index];
        final isSelected = index == matchesPageViewModel.currentUserOpenIndex;
        return Column(
          children: [
            GestureDetector(
              onTap: () => matchesPageViewModel.userPressed(index),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _circleImage(currentUser.image),
                  const SizedBox(height: 8),
                  Text(currentUser.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("${currentUser.age} • ${currentUser.city}")
                ],
              ),
            ),
            if (isSelected)
                  matchesPageViewModel.profileLoading?
                    const Padding(padding: EdgeInsets.all(20),child: CircularProgressIndicator())
                  : matchesPageViewModel.profileError ? 
                    _errorBox('שגיאה בטעינת פרופיל',() => matchesPageViewModel.getUser(index))
                  : ConstrainedBox(
                    constraints:  BoxConstraints(maxHeight: MediaQuery.of(context).size.height -100),
                    child:ProfileCard(
                      user: currentUser,
                      onCancelMatch: () => matchesPageViewModel.cancelMatch(index),
                      goToFacebookProfile: matchesPageViewModel.goToFacebookProfile,
                      key : ValueKey(currentUser.userId)
                        )
                    )
          ],
        );
      },
        )
    );
  }

  Widget _circleImage(String url)
  {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: 800,
          height: 80,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.person,
            size: 40,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _errorBox(String text, VoidCallback onRetry)
  {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: onRetry, child: const Text('נסה שוב')),
        ],
      ),
    );
  }

}
