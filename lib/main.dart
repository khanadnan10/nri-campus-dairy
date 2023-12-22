import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nri_campus_dairy/providers/user_provider.dart';
import 'package:nri_campus_dairy/responsive/mobile_screen_layout.dart';
import 'package:nri_campus_dairy/responsive/responsive_layout.dart';
import 'package:nri_campus_dairy/responsive/web_screen_layout.dart';
import 'package:nri_campus_dairy/screens/login_screen.dart';
import 'package:nri_campus_dairy/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialise app based on platform- web or mobile
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCUJCZtMFj6T2x6s2S0L8dvnyyL4cmEhTE",
          projectId: "finalyearcollegeapp",
          storageBucket: "finalyearcollegeapp.appspot.com",
          messagingSenderId: "982230669868",
          appId: "1:982230669868:web:b7736da2119771c64c4f89"),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(), // Wrap your app
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        // useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        title: 'NRI Campus Diary',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home: const InitializingPersistenanceState(),
      ),
    );
  }
}

class InitializingPersistenanceState extends StatelessWidget {
  const InitializingPersistenanceState({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                  '${snapshot.error} \n An error occurred while processing. Please try again later.'),
            );
          }
        }
        return const LoginScreen();
      },
    );
  }
}
