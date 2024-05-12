import 'package:ccwassist/screens/qbank.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ccwassist/screens/questionpaper.dart';

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
        title: const Text('Scheduled Tests'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body:  Expanded(
        child: SingleChildScrollView(
          child: GetTests(),
        ),
      ),
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
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('tests').orderBy('StartDate').snapshots();

  deleteTest(String docID) async {
    FirebaseFirestore.instance.collection('tests').doc(docID).delete();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
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
            return Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['StartDate'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(data['Course']),
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
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white
                          ),
                          child: const Text('Questions'),
                        ),
                      ],
                    ),
                    const Divider(), // Add a divider
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}