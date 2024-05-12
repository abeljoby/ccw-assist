import 'package:ccwassist/screens/homestudent.dart';
import 'package:ccwassist/screens/hometeacher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ccwassist/screens/first.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _WrapperState();
}

class _WrapperState extends State<HomeWrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot) {
          String? email = snapshot.data?.email;
          if(snapshot.hasData) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("users").where("email",isEqualTo: email).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> qsnapshot) {
                Map loggedUser = (qsnapshot.data?.docs.firstOrNull?.data()??{}) as Map;
                if(qsnapshot.hasData) {
                  String userType = loggedUser["userType"];
                  if(userType == "Student") {
                    return HomeStudent(data: loggedUser,);
                  }
                  else {
                    return HomeTeacher(data: loggedUser);
                  }
                }
                else {
                  return CircularProgressIndicator();
                }
              }
            );
          }
          else {
            return First();
          }
        }
      )
    );
  }
}