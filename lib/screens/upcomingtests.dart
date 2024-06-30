import 'package:ccwassist/screens/qpscreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpcomingTests extends StatefulWidget {
  const UpcomingTests({super.key});

  @override
  State<UpcomingTests> createState() => _UpcomingTestsState();
}

class _UpcomingTestsState extends State<UpcomingTests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Tests'),
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
  
  @override
  void initState() {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    currentDate = formatter.format(now);
    loadUserDetails();
    super.initState();
  }

  void loadUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    emailID = prefs.getString("email")!;
  }

  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('tests').orderBy('StartDate').snapshots();

  bool isValidTimeRange(String start, String duration) {
    TimeOfDay startTime = TimeOfDay(hour: int.parse(start.substring(0,2)), minute: int.parse(start.substring(3,5)));
    int addedminutes = int.parse(duration.substring(0,2));
    int newminutes = (startTime.minute + addedminutes)%60;
    int newhour = startTime.hour + (startTime.minute + addedminutes)~/60;
    TimeOfDay endTime = TimeOfDay(hour: newhour, minute: newminutes);
    TimeOfDay now = TimeOfDay.now();
    return ((now.hour > startTime.hour) || (now.hour == startTime.hour && now.minute >= startTime.minute))
        && ((now.hour < endTime.hour) || (now.hour == endTime.hour && now.minute <= endTime.minute));
  }

  Widget _buildTestSection(Map<String,dynamic> data, DocumentSnapshot document) {
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
            if(isValidTimeRange(data['StartTime'], data['Duration'])&&(currentDate == data['StartDate']))
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => TestScreen(id: document.id,data: data,email: emailID)),(Route<dynamic> route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white
                    ),
                    child: const Text('Attend Test'),
                  ),
                ],
              ),
            const Divider(),
          ],
        ),
      ),
    );
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
            return _buildTestSection(data,document);
          }).toList(),
        );
      },
    );
  }
}