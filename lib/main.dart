import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp( MyApp());
}
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);

    return GetMaterialApp(
      smartManagement: SmartManagement.keepFactory,
      title: 'Mango World Car',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'HelveticaNeue',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        //visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Routes.INITIAL,
      //home: Get.toNamed(""),
      getPages:AppPages.pages,

    );
  }
}
