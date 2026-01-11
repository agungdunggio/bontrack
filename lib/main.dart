import 'package:bontrack/app/theme/app_themes.dart';
import 'package:bontrack/app/widget/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'core/services/auth_service.dart';
import 'core/services/debt_service.dart';
import 'core/cubit/auth/auth_cubit.dart';
import 'core/cubit/debt/debt_cubit.dart';
import 'core/cubit/user/user_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        RepositoryProvider(create: (context) => DebtService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(
              authService: context.read<AuthService>(),
            )..checkAuthStatus(),
          ),
          BlocProvider(
            create: (context) => DebtCubit(
              debtService: context.read<DebtService>(),
            ),
          ),
          BlocProvider(
            create: (context) => UserCubit(
              authService: context.read<AuthService>(),
            ),
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
