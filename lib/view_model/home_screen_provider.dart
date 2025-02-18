import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

List<dynamic> mapData = [];

///Isolate method : fetching data from api
void fetchDataInIsolate(SendPort sendPort) async {

  try{

    /// Waiting 5 seconds for testing multithreading
    await Future.delayed(Duration(seconds: 5),);

    const url = "https://jsonplaceholder.typicode.com/users";
    final response = await http.get(Uri.parse(url),);

    if(response.statusCode == 200){
      log("\nApi fetching successful, status code : ${response.statusCode}\n");
      mapData = jsonDecode(response.body);
      debugPrint("\nDecoded json data : $mapData\n");
      List<dynamic> data = jsonDecode(response.body);
      sendPort.send(data);
    }
    else{
      log("\nApi fetching failed due to status code : ${response.statusCode}\n");
      sendPort.send({});
    }

  }catch(error){
    log("\nError while fetching data in another thread (multithreading) : $error\n");

  }

}



class HomeScreenProvider with ChangeNotifier{

  ///onPressed isolate method
  Future<List<dynamic>> onPressed() async {
    debugPrint("\nIsolate method!\n");

    try{
      ReceivePort receivePort = ReceivePort();

      await Isolate.spawn(fetchDataInIsolate, receivePort.sendPort);
      dynamic _data;
      receivePort.listen((data){
        _data = data;
      });
      return _data;
    }catch(error){
      log("\nError while fetching data in another thread (multithreading) : $error\n");
      return [];
    }
  }

}