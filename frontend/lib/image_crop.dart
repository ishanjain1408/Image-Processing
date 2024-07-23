import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ImageCropButton extends StatefulWidget {
  final CropController? controller;
  final Function(Image, List<int>) onCrop;
  final Function(Uint8List) onTemplateUpload;

  const ImageCropButton({
    Key? key,
    this.controller,
    required this.onCrop,
    required this.onTemplateUpload,
  }) : super(key: key);

  @override
  _ImageCropButtonState createState() => _ImageCropButtonState();
}

class _ImageCropButtonState extends State<ImageCropButton> {
  String? _selectedTemplate;

  Future<Uint8List?> imageToBytes(Image? image) async {
    if (image == null) return null;

    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
            (ImageInfo info, bool synchronousCall) {
              completer.complete(info.image);
            },
            onError: (dynamic exception, StackTrace? stackTrace) {
              completer.completeError(exception, stackTrace);
            },
          ),
        );

    try {
      ui.Image uiImage = await completer.future;
      final ByteData? byteData =
          await uiImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
    } catch (e) {
      print("Error converting image to bytes: $e");
    }
    return null;
  }

  Future<void> cropImage() async {
    if (widget.controller != null) {
      Image? croppedImage = await widget.controller!.croppedImage();
      if (croppedImage != null) {
        var bytes = await imageToBytes(croppedImage);
        if (bytes != null) {
          widget.onCrop(croppedImage, bytes);
        }
      }
    }
  }

  Future<void> uploadTemplateFromPC() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        Uint8List fileBytes = result.files.first.bytes!;
        widget.onTemplateUpload(fileBytes);
      } else {
        print('User canceled the file picker.');
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: Color(0xFFF17252a),
            borderRadius: BorderRadius.circular(38.0),
          ),
          child: DropdownButton<String>(
            dropdownColor: Color(0xFFF17252a),
            style: TextStyle(color: Color(0xFFFdef2f1)),
            icon: Icon(Icons.arrow_drop_down, color: Color(0xFFFdef2f1)),
            underline: Container(),
            hint: _selectedTemplate == null
                ? Row(
                    children: [
                      Icon(
                        Icons.save,
                        color: Color(0xFFFdef2f1),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        'Template',
                        style: TextStyle(color: Color(0xFFFdef2f1)),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        _selectedTemplate == 'Save Template'
                            ? Icons.crop
                            : Icons.upload_file,
                        color: Color(0xFFFdef2f1),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        _selectedTemplate!,
                        style: TextStyle(color: Color(0xFFFdef2f1)),
                      ),
                    ],
                  ),
            items: <String>['Save Template', 'Select Template']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Icon(
                      value == 'Save Template' ? Icons.crop : Icons.upload_file,
                      color: Color(0xFFF17252a),
                    ),
                    SizedBox(width: 8.0),
                    Text(value),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedTemplate = newValue;
              });

              if (newValue == 'Save Template') {
                cropImage();
              } else if (newValue == 'Select Template') {
                uploadTemplateFromPC();
              }
            },
          ),
        ),
      ],
    );
  }
}
