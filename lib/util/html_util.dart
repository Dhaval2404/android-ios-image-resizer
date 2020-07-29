import 'dart:html' as html;

import 'package:image_picker_web/image_picker_web.dart';
import 'package:imageresizer/data/image_file.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as Path;

class HtmlUtil {

  static Future<ImageFile> pickImage() async {
    var mediaData = await ImagePickerWeb.getImageInfo;
    String mimeType = mime(Path.basename(mediaData.fileName));
    html.File mediaFile =
        new html.File(mediaData.data, mediaData.fileName, {'type': mimeType});

    if (mediaFile != null) {
      print(mediaFile.name);
      return ImageFile(List.from(mediaData.data), fileName: mediaFile.name);
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
