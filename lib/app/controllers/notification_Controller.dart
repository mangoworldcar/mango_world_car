import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  // 최신버전의 초기화 방법
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  Rx<RemoteMessage> remoteMessage = const RemoteMessage().obs;
  // remoteMessage 가 obx 에서 검출이 잘되지 않아서 dateTime 을 추가함
  Rx<DateTime> dateTime = DateTime.now().obs;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;

  bool isFlutterLocalNotificationsInitialized = false;

  @override
  void onInit() {
    _initNotification();
    // 토큰을 알면 특정 디바이스에게 문자를 전달가능
    _getToken();

    super.onInit();
  }

  void _getToken() {
    _messaging.getToken().then((token) {

    });
  }

  Future<void> _initNotification() async {

    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;

    // 앱이 동작중일때 호출됨
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      _addNotification(event);

    });
    // 앱이 background 동작중일때 호출됨, 종료중일때도 호출됨?
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // 메시지를 변수에 저장
  void _addNotification(RemoteMessage event) {
    dateTime(event.sentTime);
    //remoteMessage(event);
    showFlutterNotification(event);
    // debugPrint(event.toMap().toString());
  }


  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null ) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: android.smallIcon,
          ),
        ),
      );
    }
  }



  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();
    showFlutterNotification(message);
  }


}
