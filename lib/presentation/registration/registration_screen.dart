import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/register/register_bloc.dart';
import '../../data/repository/attendance_repository.dart';
import '../../models/employee.dart';

class RegistrationScreen extends StatelessWidget {
  final Employee employee;
  const RegistrationScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final attendanceRepository = context.read<AttendanceRepository>();
    return BlocProvider(
      create:
          (context) =>
              RegisterBloc(attendanceRepository: attendanceRepository)
                ..add(InitializeCamera(employee: employee)),
      child: BlocConsumer<RegisterBloc, RegisterState>(
        listenWhen: (previous, current) {
          final doneProcessing =
              previous.isDetecting == true && current.isDetecting == false;
          return doneProcessing;
        },
        listener:
            (context, state) => {
              if (state.success == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Wajah berhasil registrasi"),
                    backgroundColor: Colors.green,
                  ),
                ),
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${state.errorMessage}"),
                    backgroundColor: Colors.red,
                  ),
                ),
              },
              if (state.isRegistered) {
                Navigator.popUntil(context, (route) => route.isFirst)
              }
            },
        builder: (context, state) {
          if (state.cameraController == null ||
              !state.cameraController!.value.isInitialized) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: state.cameraController!.value.previewSize!.height,
                            height: state.cameraController!.value.previewSize!.width,
                            child: Stack(
                              children: [
                                CameraPreview(state.cameraController!),

                                if (state.isLoading && state.detectedName != null)
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    child: Center(
                                      child: Card(
                                        elevation: 6,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              CircularProgressIndicator(),
                                              SizedBox(height: 16),
                                              Text(
                                                "Mendaftarkan wajah...",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      if (state.detectedName != null)
                        buildRegisterCard(
                          isSuccess: true,
                          name: state.detectedName,
                        )
                      else
                        buildRegisterCard(isSuccess: false),
                    ],
                  ),
                ),

                Container(
                  height: 40.w,
                  width: double.infinity,
                  color: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.date,
                        style: TextStyle(color: Colors.white, fontSize: 14.w),
                      ),
                      Text(
                        state.time,
                        style: TextStyle(color: Colors.white, fontSize: 14.w),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.w),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        size: 48.w,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          "Silakan lakukan deteksi wajah dengan mengarahkan wajah ke kamera dalam posisi stabil. Proses ini hanya memerlukan beberapa detik.",
                          style: TextStyle(fontSize: 12.w),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.w),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildRegisterCard({required bool isSuccess, String? name}) {
    return Positioned(
      left: 16.w,
      right: 16.w,
      bottom: 24.w,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
        ),
        child: Column(
          children: [
            if (isSuccess)
              Text(
                "Nama : ${name!}",
                style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 8.w),
            Text(
              isSuccess
                  ? "Registrasi Berhasil"
                  : "Registrasi Gagal! Silakan coba lagi!",
              style: TextStyle(
                fontSize: 12.w,
                color: isSuccess ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
