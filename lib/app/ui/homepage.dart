import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mango_world_car/app/controllers/home_controller.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';


import '../routes/app_pages.dart';

class HomePage extends GetView<HomeController> {

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  // WebViewController를 선언합니다.
  late WebViewController _webViewController;

  String strUrl = "";

  DateTime? currentBackPressTime;

  void _permission() async {

    Map<Permission,PermissionStatus> statuses = await [Permission.camera,Permission.storage,Permission.microphone].request();

    if((statuses[Permission.camera]!.isGranted  )
        && (statuses[Permission.storage]!.isGranted )&& (statuses[Permission.microphone]!.isGranted ) ){

    }
    else{
     //openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {

    return
      WillPopScope(
        child:
            Scaffold(
                backgroundColor:Colors.white,
                resizeToAvoidBottomInset: true,
                body:
                  SafeArea(
                    child:
                      Obx(() {
                        return Opacity(
                          opacity: this.controller.isLoading.value ? 0:1,
                          child: WebView(
                          initialUrl: 'https://stageclient.mangoworldcar.com${controller.pageUrl.value}',
                          debuggingEnabled: false,
                          userAgent: "mangoworld",
                          gestureNavigationEnabled: true,
                          zoomEnabled: false,
                          javascriptMode: JavascriptMode.unrestricted,
                          backgroundColor:Colors.white,
                          onWebViewCreated: (WebViewController webViewController) {
                            if(this.controller.m_b_controllComplete == false){
                              _controller.complete(webViewController);
                              _webViewController = webViewController;
                              _permission();
                              //this.controller.signInWithGoogle();
                              this.controller.m_b_controllComplete.value = true;
                            }
                          },
                          onPageFinished: (String url) {
                            if (this.controller.isLoading.value) {
                              this.controller.isLoading.value = false;
                            }
                          },
                          navigationDelegate: (NavigationRequest request) {
                            if (request.url.startsWith('https://wa.me') || request.url.startsWith('https://admin.mangoworldcar.com')) {
                               launch(request.url); 
                               return NavigationDecision.prevent;
                            }
                            return NavigationDecision.navigate;
                          },
                          javascriptChannels: <JavascriptChannel>{

                            _snackbarJavascriptChannel(context),
                            _moveToPageJavascriptChannel(context),
                            _moveToBackJavascriptChannel(context),
                            _getFcmToken(context),
                            // _fileDownloadJavascriptChannel(context),
                            _getGoogleLogin(context),
                            _getAppleLogin(context),
                            _setCopyText(context)
                          },
                      )
                    );

                    }
                  )
            )
          ),
        onWillPop: _onWillPop,
      );
    }

  Future<bool> _onWillPop() async {

    if(Platform.isAndroid){

      var strCurrentUrl = await _webViewController.currentUrl();
      if(strCurrentUrl!.isNotEmpty
          && !(strCurrentUrl!.toLowerCase().contains("/login") || strCurrentUrl!.toLowerCase() == "https://stagestageclient.mangoworldcar.com/main" || strCurrentUrl!.toLowerCase().contains("/firstlanguegechoice") ) ){

        _webViewController.goBack();

        return Future.value(false);
      }
      else{
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
    }else{
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

  JavascriptChannel _getFcmToken(BuildContext context){
      return JavascriptChannel(
          name: 'getfcmtoken',
          onMessageReceived: (JavascriptMessage message) async {

            FirebaseMessaging.instance.getToken().then((token) {

              String javaScriptString = "fn_getFcmToken('"+token!+"')";

              _webViewController.runJavascript(javaScriptString);
            });



          });
    }

  JavascriptChannel _getGoogleLogin(BuildContext context){
    return JavascriptChannel(
        name: 'getGoogleLogin',
        onMessageReceived: (JavascriptMessage message) async {

          await this.controller.signInWithGoogle().then((value) {

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
            await this.controller.signInWithApple().then((value) {

              String javaScriptString = "m_loginModule.fn_getAppleAccessKey('"+value+"')";
              _webViewController.runJavascript(javaScriptString);
            });
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

  JavascriptChannel _moveToPageJavascriptChannel(BuildContext context) {

    String strName = "movetopage";

    if(Platform.isAndroid){
      //strName = "androidmovetopage";
    }

    return JavascriptChannel(
        name: strName,
        onMessageReceived: (JavascriptMessage message) async {
          Map<String, dynamic> jsonMessage = jsonDecode(message.message);

          String strOpenType = jsonMessage["opentype"];
          String strMsg = jsonMessage["msg"];

          int randomNumber = Random().nextInt(100) + 1;
          if(strOpenType == "closeall") {

            //Get.until((route) => Get.currentRoute == Routes.INITIAL);
            //Get.toNamed(Routes.DETAILS, arguments:{"url",jsonMessage["url"]} );
            _webViewController.loadUrl("https://stagestageclient.mangoworldcar.com" + jsonMessage["url"]);

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

    String strName = "movetoback";

    if(Platform.isAndroid){
      //strName = "androidmovetoback";
    }

    return JavascriptChannel(
      name: strName,
      onMessageReceived: (JavascriptMessage message) async {
        Map<String, dynamic> jsonMessage = jsonDecode(message.message);

        bool bReload = jsonMessage["breload"];
        String strMsg = jsonMessage["msg"];

        if(bReload) {

          //Get.until((route) => Get.currentRoute == Routes.INITIAL);
          //Get.toNamed(Routes.DETAILS, arguments:{"url",jsonMessage["url"]} );

          /*if(Platform.isAndroid) {

            await _webViewController.goBack();
            Future.delayed(Duration(milliseconds: 100), () {

              _webViewController.reload();
              // Do something
            });


          }
          else{
            Get.back(result: "reload");
          }*/


          Get.back(result: "reload");
        }
        else{
          /*if(Platform.isAndroid) {
            _webViewController.goBack();
          }
          else{
            Get.back();
          }*/

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



  // JavascriptChannel _fileDownloadJavascriptChannel(BuildContext context) {

  //   return JavascriptChannel(
  //       name: "filedownload",
  //       onMessageReceived: (JavascriptMessage message) async {
  //         Map<String, dynamic> jsonMessage = jsonDecode(message.message);

  //         String strUrl = jsonMessage["url"];
  //         String strFileName = jsonMessage["filename"];

  //         this.controller.onDownloadFile(strUrl, strFileName);
  //       });
  // }
}