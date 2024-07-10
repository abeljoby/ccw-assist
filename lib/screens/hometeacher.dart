import 'package:ccwassist/screens/homewrapper.dart';
import 'package:ccwassist/screens/studentperformance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ccwassist/screens/classroom.dart';
import 'package:ccwassist/screens/scheduledtests.dart';
import 'package:ccwassist/screens/createtest.dart';
import 'package:ccwassist/screens/qbank.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'upcomingtests.dart';
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
        title: const Text('Teacher Home', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => const ProfilePage())));
          }, icon: const Icon(Icons.person_rounded,color: Colors.black,size: 30,),
          tooltip:'View Profile'),
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
                  padding: const EdgeInsets.all(15.0),
                  child: Material(
                    color: Colors.amber,
                    elevation: 7.0,
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox( // Set specific height and width
                      height: 80.0,
                      width: 150.0,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context,MaterialPageRoute(builder: ((context) => const CreateTest())));
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              'Create New Test',
                              style: TextStyle(fontSize: 19.0),
                              textAlign: TextAlign.center
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                padding: const EdgeInsets.all(15.0),
                child: Material(
                  color: Colors.amber,
                  elevation: 7.0,
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox( // Set specific height and width
                    height: 80.0,
                    width: 150.0,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context,MaterialPageRoute(builder: ((context) => const Classroom())));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            'Classrooms',
                            style: TextStyle(fontSize: 19.0),
                            textAlign: TextAlign.center
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Material(
                    color: Colors.amber,
                    elevation: 7.0,
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox( // Set specific height and width
                      height: 80.0,
                      width: 150.0,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: ((context) => const ScheduledTests())));
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              'Scheduled Tests',
                              style: TextStyle(fontSize: 19.0),
                              textAlign: TextAlign.center
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Material(
                    color: Colors.amber,
                    elevation: 7.0,
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox( // Set specific height and width
                      height: 80.0,
                      width: 150.0,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: ((context) => const QBank())));
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              'Question Bank',
                              style: TextStyle(fontSize: 19.0),
                              textAlign: TextAlign.center
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ],
              ),           
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Material(
                  color: Colors.amber,
                  elevation: 7.0,
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox( // Set specific height and width
                    height: 80.0,
                    width: 345.0,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: ((context) => const StudentPerformance())));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            'Student Performance',
                            style: TextStyle(fontSize: 19.0),
                            textAlign: TextAlign.center
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}