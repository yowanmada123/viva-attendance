import 'dart:convert';

class Employee {
  final int idemployee;
  final String name;
  final String address1;
  Employee({
    required this.idemployee,
    required this.name,
    required this.address1,
  });

  Employee copyWith({
    int? idemployee,
    String? name,
    String? address1,
  }) {
    return Employee(
      idemployee: idemployee ?? this.idemployee,
      name: name ?? this.name,
      address1: address1 ?? this.address1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idemployee': idemployee,
      'name': name,
      'address1': address1,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      idemployee: map['idemployee']?.toInt() ?? 0,
      name: map['name'] ?? '',
      address1: map['address1'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Employee.fromJson(String source) => Employee.fromMap(json.decode(source));

  @override
  String toString() => 'Employee(idemployee: $idemployee, name: $name, address1: $address1)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Employee &&
      other.idemployee == idemployee &&
      other.name == name &&
      other.address1 == address1;
  }

  @override
  int get hashCode => idemployee.hashCode ^ name.hashCode ^ address1.hashCode;
}