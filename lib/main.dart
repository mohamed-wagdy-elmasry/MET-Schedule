/// MET BIS 4th Year — Smart Schedule & Student Hub
///
/// Entry point: initialises services, provides BLoCs, and decides
/// whether to show onboarding or the main home screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/app_localizations.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local_schedule_datasource.dart';
import 'data/repositories/schedule_repository_impl.dart';
import 'domain/repositories/schedule_repository.dart';
import 'presentation/bloc/preferences_cubit.dart';
import 'presentation/bloc/schedule_cubit.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.bgSurface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialise SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Non-blocking notification service init
  NotificationService.instance.init().ignore();

  runApp(METApp(prefs: prefs));
}

class METApp extends StatefulWidget {
  final SharedPreferences prefs;
  final ScheduleRepository? scheduleRepository;
  final PreferencesCubit? preferencesCubit;
  final ScheduleCubit? scheduleCubit;

  const METApp({
    super.key,
    required this.prefs,
    this.scheduleRepository,
    this.preferencesCubit,
    this.scheduleCubit,
  });

  @override
  State<METApp> createState() => _METAppState();
}

class _METAppState extends State<METApp> {
  late final ScheduleRepository _scheduleRepository;
  late final PreferencesCubit _preferencesCubit;
  late final ScheduleCubit _scheduleCubit;
  late final bool _ownsPreferencesCubit;
  late final bool _ownsScheduleCubit;

  @override
  void initState() {
    super.initState();
    _scheduleRepository = widget.scheduleRepository ??
        ScheduleRepositoryImpl(LocalScheduleDataSource());
    _ownsPreferencesCubit = widget.preferencesCubit == null;
    _ownsScheduleCubit = widget.scheduleCubit == null;
    _preferencesCubit = widget.preferencesCubit ?? PreferencesCubit(widget.prefs);
    _scheduleCubit = widget.scheduleCubit ?? ScheduleCubit(_scheduleRepository);
  }

  @override
  void dispose() {
    if (_ownsPreferencesCubit) {
      _preferencesCubit.close();
    }
    if (_ownsScheduleCubit) {
      _scheduleCubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _preferencesCubit),
        BlocProvider.value(value: _scheduleCubit),
      ],
      child: BlocBuilder<PreferencesCubit, PreferencesState>(
        builder: (context, prefsState) {
          final isDark = prefsState.themeMode == ThemeMode.dark;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: isDark ? AppTheme.bgSurface : AppTheme.bgSurfaceLight,
              systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            ),
            child: MaterialApp(
              title: 'MET Schedule',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.getLightTheme(prefsState.primaryColor),
              darkTheme: AppTheme.getDarkTheme(prefsState.primaryColor),
              themeMode: prefsState.themeMode,

              // ── Localisation ──
              locale: prefsState.locale,
              supportedLocales: const [Locale('ar'), Locale('en')],
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              // ── Global Smooth Momentum Scrolling ──
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                overscroll: false,
              ),

              // ── Clamp text scaling to prevent UI overflow
              //    with large accessibility font sizes (0.8 - 1.4) ──
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: MediaQuery.of(context).textScaler.clamp(
                      minScaleFactor: 0.8,
                      maxScaleFactor: 1.4,
                    ),
                  ),
                  child: child!,
                );
              },

              // ── Routing ──
              home: const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}

/// Wrapper that loads schedule data on first build, then shows [HomeScreen].
///
/// Separated from HomeScreen so the BlocBuilder doesn't trigger a
/// re-load every time the preferences emit.
class ScheduleLoader extends StatefulWidget {
  const ScheduleLoader({super.key});

  @override
  State<ScheduleLoader> createState() => _ScheduleLoaderState();
}

class _ScheduleLoaderState extends State<ScheduleLoader> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final prefs = context.read<PreferencesCubit>().state;
      context.read<ScheduleCubit>().loadSchedule(prefs.group, prefs.section);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for preference changes (group/section) to reload
    return BlocListener<PreferencesCubit, PreferencesState>(
      listenWhen: (prev, curr) =>
          prev.group != curr.group ||
          prev.section != curr.section ||
          prev.hasOnboarded != curr.hasOnboarded,
      listener: (context, state) {
        if (state.hasOnboarded) {
          context.read<ScheduleCubit>().loadSchedule(state.group, state.section);
        }
      },
      child: const HomeScreen(),
    );
  }
}
