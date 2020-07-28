import 'package:image_picker/image_picker.dart';
import 'package:imageresizer/data/ImageFile.dart';

class IntentUtil {

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
