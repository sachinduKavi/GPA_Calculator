import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gpa_calculator/Domain.dart';
import 'package:gpa_calculator/UploadData.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, dynamic> userDetails = {
    "userName" : "Loading...",
    "email": "Loading...",
    "password": "Loading...",
    "university": "Loading...",
    "degree": "Loading...",
    "mobile": "Loading..."
  };
  String userEmail = "";

  @override
  void initState() {
    // TODO: implement initState
    // Initiate all async functions ...
    fetchUserDetails();
    super.initState();
  }

  Future<void> fetchUserDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userEmail = preferences.getString("user_email") ?? "null";
    if(userEmail != null) {
      try {
        final response = await http.post(
          Uri.parse("${Domain.mainDomain}users/getUserDetails"),
          body: {"user_email": userEmail},
        );

        setState(() {
          userDetails = jsonDecode(response.body)['results'];
        });
        print('${response.body}');
      } catch (e) {
        print("Error : $e");
      }
    }
  }

  void fetchUsers(Map<String, dynamic> map) {
    setState(() {
      userDetails = map;
    });
  }

  TextEditingController valueController = TextEditingController();
  Future<void> editUserDetails(String key) async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context, builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(padding: EdgeInsets.all(10), child: Text("Change User Details", style: TextStyle(fontSize: 30, color: Colors.activeColor, fontWeight: FontWeight.bold),)),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      const Text("New Value", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.mainColor)),

                    SizedBox(
                        width: double.infinity,
                        child: TextField(
                          controller: valueController,
                          decoration: InputDecoration(hintText: key, enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(width: 4, color: Colors.mainColor)
                        )), style: const TextStyle(fontSize: 22),)),]
                   ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(onPressed: () async {
                      showDialog(context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white,));
                      });
                      Map<String, dynamic>? response = await UploadData.editUserDetails(userEmail, key, valueController.text.toString());
                      if(response != null){
                        fetchUsers(response);
                      }

                      Navigator.pop(context);
                      Navigator.pop(context);

                    },
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.activeColor), ), child: const Padding(padding: EdgeInsets.all(8) ,child: Text("Update", style: TextStyle(fontSize: 22)),
                    ),),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: (){
          Navigator.of(context).pushNamed("degree");
        },),
        title: const Text("My Profile"),),
      body: Column(
        children:[
          Container(
            width: double.infinity,
            color: Colors.black87,
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Column(
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage("assets/images/user.png"),
                        radius: 70,
                        backgroundColor: Colors.white,
                      ),

                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text("${userDetails['userName']}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),))
                    ],
                  )

                ],
              ),
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 100, child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 20),)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(child: Text("${userDetails['email']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 20), softWrap: true,)),

                              Expanded(child: Container())

                            ])
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(child: Text("Mobile Number", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 20),),),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(child: Text("${userDetails['mobile']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 20), overflow: TextOverflow.ellipsis,)),

                              SizedBox(child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue,),
                                onPressed: () {
                                  editUserDetails("mobile");
                                  valueController.text = "";
                                },)),

                            ])
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 100, child: Text("Password", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 20),),),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(child: Text("${userDetails['password']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 20), softWrap: true,)),

                              SizedBox(child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue,),
                                onPressed: () {
                                  editUserDetails("password");
                                  valueController.text = "";
                                },)),

                            ])
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 100, child: Text("University", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 20),)),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                          SizedBox(child: Text("${userDetails['university']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 20), softWrap: true,)),

                            SizedBox(child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue,),
                          onPressed: () {
                            editUserDetails("university");
                            valueController.text = "";
                          },)),

                        ])
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 100, child: Text("Degree", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 20),)),
                        Row(
                            children: [
                              Expanded(child: Text("${userDetails['degree']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 20), softWrap: true,)),

                              SizedBox(child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue,),
                                onPressed: () async {
                                  await editUserDetails("degree");
                                  SharedPreferences preferences = await SharedPreferences.getInstance();
                                  preferences.setString("degree_name", userDetails['degree_name']);
                                  valueController.text = "";
                                },)),

                            ])
                      ],
                    ),
                  ),



                ],
              ),
            ),
          ),
        ]
      ),
    );
  }
}
