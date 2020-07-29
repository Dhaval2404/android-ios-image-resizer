import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:imageresizer/app_constant.dart';
import 'package:imageresizer/data/image_file.dart';
import 'package:imageresizer/util/file_util.dart';
import 'package:imageresizer/util/html_util.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:easy_localization/easy_localization.dart';

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
                  )),
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
    if (!imageFile.android && !imageFile.iOS) {
      return;
    }

    if (!imageFile.isUploading()) {
      setState(() {
        imageFile.setUploading();
      });
    }

    // await dummyGetCall();
    // await uploadFileWithDefault(imageFile);
    await uploadFileWithDio(imageFile);
  }

  Future uploadFileWithDio(ImageFile imageFile) async {
    String fileName = imageFile.fileName;
    List<int> fileBytes = imageFile.fileBytes;

    Dio dio = new Dio();
    var response = await dio.post(
      AppConstant.IMAGE_RESIZER_URL,
      options: Options(responseType: ResponseType.bytes),
      data: FormData.fromMap({
        "android": imageFile.android,
        "ios": imageFile.iOS,
        "file": MultipartFile.fromBytes(fileBytes, filename: fileName),
      }),
      onSendProgress: (int sent, int total) {
        setState(() {
          imageFile.progress = ((sent * 100) / total).floor();
        });
      },
    );

    setState(() {
      imageFile.status = ImageFileStatus.FINISH;
    });

    if (response.data != null) {
      HtmlUtil.saveFile(fileName, response.data);
    }
  }

  Future uploadFileWithDefault(ImageFile imageFile) async {
    String fileName = imageFile.fileName;
    List<int> fileBytes = imageFile.fileBytes;

    var uri = Uri.parse(AppConstant.IMAGE_RESIZER_URL);
    var request = new http.MultipartRequest("POST", uri);

    var file =
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName);
    request.fields["android"] = imageFile.android.toString();
    request.fields["iso"] = imageFile.iOS.toString();
    request.files.add(file);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    setState(() {
      imageFile.progress = 100;
      imageFile.status = ImageFileStatus.FINISH;
    });

    if (response.bodyBytes != null) {
      HtmlUtil.saveFile(fileName, response.bodyBytes);
    }
  }

  Future dummyGetCall() async {
    String url = AppConstant.IMAGE_RESIZER_URL;
    print("Url:" + url);
    var value = await http.get(url);
    print("Response:" + value.body);
  }
}
