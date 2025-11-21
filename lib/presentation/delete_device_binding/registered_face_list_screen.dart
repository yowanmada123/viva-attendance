import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viva_attendance/bloc/delete_registered_user/delete_registered_user_event.dart';
import 'package:viva_attendance/bloc/delete_registered_user/delete_registered_user_state.dart';

import '../../bloc/delete_registered_user/delete_registered_user_bloc.dart';

class DeleteRegisteredFaceScreen extends StatefulWidget {
  const DeleteRegisteredFaceScreen({super.key});

  @override
  State<DeleteRegisteredFaceScreen> createState() =>
      _DeleteRegisteredFaceScreenState();
}

class _DeleteRegisteredFaceScreenState
    extends State<DeleteRegisteredFaceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DeviceRegisteredBloc>().add(LoadRegisteredFaces());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete Registered Face"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: BlocConsumer<DeviceRegisteredBloc, DeviceRegisteredState>(
          listener: (context, state) {
            if (state is DeleteRegisteredSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<DeviceRegisteredBloc>().add(LoadRegisteredFaces());
            }

            if (state is DeviceRegisteredError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DeviceRegisteredLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DeviceRegisteredError) {
              return Center(child: Text(state.message));
            }

            if (state is DeviceRegisteredLoaded) {
              final faces = state.faces;

              if (faces.isEmpty) {
                return const Center(child: Text("Tidak ada wajah terdaftar."));
              }

              return ListView.separated(
                itemCount: faces.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, index) {
                  final face = faces[index];

                  return ListTile(
                    title: Text("User ID: ${face.id}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text("Konfirmasi"),
                                content: Text("Hapus user ID: ${face.id}?"),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text("Batal"),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text("Hapus"),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          context.read<DeviceRegisteredBloc>().add(
                            DeleteRegisteredFace(face.id),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
