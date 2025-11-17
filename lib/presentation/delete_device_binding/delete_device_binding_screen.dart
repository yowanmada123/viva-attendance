import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/device_binding/device_binding_bloc.dart';

class DeleteDeviceBindingScreen extends StatefulWidget {
  const DeleteDeviceBindingScreen({super.key});

  @override
  State<DeleteDeviceBindingScreen> createState() => _DeleteDeviceBindingScreenState();
}

class _DeleteDeviceBindingScreenState extends State<DeleteDeviceBindingScreen> {
  @override
  void initState() {
    context.read<DeviceBindingBloc>().add(LoadRegisteredFaces());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log('Access to presentation/delete_device_binding/delete_device_binding_screen.dart');
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Delete Registered Face",
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.w,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: BlocConsumer<DeviceBindingBloc, DeviceBindingState>(
          listenWhen: (previous, current) => current is DeleteDeviceBindingSuccess || current is DeviceBindingError,
          listener: (context, state) {
            if (state is DeleteDeviceBindingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );

              context.read<DeviceBindingBloc>().add(LoadRegisteredFaces());
            }

            if (state is DeviceBindingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DeviceBindingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DeviceBindingError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: Colors.red, fontSize: 16.sp),
                ),
              );
            }

            if (state is DeviceBindingLoaded) {
              final faces = state.faces;

              if (faces.isEmpty) {
                return Center(
                  child: Text(
                    "Belum ada wajah terdaftar.",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                );
              }

              return SingleChildScrollView(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: faces.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final face = faces[index];
                    final isEven = index % 2 == 0;

                    return Container(
                      color: isEven
                          ? Colors.grey.shade100
                          : Colors.grey.shade200,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        title: Text(
                          face.name,
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          "ID: ${face.idemployee}",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Konfirmasi"),
                                content: Text(
                                  "Apakah Anda yakin ingin menghapus wajah milik ${face.name}?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Batal"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Hapus", style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              context.read<DeviceBindingBloc>().add(DeleteRegisteredFace(face.idemployee, face.name));
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox();
          }
        ),
      )
    );
  }
}