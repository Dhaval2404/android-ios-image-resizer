import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:imageresizer/data/image_file.dart';
import 'package:imageresizer/data/image_file_repo.dart';
import 'package:imageresizer/util/file_util.dart';
import 'package:imageresizer/util/firebase_analytics_util.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ImageFileWidget extends StatefulWidget {
  final ImageFile imageFile;

  ImageFileWidget(this.imageFile);

  @override
  _ImageFileWidgetState createState() => _ImageFileWidgetState();
}

class _ImageFileWidgetState extends State<ImageFileWidget> {
  @override
  Widget build(BuildContext context) {
    var imageFile = widget.imageFile;
    var isNotUploading = !imageFile.isUploading();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      color: Colors.grey[100],
      child: Container(
        padding: EdgeInsets.all(16),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 260, maxWidth: 260),
                child: Text(
                  imageFile.fileName,
                  maxLines: 1,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                FileUtil.getFileSize(imageFile.fileBytes.length),
                style: Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(color: Colors.green[500]),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 260),
              child: new LinearPercentIndicator(
                lineHeight: 16.0,
                percent: imageFile.progress / 100,
                center: Text(
                  'upload_progress'.plural(imageFile.progress),
                  style: new TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.grey,
                progressColor: Theme.of(context).primaryColor,
              ),
            ),
            Container(
              width: 150,
              height: 48,
              child: CheckboxListTile(
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text('platform_android'.tr()),
                value: imageFile.android,
                onChanged: (newValue) {
                  setState(() {
                    if (isNotUploading) imageFile.android = newValue;
                  });
                },
              ),
            ),
            Container(
              width: 120,
              height: 48,
              child: CheckboxListTile(
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text('platform_ios'.tr()),
                value: imageFile.iOS,
                onChanged: (newValue) {
                  setState(() {
                    if (isNotUploading) imageFile.iOS = newValue;
                  });
                },
              ),
            ),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(imageFile.isUploading()
                  ? 'status_uploading'.tr()
                  : 'status_upload'.tr()),
              onPressed: uploadFile,
            )
          ],
        ),
      ),
    );
  }

  uploadFile() async {
    var imageFile = widget.imageFile;

    FirebaseAnalyticsUtil.logEvent(name: "Upload File", parameters: {
      "android": imageFile.android,
      "ios": imageFile.iOS,
    });

    imageFile.progress = 0;
    if (!imageFile.android && !imageFile.iOS) {
      return;
    }

    if (!imageFile.isUploading()) {
      setState(() {
        imageFile.setUploading();
      });
    }

    imageFileRepo.uploadFileWithDio(imageFile, () {
      setState(() {});
    });
  }
}
