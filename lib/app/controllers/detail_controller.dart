import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:flutter_webview_pro/webview_flutter.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DetailController extends GetxController {

  @override
  void onInit() {
    super.onInit();

    if (Platform.isAndroid) WebView.platform = AndroidWebView();


    //FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Future<void> onDownloadFile(String strUrl , String strFileName)
  // async {

  //   String dir = (await getApplicationDocumentsDirectory()).path; 	//path provider로 저장할 경로 가져오기
  //   try{
  //     await FlutterDownloader.enqueue(
  //       url: "https://admin.mangoworldcar.com$strUrl", 	// file url
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

  static void downloadCallback(
      String id, int status, int progress) {
   // print('Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    //final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    //send.send([id, status, progress]);
  }

}