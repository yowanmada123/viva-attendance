import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/attendance/attendance_bloc.dart';

class FaceRecognitionScreen extends StatelessWidget {
  const FaceRecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AttendanceBloc()..add(InitializeCamera()),
      child: BlocConsumer<AttendanceBloc, AttendanceState>(
        listenWhen: (previous, current) => previous.success != current.success && current.success == true,
        listener:
            (context, state) => {
              if (state.success == true)
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${state.detectedName} berhasil absen"),
                      backgroundColor: Colors.green,
                    ),
                  ),
                  Navigator.popUntil(context, (route) => route.isFirst),
                },
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
                            width:
                                state
                                    .cameraController!
                                    .value
                                    .previewSize!
                                    .height,
                            height:
                                state
                                    .cameraController!
                                    .value
                                    .previewSize!
                                    .width,
                            child: CameraPreview(state.cameraController!),
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
