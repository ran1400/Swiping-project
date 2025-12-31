
import 'package:flutter/material.dart';
import 'package:swiping_project/model/data_structures/user.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ProfileCard extends StatefulWidget
{
  final MatchUser user;
  final VoidCallback onCancelMatch;
  final VoidCallback goToFacebookProfile;

  const ProfileCard({required this.user,
                     required this.onCancelMatch,
                     required this.goToFacebookProfile,
                     required super.key,});


  @override
  State<ProfileCard> createState() => _ProfileCardState();
}


class _ProfileCardState extends State<ProfileCard>
{
  bool _expanded = false;
  bool _cancelMatchBtnPressed = false;

  @override
  Widget build(BuildContext context)
  {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _profileImage(),
            // overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black.withValues(alpha: 0.6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _cancelMatchBtnPressed ?
                      _textOnCard('לבטל את המאצ׳?')
                    :
                      _textOnCard('${widget.user.name}, ${widget.user.age}, ${widget.user.city}'),

                    const SizedBox(height: 10),

                    if (_expanded && !_cancelMatchBtnPressed)
                      _aboutUserText(),

                    _cancelMatchBtnPressed ?
                      _cancelMatchButtons()
                    :
                      _regularCardButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _regularCardButtons()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleButton('❌', Colors.white, () {
          setState(() => _cancelMatchBtnPressed = true);
        }),
        _showWhatImWriteButton(_expanded ? 'סגור' : 'לראות מה כתבתי',
              () => setState(() => _expanded = !_expanded),
        ),
        _facebookButton(),
      ],
    );
  }

  Widget _cancelMatchButtons()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _circleButton('כן', Colors.red, () {
          widget.onCancelMatch();
          setState(() => _cancelMatchBtnPressed = false);
        }),
        _circleButton('לא', Colors.grey, () {
          setState(() => _cancelMatchBtnPressed = false);
        }),
      ],
    );
  }

  Widget _aboutUserText()
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
          maxHeight: MediaQuery.of(context).size.height * 0.3
      ),
        child : Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      widget.user.about,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    )
                )
            )
        )
    );
  }


  Widget _textOnCard(String text)
  {
    return Text(text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _profileImage()
  {
    return CachedNetworkImage(
      imageUrl: widget.user.image,
      fit: BoxFit.cover,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  Widget _circleButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color,
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

  Widget _showWhatImWriteButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }



  Widget _facebookButton()
  {
    return GestureDetector(
      onTap: widget.goToFacebookProfile,
      child: const CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        child: Icon(Icons.facebook, color: Color(0xFF1877f2), size: 30),
      ),
    );
  }
}
