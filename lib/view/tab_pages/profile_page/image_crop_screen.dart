
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

import 'package:swiping_project/view_model/tab_layout_view_models/profile_page_view_model.dart';

class ImageCropScreen extends StatefulWidget
{
  final ProfilePageViewModel profilePageViewModel;

  const ImageCropScreen({super.key, required this.profilePageViewModel});

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen>
{
  final CropController _controller = CropController();

  bool _isLoading = true;
  bool _showCrop = false;

  @override
  void initState()
  {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async

    {
      if (mounted)
      {
        setState(()
        {
          _isLoading = false;
          _showCrop = true;
        });
      }
    });
  }

  @override
  void dispose()
  {
    _showCrop = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: _isLoading
              ? AppBar(title: Center(child:const Text('...טוען')))
              :AppBar(leading: IconButton(onPressed: () =>widget.profilePageViewModel.finishCroppingImage(null),
                      icon: const Icon(Icons.arrow_back_rounded)),
                      title: Center(child: const Text('בחר מיקום לתמונה')),
                      actions: [IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () {
                                  setState(() => _isLoading = true);
                                  Future.delayed(Duration.zero, () => _controller.crop());
                                },
                                ),
                                ],
                     ),
      body: _showCrop
            ? Crop(
              controller: _controller,
              image: widget.profilePageViewModel.imageToCrop!,
              aspectRatio: 2 / 3,
              withCircleUi: false,
              onCropped:widget.profilePageViewModel.finishCroppingImage,
              )
            : const SizedBox.shrink(),
    );
  }

}