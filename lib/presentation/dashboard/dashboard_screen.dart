import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/logout/logout_bloc.dart';
import '../attendance_type/attendance_type_screen.dart';
import '../employee/employee_register_screen.dart';
import '../widgets/base_card_button.dart';
import '../widgets/base_pop_up_dialog.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Viva Attendance',
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
                  context.read<AuthenticationBloc>().add(
                    SetAuthenticationStatus(isAuthenticated: false),
                  );
                }
              },
              builder: (context, state) {
                return GestureDetector(
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
                          question:
                              "Apakah Anda yakin ingin keluar dari aplikasi?",
                        );
                      },
                    );
                  },
                  child: Icon(Icons.logout, color: Colors.white),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Viva Attendance",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.w),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.w),
              Text(
                "Halo! Terima kasih sudah login. Aplikasi ini hadir untuk memudahkan pengelolaan absensimu. Kamu bisa menambahkan data baru bila perlu, atau langsung masuk ke halaman absensi untuk mencatat kehadiran.",
                style: TextStyle(fontSize: 12.w),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.w),
        
              BaseCardButton(
                title: "Halaman Absensi",
                color: Theme.of(context).primaryColor,
                icon: Icons.camera_enhance_outlined,
                description:
                    "Anda akan diarahkan menuju laman pemilihan jenis absensi.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceTypeScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.w),
        
              BaseCardButton(
                title: "Tambah Data Absensi Baru",
                color: Theme.of(context).secondaryHeaderColor,
                icon: Icons.camera_enhance_outlined,
                description:
                    "Anda dapat menambahkan data karyawan baru pada sistem absensi.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EmployeeRegisterScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
