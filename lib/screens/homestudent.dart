import 'package:ccwassist/screens/studentclassroom.dart';
import 'package:ccwassist/screens/homewrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'upcomingtests.dart';
import 'feedback.dart';
import 'profile.dart';
import 'testhistory.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeStudent extends StatefulWidget {
  final Map data;
  const HomeStudent({super.key, required this.data});

  @override
  State<HomeStudent> createState() => _HomeStudentState();
}

class _HomeStudentState extends State<HomeStudent> {
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
        title: const Text('Student Home', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => const ProfilePage())));
              },
              icon: const Icon(Icons.person_rounded,color: Colors.black,size: 30,),
              tooltip:'View Profile'),
        ],
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Image(image: AssetImage('images/ritcsdept.jpg')),
              const SizedBox(height: 20),
              Text('Welcome, ${name}'),
              const SizedBox(height: 20),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) =>
                                  const UpcomingTests())));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            'Upcoming Tests',
                            style: TextStyle(fontSize: 19.0),
                            textAlign: TextAlign.center
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
                          Navigator.push(context, MaterialPageRoute(builder: ((context) => const StudentClassroom())));
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
                          Navigator.push(context, MaterialPageRoute(builder: ((context) => const Courses())));
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              'Courses',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) =>
                                  const TestHistory())));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            'Test History',
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/joinclass');
        },
        label: Text('Join classroom'),
        // shape: const CircleBorder(),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses',style: TextStyle(fontWeight: FontWeight.bold)),
        // centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50, // specify the desired height
                width: double.infinity, // specify the desired width
                color: Colors.black, // example background color
                child: const Center(
                  child: Text(
                    'Discrete Mathematical Structures',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50, // specify the desired height
                width: double.infinity, // specify the desired width
                color: Colors.black, // example background color
                child: const Center(
                  child: Text(
                    'Data Structures',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50, // specify the desired height
                width: double.infinity, // specify the desired width
                color: Colors.black, // example background color
                child: const Center(
                  child: Text(
                    'Computer Organization and Architecture',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50, // specify the desired height
                width: double.infinity, // specify the desired width
                color: Colors.black, // example background color
                child: const Center(
                  child: Text(
                    'Database Management System',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50, // specify the desired height
                width: double.infinity, // specify the desired width
                color: Colors.black, // example background color
                child: const Center(
                  child: Text(
                    'Operating Systems',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50, // specify the desired height
                width: double.infinity, // specify the desired width
                color: Colors.black, // example background color
                child: const Center(
                  child: Text(
                    'Formal Languages and Automata Theory',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
              width: double.infinity,
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.amber,
            //     foregroundColor: Colors.black,
            //   ),
            //   child: const Text('Back to home'),
            // )
          ],
        ),
      )
    );
  }
}
