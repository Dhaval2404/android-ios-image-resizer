import 'dart:html';

abstract class FilePickerListener {
  void onFilePicked(List<File> files);
}