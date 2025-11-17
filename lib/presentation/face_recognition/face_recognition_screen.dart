import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/attendance/attendance_bloc.dart';
import '../../data/repository/attendance_repository.dart';

class FaceRecognitionScreen extends StatelessWidget {
  final String attendanceType;
  const FaceRecognitionScreen({super.key, required this.attendanceType});

  @override
  Widget build(BuildContext context) {
    final attendanceRepository = context.read<AttendanceRepository>();
    return BlocProvider(
      create:
          (context) =>
              AttendanceBloc(attendanceRepository: attendanceRepository)
                ..add(InitializeCamera(attendanceType: attendanceType)),
      child: BlocConsumer<AttendanceBloc, AttendanceState>(
         // 🔥 Dengarkan perubahan success ATAU errorMessage
        listenWhen: (previous, current) {
          final successChanged = previous.success != current.success && current.success == true;
          final errorChanged = previous.errorMessage != current.errorMessage &&
              current.errorMessage != null &&
              current.errorMessage!.isNotEmpty;
          return successChanged || errorChanged;
        },
        listener:
            (context, state) => {
              // ✔ Jika berhasil
              if (state.success == true)
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.serverMessage ?? "Success"),
                      backgroundColor: Colors.green,
                    ),
                  ),
                  Navigator.popUntil(context, (route) => route.isFirst),
                  
                }
              else if (state.errorMessage != null && state.errorMessage !.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                )
              }
              // // ✔ Jika gagal
              // else {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: Text("${state.errorMessage}"),
              //         backgroundColor: Colors.red,
              //       ),
              //     ),
              // }

            },
        builder: (context, state) {
          final controller = state.cameraController;
          if (controller == null ||
              !controller.value.isInitialized) {
            return Scaffold(body: Center(child: CircularProgressIndicator(),),);
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
                            width:
                                controller
                                    .value
                                    .previewSize!
                                    .height,
                            height:
                                controller
                                    .value
                                    .previewSize!
                                    .width,
                            child: Stack(
                              children: [
                                CameraPreview(controller),

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
                                                "Mencocokkan wajah...",
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
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),

                      if (state.detectedName != null)
                        buildAttendanceCard(
                          isSuccess: true,
                          name: state.detectedName,
                        )
                      else
                        buildAttendanceCard(isSuccess: false),
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

  Widget buildAttendanceCard({required bool isSuccess, String? name}) {
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
                  ? "Wajah Dikenali, Berhasil Absen !!!"
                  : "Wajah Tidak Dikenali, Gagal Melakukan Absensi, coba posisikan lagi !!!",
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
