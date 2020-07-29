import 'dart:html' as html;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as Path;

import 'app_constant.dart';
import 'data/ImageFile.dart';
import 'image_file_widget.dart';
import 'util/intent_util.dart';

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
          'app_name'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          FlatButton(
            onPressed: () {
              IntentUtil.launchURL(AppConstant.GITHUB_URL);
            },
            child: Text(
              "Source on Github",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: _body(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImage2,
        label: Text('Pick Image'),
        icon: Icon(Icons.photo),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _body() {
    var margin = MediaQuery.of(context).size.width * 0.05;
    return Container(
      child: Card(
          margin: EdgeInsets.all(margin),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: IMAGE_FILES.isEmpty ? _emptyView() : _imageListing()),
    );
  }

  Widget _emptyView() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("PICK IMAGE TO RESIZE",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
                "The page will helps you re-size your Android and iOS image assets. Upload your maximum resolution image in PNG, JPG or WEBP format, and you'll get back a .ZIP file with the image assets re-sized.",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 20)),
          )
        ],
      ),
    );
  }

  Widget _imageListing() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemCount: IMAGE_FILES.length,
        itemBuilder: (context, index) {
          return ImageFileWidget(IMAGE_FILES[index]);
        },
      ),
    );
  }

  _pickImage2() async {
    var mediaData = await ImagePickerWeb.getImageInfo;
    String mimeType = mime(Path.basename(mediaData.fileName));
    html.File mediaFile =
        new html.File(mediaData.data, mediaData.fileName, {'type': mimeType});

    if (mediaFile != null) {
      print(mediaFile.name);
      setState(() {
        var imageFile =
            ImageFile(List.from(mediaData.data), fileName: mediaFile.name);
        IMAGE_FILES.add(imageFile);
      });
    }
  }
}
