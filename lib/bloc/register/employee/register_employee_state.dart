part of 'register_employee_bloc.dart';

abstract class RegisterEmployeeState extends Equatable {
  const RegisterEmployeeState();

  @override
  List<Object?> get props => [];
}

class EmployeeRegisterInitial extends RegisterEmployeeState {}

class EmployeeSearchLoading extends RegisterEmployeeState {}

class EmployeeSearchSuccess extends RegisterEmployeeState {
  final List<Employee> employees;
  const EmployeeSearchSuccess(this.employees);

  @override
  List<Object?> get props => [employees];
}

class EmployeeSearchError extends RegisterEmployeeState {
  final String message;
  const EmployeeSearchError(this.message);

  @override
  List<Object?> get props => [message];
}