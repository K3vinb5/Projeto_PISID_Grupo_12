import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({Key? key}) : super(key: key);

  @override
  LoginFormScreenState createState() {
    return LoginFormScreenState();
  }
}

class LoginFormScreenState extends State<LoginFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController(text: "root");
  final passwordController = TextEditingController();
  final ipController = TextEditingController(text: "127.0.0.1");
  final portController = TextEditingController(text: "80");

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: usernameController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please insert a valid username';
                }
                return null;
              },
            ),
            TextFormField(
              controller: passwordController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            TextFormField(
              controller: ipController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'IP (xxx.xxx...)',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please insert a valid IP';
                }
                return null;
              },
            ),
            TextFormField(
              controller: portController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Port Apache',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    validateLogin();
                  }
                },
                child: const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  validateLogin() async {
    String loginURL = "http://" +
        ipController.text.trim() +
        ":" +
        portController.text.trim() +
        "/db/db_validateLogin.php";
    print(loginURL);
    try{
      var response = await http.post(Uri.parse(loginURL), body: {
        'username': usernameController.text.trim(), //get the username text
        'password': passwordController.text.trim() //get password text
      });
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        print(jsonData);
        if (jsonData["success"]) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', usernameController.text.trim());
          await prefs.setString('password', passwordController.text.trim());
          await prefs.setString('ip', ipController.text.trim());
          await prefs.setString('port', portController.text.trim());
          context.go("/alerts");
        } else {
          print(response.body);
          showErrorDialog();
        }
      } else {
        //if status code different from 200 then something went wrong
        showErrorDialog();
      }
    }catch(e){
      //If we ended up on this code than something went wrong locating the database itself or the supposed file location(I think)
      showErrorDialog();
    }
    
  }
  void showErrorDialog(){
    //TODO message field currently missing
    // Something like this: Text(jsonData["message"]),
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width:  MediaQuery.of(context).size.width * 0.5,
            child: const Center(child: Text("The connection to the database failed.")),
          ),
        );
      },
    );
  }
}
