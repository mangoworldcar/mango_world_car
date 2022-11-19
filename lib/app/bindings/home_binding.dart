import 'package:get/get.dart';
import 'package:mango_world_car/app/controllers/home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
    // Get.lazyPut<HomeController>(() {
    //   return HomeController(
    //       repository:
    //       MyRepository(apiClient: MyApiClient(httpClient: http.Client())));
    // });


  }
}