import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';

import '../routes/app_pages.dart';

class DetailPage extends StatefulWidget{

  const DetailPage({Key? key}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPage();

}


class _DetailPage extends State<DetailPage> {

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  late WebViewController _webViewController;

  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(child: WebView(
          initialUrl: 'https://client.mangoworldcar.com${Uri.decodeComponent(Get.arguments["url"])}',
          debuggingEnabled: true,
          userAgent: "mangoworld",
          gestureNavigationEnabled: true,
          zoomEnabled: false,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
            _webViewController = webViewController;
          },
          javascriptChannels: <JavascriptChannel>{
            _snackbarJavascriptChannel(context),
            _moveToPageJavascriptChannel(context),
            _moveToBackJavascriptChannel(context),
          },
        ),
        )
    );
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

            var resultData = Get.offAllNamed(Routes.INITIAL+ "?Ran=" + randomNumber.toString() ,arguments: {"url": Uri.encodeComponent(jsonMessage["url"])});

            if(resultData == "reload"){
              _webViewController.reload();
            }

          }else if(strOpenType == "onlyone"){
            var resultData = Get.offNamedUntil(Routes.DETAILS+ "?Ran=" + randomNumber.toString() , (route) => (route as GetPageRoute).routeName == Routes.INITIAL,arguments: {"url": Uri.encodeComponent(jsonMessage["url"])});

            if(resultData == "reload"){
              _webViewController.reload();
            }
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