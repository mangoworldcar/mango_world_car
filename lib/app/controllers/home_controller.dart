import 'package:get/get.dart';

class HomeController extends GetxController {

  RxString pageUrl = "".obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if(args != null && args["url"] != null){
      pageUrl(Uri.decodeComponent(args["url"]));
    }

    update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}