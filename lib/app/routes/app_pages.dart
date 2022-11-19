import 'package:get/get.dart';
import 'package:mango_world_car/app/bindings/home_binding.dart';
import 'package:mango_world_car/app/bindings/detail_binding.dart';
import 'package:mango_world_car/app/ui/homepage.dart';
import 'package:mango_world_car/app/ui/detailpage.dart';
part './app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
        name: Routes.INITIAL, page: () => HomePage(), binding: HomeBinding()),
    GetPage(
        name: Routes.DETAILS,
        page: () => DetailPage(),
        binding: DetailBinding()),
  ];
}