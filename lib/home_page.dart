import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'data/ImageFile.dart';
import 'image_file_widget.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'dart:html' as html;
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as Path;

List<ImageFile> IMAGE_FILES = <ImageFile>[];

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Android & iOS Image Builder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(child: _body()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImage2,
        label: Text('Pick Image'),
        icon: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _body() {
    return Card(
        margin: EdgeInsets.all(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: _body2());
  }

  Widget _body2() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: IMAGE_FILES.length,
        itemBuilder: (context, index) {
          return ImageFileWidget(IMAGE_FILES[index]);
        },
      ),
    );
  }

  _pickImage() async {
    final _picker = ImagePicker();
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    var bytes = await pickedFile.readAsBytes();
    var imageFile = ImageFile(List.from(bytes), fileName: "");
    IMAGE_FILES.add(imageFile);
    setState(() {});
  }

  _pickImage2() async {
    var mediaData = await ImagePickerWeb.getImageInfo;
    String mimeType = mime(Path.basename(mediaData.fileName));
    html.File mediaFile =
        new html.File(mediaData.data, mediaData.fileName, {'type': mimeType});

    if (mediaFile != null) {
      print(mediaFile.name);
      var imageFile = ImageFile(List.from(mediaData.data), fileName: mediaFile.name);
      IMAGE_FILES.add(imageFile);
      setState(() {

      });
    }else{
      print("mediaFile is null");
    }
  }
}
