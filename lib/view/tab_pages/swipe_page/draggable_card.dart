import 'package:flutter/material.dart';
import 'package:swiping_project/model/data_structures/user.dart';
import 'package:cached_network_image/cached_network_image.dart';



class DraggableCard extends StatefulWidget
{

  final SwipeUser user;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const DraggableCard({
    super.key,
    required this.user,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> with SingleTickerProviderStateMixin
{
  Offset _position = Offset.zero;
  double _rotation = 0.0;
  double? _startDragX;
  late AnimationController _controller;
  bool expanded = false;

  static const double threshold = 100.0; // when its consider swipe
  static const double minDrag = 30.0;   // min for showing drag
  static const int animationDuration = 300; // in milliseconds
  static const double rotationFactor = 300.0; // How fast the card rotates
  static const double maxDragDistance = 400.0; // How far the card can be dragged



  @override
  void initState()
  {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: animationDuration)
    );
  }

  @override
  void dispose()
  {
    _controller.dispose();
    super.dispose();
  }

  void _animateSwipe(Offset targetOffset, VoidCallback onComplete)
  {
    // Stop any ongoing animation
    _controller.stop();
    _controller.reset();

    // Calculate proper rotation based on actual current position
    final double startRotation = _rotation;
    final double endRotation;
    if ( targetOffset == Offset.zero)
      endRotation = 0.0;
    else
      endRotation = targetOffset.dx / rotationFactor;

    // Create position animation from current position to target
    final Animation<Offset> positionAnim = Tween<Offset>(
        begin: _position,
        end: targetOffset
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut
    ));

    // Create rotation animation from current rotation to target
    final Animation<double> rotationAnim = Tween<double>(
        begin: startRotation,
        end: endRotation
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut
    ));

    // Update position and rotation during animation
    void listener()
    {
      if (mounted)
      {
        setState(()
        {
          _position = positionAnim.value;
          _rotation = rotationAnim.value;
        });
      }
    }

    // Handle animation completion
    void statusListener(AnimationStatus status)
    {
      if (status == AnimationStatus.completed)
      {
        onComplete();
        if (mounted)
        {
          setState(() {
            _position = Offset.zero;
            _rotation = 0.0;
            _startDragX = null;
          });
        }
        _controller.removeListener(listener);
        _controller.removeStatusListener(statusListener);
      }
    }

    _controller.addListener(listener);
    _controller.addStatusListener(statusListener);
    _controller.forward();
  }


  void _onDragStart(DragStartDetails details)
  {
    // Prevent drag during animation
    if (_controller.isAnimating)
      return;
    _startDragX = details.globalPosition.dx;
  }

  void _onDragUpdate(DragUpdateDetails details)
  {
    // Prevent update during animation or if drag hasn't started
    if (_controller.isAnimating || _startDragX == null)
      return;

    setState(()
    {
      // Calculate horizontal displacement
      double dx = details.globalPosition.dx - _startDragX!;
      // Clamp displacement to prevent excessive dragging
      dx = dx.clamp(-maxDragDistance, maxDragDistance);
      _position = Offset(dx, 0);
      // Update rotation based on displacement
      _rotation = _position.dx / rotationFactor;
    });
  }

  void _onDragEnd(DragEndDetails details)
  {
    // Prevent action during animation or if drag hasn't started
    if (_controller.isAnimating || _startDragX == null)
      return;

    // Determine swipe action based on displacement

    if (_position.dx.abs() < minDrag) // Minimal drag - return to center
      _animateSwipe(Offset.zero, () {});
    else if (_position.dx > threshold) // Right swipe exceeds threshold - complete right swipe
      _animateSwipe(Offset(maxDragDistance, 0), widget.onSwipeRight);
    else if (_position.dx < -threshold) // Left swipe exceeds threshold - complete left swipe
      _animateSwipe(Offset(-maxDragDistance, 0), widget.onSwipeLeft);
    else // Drag below threshold - return to center
      _animateSwipe(Offset.zero, () {});
    _startDragX = null;
  }


  @override
  Widget build(BuildContext context)
  {
    return Transform.translate(
      offset: _position,
      child: Transform.rotate(
        angle: _rotation,
        child: GestureDetector(
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              clipBehavior: Clip.hardEdge,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCardImage(widget.user.image),
                  Positioned(bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.black.withValues(alpha: 0.6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAgeNameCityText(widget.user.age, widget.user.name, widget.user.city),
                          if (expanded)
                            _buildShowWhatImWrite(widget.user.about),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _circleButton("❌",() => _animateSwipe(Offset(-maxDragDistance, 0), widget.onSwipeLeft)),
                              _buildShowWhatImWriteBtn(),
                              _circleButton("❤️",() => _animateSwipe(Offset(maxDragDistance, 0), widget.onSwipeRight)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShowWhatImWrite(String about)
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
              ),
            )
        )
    );
  }

  Widget _buildAgeNameCityText(int age, String name, String city)
  {
    return Text(
      '$name, $age, $city',
      style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCardImage(String image)
  {
    return CachedNetworkImage(
      imageUrl: image,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  Widget _buildShowWhatImWriteBtn()
  {
    return ElevatedButton(
      onPressed: () {setState(() {expanded = !expanded;});},
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(12))),
      child: Text(expanded ? 'סגור' : 'לראות מה כתבתי'),
    );
  }

  Widget _circleButton(String text,VoidCallback onPress)
  {
    return GestureDetector(
      onTap: onPress,
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