import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'coordinate_display.dart';
import 'image_crop.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _sourceImage;
  Image? _templateImage;
  Uint8List? _sourceImageBase64;
  Uint8List? _templateImageBase64;
  final picker = ImagePicker();
  List<List<int>> _coordinates = [];
  bool _isLoading = false;
  Uint8List? _markedImageBase64;
  CropController? _controller;
  bool? _isLoadingSource = false;
  List<int>? sourceImageBytes;
  String? selectedAlgorithm = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = CropController();
  }

  Future<void> getImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Uint8List f = await image.readAsBytes();
      String path = image.path;
      _sourceImage = File(path);
      sourceImageBytes = f.toList();

      setState(() {
        _isLoadingSource = false;
        _sourceImageBase64 = f;
      });
    }
  }

  Future<void> uploadImages() async {
    if (_sourceImageBase64 == null || _templateImageBase64 == null) {
      print('No images to upload.');
      return;
    }

    var url = 'http://127.0.0.1:5000/match-template';

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'source_image',
        sourceImageBytes!,
        filename: 'source_image.jpg',
      ),
    );
    request.files.add(
      http.MultipartFile.fromBytes(
        'template_image',
        _templateImageBase64!,
        filename: 'template_image.jpg',
      ),
    );
    request.fields['algorithm_type'] = selectedAlgorithm!;
    setState(() {
      _isLoading = true;
      _markedImageBase64 = null;
      _coordinates.clear();
    });

    try {
      var response = await request.send().timeout(Duration(seconds: 60));

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);

        setState(() {
          _coordinates = List<List<int>>.from(
              jsonData['coordinates'].map((coord) => List<int>.from(coord)));
          _markedImageBase64 = base64Decode(jsonData['marked_image_base64']);
        });
      } else {
        print('Failed to upload images. Status code: ${response.statusCode}');
      }
    } on SocketException {
      print(
          'Connection error. Please check if the server is running and reachable.');
    } on TimeoutException {
      print('Request timed out. Please check server response time.');
    } catch (e) {
      print('Unexpected error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _markedImageBase64 = null;
      _coordinates.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Image Processing',
            style: TextStyle(
              color: Color(0xFFFdef2f1),
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: Color(0xFFF17252a),
        titleSpacing: 20,
        centerTitle: true,
      ),
      body: _selectedIndex == 0
          ? _buildCreateTemplate()
          : _buildMatchWithTemplate(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Create Template',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Match with Template',
              backgroundColor: Colors.black),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFF17252a),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCreateTemplate() {
    return Container(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _isLoading
                ? CircularProgressIndicator()
                : Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFFF17252a),
                              width: 1.0,
                            ),
                          ),
                          child: _sourceImageBase64 == null
                              ? Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 100,
                                    color: Color(0xfff8697c4),
                                  ),
                                )
                              : _isLoadingSource == true
                                  ? Center(
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : CropImage(
                                      controller: _controller,
                                      image: Image.memory(
                                        _sourceImageBase64!,
                                        height: 400,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFFF17252a),
                              width: 1.0,
                            ),
                          ),
                          child: _templateImageBase64 == null
                              ? Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 100,
                                    color: Color(0xfff8697c4),
                                  ),
                                )
                              : Image.memory(
                                  _templateImageBase64!,
                                  height: 400,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoadingSource = true;
                    });
                    getImage();
                  },
                  icon: Icon(
                    Icons.image,
                    color: Color(0xFFFdef2f1),
                  ),
                  label: Text(
                    'Source Image',
                    style: TextStyle(
                      color: Color(0xFFFdef2f1),
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFFF17252a)),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    ),
                  ),
                ),
                ImageCropButton(
                  controller: _controller,
                  onCrop: (image, imageBytes) {
                    setState(() {
                      _templateImage = image;
                      _templateImageBase64 = Uint8List.fromList(imageBytes);
                      log(_templateImage.toString());
                    });
                  },
                  onTemplateUpload: (templateBytes) {
                    setState(() {
                      _templateImageBase64 = templateBytes;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchWithTemplate() {
    return Container(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _isLoading
                ? CircularProgressIndicator()
                : Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 12.0),
              margin: EdgeInsets.only(top: 24.0),
              decoration: BoxDecoration(
                color: Color(0xFFF17252a),
                borderRadius: BorderRadius.circular(38.0),
              ),
              child: DropdownButton<String>(
                dropdownColor: Color(0xFFF17252a),
                style: TextStyle(color: Color(0xFFFdef2f1)),
                icon: Icon(Icons.arrow_drop_down, color: Color(0xFFFdef2f1)),
                underline: Container(),
                hint: Text(
                  selectedAlgorithm != null && selectedAlgorithm != ''
                      ? selectedAlgorithm!
                      : 'Select Algorithm',
                  style: TextStyle(color: Color(0xFFFdef2f1)),
                ),
                items: <String>[
                  'CoeffNormalizedMatching',
                  'SquareDifferenceMatching',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAlgorithm = newValue!;
                  });
                },
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: uploadImages,
              icon: Icon(
                Icons.find_in_page,
                color: Color(0xFFFdef2f1),
              ),
              label: Text(
                'Match Template',
                style: TextStyle(
                  color: Color(0xFFFdef2f1),
                ),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFFF17252a)),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                ),
              ),
            ),
            SizedBox(height: 24.0),
            Column(
              children: [
                Text(
                  'Matched Image:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24.0),
            _markedImageBase64 != null
                ? Image.memory(
                    _markedImageBase64!,
                    height: 400,
                    fit: BoxFit.contain,
                  )
                : Container(),
            SizedBox(height: 24.0),
            CoordinateDisplay(coordinates: _coordinates),
          ],
        ),
      ),
    );
  }
}
