import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:imageresizer/util/html_util.dart';

import 'app_constant.dart';
import 'data/image_file.dart';
import 'image_file_widget.dart';
import 'util/intent_util.dart';

List<ImageFile> IMAGE_FILES = <ImageFile>[];

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> _actions() {
    return <Widget>[
      FlatButton(
        onPressed: () {
          IntentUtil.launchURL(AppConstant.GITHUB_URL);
        },
        child: Text(
          'action_github'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'app_name'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: _actions(),
      ),
      body: _body(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImageClick,
        label: Text('action_pick_image'.tr()),
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
          Text(
            'empty_view_title'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'empty_view_subtitle'.tr(),
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 20),
            ),
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

  _pickImageClick() async {
    var imageFile = await HtmlUtil.pickImage();
    if (imageFile != null) {
      setState(() {
        IMAGE_FILES.add(imageFile);
      });
    }
  }
}
