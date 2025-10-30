import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geocoding/geocoding.dart';

import '../../bloc/register/employee/register_employee_bloc.dart';
import '../../models/employee.dart';
import '../registration/registration_screen.dart';
import '../widgets/base_dropdown_search.dart';

class EmployeeRegisterScreen extends StatefulWidget {
  const EmployeeRegisterScreen({super.key});

  @override
  State<EmployeeRegisterScreen> createState() => _EmployeeRegisterScreenState();
}

class _EmployeeRegisterScreenState extends State<EmployeeRegisterScreen> {
  Timer? _debounce;
  List<Employee> employeeList = [];
  Employee? selectedEmployee;
  bool isSales = false;
  latlng.LatLng? selectedLatLng;
  List<Marker> _markers = [];
  final MapController _mapController = MapController();
  String? selectedAddress;
  bool _isAddressLoading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Employee Registration",
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
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocListener<RegisterEmployeeBloc, RegisterEmployeeState>(
              listener: (context, state) {
                if (state is EmployeeSearchError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Telah terjadi kesalahan. Silakan coba lagi!",
                      ),
                      duration: Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      backgroundColor: Color.fromARGB(255, 243, 78, 78),
                    ),
                  );
                } else if (state is EmployeeSearchSuccess) {
                  setState(() {
                    employeeList = state.employees;
                  });
                }
              },
              child: BaseDropdownSearch<Employee>(
                label: "Select Employee",
                items: employeeList,
                getLabel: (emp) => '${emp.idemployee} - ${emp.name}',
                selectedValue: selectedEmployee,
                onChanged: (val) {
                  setState(() => selectedEmployee = val);
                },
                onSearchChanged: (query) {
                  if (_debounce?.isActive ?? false) _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    if (query.isNotEmpty) {
                      context.read<RegisterEmployeeBloc>().add(SearchEmployeeEvent(query));
                    }
                  });
                },
              ),
            ),
            SizedBox(height: 12.w),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Is Sales?",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14.w,
                ),
              ),
              value: isSales,
              onChanged: (val) {
                setState(() {
                  isSales = val ?? false;
                  if (!isSales) {
                    selectedLatLng = null;
                    _markers = [];
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (isSales) ...[
              SizedBox(height: 8.w),
              Container(
                height: 250.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                clipBehavior: Clip.hardEdge,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: selectedLatLng ?? latlng.LatLng(-7.24917, 112.75083),
                    initialZoom: selectedLatLng == null ? 12.0 : 12.0,
                    onTap: (tapPos, point) {
                      setState(() {
                        selectedLatLng = point;
                        selectedAddress = null;
                        _markers = [
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: point,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ];
                      });
                      _mapController.move(point, 17.0);
                      _fetchAddress(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.viva_attendance',
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
              ),
              SizedBox(height: 8.w),
              if (selectedLatLng != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address:',
                      style: TextStyle(fontSize: 13.w, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 6.w),
                    if (_isAddressLoading)
                      Row(
                        children: [
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8.w),
                          Text('Mencari alamat...', style: TextStyle(fontSize: 13.w)),
                        ],
                      )
                    else
                      Text(
                        selectedAddress ?? 'Alamat tidak tersedia',
                        style: TextStyle(fontSize: 13.w),
                      ),
                  ],
                ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedEmployee == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegistrationScreen(
                              employee: selectedEmployee!,
                              isSales: isSales,
                              latitude: selectedLatLng!.latitude,
                              longitude: selectedLatLng!.longitude,
                              address: selectedAddress,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12.w),
                ),
                child: Text(
                  "Next",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.w,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchAddress(latlng.LatLng point) async {
    setState(() {
      _isAddressLoading = true;
      selectedAddress = null;
    });

    try {
      final placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [p.street, p.subLocality, p.locality, p.administrativeArea, p.postalCode, p.country];
        final address = parts.whereType<String>().where((s) => s.trim().isNotEmpty).join(', ');
        if (mounted) {
          setState(() {
            selectedAddress = address;
            _isAddressLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            selectedAddress = 'Alamat tidak ditemukan';
            _isAddressLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          selectedAddress = 'Gagal mengambil alamat';
          _isAddressLoading = false;
        });
      }
    }
  }
}