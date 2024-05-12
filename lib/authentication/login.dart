import 'package:ccwassist/screens/homewrapper.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // bool isStudent = true; // Initially set to student registration
  
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  // Color StudentColorButton = Colors.black;
  // Color TeacherColorButton = Colors.white;
  // Color StudentTextButton = Colors.white;
  // Color TeacherTextButton = Colors.purple;
  // void clrchg() {
  //   setState(() {
  //     if (isStudent == true) {
  //       StudentColorButton = Colors.black;
  //       TeacherColorButton = Colors.white;

  //       StudentTextButton = Colors.white;
  //       TeacherTextButton = Colors.purple;
  //     } else {
  //       StudentColorButton = Colors.white;
  //       TeacherColorButton = Colors.black;

  //       StudentTextButton = Colors.purple;
  //       TeacherTextButton = Colors.white;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Image(image: AssetImage("images/ritgate.jpg")),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Login(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget Login() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // const Divider(thickness: 5,color: Colors.black,),
          const SizedBox( height: 30 ),
          TextField(
            controller: _email,
            style: const TextStyle(fontSize: 20),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0)),
              labelText: "Email",
              hintText: "Enter Email ID",
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _password,
            style: const TextStyle(fontSize: 20),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              labelText: "Password",
              hintText: "Enter Password",
            ),
            obscureText: true,
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: (() => _login(context, _email.text, _password.text)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                fixedSize: const Size(150, 50)),
            child: const Text(
              'Login',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 40),
          // TextButton(
          //     onPressed: () {}, child: const Text('Forgot Password ?')),
        ],
      )
    );
  }

  void _login(BuildContext context, String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = await _auth.signInWithEmailAndPassword(email: email, password: password);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Logged in"),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeWrapper()),ModalRoute.withName('/'));
      } on FirebaseAuthException catch (error) {
        if (error.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No user found for that email"),
            ),
          );
        } else if (error.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Incorrect password"),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Something went wrong: ${error.message}"),
            ),
          );
        }
      }
    }
  }
}