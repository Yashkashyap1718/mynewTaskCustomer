// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:customer/app/modules/home/views/home_view.dart';
// import 'package:customer/app/modules/login/views/login_email_verification_view.dart';
// import 'package:customer/firebase_options.dart';
// import 'package:customer/services/localization_service.dart';
// import 'package:customer/theme/styles.dart';
// import 'package:customer/utils/dark_theme_provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'app/routes/app_pages.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   configLoading();
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     title: 'MyTaxi',
//     theme: ThemeData(
//       primarySwatch: Colors.amber,
//       textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1),
//     ),
//     home: const MyApp(),
//   ));
// }

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   DarkThemeProvider themeChangeProvider = DarkThemeProvider();

//   @override
//   void initState() {
//     getCurrentAppTheme();
//     WidgetsBinding.instance.addObserver(this);
//     // WidgetsBinding.instance.addPostFrameCallback((_) {});
//     super.initState();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     getCurrentAppTheme();
//   }

//   void getCurrentAppTheme() async {
//     themeChangeProvider.darkTheme =
//         await themeChangeProvider.darkThemePreference.getTheme();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) {
//         return themeChangeProvider;
//       },
//       child: Consumer<DarkThemeProvider>(
//         builder: (context, value, child) {
//           return GetMaterialApp(
//               title: 'MyTaxi'.tr,
//               debugShowCheckedModeBanner: false,
//               theme: Styles.themeData(
//                   themeChangeProvider.darkTheme == 0
//                       ? true
//                       : themeChangeProvider.darkTheme == 1
//                           ? false
//                           : themeChangeProvider.getSystemThem(),
//                   context),
//               localizationsDelegates: const [
//                 CountryLocalizations.delegate,
//               ],
//               locale: LocalizationService.locale,
//               fallbackLocale: LocalizationService.locale,
//               translations: LocalizationService(),
//               builder: EasyLoading.init(),
//               initialRoute: AppPages.INITIAL,
//               getPages: AppPages.routes,
//               home: AuthCheck());
//         },
//       ),
//     );
//   }
// }

// void configLoading() {
//   EasyLoading.instance
//     ..displayDuration = const Duration(milliseconds: 2000)
//     ..indicatorType = EasyLoadingIndicatorType.circle
//     ..loadingStyle = EasyLoadingStyle.custom
//     ..indicatorSize = 45.0
//     ..radius = 10.0
//     ..progressColor = const Color(0xFFFEA735)
//     ..backgroundColor = const Color(0xFFf5f6f6)
//     ..indicatorColor = const Color(0xFFFEA735)
//     ..textColor = const Color(0xFFFEA735)
//     ..maskColor = const Color(0xFFf5f6f6)
//     ..userInteractions = true
//     ..dismissOnTap = false;
// }

// class AuthCheck extends StatefulWidget {
//   const AuthCheck({super.key});

//   @override
//   State<AuthCheck> createState() => _AuthCheckState();
// }

// class _AuthCheckState extends State<AuthCheck> {
//   bool isLoggedIn = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissionsAndLoginStatus();
//   }

//   Future<void> _checkPermissionsAndLoginStatus() async {
//     // First request location permissions

//     // Then check if user is logged in
//     await _checkIfLoggedIn();
//   }

//   Future<void> _checkIfLoggedIn() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool? loginStatus = prefs.getBool('isLoggedIn');

//     setState(() {
//       isLoggedIn = loginStatus ?? false;
//     });

//     if (isLoggedIn) {
//       Get.off(() => const HomeView());
//     } else {
//       Get.off(() => const LoginView());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isLoggedIn ? const HomeView() : const LoginView();
//   }
// }

import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/firebase_options.dart';
import 'package:customer/services/localization_service.dart';
import 'package:customer/theme/styles.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/my_notification_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/routes/app_pages.dart';
import 'constant/api_constant.dart';
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  MyNotificationHandler().showNotification(message);
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MyNotificationHandler().requestNotificationPermissions();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    MyNotificationHandler().showNotification(message);
  });

  // Location location = Location();

  // // Check if permission is granted, request if not
  // PermissionStatus permissionStatus = await location.requestPermission();


  // if (permissionStatus != PermissionStatus.granted) {
  //   // Handle the case where permission is not granted
  //   print('Location permission not granted');
  // } else {
  // Proceed with app startup
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if(prefs.getString("token") != null){
    token = prefs.getString("token")!;

    print("TOKEN:: $token");
  }
  runApp(MyApp());
  // }
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    getCurrentAppTheme();
  }

  // Load the current theme preference
  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => themeChangeProvider,
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return GetMaterialApp(
            title: 'MyTaxi'.tr,
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(
              themeChangeProvider.darkTheme == 0
                  ? true
                  : themeChangeProvider.darkTheme == 1
                      ? false
                      : themeChangeProvider.getSystemThem(),
              context,
            ),
            localizationsDelegates: const [
              CountryLocalizations.delegate,
            ],
            locale: LocalizationService.locale,
            fallbackLocale: LocalizationService.locale,
            translations: LocalizationService(),
            builder: EasyLoading.init(),
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
          );
        },
      ),
    );
  }
}

// Configure EasyLoading
void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = const Color(0xFFFEA735)
    ..backgroundColor = const Color(0xFFf5f6f6)
    ..indicatorColor = const Color(0xFFFEA735)
    ..textColor = const Color(0xFFFEA735)
    ..maskColor = const Color(0xFFf5f6f6)
    ..userInteractions = true
    ..dismissOnTap = false;
}
