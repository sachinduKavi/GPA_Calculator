import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpa_calculator/Domain.dart';
import 'package:gpa_calculator/SQL_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UploadData {
  static Future<bool> uploadAllResults(BuildContext context) async{
    Map<String, dynamic> uploadResultMap = {};
    // Loading demonstration
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
      return const AlertDialog(
        icon: Icon(Icons.cloud_upload_rounded, size: 50, color: Colors.blueAccent,),
        title: Text("Data Uploading", style: TextStyle(color: Colors.black87, fontSize: 25),),
        content: SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator(color: Colors.blueAccent,))),
      );
    });
    // Get user name from shared preferences
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userEmail = preferences.getString("user_email").toString();
    // Get results data from sqlflite
    var results = await SQLHelper.getAllResults();

    uploadResultMap["user_email"] = userEmail;
    uploadResultMap["results_data"] = results;

    print('Upload Results:  ${jsonEncode(uploadResultMap)}');

    bool returnType;
    try {
      final response = await http.put(Uri.parse('${Domain.mainDomain}results/uploadResults'),
          body: jsonEncode(uploadResultMap),
          headers: {
            "Content-Type": "application/json"
          }
      );
      print('Response: ${response.statusCode}');
      print('Response: ${response.body}');
      returnType = true;
    } catch(exception) {
      print('Error $exception');
      returnType = false;
      showDialog(context: context, builder: (BuildContext context) {
        return const AlertDialog(
          icon: Icon(Icons.warning, color: Colors.red, size: 50,),
          title: Text("Connection terminated", style: TextStyle(fontSize: 22, color: Colors.red),),
        );
      });
    }
    Navigator.of(context).pop();
    return returnType;
  }


  static Future<void> downloadResults(String userEmail) async{
    int count = 0;
    while (count < 3) {
      try{
        final response = await http.post(Uri.parse("${Domain.mainDomain}results/downloadResults"),
        body: {"user_email": userEmail},
        );
        print('Response ${response.body}');
        var values = jsonDecode(response.body);
        var results = values['result'];
        String year, sem;
        for(final val in results) {
          year = val['year_sem'].toString().split("_")[0];
          sem = val['year_sem'].toString().split("_")[1];
          await SQLHelper.createResult(val['module_name'], val['credits'], val['grade'], int.parse(sem), int.parse(year));
        }
        break;
      } catch (e) {
        print('Error: $e');
        count++;
      }
    }

  }

  // Edit user details in the cloud
  static Future<Map<String, dynamic>?> editUserDetails(String userEmail, String key, String newValue) async {
    print('Upload function is running ...');
    try {
      final response = await http.put(Uri.parse("${Domain.mainDomain}users/editUser"),
      body: jsonEncode({
        "user_email": userEmail,
        "key": key,
        "new_value": newValue
      }),
        headers: {
        "Content-Type": "application/json"
        }
      );
      print('Response ${response.body}');

      return jsonDecode(response.body);
    }catch (e) {
      print("Error : $e");
    }
    return null;
  }




}