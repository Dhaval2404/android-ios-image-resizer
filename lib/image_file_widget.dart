import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:imageresizer/data/ImageFile.dart';
import 'package:imageresizer/util/file_util.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

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
                  constraints: BoxConstraints(
                      minWidth: 260,
                      maxWidth: 260),
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
                  imageFile.progress.toString() + "%",
                  style: new TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
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
                title: const Text('Android'),
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
                title: const Text('iOS'),
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
              child: Text(imageFile.isUploading() ? "Uploading" : "Upload"),
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
      imageFile.setUploading();
    }

    setState(() {});

    String url = "http://192.168.1.100:8080/ImageUploadDemo/image-resizer";

    Dio dio = new Dio();
/*

    var response = await dio.post(
      url,
      options: Options(responseType: ResponseType.bytes),
      data: FormData.fromMap({
        "android" : false,
        "ios" : true,
        "file": http.MultipartFile.fromBytes("file",imageFile.fileBytes,
            contentType: MediaType('image', '*'),
            filename: imageFile.fileName)
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
    saveFile(imageFile.fileName, response.data);

 */

    // await simpleGetCall(url);
     await uploadFile2(url, {"Authorization" : "Basic ABCD"}, imageFile.fileName, imageFile.fileBytes);
  }

  Future<http.Response> uploadFile2(String url, Map<String, String> headers,
      String fileName, List<int> fileBytes) async {
    print("Url:" + url);
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    print("D" + fileBytes.length.toString());

    request.fields["android"] = "true";
    request.fields["iso"] = "true";
    request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
    print("C");
    // request.headers.addAll(headers);
    print("B");
    var streamedResponse = await request.send();
    print("A");
    var response = await http.Response.fromStream(streamedResponse);

    print("A1:" + response.bodyBytes.length.toString());
    saveFile(fileName, response.bodyBytes);

    return response;
  }

  saveFile(String fileName, List<int> bytes) {
    // prepare
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName + '.zip';
    html.document.body.children.add(anchor);

    // download
    anchor.click();

    // cleanup
    html.document.body.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Future simpleGetCall(String url) async {
    print("Url:" + url);
    var value = await http.get(url);
    print("Response:" + value.body);
  }
}
