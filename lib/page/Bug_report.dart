import 'dart:io';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // Corrected import

class BugDetect extends StatefulWidget {
  @override
  _ImageClassifierState createState() => _ImageClassifierState();
}

class _ImageClassifierState extends State<BugDetect> {
  File? _image;
  String? _response;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _response = null; // Reset the response when a new image is picked.
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> _classifyImage() async {
    if (_image == null) return;
    setState(() {
      _loading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://papi-production.up.railway.app/classify/'),
      );
      request.files
          .add(await http.MultipartFile.fromPath('file', _image!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          _response = jsonResponse['confidence'] * 100 >= 90
              ? 'Disease: ${jsonResponse['class']}\nConfidence: ${(jsonResponse['confidence'] * 100).toStringAsFixed(2)}%'
              : 'Unable to predict, Try again';
        });
      } else {
        setState(() {
          _response = 'Error classifying image';
        });
      }
    } catch (error) {
      setState(() {
        _response = 'Error: $error';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
      _response = null;
    });
  }

  final items = <Widget>[
    Icon(Icons.bug_report, size: 30),
    Icon(Icons.cloud, size: 30),
    Icon(Icons.shop, size: 30),
  ];

  int index = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Replace the background color with a gradient in the body instead
      appBar: AppBar(
        title: Text(
          'Image Classifier',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        shadowColor: Colors.white.withOpacity(0.5),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[400]!, Colors.blue[900]!],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_image == null)
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: screenWidth > 600 ? 400 : 300,
                      height: screenWidth > 600 ? 200 : 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload,
                              size: 60, color: Colors.black),
                          SizedBox(height: 10),
                          Text(
                            'Click to upload or drag and drop an image',
                            style:
                                TextStyle(color: Colors.black, fontSize: 14.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_image != null)
                  Stack(
                    children: [
                      Image.file(
                        _image!,
                        width: screenWidth > 600 ? 250 : 200,
                        height: screenWidth > 600 ? 250 : 200,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child:
                              Icon(Icons.cancel, color: Colors.red, size: 30),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: (_image == null || _loading)
                      ? null
                      : _classifyImage, // Disable the button when no image is selected or loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.white, // Button background color always white
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth > 600 ? 20 : 15,
                      vertical: screenWidth > 600 ? 15 : 10,
                    ),
                  ),
                  child: Text(
                    _loading ? 'Classifying...' : 'Classify Image',
                    style: TextStyle(
                      fontSize: screenWidth > 600 ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Text color is black for contrast
                      letterSpacing:
                          1.1, // Letter spacing for better readability
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_response != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          'Response:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _response!,
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        index: index,
        height: 60,
        onTap: (selectedIndex) {
          setState(() {
            index = selectedIndex;
          });
          if (selectedIndex == 0) {
            // Navigate to BugDetect when the first tab (bug icon) is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BugDetect()),
            );
          }
        },
      ),
    );
  }
}
