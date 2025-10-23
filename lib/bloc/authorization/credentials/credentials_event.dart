part of 'credentials_bloc.dart';

sealed class CredentialsEvent extends Equatable {
  const CredentialsEvent();

  @override
  List<Object> get props => [];
}

final class CredentialsLoad extends CredentialsEvent {}
