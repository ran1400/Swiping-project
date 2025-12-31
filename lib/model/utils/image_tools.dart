
// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageTools
{

  static String? getImageType(Uint8List image)
  {
    if (image.length < 4)
      return null;

    // JPEG - FF D8
    if (image[0] == 0xFF && image[1] == 0xD8)
      return 'jpeg';

    // PNG - 89 50 4E 47
    if (image[0] == 0x89 && image[1] == 0x50 && image[2] == 0x4E && image[3] == 0x47)
      return 'png';

    return null;
  }

  static Uint8List? getSmallImage(Uint8List image, {int maxDimension = 120})
  {
    try
    {
      final img.Image? originalImage = img.decodeImage(image);
      if (originalImage == null)
        return null;

      final newHeight = maxDimension;
      final newWidth = (maxDimension * 2 / 3).round();

      final img.Image resized = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.cubic,
      );

      return Uint8List.fromList(img.encodePng(resized));
    }
    catch (e)
    {
      return null;
    }
  }



  static Uint8List? resizeImageResToMax1500(Uint8List image)
  {
    try
    {
      img.Image? original = img.decodeImage(image);
      if (original == null)
        return null;

      int width = original.width;
      int height = original.height;

      const int maxSide = 1500;

      if (width <= maxSide && height <= maxSide)
        return image;

      double scale = width > height ? maxSide / width : maxSide / height;

      int newWidth = (width * scale).round();
      int newHeight = (height * scale).round();


      img.Image resized = img.copyResize(
        original,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      return Uint8List.fromList(img.encodeJpg(resized, quality: 90));
    }
    catch (e)
    {
      return null;
    }
  }

}