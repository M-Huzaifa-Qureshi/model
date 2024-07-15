import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ScanFaceModel extends StatefulWidget {
  const ScanFaceModel({super.key});

  @override
  State<ScanFaceModel> createState() => _ScanFaceModelState();
}

class _ScanFaceModelState extends State<ScanFaceModel> {
  String parsedText = '';
  bool isLoading = false;
  File? selectedImage;
  String? diseaseName;
  String? medicationSuggestion;

  Future<void> parseText() async {
    final imageFile = await _pickImage();

    if (imageFile != null) {
      setState(() {
        selectedImage = File(imageFile.path);
        isLoading = true;
      });

      await _getTextFromPicture(imageFile.path);
    }
  }

  Future<XFile?> _pickImage() async {
    try {
      return await ImagePicker().pickImage(source: ImageSource.gallery);
    } catch (e) {
      _setErrorState('Error picking image: $e');
      return null;
    }
  }

  Future<void> _getTextFromPicture(String filePath) async {
    File imageFile = File(filePath);
    String base64Image = base64Encode(imageFile.readAsBytesSync());

    await _sendPostRequest(base64Image);
  }

  Future<void> _sendPostRequest(String base64String) async {
    int retryCount = 3;

    for (int i = 0; i < retryCount; i++) {
      try {
        final response = await http.post(
          Uri.parse(
              "https://detect.roboflow.com/skin-disease-detection-s7zik/1?api_key=7RFrwpqNKxeWnjKneF5q"),
          body: base64String,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Response data: $data'); // Log the entire response for debugging
          if (data.containsKey('predictions') && data['predictions'].isNotEmpty) {
            _updateParsedText(data['predictions'][0]['class']);
          } else {
            _updateParsedText('No disease detected.');
          }
          return;
        } else {
          _setErrorState('Error: ${response.reasonPhrase}');
        }
      } catch (e) {
        if (i == retryCount - 1) {
          _setErrorState('Exception: $e');
        }
      }
    }
  }

  void _updateParsedText(String detectedClass) {
    setState(() {
      print('Detected class: $detectedClass'); // Log the detected class for debugging
      parsedText = detectedClass;
      diseaseName = detectedClass != 'No disease detected.' ? detectedClass : null;
      isLoading = false;

      if (detectedClass.toLowerCase() == 'vitiligo') {
        medicationSuggestion = 'Suggested medications: Panadol, Disprine';
      } else if (detectedClass.toLowerCase() == 'warts') {
        medicationSuggestion = 'Suggested medications: Betnovate tube, Nivea cream';
      } else {
        medicationSuggestion = null;
      }
    });
  }

  void _setErrorState(String message) {
    setState(() {
      print('Error state: $message'); // Log error message for debugging
      parsedText = message;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Detection App'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'Disease Detection',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              if (selectedImage != null)
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(selectedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 15),
              _buildButton(
                'Upload an Image',
                parseText,
              ),
              const SizedBox(height: 15),
              Text(
                parsedText,
                style: const TextStyle(fontSize: 18),
              ),
              if (medicationSuggestion != null) ...[
                const SizedBox(height: 10),
                Text(
                  medicationSuggestion!,
                  style: const TextStyle(fontSize: 18, color: Colors.green),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Consulted by Dr. M. Huzaifa, MBBS',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Function() onPressed) {
    return Container(
      color: Colors.blue,
      width: MediaQuery.of(context).size.width / 2,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        onPressed: onPressed,
        child: isLoading
            ? const CircularProgressIndicator(
          color: Colors.white,
        )
            : Text(text),
      ),
    );
  }
}
