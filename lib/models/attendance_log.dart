class AttendanceLog {
  final int? id;
  final String employeeId;
  final String attendanceType;
  final String address;
  final double latitude;
  final double longitude;
  final String deviceId;
  final DateTime timestamp;
  final bool success;

  AttendanceLog({
    this.id,
    required this.employeeId,
    required this.attendanceType,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.deviceId,
    required this.timestamp,
    this.success = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'attendanceType': attendanceType,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'deviceId': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'success': success ? 1 : 0,
    };
  }

  factory AttendanceLog.fromMap(Map<String, dynamic> map) {
    return AttendanceLog(
      id: map['id'],
      employeeId: map['employeeId'],
      attendanceType: map['attendanceType'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      deviceId: map['deviceId'],
      timestamp: DateTime.parse(map['timestamp']),
      success: map['success'] == 1,
    );
  }
}