import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:face_verification/face_verification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'bloc/auth/authentication/authentication_bloc.dart';
import 'bloc/auth/logout/logout_bloc.dart';
import 'bloc/authorization/credentials/credentials_bloc.dart';
import 'bloc/register/employee/register_employee_bloc.dart';
import 'bloc/update/update_bloc.dart';
import 'data/data_providers/rest_api/attendance_rest.dart';
import 'data/data_providers/rest_api/auth_rest.dart';
import 'data/data_providers/rest_api/authorization_rest.dart';
import 'data/data_providers/shared-preferences/shared_preferences_key.dart';
import 'data/data_providers/shared-preferences/shared_preferences_manager.dart';
import 'data/repository/attendance_repository.dart';
import 'data/repository/auth_repository.dart';
import 'data/repository/authorization_repository.dart';
import 'environment.dart';
import 'presentation/attendance_type/attendance_type_screen.dart';
import 'presentation/dashboard/dashboard_screen.dart';
import 'presentation/login/login_form_screen.dart';
import 'utils/background_sync.dart';
import 'utils/interceptors/dio_request_token_interceptor.dart';
import 'utils/strict_location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FaceVerification.instance.init();

  try {
    await StrictLocation.checkAndRequestPermission();
  } catch (e) {
    log('❌ Gagal meminta izin lokasi: $e');
  }

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  final authSharedPref = SharedPreferencesManager(
    key: SharedPreferencesKey.authKey,
  );

  final dioClient = Dio(Environment.dioBaseOptions)
    ..interceptors.addAll([DioRequestTokenInterceptor()]);
  final authorizationClient = Dio(AuthorizationEnvironment.dioBaseOptions)
    ..interceptors.addAll([DioRequestTokenInterceptor()]);

  final authRest = AuthRest(dioClient);
  final authorizationRest = AuthorizationRest(authorizationClient);
  final attendanceRest = AttendanceRest(dioClient);

  final authRepository = AuthRepository(
    authRest: authRest,
    authSharedPref: authSharedPref,
  );
  final authorizationRepository = AuthorizationRepository(
    authorizationRest: authorizationRest,
  );
  final attendanceRepository = AttendanceRepository(
    attendanceRest: attendanceRest,
  );

  BackgroundSync.initialize(attendanceRepository);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: attendanceRepository),
        RepositoryProvider.value(value: authorizationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(lazy: false, create: (context) => AuthenticationBloc()),
          BlocProvider(lazy: false, create: (context) => RegisterEmployeeBloc(attendanceRepository: attendanceRepository)),
          BlocProvider(lazy: false, create: (context) => CredentialsBloc(authorizationRepository: authorizationRepository)),
          BlocProvider(lazy: false, create: (context) => UpdateBloc()..add(CheckForUpdate())),
          BlocProvider(
            lazy: false,
            create: (context) => LogoutBloc(authRepository),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    BackgroundSync.startSync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BackgroundSync.stopSync();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      BackgroundSync.startSync();
    } else if (state == AppLifecycleState.paused) {
      BackgroundSync.stopSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder:
          (context, widget) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Viva Attendance',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              primaryColor: Color(0xff541690),
              hintColor: Color(0xffF1F1F1),
              disabledColor: Color(0xff808186),
              secondaryHeaderColor: Color(0xffAE75DA),
              fontFamily: "Poppins",
              textTheme: TextTheme(
                labelSmall: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12,
                ),
                labelMedium: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                ),
                labelLarge: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                headlineLarge: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            home: BlocListener<UpdateBloc, UpdateState>(
              listener: (context, state) {
                if (state is UpdateAvailable) {
                  _showUpdateDialog(context, state);
                } else if (state is UpdateDownloaded) {
                  Navigator.pop(context);
                  OpenFile.open(state.filePath);
                } else if (state is UpdateError) {
                  Navigator.pop(context);
                  _showErrorDialog(context, state.message);
                }
              },
              child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
                listener:
                    (context, authState) => {
                      if (authState is Authenticated)
                        {
                          context.read<CredentialsBloc>().add(
                            CredentialsLoad(),
                          ),
                        },
                    },
                builder: (context, authState) {
                  return BlocBuilder<CredentialsBloc, CredentialsState>(
                    builder: (context, credState) {
                      if (authState is Authenticated) {
                        if (credState is CredentialsLoadSuccess) {
                          final credentials = credState.credentials;
                          if (credentials["ADMIN_ABSEN"] == "Y") {
                            return DashboardScreen();
                          }
                          return AttendanceTypeScreen();
                        }
                      }
                      return LoginFormScreen();
                    },
                  );
                },
              ),
            ),
          ),
    );
  }

  void _showUpdateDialog(BuildContext context, UpdateAvailable state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text('Update Tersedia'),
              content: Text(
                'Versi ${state.latestVersion} tersedia:\n\n${state.updateNotes}',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => _handleUpdate(context, state),
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _handleUpdate(
    BuildContext context,
    UpdateAvailable state,
  ) async {
    Navigator.pop(context);

    if (!await _checkStoragePermission(context)) return;

    if (!await _checkInstallPermission(context)) return;

    context.read<UpdateBloc>().add(DownloadUpdate(state.apkUrl));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => PopScope(
            canPop: false,
            child: AlertDialog(
              title: Text(
                "Sedang Memperbarui…",
                style: TextStyle(fontSize: 16.w),
              ),
              content: BlocBuilder<UpdateBloc, UpdateState>(
                buildWhen: (prev, curr) => curr is UpdateDownloading,
                builder: (context, state) {
                  double progress = 0.0;
                  if (state is UpdateDownloading) {
                    progress = state.progress;
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 12),
                      Text("${(progress * 100).toStringAsFixed(0)}%"),
                    ],
                  );
                },
              ),
            ),
          ),
    );
  }

  Future<bool> _checkStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        final status = await Permission.manageExternalStorage.request();
        if (status.isGranted) return true;
      } else {
        final status = await Permission.storage.request();
        if (status.isGranted) return true;
      }

      _showErrorDialog(context, 'Izin penyimpanan tidak diberikan.');
      return false;
    }

    return true;
  }

  Future<bool> _checkInstallPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 26) {
        final status = await Permission.requestInstallPackages.request();
        if (status.isGranted) return true;

        _showErrorDialog(
          context,
          'Izin install dari sumber tidak dikenal tidak diberikan.',
        );
        return false;
      }
    }

    return true;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
