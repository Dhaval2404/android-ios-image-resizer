import 'package:image_picker/image_picker.dart';
import 'package:imageresizer/data/ImageFile.dart';
import 'package:url_launcher/url_launcher.dart';

class IntentUtil {

  static Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  /// Support Web, Android, iOS
  static Future<ImageFile> pickImage() async {
    final _picker = ImagePicker();
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      var bytes = await pickedFile.readAsBytes();
      return ImageFile(List.from(bytes), fileName: "");
    }
    return null;
  }
}
