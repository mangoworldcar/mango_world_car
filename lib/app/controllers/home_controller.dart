import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';


import 'package:path_provider/path_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class HomeController extends GetxController {
  //0 = No Internet, 1 = WIFI Connected ,2 = Mobile Data Connected.
  var connectionType = 0.obs;

  RxString pageUrl = "".obs;
  RxBool m_b_controllComplete = false.obs;


  final Connectivity _connectivity = Connectivity();

  late StreamSubscription _streamSubscription;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();


    if(args != null && args["url"] != null){
      pageUrl(Uri.decodeComponent(args["url"]));
    }


    //FlutterDownloader.registerCallback(downloadCallback);

    getConnectivityType();
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen(_updateState);

    //onDownloadFile();
    update();


  }


  _updateState(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        connectionType.value = 1;
        break;
      case ConnectivityResult.mobile:
        connectionType.value = 2;

        break;
      case ConnectivityResult.none:
        connectionType.value = 0;
        break;

    }
  }



  Future<void> getConnectivityType() async {
    late ConnectivityResult connectivityResult;
    try {
      connectivityResult = await (_connectivity.checkConnectivity());
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return _updateState(connectivityResult);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();

    _streamSubscription.cancel();

  }

  // Future<void> onDownloadFile(String strUrl , String strFileName)
  // async {

  //   String dir = (await getApplicationDocumentsDirectory()).path; 	//path provider로 저장할 경로 가져오기
  //   try{
  //     await FlutterDownloader.enqueue(
  //       url: "https://admin.mangoworldcar.com/$strUrl", 	// file url
  //       savedDir: '$dir/',	// 저장할 dir
  //       fileName: strFileName,	// 파일명
  //       showNotification: true,
  //       openFileFromNotification: true,
  //       saveInPublicStorage: true ,	// 동일한 파일 있을 경우 덮어쓰기 없으면 오류발생함!
  //     );

  //     await FlutterDownloader.loadTasks();

  //     Fluttertoast.showToast(
  //       msg: "File Download",
  //       toastLength: Toast.LENGTH_SHORT,
  //     );
  //     //print("파일 다운로드 완료");
  //   }catch(e){

  //     Fluttertoast.showToast(
  //       msg: "File Download Error",
  //       toastLength: Toast.LENGTH_SHORT,
  //     );
  //     //print("eerror :::: $e");
  //   }

  // }


  Future<String> signInWithGoogle() async {
    try{

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential _userCredential = await FirebaseAuth.instance.signInWithCredential(credential);


      return _userCredential.user?.uid ?? "";
    }
    catch(e){
      return "";
    }

  }


  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) =>
    charset[random.nextInt(charset.length)]).join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String> signInWithApple() async {

    try{
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      //앱에서 애플 로그인 창을 호출하고, apple계정의 credential을 가져온다.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        /*webAuthenticationOptions: WebAuthenticationOptions(
            clientId: "com.aig.mangoworldcar.appleauth",
            redirectUri: Uri.parse(
                "https://mangoworldcar.firebaseapp.com/__/auth/handler"))*/
      );


      //그 credential을 넣어서 OAuth를 생성
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );


      UserCredential _userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);


      return _userCredential.user?.uid ?? "";

    }
    catch(e)
    {
      return "";
    }
  }

  static void downloadCallback(
      String id, int status, int progress) {
    //print('Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    //final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    //send.send([id, status, progress]);
  }

}