import 'package:image_picker/image_picker.dart';

class ImageFile {
  bool android;
  bool iOS;
  int progress;
  ImageFileStatus status;
  String fileName;
  List<int> fileBytes;

  ImageFile(
    this.fileBytes, {
    this.fileName = "image.png",
    this.android = true,
    this.iOS = true,
    this.progress = 0,
    this.status = ImageFileStatus.ADDED,
  });

  bool isUploading() => status == ImageFileStatus.UPLOADING;

  bool isFinished() => status == ImageFileStatus.FINISH;

  bool isAdded() => status == ImageFileStatus.ADDED;

  setUploading() {
    status = ImageFileStatus.UPLOADING;
  }
}

enum ImageFileStatus { ADDED, UPLOADING, FINISH }
