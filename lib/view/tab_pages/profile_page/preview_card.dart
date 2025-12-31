

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:swiping_project/model/data_structures/user.dart';
import 'package:provider/provider.dart';

import 'package:swiping_project/view_model/tab_layout_view_models/profile_page_view_model.dart';


class PreviewCard extends StatefulWidget
{

  const PreviewCard({super.key});

  @override
  State<PreviewCard> createState() => _PreviewCardState();

}

class _PreviewCardState extends State<PreviewCard>
{
  bool _expanded = false;
  @override
  Widget build(BuildContext context)
  {
    final ProfilePageViewModel profilePageViewModel = context.watch<ProfilePageViewModel>();
    final MyProfile myDetails = profilePageViewModel.myProfile!;
    return AspectRatio(
        aspectRatio: 2 / 3,
        child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            clipBehavior: Clip.hardEdge,
            child: Stack(
                fit: StackFit.expand,
                children: [
                  if(myDetails.image != null)
                    _imageContainer(myDetails.image!),
                  Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                            padding: const EdgeInsets.all(10),
                            color: Colors.black.withValues(alpha: 0.6),
                            child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                  _getNameAgeCityStringTextWidget(myDetails.name,myDetails.age,myDetails.city),
                                  const SizedBox(height: 10),
                                  if (_expanded)
                                    _buildAboutTextField(myDetails.about),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildCircleButton("❌"),
                                      _buildShowWhatImWriteButton(),
                                      _buildCircleButton("❤️"),
                                    ],
                                  ),
                                  ],
                              ),
                            ),
                  ),
                ]
            )
        )
    );
  }

  Widget _buildAboutTextField(String about)
  {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.3),
        child : Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    about,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
            )
        )
    );
  }

  Widget _buildShowWhatImWriteButton()
  {
    return ElevatedButton(
      onPressed: () => setState(() => _expanded = !_expanded),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      child: Text(_expanded ? 'סגור' : 'לראות מה כתבתי'),
    );
  }

  Widget _getNameAgeCityStringTextWidget(String name,int age,String city)
  {
     name = name == "" ? "שם" : name;
     String ageString = age == -1 ? "גיל" : age.toString();
     city = city == "" ? "עיר"  : city;
     String text = '$name, $ageString, $city';
     return Text(text,
       style: const TextStyle(
         color: Colors.white,
         fontSize: 20,
         fontWeight: FontWeight.bold,
       ),
       textAlign: TextAlign.center,
     );
  }

  Widget _imageContainer(MyProfileImage image)
  {
    switch(image)
    {
      case Uint8ListImage():
        return Image.memory(
          image.imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        );
      case UrlImage():
        return CachedNetworkImage(
          imageUrl: image.url,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
    }
  }

  Widget _buildCircleButton(String text)
  {
    return GestureDetector(
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(fontSize: 26, color: Colors.white),
        ),
      ),
    );
  }
}
