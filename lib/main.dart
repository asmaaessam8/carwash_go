import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/constants/colors.dart';
import 'core/constants/fonts.dart';
import 'core/routes/router.dart';
import 'core/routes/routes.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('Background message');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

 await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

await FirebaseMessagingService().initialize();

runApp(const CarWashGoApp());
}

class CarWashGoApp extends StatelessWidget {
  const CarWashGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CarWash Go',
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
        theme: ThemeData(
          fontFamily: AppFonts.mainFont,
          scaffoldBackgroundColor: AppColors.secondary,
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
          textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
