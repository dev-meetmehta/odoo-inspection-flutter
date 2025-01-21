import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: AppColors.white,
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
  ));
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PushNotificationsManager.init();
    return OverlaySupport.global(
      child: MaterialApp(
        title: 'Inspection',
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationService.navigatorKey,
        builder: (context, child) {
          final data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
        theme: ThemeData(
          fontFamily: 'Satoshi',
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            bodyText2: TextStyle(
              color: AppColors.brown600,
            ),
          ),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: AppColors.orange100,
          ),
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              statusBarColor: AppColors.secondary400,
            ),
            toolbarHeight: 0,
            elevation: 0,
            backgroundColor: AppColors.secondary400,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}