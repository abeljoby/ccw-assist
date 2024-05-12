import 'package:ccwassist/screens/homewrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ccwassist/screens/classroom.dart';
import 'package:ccwassist/screens/scheduledtests.dart';
import 'package:ccwassist/screens/createtest.dart';
import 'package:ccwassist/screens/qbank.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'upcomingtests.dart';
import 'testhistory.dart';
import 'feedback.dart';
import 'profile.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeTeacher extends StatefulWidget {
  final Map data;
  const HomeTeacher({super.key, required this.data});

  @override
  State<HomeTeacher> createState() => _HomeTeacherState();
}

class _HomeTeacherState extends State<HomeTeacher> {
  final user = FirebaseAuth.instance.currentUser!;
  late Map userDetails = {};
  late String name = "";

  @override 
  void initState() {
    userDetails = widget.data;
    // clearUserDetails();
    storeUserDetails();
    super.initState();
  }

  void clearUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void loadUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  void storeUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("batch", userDetails["batch"]);
      prefs.setString("dept", userDetails["dept"]);
      prefs.setString("email", userDetails["email"]);
      prefs.setString("ktuID", userDetails["ktuID"]);
      prefs.setString("name", userDetails["name"]);
      prefs.setString("userType", userDetails["userType"]);
      name = userDetails["name"];
    });
  }

  logout() async {
    clearUserDetails();
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeWrapper()),ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Teacher'),
        // leading: 
        //    PopupMenuButton(icon: const Icon(Icons.menu),
        //     itemBuilder: ((context) => [
        //           const PopupMenuItem(child: Text("About")),
        //         //  const PopupMenuItem(child: Text("Feedback")),
        //           const PopupMenuItem(child: Text("Change Password")),
        //           PopupMenuItem(
        //             child: Text("Logout"),
        //             onTap: () => logout,
        //           ),
        //         ]),
        //   ),
        actions: [
          IconButton(onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => const ProfilePage())));
          }, icon: const Icon(Icons.person_rounded),tooltip: 'View Profile'),
        ],
        backgroundColor: Colors.amber,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Image(image: AssetImage("images/ritcsdept.jpg")),
              const SizedBox(height: 20),
              Text('Welcome, ${name}'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(              
                      color: Colors.amber,
                      shadowColor: Colors.black,
                      elevation: 7,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 80,
                            width: 150,
                            child: ListTile(
                              title: const Text('Create New Test',style: TextStyle(fontSize: 19),textAlign: TextAlign.center,),
                              onTap: () {
                                Navigator.push(context,MaterialPageRoute(builder: ((context) => const CreateTest())));
                              },
                            ),
                          ),
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                      color: Colors.amber,
                      shadowColor: Colors.black,
                      elevation: 7,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 80,
                            width: 150,
                            child: ListTile(
                              title: const Text('Classrooms',style: TextStyle(fontSize: 19),textAlign: TextAlign.center),
                              onTap: () {
                                Navigator.push(context,MaterialPageRoute(builder: ((context) => const Classroom())));
                              },
                            ),
                          )
                        ],
                      )),
                ),
              ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(              
                      color: Colors.amber,
                      shadowColor: Colors.black,
                      elevation: 7,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 80,
                            width: 150,
                            child: ListTile(
                              title: const Text('Scheduled Tests',style: TextStyle(fontSize: 19),textAlign: TextAlign.center,),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: ((context) => const ScheduledTests())));                               
                              },
                            ),
                          ),
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                      color: Colors.amber,
                      shadowColor: Colors.black,
                      elevation: 7,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 80,
                            width: 150,
                            child: ListTile(
                              title: const Text('Question Bank',style: TextStyle(fontSize: 19),textAlign: TextAlign.center),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: ((context) => const QBank())));
                              },
                            ),
                          )
                        ],
                      )),
                  ),
                ],
              ),           
              // Padding(
              //   padding: const EdgeInsets.all(15.0),
              //   child: Card(
              //       color: Colors.amber,
              //       shadowColor: Colors.black,
              //       elevation: 7,
              //       child: Column(
              //         children: [
              //           SizedBox(
              //             height: 80,
              //             width: 345,
              //             child: ListTile(
              //               title: const Text('Student Performance',style: TextStyle(fontSize: 19),textAlign: TextAlign.center),
              //               onTap: () {},
              //             ),
              //           )
              //         ],
              //       )),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}