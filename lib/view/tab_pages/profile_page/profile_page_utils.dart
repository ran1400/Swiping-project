

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';

class ProfilePageUtils
{
  static Future<void> handleImagePick(Function(Uint8List?) doWithInput) async
  {
    Uint8List? image;
    if (kIsWeb)
      image = await _handleImagePickForWeb();
    else
      image = await _handleImagePickForMobile();
    if (image == null)
    {
      doWithInput(null);
      return ;
    }
    doWithInput(image);
  }

  static Future<Uint8List?> _handleImagePickForWeb() async
  {
    final typeGroup = XTypeGroup(label: 'images', extensions: ['jpg','png','gif','jpeg','bmp','webp','heic']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null)
      return await file.readAsBytes();
    else
      return null;
  }


  static Future<Uint8List?> _handleImagePickForMobile() async
  {
    try
    {
      XFile? imageFile;
      final picker = ImagePicker();
      imageFile = await picker.pickImage(source: ImageSource.gallery);
      if (imageFile != null)
        return await imageFile.readAsBytes();
      else
        return null;
    }
    catch(e)
    {
      return null;
    }
  }

  static Future<void> handleDatePicker(BuildContext context ,Function(String?) doWithInput) async
  {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(1900);
    DateTime lastDate =  DateTime.now();
    final DateTime? pickedDate = await showDatePicker(context: context, initialDate: initialDate, firstDate: firstDate, lastDate: lastDate);

    if (pickedDate != null)
    {
      final String formattedDate = //yyyy-mm-dd
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      doWithInput(formattedDate);
    }
    else
      doWithInput(null);
  }

}


