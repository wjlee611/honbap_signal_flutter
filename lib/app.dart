import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:honbap_signal_flutter/Themes/create_material_color.dart';
import 'package:honbap_signal_flutter/bloc/auth/authentication/authentication_bloc.dart';
import 'package:honbap_signal_flutter/bloc/auth/authentication/authentication_state.dart';
import 'package:honbap_signal_flutter/bloc/home/signal_box_dialog/signal_box_dialog_bloc.dart';
import 'package:honbap_signal_flutter/bloc/signal/signal_list_bloc.dart';
import 'package:honbap_signal_flutter/constants/sizes.dart';
import 'package:honbap_signal_flutter/cubit/user_cubit.dart';
import 'package:honbap_signal_flutter/cubit/user_profile_upload_cubit.dart';
import 'package:honbap_signal_flutter/repository/honbab/home/home_repository.dart';
import 'package:honbap_signal_flutter/repository/honbab/chat/chat_list_repository.dart';
import 'package:honbap_signal_flutter/repository/honbab/home/signal_box/home_signal_box_repository.dart';
import 'package:honbap_signal_flutter/repository/honbab/signal/signal_list_repository.dart';
import 'package:honbap_signal_flutter/repository/honbab/user/user_profile_repository.dart';
import 'package:honbap_signal_flutter/screens/common/user_profile/user_profile_screen.dart';
import 'package:honbap_signal_flutter/screens/routes/route_navigation_widget.dart';
import 'package:honbap_signal_flutter/screens/auth/auth_screen.dart';
import 'package:honbap_signal_flutter/screens/splash/splash_page.dart';

import 'bloc/chat/chat_list/chat_list_bloc.dart';
import 'bloc/home/get_signal_apply/home_signal_apply_bloc.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: context.read<AuthenticationBloc>(),
      redirect: (context, state) {
        var authState = context.read<AuthenticationBloc>().state.status;

        switch (authState) {
          case AuthenticationStatus.init:
            return '/';
          case AuthenticationStatus.loading:
          case AuthenticationStatus.error:
            break;
          case AuthenticationStatus.unauthenticated:
            return '/auth';
          case AuthenticationStatus.authenticated:
            return '/home';
          case AuthenticationStatus.firstAuthenticated:
            return '/profile';
        }
        return state.path;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => RepositoryProvider(
            create: (context) => UserProfileRepository(),
            child: BlocProvider(
              create: (context) => UserProfileUploadCubit(
                userProfile: context.read<UserCubit>().state.user!.userProfile,
                userProfileRepository: context.read<UserProfileRepository>(),
              ),
              child: const UserProfileScreen(isFirst: true),
            ),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => MultiRepositoryProvider(
            providers: [
              RepositoryProvider(
                create: (context) => HonbabSignalListRepository(),
              ),
              RepositoryProvider(
                create: (context) => HomeSignalApplyRepository(),
              ),
              RepositoryProvider(
                create: (context) => ChatListRepository(),
              ),
              RepositoryProvider(
                  create: (context) => HomeSignalBoxRepository()),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => SignalListBloc(
                      context.read<HonbabSignalListRepository>()),
                ),
                BlocProvider(
                  create: (context) => HomeSignalApplyBloc(
                      context.read<HomeSignalApplyRepository>()),
                ),
                BlocProvider(
                  create: (context) => SignalBoxDialogBloc(
                      context.read<HomeSignalBoxRepository>()),
                ),
                BlocProvider(
                  create: (context) =>
                      ChatListBloc(context.read<ChatListRepository>()),
                ),
              ],
              child: const RouteNavigationWidget(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: '혼밥시그널',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: createMaterialColor(const Color(0xffff4b25)),
        fontFamily: 'Pretendard',
        textTheme: const TextTheme(
          // 2022 sets
          // displayLarge, displayMedium, displaySmall
          // headlineLarge, headlineMedium, headlineSmall
          // titleLarge, titleMedium, titleSmall
          // bodyLarge, bodyMedium, bodySmall
          // labelLarge, labelMedium, labelSmall
          titleMedium: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: Sizes.size20,
          ),
          titleSmall: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: Sizes.size16,
          ),
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: Sizes.size18,
          ),
          labelSmall: TextStyle(
            color: Color(0xFFB8B8B8),
            fontSize: Sizes.size14,
            letterSpacing: Sizes.size1 / Sizes.size2,
          ),
        ),
      ),
    );
  }
}
