

import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repository/attendance_repository.dart';
import '../../../models/employee.dart';

part 'register_employee_event.dart';
part 'register_employee_state.dart';

class RegisterEmployeeBloc extends Bloc<RegisterEmployeeEvent, RegisterEmployeeState> {
  final AttendanceRepository attendanceRepository;

  RegisterEmployeeBloc({required this.attendanceRepository}) : super(EmployeeRegisterInitial()) {
    on<SearchEmployeeEvent>(_onSearchEmployee);
  }

  Future<void> _onSearchEmployee(
    SearchEmployeeEvent event,
    Emitter<RegisterEmployeeState> emit,
  ) async {
    if (event.query.isEmpty) return;
    emit(EmployeeSearchLoading());
    try {
      final res = await attendanceRepository.searchEmployee(query: event.query);
      
      res.fold(
        (l) => emit(EmployeeSearchError(l.message!)),
        (employees) {
          log('$employees');
          emit(EmployeeSearchSuccess(employees));
        },
      );
    } catch (e) {
      emit(EmployeeSearchError(e.toString()));
    }
  }
}
