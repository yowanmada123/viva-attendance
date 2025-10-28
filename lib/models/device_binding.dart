import 'dart:convert';

class DeviceBinding {
  final String name;
  final String idemployee;
  final String officeId;
  DeviceBinding({
    required this.name,
    required this.idemployee,
    required this.officeId,
  });

  DeviceBinding copyWith({
    String? name,
    String? idemployee,
    String? officeId,
  }) {
    return DeviceBinding(
      name: name ?? this.name,
      idemployee: idemployee ?? this.idemployee,
      officeId: officeId ?? this.officeId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'idemployee': idemployee,
      'office_id': officeId,
    };
  }

  factory DeviceBinding.fromMap(Map<String, dynamic> map) {
    return DeviceBinding(
      name: map['name'] ?? '',
      idemployee: map['idemployee'] ?? '',
      officeId: map['office_id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceBinding.fromJson(String source) => DeviceBinding.fromMap(json.decode(source));

  @override
  String toString() => 'DeviceBinding(name: $name, idemployee: $idemployee, officeId: $officeId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is DeviceBinding &&
      other.name == name &&
      other.idemployee == idemployee &&
      other.officeId == officeId;
  }

  @override
  int get hashCode => name.hashCode ^ idemployee.hashCode ^ officeId.hashCode;
}