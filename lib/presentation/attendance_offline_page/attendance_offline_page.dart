import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viva_attendance/bloc/attendance_offline/attendance_offline_bloc.dart';
import 'package:viva_attendance/bloc/attendance_offline/attendance_offline_event.dart';
import 'package:viva_attendance/bloc/attendance_offline/attendance_offline_state.dart';
// import '../bloc/offline_attendance_bloc.dart';
// import '../bloc/offline_attendance_event.dart';
// import '../bloc/offline_attendance_state.dart';

class AttendanceOfflinePage extends StatelessWidget {
  const AttendanceOfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OfflineAttendanceBloc()..add(LoadOfflineAttendance()),
      child: Scaffold(
        appBar: AppBar(title: const Text("Absensi Tersimpan (Offline)")),

        floatingActionButton:
            BlocBuilder<OfflineAttendanceBloc, AttendanceOfflineState>(
              builder: (context, state) {
                return FloatingActionButton.extended(
                  onPressed:
                      state.isUploading
                          ? null
                          : () {
                            context.read<OfflineAttendanceBloc>().add(
                              UploadOfflineAttendance(),
                            );
                          },
                  label:
                      state.isUploading
                          ? const Text("Uploading...")
                          : const Text("Upload Sekarang"),
                  icon:
                      state.isUploading
                          ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                          : const Icon(Icons.cloud_upload),
                );
              },
            ),

        body: BlocBuilder<OfflineAttendanceBloc, AttendanceOfflineState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.logs.isEmpty) {
              return const Center(
                child: Text(
                  "Tidak ada data absensi offline",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: state.logs.length,
              itemBuilder: (context, index) {
                final item = state.logs[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      "${item.employeeId} • ${item.attendanceType}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Alamat: ${item.address}\n"
                      "Lat: ${item.latitude}, Long: ${item.longitude}\n"
                      "Tanggal: ${item.entryDate}",
                    ),
                    trailing: const Icon(Icons.pending_actions),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
