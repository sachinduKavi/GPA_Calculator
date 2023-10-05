import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gpa_calculator/Domain.dart';
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
    String? userEmail = sp.getString("userEmail");
    print('User: ' + userEmail.toString());

    if(userEmail != null)
      Navigator.of(context).pushNamed("degree");

  }

  @override
  Widget build(BuildContext context) {
    _readCurrentUser();
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
                Text("Make your dreams come true", style: TextStyle(color: Color(0xFFFE9004), fontWeight: FontWeight.bold, fontSize: 15))
              ],
            ),
          )
        ]
      ),
    );
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
    showDialog(context: context, builder: (context) {
      return const Center(child: CircularProgressIndicator(),);
    });
    final sp = await SharedPreferences.getInstance();
    sp.setString("userEmail", email);
    var response = await http.get(Uri.parse('${Domain.mainDomain}users/userAuthorization/$email/$password'));
    print(response.body);
    Navigator.of(context).pop();
    var result = jsonDecode(response.body);
    if(result['authorized']) {
      Navigator.of(context).pushNamed("degree");
    }
  }
}
