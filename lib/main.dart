import 'package:bontrack/app/theme/app_themes.dart';
import 'package:bontrack/app/widget/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bontrack/firebase_options.dart';
import 'package:bontrack/core/services/auth_service.dart';
import 'package:bontrack/core/services/bon_service.dart';
import 'package:bontrack/core/cubit/auth/auth_cubit.dart';
import 'package:bontrack/core/cubit/user/user_cubit.dart';
import 'package:bontrack/core/cubit/bon/bon_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Warning: .env file not found in assets: $e');
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthService()),
        RepositoryProvider(create: (context) => BonService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthCubit(authService: context.read<AuthService>())
                  ..checkAuthStatus(),
          ),
          BlocProvider(
            create: (context) =>
                UserCubit(authService: context.read<AuthService>()),
          ),
          BlocProvider(
            create: (context) =>
                BonCubit(bonService: context.read<BonService>()),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 800),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              title: 'Bontrack',
              debugShowCheckedModeBanner: false,
              theme: AppThemes.light,
              darkTheme: AppThemes.dark,
              themeMode: ThemeMode.system,
              home: const AuthWrapper(),
              
            );
          },
        ),
      ),
    );
  }
}
