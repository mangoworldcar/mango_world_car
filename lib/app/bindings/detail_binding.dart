import 'package:get/get.dart';
import 'package:mango_world_car/app/controllers/detail_controller.dart';

class DetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(DetailController());
    // Get.lazyPut<HomeController>(() {
    //   return HomeController(
    //       repository:
    //       MyRepository(apiClient: MyApiClient(httpClient: http.Client())));
    // });


  }
}