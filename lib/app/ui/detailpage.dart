import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
//import 'package:mango_world_car/app/controllers/home_controller.dart';

import 'package:mango_world_car/app/controllers/detail_controller.dart';
import 'package:mango_world_car/app/controllers/home_controller.dart';
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(child: WebView(
          initialUrl: 'https://client.mangoworldcar.com${Uri.decodeComponent(Get.arguments["url"])}',
          debuggingEnabled: false,
          userAgent: "mangoworld",
          gestureNavigationEnabled: false,
          //allowsInlineMediaPlayback: false,
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
            _fileDownloadJavascriptChannel(context),
            _getGoogleLogin(context),
            _getAppleLogin(context),
            _setCopyText(context)
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
           // var resultData = Get.offNamedUntil(Routes.DETAILS+ "?Ran=" + randomNumber.toString() , (route) => (route as GetPageRoute).routeName == Routes.DETAILS,arguments: {"url": Uri.encodeComponent(jsonMessage["url"])});

          var resultData = Get.offNamedUntil(Routes.DETAILS+ "?Ran=" + randomNumber.toString(), ModalRoute.withName(Routes.INITIAL),arguments: {"url": Uri.encodeComponent(jsonMessage["url"])});
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


  JavascriptChannel _setCopyText(BuildContext context){
    return JavascriptChannel(
        name: 'setCopyText',
        onMessageReceived: (JavascriptMessage message) async {

          Map<String, dynamic> jsonMessage = jsonDecode(message.message);

          Clipboard.setData(ClipboardData(text: jsonMessage["text"]));


        });
  }

  JavascriptChannel _fileDownloadJavascriptChannel(BuildContext context) {

    return JavascriptChannel(
        name: "filedownload",
        onMessageReceived: (JavascriptMessage message) async {
          Map<String, dynamic> jsonMessage = jsonDecode(message.message);

          String strUrl = jsonMessage["url"];
          String strFileName = jsonMessage["filename"];

          Get.find<DetailController>().onDownloadFile(strUrl, strFileName);
        });
  }

  JavascriptChannel _getGoogleLogin(BuildContext context){
    return JavascriptChannel(
        name: 'getGoogleLogin',
        onMessageReceived: (JavascriptMessage message) async {

          await Get.find<HomeController>().signInWithGoogle().then((value) {

            String javaScriptString = "m_loginModule.fn_getGoogleAccessKey('"+value+"')";

            _webViewController.runJavascript(javaScriptString);
          });
        });
  }


  JavascriptChannel _getAppleLogin(BuildContext context){
    return JavascriptChannel(
        name: 'getAppleLogin',
        onMessageReceived: (JavascriptMessage message) async {

          if(Platform.isAndroid){

            String javaScriptString = "m_loginModule.fn_setAppleWebLogin()";
            _webViewController.runJavascript(javaScriptString);

          }
          else{
            await Get.find<HomeController>().signInWithApple().then((value) {

              String javaScriptString = "m_loginModule.fn_getAppleAccessKey('"+value+"')";
              _webViewController.runJavascript(javaScriptString);
            });
          }

        });
  }
}