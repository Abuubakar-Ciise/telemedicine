// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:tele/controllers/user_Controller.dart';
// import 'package:tele/controllers/internet_controller.dart';
// import 'package:tele/controllers/doctor_transection_controller.dart';
// import 'package:tele/routes/app_routes.dart';
// import 'package:tele/services/StorageService.dart';
// // import 'package:tele/services/firebase_notification_handler.dart';
// import 'package:tele/services/notification_service.dart';
// import 'package:tele/services/notification_debug_helper.dart';
// import 'package:tele/services/get_api_services.dart';
// import 'package:tele/views/screens/CallPage/firebase_api.dart';
// import 'package:tele/views/screens/NoInternetConnection.dart';
// import 'package:tele/views/screens/components/config.dart';
// import 'package:toastification/toastification.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// @pragma('vm:entry-point') // required for background message handler
// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   await Firebase.initializeApp();

//   print('Handling background message: ${message.messageId}');
//   print('Background message data: ${message.data}');

//   // Always show local notification for background messages
//   // This overrides any system notification from FCM
//   print('🔔 DEBUG: Background message received - showing local notification');

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails(
//     'default_channel',
//     'Default',
//     channelDescription: 'General notifications',
//     importance: Importance.high,
//     priority: Priority.high,
//   );

//   const NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);

//   await flutterLocalNotificationsPlugin.show(
//     message.hashCode,
//     message.notification?.title ?? 'New Appointment',
//     message.notification?.body ?? 'You have a new appointment update',
//     platformChannelSpecifics,
//     payload: jsonEncode(message.data),
//   );
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: '.env');
//   await Firebase.initializeApp(
//     options: FirebaseOptions(
//       apiKey: Config.firebaseapkey,
//       appId: Config.firebaseappid,
//       messagingSenderId: Config.firebasemessagingsenderid,
//       projectId: Config.firebaseprojectid,
//     ),
//   );

//   const AndroidNotificationChannel callChannel = AndroidNotificationChannel(
//     'call_channel',
//     'Call Notifications',
//     description: 'Channel used for incoming call notifications',
//     importance: Importance.high,
//   );

//   const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
//     'default_channel',
//     'Default',
//     description: 'General notifications',
//     importance: Importance.high,
//   );

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(callChannel);

//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(defaultChannel);

//   final accessToken = await AccessTokenService().getAccessToken();
//   final token = await FirebaseMessaging.instance.getToken();

//   if (accessToken == null) {
//     print("Failed to get access token.");
//     return;
//   }

//   print("this Your accessToken  $accessToken");
//   print("this Your token  $token");

//   Get.put(UserController());
//   Get.put(DoctorTransectionController());
//   Get.put(InternetController(), permanent: true);

//   FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//   // Remove duplicate notification initialization - it's handled in MyApp
//   // await FirebaseNotification().initNotification();

//   ZegoUIKit().init(appID: Config.appId, appSign: Config.appSign);

//   Map<String, String?> userData = await StorageService.getUserData();
//   final userId = userData["userId"];
//   if (userId != null) {
//     await ApiGetServices.updateFcmToken(userId);
//   }

//   FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
//     final userData = await StorageService.getUserData();
//     final userId = userData["userId"];
//     if (userId != null) {
//       await ApiGetServices.updateFcmToken(userId);
//     }
//   });

//   runApp(ToastificationWrapper(
//     child: MyApp(),
//   ));
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final handler = FirebaseNotificationHandler(navigatorKey);
//       await handler.initNotification();

//       // Remove duplicate notification handling - it's already handled in FirebaseNotificationHandler
//       // await _handleInitialNotification(handler);
//       // await _handlePendingNotification(handler);
//     });
//   }

//   Future<void> _handleInitialNotification(FirebaseNotificationHandler handler) async {
//     RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       await NotificationDebugHelper.logNotificationEvent(
//         'App launched by notification',
//         initialMessage.data
//       );
//       // Delay navigation to ensure app is fully initialized
//       await Future.delayed(Duration(milliseconds: 1000));
//       await handler.handleNotificationNavigation(initialMessage.data);
//     }
//   }

//   Future<void> _handlePendingNotification(FirebaseNotificationHandler handler) async {
//     final notificationData = await NotificationService.getPendingNotification();

//     if (notificationData != null) {
//       await NotificationDebugHelper.logNotificationEvent(
//         'Handling pending notification from background',
//         notificationData
//       );

//       // Delay navigation to ensure app is fully initialized
//       await Future.delayed(Duration(milliseconds: 1000));
//       await handler.handleNotificationNavigation(notificationData);
//     }
//   }

//   Future<String?> _isLoggedIn() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('auth_token');
//     String? userType = prefs.getString('userType');
//     if (token != null && token.isNotEmpty) {
//       return userType;
//     } else {
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _isLoggedIn(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return MaterialApp(
//             home: Scaffold(
//               body: Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     Color.fromARGB(255, 9, 130, 13),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         } else {
//           String? userType = snapshot.data;
//           String initialRoute = '/login';
//           if (userType == "0") {
//             initialRoute = '/doctormainscreen';
//           } else if (userType == "1") {
//             initialRoute = '/mainscreen';
//           }

//           return GetMaterialApp(
//             navigatorKey: navigatorKey,
//             debugShowCheckedModeBanner: false,
//             initialRoute: initialRoute,
//             getPages: AppRoutes.routes,
//           );
//         }
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tele/controllers/user_Controller.dart';
import 'package:tele/controllers/doctor_transection_controller.dart';
import 'package:tele/controllers/language_controller.dart';
import 'package:tele/routes/app_routes.dart';
import 'package:tele/services/StorageService.dart';
import 'package:tele/services/get_api_services.dart';
import 'package:tele/services/firebase_notification_handler.dart';
import 'package:tele/services/background_message_handler.dart';
import 'package:tele/views/screens/CallPage/firebase_api.dart';
import 'package:tele/views/screens/components/config.dart';
import 'package:tele/views/screens/CallPage/call_helpers.dart';
import 'package:tele/theme/app_theme.dart';
import 'dart:io';
import 'package:toastification/toastification.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// ignore: depend_on_referenced_packages
import 'package:zego_uikit/zego_uikit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
/// Every HTTP request in the app gives up connecting after 8 seconds, so screens
/// show an error quickly instead of staying blank when the server is off/unreachable.
class _AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => super.createHttpClient(context)
    ..connectionTimeout = const Duration(seconds: 8)
    ..idleTimeout = const Duration(seconds: 15);
}

Future<void> main() async {
  HttpOverrides.global = _AppHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Config.ensureLoaded();
  // Push notifications must never stop the app from opening, so every
  // Firebase step below is allowed to fail (e.g. no Google Play services).
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(options: Config.firebaseOptions);
    firebaseReady = true;
  } catch (e) {
    debugPrint('⚠️ Firebase init failed: $e');
  }
  const AndroidNotificationChannel callChannel = AndroidNotificationChannel(
    'call_channel',
    'Call Notifications',
    description: 'Channel used for incoming call notifications',
    importance: Importance.high,
  );
  const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
    'default_channel',
    'Default',
    description: 'General notifications',
    importance: Importance.high,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(callChannel);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(defaultChannel);
  Get.put(UserController());
  Get.put(DoctorTransectionController());
  // Get.put(InternetController(), permanent: true);
  Get.put(LanguageController(), permanent: true);
  if (firebaseReady) {
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
  ZegoUIKit().init(appID: Config.appId, appSign: Config.appSign);
  Map<String, String?> userData = await StorageService.getUserData();
  final userId = userData["userId"];
  RemoteMessage? initialMessage;
  if (firebaseReady) {
    try {
      // Local lookup (no network), but never let it hold up the first frame
      initialMessage = await FirebaseMessaging.instance.getInitialMessage().timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('⚠️ getInitialMessage: $e');
    }
  }

  // // Clear old EasyLocalization cache to fix locale issues
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.remove('locale');
  // await prefs.remove('codegen_loader.locale');

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Load saved language
  String savedLanguage = await StorageService.getLanguage();
  
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('so')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      // startLocale: savedLanguage == 'so' ? Locale('so') : Locale('en'),
      saveLocale: true,
      child: ToastificationWrapper(
        child: MyApp(initialMessage: initialMessage),
      ),
    ),
  );

  // Everything that may wait on the network or on the user (permission prompt)
  // runs after the app is on screen, so it never causes a blank start.
  if (firebaseReady) _setUpPushInBackground(userId);
}

Future<void> _setUpPushInBackground(String? userId) async {
  try {
    await FirebaseNotification().initNotification().timeout(const Duration(seconds: 20));
  } catch (e) {
    debugPrint('⚠️ Notification setup failed: $e');
  }
  if (userId != null) {
    ApiGetServices.updateFcmToken(userId).catchError((e) => debugPrint('⚠️ updateFcmToken: $e'));
  }
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final userData = await StorageService.getUserData();
    final id = userData["userId"];
    if (id != null) {
      await ApiGetServices.updateFcmToken(id).catchError((e) => debugPrint('⚠️ updateFcmToken: $e'));
    }
  }, onError: (e) => debugPrint('⚠️ onTokenRefresh: $e'));
}

// class MyApp extends StatefulWidget {
//   final RemoteMessage? initialMessage;
//   const MyApp({super.key, required this.initialMessage});
//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final handler = FirebaseNotificationHandler(navigatorKey);
//       await handler.initNotification();

//       if (widget.initialMessage != null) {
//         print("App launched via terminated notification.");
//         await handler.handleNotificationNavigation(widget.initialMessage!.data);
//       }
//     });
//   }
  
//   Future<String?> _isLoggedIn() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('auth_token');
//     String? userType = prefs.getString('userType');
//     if (token != null && token.isNotEmpty) {
//       return userType;
//     } else {
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<String?>(
//       future: _isLoggedIn(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return MaterialApp(
//             home: Scaffold(
//               body: Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     Color.fromARGB(255, 9, 130, 13),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         } else {
//           String? userType = snapshot.data;
//           String initialRoute = '/login';
//           if (userType == "0") {
//             initialRoute = '/doctormainscreen';
//           } else if (userType == "1") {
//             initialRoute = '/mainscreen';
//           }
//           return GetMaterialApp(
//             navigatorKey: navigatorKey,
//             debugShowCheckedModeBanner: false,
//             initialRoute: initialRoute,
//             getPages: AppRoutes.routes,
//             localizationsDelegates: [
//               GlobalMaterialLocalizations.delegate,
//               GlobalWidgetsLocalizations.delegate,
//               GlobalCupertinoLocalizations.delegate,
//               ...context.localizationDelegates,
//             ],
//             supportedLocales: context.supportedLocales,
//             locale: context.locale,
//             localeResolutionCallback: (locale, supportedLocales) {
//               // If the current locale is Somali but Material doesn't support it,
//               // fall back to English for Material components while keeping Somali for our translations
//               if (locale?.languageCode == 'so') {
//                 return Locale('en'); // Use English for Material components
//               }
//               return locale;
//             },
//           );
//         }
//       },
//     );
//   }
// }
class MyApp extends StatefulWidget {
  final RemoteMessage? initialMessage;
  const MyApp({super.key, required this.initialMessage});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Incoming call accepted while the app was closed -> join it now
      await openAcceptedCallIfAny();

      // Calls ring inside the open app even when push notifications don't work
      startIncomingCallPoller();

      final handler = FirebaseNotificationHandler(navigatorKey);
      await handler.initNotification();

      // Android 14+: allow incoming calls to show on the lock screen / when the app is closed
      if ((await _isLoggedIn()) != null) {
        await Future.delayed(const Duration(seconds: 2));
        await ensureFullScreenCallPermission();
      }

      if (widget.initialMessage != null) {
        // Ensure widget is still in tree before using context
        if (!mounted) return;
        await handler.handleNotificationNavigation(widget.initialMessage!.data);
      }
    });
  }

  Future<String?> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userType = prefs.getString('userType');
    return (token != null && token.isNotEmpty) ? userType : null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            // Same look as the native splash, so the start is seamless (no white flash)
            home: Scaffold(
              backgroundColor: AppColors.brand,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/branding/splash_logo.png', width: 180, height: 180),
                    const SizedBox(height: 8),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        String? userType = snapshot.data;
        String initialRoute = '/login';
        if (userType == "0") {
          initialRoute = '/doctormainscreen';
        } else if (userType == "1") {
          initialRoute = '/mainscreen';
        }

        return GetMaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: initialRoute,
          getPages: AppRoutes.routes,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            ...context.localizationDelegates,
          ],
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          localeResolutionCallback: (locale, supportedLocales) {
            // Somali not supported by Material → fallback to English
            if (locale?.languageCode == 'so') {
              return const Locale('en');
            }
            return locale;
          },
        );
      },
    );
  }
}
