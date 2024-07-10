import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ccwassist/screens/questionpaper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ScheduledTests extends StatefulWidget {
  const ScheduledTests({super.key});

  @override
  State<ScheduledTests> createState() => _ScheduledTestsState();
}

class _ScheduledTestsState extends State<ScheduledTests> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Tests',style: TextStyle(fontWeight: FontWeight.bold)),
        // centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: GetTests(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.popAndPushNamed(context, '/createtest');
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GetTests extends StatefulWidget {
  @override
    State<GetTests> createState() => GetTestsState();
}

class GetTestsState extends State<GetTests> {
  late String currentDate = '';
  late String emailID = '';
  late Stream<QuerySnapshot> _testStream;

  deleteTest(String docID) async {
    FirebaseFirestore.instance.collection('tests').doc(docID).delete();
  }

  void loadUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    emailID = prefs.getString("email")!;
  }

  @override
  void initState() {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    currentDate = formatter.format(now);
    loadUserDetails();
    super.initState();
    _testStream = FirebaseFirestore.instance.collection('tests').where('StartDate',isGreaterThanOrEqualTo: currentDate).orderBy('StartDate').orderBy('StartTime').snapshots();
  }

  Widget _buildTestSection(Map<String,dynamic> data, DocumentSnapshot document) {
    String dateString = data["StartDate"];
    // Parse the date string
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse(dateString);

    // Get Day of week as string
    DateFormat dayOfWeekFormat = DateFormat("EEEE"); // EEEE for full weekday name
    String dayOfWeek = dayOfWeekFormat.format(dateTime);

    // Format the date with desired output format
    DateFormat monthYearFormat = DateFormat("d MMMM yyyy"); // d for day with no leading zero, MMMM for full month name
    String formattedDate = monthYearFormat.format(dateTime);

    // Combine day of week and formatted date
    String dateHeading = "$dayOfWeek, $formattedDate";

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 16,right: 16,top: 5,bottom: 5),
          width: double.infinity,
          color: Colors.black,
          child: Text(dateHeading, style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        ),
        Container(
          padding: const EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 16),
          // padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(data['StartDate'], style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(data['Course'],style: TextStyle(fontWeight: FontWeight.bold)),
              Text(data['StartTime']),
              Text("Modules ${data['Modules'].toString().substring(1, data['Modules'].toString().length - 1)}"),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                //   ElevatedButton(
                //     onPressed: () {
                //       // Handle edit test action
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.indigo,
                //       foregroundColor: Colors.white
                //     ),
                //     child: const Text('Edit test'),
                // ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle delete test action
                      setState(() {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Confirm delete'),
                            content: Text('Are you sure you want to delete this test?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(false);
                                },
                                child: Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(true);
                                  deleteTest(document.id);
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          ),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white
                    ),
                    child: const Text('Delete test'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.push(context,MaterialPageRoute(builder: ((context) => QuestionPaper(data: data,id: document.id))));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black
                    ),
                    child: const Text('Questions'),
                  ),
                ],
              ),
              // const Divider(), // Add a divider
            ],
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _testStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child:SizedBox(width: 30, height: 30, child: CircularProgressIndicator()));
        }

        return ListView(
          shrinkWrap: true,
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          return _buildTestSection(data,document);
          }).toList(),
        );
      },
    );
  }
}