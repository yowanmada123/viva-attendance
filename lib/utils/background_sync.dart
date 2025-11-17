import 'dart:async';
import 'dart:math';
import '../data/data_providers/local_database.dart';
import '../data/repository/attendance_repository.dart';

class BackgroundSync {
  static Timer? _syncTimer;
  static late final AttendanceRepository _repository;

  static void initialize(AttendanceRepository repository) {
    _repository = repository;
  }

  static void startSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _syncPendingLogs();
    });
  }

  static void stopSync() {
    _syncTimer?.cancel();
  }

  static Future<void> _syncPendingLogs() async {
    try {
      final pendingLogs = await LocalDatabase.getPendingLogs();

      for (final log in pendingLogs) {
        await _syncLogWithRetry(log, maxRetries: 3);
      }
    } catch (e) {
      print('Background sync error: $e');
    }
  }

  static Future<void> _syncLogWithRetry(
    dynamic log, {
    int maxRetries = 3,
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final result = await _repository.attendanceLog(
          deviceId: log.deviceId,
          employeeId: log.employeeId,
          attendanceType: log.attendanceType,
          address: log.address,
          latitude: log.latitude,
          longitude: log.longitude, 
          entryDate: log.entryDate,
        );

        result.fold((error) => throw Exception(error.toString()), (
          success,
        ) async {
          await LocalDatabase.deleteLog(log.id!);
          print('Log synced successfully: ${log.id}');
        });
        return;
      } catch (e) {
        retryCount++;
        if (retryCount < maxRetries) {
          final delay = Duration(seconds: pow(2, retryCount).toInt());
          await Future.delayed(delay);
          print(
            'Retry $retryCount for log ${log.id} after ${delay.inSeconds}s',
          );
        } else {
          await LocalDatabase.deleteLog(log.id!);
          print('Failed to sync log ${log.id} after $maxRetries attempts');
        }
      }
    }
  }
}
