part of 'register_employee_bloc.dart';

abstract class RegisterEmployeeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchEmployeeEvent extends RegisterEmployeeEvent {
  final String query;
  SearchEmployeeEvent(this.query);

  @override
  List<Object?> get props => [query];
}