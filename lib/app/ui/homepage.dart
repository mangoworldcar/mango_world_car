import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mango_world_car/app/controllers/home_controller.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../routes/app_pages.dart';

class HomePage extends GetView<HomeController> {

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  // WebViewController를 선언합니다.
  late WebViewController _webViewController;

  String strUrl = "";

  DateTime? currentBackPressTime;

  void _permission() async {

    Map<Permission,PermissionStatus> statuses = await [Permission.camera,Permission.storage].request();

    if((statuses[Permission.camera]!.isGranted  || statuses[Permission.camera]!.isLimited)
        && (statuses[Permission.storage]!.isGranted  || statuses[Permission.storage]!.isLimited) ){

    }
    else{
      openAppSettings();
    }
  }


  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
        child:
            Scaffold(
              body:
              SafeArea(
                child:
            Obx(() =>
                  WebView(
                   // initialUrl: "${controller.pageUrl.value}",
                    initialUrl: 'https://client.mangoworldcar.com${controller.pageUrl.value}',
                    debuggingEnabled: true,
                    userAgent: "mangoworld",
                    gestureNavigationEnabled: true,
                    zoomEnabled: false,
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller.complete(webViewController);
                      _webViewController = webViewController;
                      _permission();
                    },
                    javascriptChannels: <JavascriptChannel>{
                      _snackbarJavascriptChannel(context),
                      _moveToPageJavascriptChannel(context),
                      _moveToBackJavascriptChannel(context),
                    },
                  )
              )
            )
          ),
        onWillPop: _onWillPop,
      );
    }

  Future<bool> _onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: "Please click BACK again to exit",
        toastLength: Toast.LENGTH_LONG,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }



  JavascriptChannel _snackbarJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'snackbar',
        onMessageReceived: (JavascriptMessage message) {

          Map<String, dynamic> jsonMessage = jsonDecode(message.message);
          Get.snackbar(
            jsonMessage["header"],
            jsonMessage["title"],
            snackPosition: SnackPosition.BOTTOM,
            forwardAnimationCurve: Curves.elasticInOut,
            reverseAnimationCurve: Curves.easeOut,
          );
        });
    }

    JavascriptChannel _moveToPageJavascriptChannel(BuildContext context) {
      return JavascriptChannel(
          name: 'movetopage',
          onMessageReceived: (JavascriptMessage message) async {
            Map<String, dynamic> jsonMessage = jsonDecode(message.message);

            String strOpenType = jsonMessage["opentype"];
            String strMsg = jsonMessage["msg"];

            int randomNumber = Random().nextInt(100) + 1;
            if(strOpenType == "closeall") {

              //Get.until((route) => Get.currentRoute == Routes.INITIAL);
              //Get.toNamed(Routes.DETAILS, arguments:{"url",jsonMessage["url"]} );
              _webViewController.loadUrl("https://client.mangoworldcar.com" + jsonMessage["url"]);

              //_webViewController.reload();

            }
            else{

              var resultData = await Get.toNamed(Routes.DETAILS+ "?Ran=" + randomNumber.toString(), arguments:{"url": Uri.encodeComponent(jsonMessage["url"])} );

              if(resultData == "reload"){
                _webViewController.reload();
              }

            }
            if(strMsg.isNotEmpty && strMsg != "" ) {
              Fluttertoast.showToast(
                msg: strMsg,
                toastLength: Toast.LENGTH_SHORT,
              );
            }
          });
    }

    JavascriptChannel _moveToBackJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'movetoback',
        onMessageReceived: (JavascriptMessage message) async {
          Map<String, dynamic> jsonMessage = jsonDecode(message.message);

          bool bReload = jsonMessage["breload"];
          String strMsg = jsonMessage["msg"];

          if(bReload) {

            //Get.until((route) => Get.currentRoute == Routes.INITIAL);
            //Get.toNamed(Routes.DETAILS, arguments:{"url",jsonMessage["url"]} );
            Get.back(result: "reload");

          }
          else{
            Get.back();
          }

          if(strMsg.isNotEmpty && strMsg != "" ) {
            Fluttertoast.showToast(
              msg: strMsg,
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        });
    }
}