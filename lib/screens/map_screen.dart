import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parkingadmin/main.dart';

import 'booking_screen.dart';
class map_screen extends StatefulWidget {
  const map_screen({Key? key}) : super(key: key);

  @override
  State<map_screen> createState() => _map_screenState();
}

class _map_screenState extends State<map_screen> {

  List<dynamic> parkingBoxList = [];
  int colNum = 0;
  bool isDataLoading = true;
  getParkingModel() async {
    bool isNetOn = await checkInternetConnection();
    if(isNetOn == true){
      setState(() {
        isDataLoading = true;
      });
      final url =Uri.parse('https://script.google.com/macros/s/AKfycbwtDQEAJYzKYhcae_GlCvCJm6JdHRarTCPR7OeLnG0Kc8Di0pInbTb_wrWJ75c0rp2B/exec');
      final response = await http.get(url);
      if(response.statusCode == 200){
        var json = jsonDecode(response.body);
        parkingBoxList = json['values'];
        colNum = json['columns'];
        print(parkingBoxList);
      }
      setState(() {
        isDataLoading = false;
      });
    }else{
      showToast(context, "Please turn on the internet", true, Colors.red, 100);
    }
  }

  @override
  void initState() {
    getParkingModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
      (isDataLoading == true)
          ?
      Container(
        height: MediaQuery.of(context).size.height - 70,
        width: double.infinity,
        child: Center(
          child: Container(
            width: 20,height: 20,child: CircularProgressIndicator(),
          ),
        ),
      )
          :
      Container(
        padding: EdgeInsets.all(10),
        width: double.infinity,
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: colNum, mainAxisExtent: 60, crossAxisSpacing: 10),
            itemCount: parkingBoxList.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  if(parkingBoxList[index]['value'] == "BA"){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(selectedIndex: 1)));
                  }else if(parkingBoxList[index]['value'] == "EV"){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(selectedIndex: 2)));
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: (parkingBoxList[index]['value'] == "NB") ? Colors.green.shade100 : (parkingBoxList[index]['value'] == "BA") ? Colors.yellow.shade100 : (parkingBoxList[index]['value'] == "EV") ? Colors.deepPurpleAccent.shade100 : Colors.red.shade100,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade200,
                          spreadRadius: 0.5,
                          blurRadius: 8)
                    ],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (parkingBoxList[index]['value'] == "NB") ? Colors.green : (parkingBoxList[index]['value'] == "BA") ? Colors.yellow : (parkingBoxList[index]['value'] == "EV") ? Colors.deepPurpleAccent : Colors.red,
                      width: 0.5, // Set the border width (optional)
                    ),
                  ),
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Center(
                    child: Text((parkingBoxList[index]['value'] == "NB") ? "${parkingBoxList[index]['boxId']}" : (parkingBoxList[index]['value'] == "BA") ? "BA" : (parkingBoxList[index]['value'] == "EV") ? "EV" : "B",style: TextStyle(fontSize: 10)),
                  ),
                ),
              );
            }),
      );
  }
}
