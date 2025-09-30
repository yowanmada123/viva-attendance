import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/logout/logout_bloc.dart';
import '../widgets/base_card_button.dart';
import '../widgets/base_pop_up_dialog.dart';

class AttendanceTypeScreen extends StatelessWidget {
  const AttendanceTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '👋 ${getGreeting()}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.w,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: BlocConsumer<LogoutBloc, LogoutState>(
              listener: (context, state) {
                if (state is LogoutSuccess || state is LogoutFailure) {
                  context.read<AuthenticationBloc>().add(SetAuthenticationStatus(isAuthenticated: false));
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
              builder: (context, state) {
                return Row(
                  children: [
                    Icon(Icons.settings, color: Colors.white),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        showDialog<bool>(
                          context: context,
                          builder: (BuildContext childContext) {
                            return BasePopUpDialog(
                              noText: "Tidak",
                              yesText: "Ya",
                              onNoPressed: () {},
                              onYesPressed: () {
                                if (state is! LogoutLoading) {
                                  context.read<LogoutBloc>().add(LogoutPressed());
                                }
                              },
                              question: "Apakah Anda yakin ingin keluar dari aplikasi?",
                            );
                          },
                        );
                      },
                      child: Icon(Icons.logout, color: Colors.white),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Viva Attendance",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.w
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.w),
            Text(
              "Absensi membutuhkan info lokasi dan hanya  dapat dilakukan jika kamu foto selfie",
              style: TextStyle(
                fontSize: 12.w,                 
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.w),

            BaseCardButton(
              title: "Absen Datang",
              titleSize: 16.w,
              color: Color(0xFF38E54D), 
              backgroundColor: Color(0xffDDFFE1),
              icon: Icons.login,
            ),
            SizedBox(height: 16.w),

            BaseCardButton(
              title: "Ishoma",
              titleSize: 16.w,
              color: Color(0xFFFFCD38), 
              backgroundColor: Color(0xFFFFFCF4),
              icon: Icons.dinner_dining,
            ),
            SizedBox(height: 16.w),

            BaseCardButton(
              title: "Istirahat Masuk",
              titleSize: 16.w,
              color: Color(0xFFFF8D29), 
              icon: Icons.lock_clock,
            ),
            SizedBox(height: 16.w),

            BaseCardButton(
              title: "Absen Pulang",
              titleSize: 16.w,
              color: Color(0xFFFF4949), 
              backgroundColor: Color(0xFFFFF0F0),
              icon: Icons.logout,
            ),
            SizedBox(height: 16.w),
          ],
        ),
      ),
    );
  }

  String getGreeting() {
    final nowUtc = DateTime.now().toUtc();
    final wibTime = nowUtc.add(const Duration(hours: 7));
    final hour = wibTime.hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }
}