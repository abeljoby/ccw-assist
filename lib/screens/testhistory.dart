import 'package:ccwassist/screens/qpscreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestHistory extends StatefulWidget {
  const TestHistory({super.key});

  @override
  State<TestHistory> createState() => _TestHistoryState();
}

class _TestHistoryState extends State<TestHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Tests'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: GetTests(),
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
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('tests').orderBy('StartDate',descending: true).snapshots();
  
  Widget _buildTestSection({
    required String date,
    required String courseName,
    required String time,
    required String modules,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 16,right: 16,top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(courseName),
          Text(time),
          Text("Modules ${modules.toString().substring(1, modules.toString().length - 1)}"),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Handle edit test action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black
                ),
                child: const Text('View Result'),
            ),
            ],
          ),
          const Divider(), // Add a divider
        ],
      ),
    );
  }
  
  @override
  void initState() {
    super.initState();
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
          // physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            return _buildTestSection(date: data["StartDate"], courseName: data["Course"], time: data["StartTime"], modules: data["Modules"].toString());
          }).toList(),
        );
      },
    );
  }
}