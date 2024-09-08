import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class BugDetect extends StatefulWidget {
  @override
  _ImageClassifierState createState() => _ImageClassifierState();
}

class _ImageClassifierState extends State<BugDetect> {
  File? _image;
  Map<String, dynamic>? _response;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _response = null; // Reset the response when a new image is picked
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
          _response = jsonResponse;
        });
      } else {
        setState(() {
          _response = {"error": "Error classifying image"};
        });
      }
    } catch (error) {
      setState(() {
        _response = {"error": "Error: $error"};
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Image Classifier'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[400]!, Colors.blue[900]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_image == null)
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: screenWidth > 600 ? 500 : double.infinity,
                      height: screenWidth > 600 ? 250 : 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload,
                              size: 50, color: Colors.white),
                          SizedBox(height: 10),
                          Text(
                            'Click to upload or drag and drop an image',
                            style: TextStyle(
                              fontSize: screenWidth > 600 ? 20 : 16,
                              color: Colors.white,
                            ),
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
                        width: screenWidth > 600 ? 400 : 300,
                        height: screenWidth > 600 ? 400 : 300,
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
                  onPressed:
                      (_image == null || _loading) ? null : _classifyImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _loading ? Colors.grey : Colors.blue,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth > 600 ? 40 : 20,
                        vertical: screenWidth > 600 ? 20 : 10),
                  ),
                  child: Text(
                    _loading ? 'Classifying...' : 'Classify Image',
                    style: TextStyle(
                      fontSize: screenWidth > 600 ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_response != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Response:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 10),
                        if (_response!['error'] != null)
                          Text(_response!['error']),
                        if (_response!['confidence'] != null &&
                            _response!['confidence'] * 100 >= 90) ...[
                          Text(
                            'Disease: ${_response!['disease']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Confidence: ${(_response!['confidence'] * 100).toStringAsFixed(2)}%',
                            style: TextStyle(fontSize: 16),
                          ),
                          if (_response!['precautions'] != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Text('Precautions:'),
                                for (var precaution
                                    in _response!['precautions'])
                                  Text('• $precaution'),
                              ],
                            ),
                        ],
                        if (_response!['confidence'] != null &&
                            _response!['confidence'] * 100 < 90)
                          Text('Unable to predict, Try again'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
