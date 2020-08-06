import 'dart:html' as html;

import 'package:image_picker_web/image_picker_web.dart';
import 'package:imageresizer/data/image_file.dart';
import 'package:imageresizer/util/file_util.dart';

class HtmlUtil {
  static Future<ImageFile> pickImage() async {
    var mediaData = await ImagePickerWeb.getImageInfo;

    if (mediaData != null) {
      var fileName = mediaData.fileName;
      if (FileUtil.getFileSizeInMB(mediaData.data.length) > 3.5) {
        throw FormatException("Maximum upload size in 3.5MB!");
      } else if (!fileName.endsWith("png") &&
          !fileName.endsWith("jpg") &&
          !fileName.endsWith("jpeg") &&
          !fileName.endsWith("jfif")) {
        throw FormatException("Only PNG and JPG images are supported!");
      } else {
        return ImageFile(List.from(mediaData.data), fileName: fileName);
      }
    }
    return null;
  }

  static saveFile(String fileName, List<int> bytes) {
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

}
