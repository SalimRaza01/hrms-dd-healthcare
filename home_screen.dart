// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController dbServerController = TextEditingController();
  TextEditingController dbNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String databaseSelect = '';
  String authenticationTypeSelect = '';
  bool passwordVisible = false;

  String databaseType = 'Select Database Type';
  var databaseTypeItems = [
    'Select Database Type',
    'mySQL',
    'Oracle',
  ];

  String authenticationType = 'Select Authentication Type';
  var authenticationTypeItems = [
    'Select Authentication Type',
    'Windows',
    'SQL',
  ];

  @override
  void initState() {
    super.initState();
  }

  // Future<void> logout() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('mytoken');
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => SplashScreen()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        actions: [
          // InkWell(
          //   onTap: () {
          //     showDialog<void>(
          //       barrierColor: const Color.fromARGB(88, 59, 59, 59),
          //       context: context,
          //       barrierDismissible: true,
          //       builder: (BuildContext context) {
          //         return CupertinoAlertDialog(
          //           title: Text(
          //             'Confirm Logout',
          //           ),
          //           actions: [
          //             CupertinoDialogAction(
          //               onPressed: () {
          //                 // logout();
          //                 Navigator.pop(context);
          //               },
          //               child: Text(
          //                 "Yes",
          //                 style: TextStyle(
          //                   color: Colors.black,
          //                 ),
          //               ),
          //             ),
          //             CupertinoDialogAction(
          //               onPressed: () {
          //                 Navigator.pop(context);
          //               },
          //               child: Text(
          //                 "No",
          //                 style: TextStyle(
          //                   color: Colors.black,
          //                 ),
          //               ),
          //             ),
          //           ],
          //           content: Text(
          //             'Are you sure want to logout?',
          //           ),
          //         );
          //       },
          //     );
          //   },
          //   child: Icon(
          //     Icons.logout_rounded,
          //     color: Colors.white,
          //   ),
          // ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: height,
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login,',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    // Text(
                    //   username!,
                    //   style: TextStyle(color: Colors.white, fontSize: 20),
                    // ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Column(
                  children: [
                    TextFormField(
                      onChanged: (value) {},
                      controller: usernameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        icon: Icon(Icons.person, color: Colors.white),
                        hintText: 'Username',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onChanged: (value) {},
                      controller: passwordController,
                      obscureText: passwordVisible,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock, color: Colors.white),
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.white),
                        suffixIcon: IconButton(
                              icon: Icon(passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(
                                  () {
                                    passwordVisible = !passwordVisible;
                                  },
                                );
                              },
                            ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onChanged: (value) {},
                      controller: dbNameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        icon: Icon(Icons.data_object, color: Colors.white),
                        hintText: 'Database Name',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onChanged: (value) {},
                      controller: dbServerController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        icon: Icon(Icons.wifi_tethering, color: Colors.white),
                        hintText: 'Database Server',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField(
                      dropdownColor: Color.fromARGB(255, 53, 53, 53),
                      value: databaseType,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      isDense: true,
                      decoration: InputDecoration(
                        icon: Icon(Icons.data_saver_off),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 15,
                        ),
                        border: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 0.7,
                          ),
                        ),
                      ),
                      items: databaseTypeItems.map((String item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          databaseType = newValue!;
                          databaseSelect = newValue;
                        });
                      },
                    ),
                    DropdownButtonFormField(
                      dropdownColor: Color.fromARGB(255, 53, 53, 53),
                      value: authenticationType,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      isDense: true,
                      decoration: InputDecoration(
                        icon: Icon(Icons.verified_user_rounded),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 15,
                        ),
                        border: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 0.7,
                          ),
                        ),
                      ),
                      items: authenticationTypeItems.map((String item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          authenticationType = newValue!;
                          authenticationTypeSelect = newValue;
                        });
                      },
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Center(
                        child: Container(
                          height: 40,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: const Color.fromARGB(255, 53, 53, 53),
                          ),
                          child: Center(
                            child: Text(
                              "SUBMIT",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
