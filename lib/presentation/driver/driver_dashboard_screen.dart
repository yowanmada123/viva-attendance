import 'package:viva_attendance/bloc/auth/authentication/authentication_bloc.dart';
import 'package:viva_attendance/bloc/auth/logout/logout_bloc.dart';
import 'package:viva_attendance/data/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();

    return BlocProvider(
      create: (context) => LogoutBloc(authRepository),
      child: MyGridLayout(),
    );
  }
}

class MyGridLayout extends StatelessWidget {
  final List<Map<String, dynamic>> buttons = [
    {'icon': Icons.local_shipping, 'text': 'Loading'},
    // {'icon': Icons.diversity_2, 'text': 'CRM'},
    // {'icon': Icons.supervisor_account, 'text': 'HRIS'},
    // {'icon': Icons.storage, 'text': 'Master'},
    // {'icon': Icons.attach_money, 'text': 'Purchasing'},
    // {'icon': Icons.warehouse, 'text': 'Warehouse'},
    // {'icon': Icons.bar_chart, 'text': 'Report'},
    // {'icon': Icons.local_shipping, 'text': 'Projects'},
    // {'icon': Icons.request_quote_outlined, 'text': 'Tax'},
    // {'icon': Icons.factory, 'text': 'Manufacture'},
    // {'icon': Icons.people, 'text': 'HRIS'},
  ];

  // void _navigateToScreen(BuildContext context, int index, String? name) {
  //   switch (index) {
  //     case 0:
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           settings: RouteSettings(name: name),
  //           builder: (context) => QrCodeScreen(),
  //         ),
  //       );
  //       break;
  //     default:
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1E4694),
        iconTheme: const IconThemeData(color: Colors.white),
        // leading: IconButton(
        //   icon: Icon(Icons.menu, color: Color(0xffffffff)),
        //   onPressed: () => print("Menu"),
        // ),
        title: Text(
          'VIVA KENCANA',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.w,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            // child: Icon(Icons.logout, color: Colors.white),
            child: BlocConsumer<LogoutBloc, LogoutState>(
              listener: (context, state) {
                if (state is LogoutFailure) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Logout Not Success")));
                } else if (state is LogoutSuccess) {
                  BlocProvider.of<AuthenticationBloc>(
                    context,
                  ).add(SetAuthenticationStatus(isAuthenticated: false));
                }
              },
              builder: (context, state) {
                return GestureDetector(
                  onTap: () {
                    // showDialog<bool>(
                    //   context: context,
                    //   builder: (BuildContext childContext) {
                    //     return BasePopUpDialog(
                    //       noText: "Tidak",
                    //       yesText: "Ya",
                    //       onNoPressed: () {},
                    //       onYesPressed: () {
                    //         if (state is! LogoutLoading) {
                    //           context.read<LogoutBloc>().add(LogoutPressed());
                    //         }
                    //       },
                    //       question:
                    //           "Apakah Anda yakin ingin keluar dari aplikasi?",
                    //     );
                    //   },
                    // );
                  },
                  child: Icon(Icons.logout, color: Colors.white),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
        child: GridView.count(
          crossAxisCount: 4, // Number of columns
          children: List.generate(buttons.length, (index) {
            return Container(
              padding: EdgeInsets.all(4.w),
              // margin: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Container(
                    //   padding: EdgeInsets.all(2.w),
                    //   decoration: BoxDecoration(
                    //     color: Color(0xff1E4694),
                    //     borderRadius: BorderRadius.circular(10.w),
                    //   ),
                    //   child: IconButton(
                    //     icon: Icon(buttons[index]['icon']),
                    //     iconSize: 24.w,
                    //     color: Colors.white,
                    //     onPressed: () {
                    //       // Add your onPressed logic here
                    //       _navigateToScreen(
                    //         context,
                    //         index,
                    //         QrCodeScreen.routeName,
                    //       );
                    //     },
                    //   ),
                    // ),
                    SizedBox(height: 2.w),
                    Text(
                      buttons[index]['text'],
                      style: TextStyle(
                        fontSize: 12.w,
                        color: Color(0xff1E4694),
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
