// import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:timeago/timeago.dart';
import 'package:wesh/pages/startPage.dart';
import 'package:wesh/providers/user.provider.dart';
import 'package:wesh/services/background.service.dart';
import 'package:wesh/services/sharedpreferences.service.dart';
import 'pages/login.dart';
import 'utils/constants.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: IOSInitializationSettings(),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      // notificationChannelId: 'my_foreground',
      // initialNotificationTitle: 'AWESOME SERVICE',
      // initialNotificationContent: 'Initializing',
      // foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually
  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    //
    service.on(BackgroundTaskHandler.updateMessagesToStatus2Key).listen((event) async {
      List messagesIds = event?['messages'] ?? [];
      // final isolate = await FlutterIsolate.spawn(performUpdateMessagesToStatus2inIsolate, {'messages': messagesIds});
      // isolate.kill();
      service.setAsBackgroundService();
    });
    //
    service.on(BackgroundTaskHandler.updateMessagesToStatus3Key).listen((event) async {
      List messagesIds = event?['messages'] ?? [];
      // final isolate = await FlutterIsolate.spawn(performUpdateMessagesToStatus3inIsolate, {'messages': messagesIds});
      // isolate.kill();
      service.setAsBackgroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

// BACKGROUND DOWLOAD TASK HANDLER
class TestClass {
  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port_$id');
    send!.send([id, status, progress]);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await UserSimplePreferences.init();

  setLocaleMessages('fr', FrMessages());

  await FlutterDownloader.initialize(
      debug: true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl: true // option: set to false to disable working with http links (default: false)
      );

  FlutterDownloader.registerCallback(TestClass.downloadCallback);

  await initializeBackgroundService();
  // await FirebaseAppCheck.instance.activate(
  //   webRecaptchaSiteKey:
  //       'recaptcha-v3-site-key', // <-- only needed for reCAPTCHA v3
  // );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
    ],
    child: const App(),
  ));
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    //
    log('Ready to start...');
    FlutterNativeSplash.remove();
    //
    SystemChrome.setApplicationSwitcherDescription(
        const ApplicationSwitcherDescription(label: 'Wesh', primaryColor: 1));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(320, 568),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            supportedLocales: const [
              Locale('fr'),
            ],
            localizationsDelegates: const [
              CountryLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            theme: ThemeData.light().copyWith(
              appBarTheme: AppBarTheme(
                iconTheme: IconThemeData(
                  size: 22.sp,
                  color: Colors.black87,
                ),
                toolbarHeight: 0.08.sh,
                titleTextStyle: TextStyle(
                  fontSize: 17.sp,
                  color: Colors.black,
                ),
              ),
              progressIndicatorTheme: ProgressIndicatorThemeData(linearMinHeight: 0.005.sh),
              checkboxTheme: CheckboxThemeData(
                fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  const Set<MaterialState> interactiveStates = <MaterialState>{
                    MaterialState.pressed,
                    MaterialState.hovered,
                    MaterialState.focused,
                  };
                  if (states.any(interactiveStates.contains)) {
                    return kPrimaryColor;
                  }
                  return kSecondColor;
                }),
              ),
              radioTheme: RadioThemeData(
                fillColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(MaterialState.selected)) {
                      return kSecondColor;
                    }

                    return Colors.white;
                  },
                ),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(MaterialState.selected)) {
                      return kSecondColor;
                    }

                    return Colors.white;
                  },
                ),
                trackColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(MaterialState.selected)) {
                      return kSecondColor.withOpacity(.2);
                    }
                    return Colors.black26;
                  },
                ),
              ),
              colorScheme: ColorScheme(
                brightness: Brightness.light,
                primary: kSecondColor,
                onPrimary: Colors.white,
                secondary: Colors.grey.shade600,
                onSecondary: Colors.grey.shade300.withOpacity(0.7),
                error: kSecondColor,
                onError: kSecondColor.withOpacity(0.7),
                background: Colors.white,
                onBackground: Colors.white.withOpacity(0.7),
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            debugShowCheckedModeBanner: false,
            home: AnnotatedRegion<SystemUiOverlayStyle>(
              // ignore: prefer_const_constructors
              value: SystemUiOverlayStyle(
                statusBarBrightness: Brightness.dark,
              ),
              child: SafeArea(
                child: StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Scaffold(
                        backgroundColor: Colors.white,
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(
                                color: kSecondColor,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Chargement...',
                                style: TextStyle(color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasData) {
                      return StartPage(context: context);
                    } else if (snapshot.hasError) {
                      return Scaffold(
                        appBar: MorphingAppBar(
                          heroTag: 'mainPageAppBar',
                        ),
                        body: const Center(
                          child: Text("Une erreur s'est produite"),
                        ),
                      );
                    } else {
                      return const LoginPage(
                        redirectToAddEmailandPasswordPage: false,
                        redirectToAddEmailPage: false,
                        redirectToUpdatePasswordPage: false,
                      );
                    }
                  },
                ),
              ),
            ),
          );
        });
  }
}
