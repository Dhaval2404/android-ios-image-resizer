import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:imageresizer/app_constant.dart';
import 'package:imageresizer/data/image_file.dart';
import 'package:imageresizer/util/html_util.dart';

ImageFileRepo imageFileRepo = ImageFileRepoImpl();

abstract class ImageFileRepo {
  Future dummyGetCall();

  Future uploadFileWithDio(ImageFile imageFile, VoidCallback callback);

  Future uploadFileWithDefault(ImageFile imageFile, VoidCallback callback);
}

class ImageFileRepoImpl implements ImageFileRepo {
  @override
  Future uploadFileWithDio(ImageFile imageFile, VoidCallback callback) async {
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
        imageFile.progress = ((sent * 100) / total).floor();
        callback.call();
      },
    );

    imageFile.status = ImageFileStatus.FINISH;
    callback.call();

    if (response.data != null) {
      HtmlUtil.saveFile(fileName, response.data);
    }
  }

  @override
  Future uploadFileWithDefault(
      ImageFile imageFile, VoidCallback callback) async {
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

    imageFile.progress = 100;
    imageFile.status = ImageFileStatus.FINISH;
    callback.call();

    if (response.bodyBytes != null) {
      HtmlUtil.saveFile(fileName, response.bodyBytes);
    }
  }

  @override
  Future dummyGetCall() async {
    String url = AppConstant.IMAGE_RESIZER_URL;
    print("Url:" + url);
    var value = await http.get(url);
    print("Response:" + value.body);
  }
}
