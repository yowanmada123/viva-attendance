import 'dart:convert';

class Employee {
  final String idemployee;
  final String name;
  final String address1;
  final String officeId;
  Employee({
    required this.idemployee,
    required this.name,
    this.address1 = '',
    this.officeId = '',
  });

  Employee copyWith({
    String? idemployee,
    String? name,
    String? address1,
    String? officeId,
  }) {
    return Employee(
      idemployee: idemployee ?? this.idemployee,
      name: name ?? this.name,
      address1: address1 ?? this.address1,
      officeId: officeId ?? this.officeId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idemployee': idemployee,
      'name': name,
      'address1': address1,
      'office_id': officeId,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      idemployee: map['idemployee']?.toInt() ?? 0,
      name: map['name'] ?? '',
      address1: map['address1'] ?? '',
      officeId: map['office_id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Employee.fromJson(String source) => Employee.fromMap(json.decode(source));

  @override
  String toString() => 'Employee(idemployee: $idemployee, name: $name, address1: $address1, officeId: $officeId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Employee &&
      other.idemployee == idemployee &&
      other.name == name &&
      other.address1 == address1 &&
      other.officeId == officeId;
  }

  @override
  int get hashCode => idemployee.hashCode ^ name.hashCode ^ address1.hashCode ^ officeId.hashCode;
}