// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_picker/gallery_picker.dart';
import 'package:gallery_picker/models/media_file.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? selectedFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUi(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<MediaFile>? medias = await GalleryPicker.pickMedia(
              context: context, singleMedia: true);
          if (medias != null && medias.isNotEmpty) {
            var data = await medias.first.getFile();
            setState(() {
              selectedFile = data;
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildUi() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _imageView(),
        _extractTextView(),
      ],
    );
  }

  Widget _imageView() {
    return Container(
      width: 300,
      height: 300,
      child: selectedFile != null
          ? Center(child: Image.file(selectedFile!))
          : Center(
              child: Container(
                child: Text("Pick Image"),
              ),
            ),
    );
  }

  Widget _extractTextView() {
    if (selectedFile == null) {
      return Container(
        child: Text("No Result"),
      );
    }
    return FutureBuilder(
        future: extractText(selectedFile!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: Text(snapshot.data.toString()),
            );
          } else if (snapshot.hasError) {
            return Container(
              child: Text(snapshot.error.toString()),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              child: Text("Loading..."),
            );
          } else {
            return Container(
              child: Text("No Result"),
            );
          }
        });
  }

  Future<String?> extractText(File file) async {
    final textRecognixer = TextRecognizer(script: TextRecognitionScript.latin);
    final InputImage inputImage = InputImage.fromFile(file);
    final RecognizedText recognizedText =
        await textRecognixer.processImage(inputImage);
    String text = recognizedText.text;
    print(recognizedText.text);
    textRecognixer.close();
    return text;
  }
}
