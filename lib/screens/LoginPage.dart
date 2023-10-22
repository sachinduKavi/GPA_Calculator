import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gpa_calculator/Domain.dart';
import 'package:gpa_calculator/SQL_helper.dart';
import 'package:gpa_calculator/UploadData.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool emailState = false, passwordState = false;

  Future<void> _readCurrentUser() async{
    final sp =  await SharedPreferences.getInstance();
    String? userEmail = sp.getString("user_email");
    print('User: ' + userEmail.toString());

    if(userEmail != null)
      Navigator.of(context).pushNamed("degree");

  }

  @override
  void initState() {
    // TODO: implement initState
    _readCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: ClipOval(
            child: SizedBox.fromSize(
              size: const Size.fromRadius(200),
                child: Image.asset("assets/images/loginImage.jpg", fit: BoxFit.cover,),
            ),
        ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 350,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(200)),
                  child: Material(
                    borderRadius: BorderRadius.circular(50),
                    elevation: 5,
                    child: ClipRRect(
                        child: SizedBox.fromSize(
                            child: Container(
                              padding: const EdgeInsets.all(25),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text("Login", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Color(0xFF6F61C0)),),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                                        child: TextField(style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                              controller: emailController,
                                              decoration: InputDecoration(
                                                hintText: "Email Address",
                                                errorText: emailState?"Email can not be empty":null,
                                                prefixIcon: const Icon(Icons.email),
                                                enabledBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(width: 3, color: Color(0xFF6F61C0)),
                                                  borderRadius: BorderRadius.all(Radius.circular(25)),
                                              )
                                          ),
                                        ),
                                      ),
                                       Padding(
                                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                                        child: TextField(
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                          obscureText: true,
                                          controller: passwordController,
                                          decoration: InputDecoration(
                                              errorText: passwordState?"Password can not be empty":null,
                                              hintText: "Password",
                                              prefixIcon: const Icon(Icons.lock),
                                              enabledBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(width: 3, color: Color(0xFF6F61C0)),
                                                borderRadius: BorderRadius.all(Radius.circular(25)),
                                              )
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    width: 250,
                                    color: const Color(0xFF6F61C0),
                                    child: Center(child: TextButton(child: const Text("Login", style: TextStyle(fontSize: 25, color:Colors.white, fontWeight: FontWeight.bold)), onPressed: () {
                                      accountAuthorization(emailController.text, passwordController.text);
                                    }),)
                                  )
                                ],
                            ),
                          ),
                      ),

                ),
                  ),
            ),
              Container(
                margin:const EdgeInsets.only(top: 20),
                child:  Center(
                  child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed('createAccount');
                      },
                      child: const Text("Create New Account?", style: TextStyle(fontSize: 15, color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),))
                ),
              ),


              Container(
                margin: const EdgeInsets.only(top: 10),
                child: InkWell(
                  onTap: () {
                    showDialog(context: context, builder: (BuildContext context) {
                        return AlertDialog(
                          icon: const Icon(Icons.warning, color: Colors.red, size: 45,),
                          title: const Text("You will not be able to save your data in the server if you skip registration. It is recommend to create a new account and login"),
                          content: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Continue button
                                ElevatedButton(onPressed: () {
                                  regSkip();
                                },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blue),
                                    ),
                                    child: const Text("Continue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),)),

                                // Cancel button
                                ElevatedButton(onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red)
                                    ),
                                    child: const Text("Cancel"))
                              ],
                            ),
                          ),
                        );
                    });

                  },
                  child: const Text("Skip Registration", style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),),
                ),
              )

              ]
          ),
          Container(
            margin: const EdgeInsets.all(20),
            width: 500,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("GPA Calculator", style: TextStyle(fontSize: 40, color: Color(0xFF0E4E67), fontWeight: FontWeight.bold),),
                Text("Keep track on your success", style: TextStyle(color: Color(0xFFFE9004), fontWeight: FontWeight.bold, fontSize: 15))
              ],
            ),
          )
        ]
      ),
    );
  }

  // Passing account authorization and registration
  // Guest users are allowed in the app
  // But guest users wont be able to sync with the cloud data base
  // Application will limited to local storage database
  Future<void> regSkip() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("user_email", "null");
    // Initiation of local database
    var scaleList = {
      "A+": 4.0,
      "A": 4.0,
      "A-": 3.7,
      "B+": 3.3,
      "B": 3.0,
      "B-": 2.7,
      "C+": 2.3,
      "C": 2.0,
      "C-": 1.7,
      "D+": 1.3,
      "D": 1.0,
      "E": 0.0,
    };

    for (final entry in scaleList.entries) {
      await SQLHelper.insertScale(entry.key, entry.value);
    }
    Navigator.of(context).pushNamed("degree");
  }

  // Password authorization check email and password from the API
  void accountAuthorization(String email, String password) {
    setState(() {
      emailState = false;
      passwordState = false;
      if(email == "") {
        emailState = true;
      }
      if (password == "") {
        passwordState = true;
      }
      if(!emailState && !passwordState) {
        requestServerAuthorization(email, password);
      };
    });
  }

  Future requestServerAuthorization(String email, String password) async{
    showDialog(context: context,
        barrierDismissible: false,
        builder: (context) {
      return const Center(child: CircularProgressIndicator(color: Colors.white,),);
    });
    final sp = await SharedPreferences.getInstance();

    try{
      var response = await http.get(Uri.parse(
          '${Domain.mainDomain}users/userAuthorization/$email/$password'));
      print(response.body);
      Navigator.of(context).pop();
      var result = jsonDecode(response.body);
      if (result['authorized']) {
        await UploadData.downloadResults(result['result'][0]['email']);
        sp.setString("degree_name", result['result'][0]['degree']);
        sp.setString("user_email", result['result'][0]['email']);

        // Initiation of local database
        var scaleList = {
          "A+": 4.0,
          "A": 4.0,
          "A-": 3.7,
          "B+": 3.3,
          "B": 3.0,
          "B-": 2.7,
          "C+": 2.3,
          "C": 2.0,
          "C-": 1.7,
          "D+": 1.3,
          "D": 1.0,
          "E": 0.0,
        };

        for (final entry in scaleList.entries) {
          await SQLHelper.insertScale(entry.key, entry.value);
        }

        Navigator.of(context).pushNamed("degree");
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  icon: Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 45,
                  ),
                  title: Text("Account authorization faild"),
                  content: Text(
                    result['message'],
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ));
            });
      }
    }catch(e) {
      Navigator.of(context).pop();
      print('Error : $e');
      showDialog(context: context, builder: (BuildContext context){
        return const AlertDialog(
          icon: Icon(Icons.wifi_tethering_error_sharp, color: Colors.red, size: 45,),
          title: Text("Sorry, can't connect to the server, please check your internet connection and try again.", style: TextStyle(fontSize: 22, color: Colors.red),),
        );
      });
    }
  }
}
