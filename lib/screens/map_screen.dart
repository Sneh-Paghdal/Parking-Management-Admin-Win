import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:parkingadmin/main.dart';

import 'booking_screen.dart';
class map_screen extends StatefulWidget {
  const map_screen({Key? key}) : super(key: key);

  @override
  State<map_screen> createState() => _map_screenState();
}

class _map_screenState extends State<map_screen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  List<dynamic> parkingBoxList = [];
  int colNum = 0;
  bool isDataLoading = true;
  bool isBooking = false;

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

  bookSlotPostApi(from,name,number,index) async {
    bool isNetOn = await checkInternetConnection();
    if(isNetOn == true){
      setState(() {
        isBooking = true;
      });
      var body = {
        "boxId": "${parkingBoxList[index]['boxId']}",
        "timeSlot": "${from}|${name}|${number}"
      };
      final url =Uri.parse('https://script.google.com/macros/s/AKfycbwphB5_uy-p8Tfen6GwpFulFuXHOCQI5sGAR0jkkkFkRxISnvaEOkl6jYLVJ0Gk_UL5/exec');
      final response = await http.post(url,body: jsonEncode(body),headers: {
        "Content-Type": "application/json"
      });
      if(response.statusCode == 200){
        print("??????????????????");
        clearFunction();
        Navigator.pop(context);
        getParkingModel();
      }else if(response.statusCode == 302){
        print(response.statusCode);
        clearFunction();
        Navigator.pop(context);
        getParkingModel();
        setState(() {
          isBooking = false;
        });
        showToast(context, "Your Booking has been done", true, Colors.green, 100);
      }
    }else{
      showToast(context, "Please turn on the internet", true, Colors.red, 100);
    }
  }

  releaseSlotPostApi(index) async {
    bool isNetOn = await checkInternetConnection();
    if(isNetOn == true){
      setState(() {
        isBooking = true;
      });
      var body = {
        "boxId": "${parkingBoxList[index]['boxId']}",
        "timeSlot": "NB"
      };
      final url =Uri.parse('https://script.google.com/macros/s/AKfycbwleOieXEIhB-lLktVxj_tmpgc29Dcy8yKu9LWtagzU2nKl-WQGGp3vPRDUQqFE78g/exec');
      final response = await http.post(url,body: jsonEncode(body),headers: {
        "Content-Type": "application/json"
      });
      if(response.statusCode == 200){
        print("??????????????????");
        clearFunction();
        Navigator.pop(context);
        getParkingModel();
      }else if(response.statusCode == 302){
        print(response.statusCode);
        clearFunction();
        Navigator.pop(context);
        getParkingModel();
        setState(() {
          isBooking = false;
        });
        showToast(context, "Slot released successfully", true, Colors.green, 100);
      }
    }else{
      Navigator.pop(context);
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
                  }else if(parkingBoxList[index]['value'] == "NB" || parkingBoxList[index]['value'] == "Booked: NB"){
                    onTabDialog(context,index);
                  }else if(parkingBoxList[index]['value'] != "BA" || parkingBoxList[index]['value'] != "EV" || parkingBoxList[index]['value'] != "NB" || parkingBoxList[index]['value'] != "Booked: NB"){
                    onReleaseDialog(context,index);
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: (parkingBoxList[index]['value'] == "NB" || parkingBoxList[index]['value'] == "Booked: NB") ? Colors.green.shade100 : (parkingBoxList[index]['value'] == "BA") ? Colors.yellow.shade100 : (parkingBoxList[index]['value'] == "EV") ? Colors.deepPurpleAccent.shade100 : Colors.red.shade100,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade200,
                          spreadRadius: 0.5,
                          blurRadius: 8)
                    ],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (parkingBoxList[index]['value'] == "NB" || parkingBoxList[index]['value'] == "Booked: NB") ? Colors.green : (parkingBoxList[index]['value'] == "BA") ? Colors.yellow : (parkingBoxList[index]['value'] == "EV") ? Colors.deepPurpleAccent : Colors.red,
                      width: 0.5, // Set the border width (optional)
                    ),
                  ),
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Center(
                    child: Text((parkingBoxList[index]['value'] == "NB" || parkingBoxList[index]['value'] == "Booked: NB") ? "${parkingBoxList[index]['boxId']}" : (parkingBoxList[index]['value'] == "BA") ? "BA" : (parkingBoxList[index]['value'] == "EV") ? "EV" : "B",style: TextStyle(fontSize: 14)),
                  ),
                ),
              );
            }),
      );
  }
  void onTabDialog(BuildContext context, int index) {
    String fromDate = "";
    String toDate = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
              child: Container(
                width: 600,
                height: 330,
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Do you want to book this slot?",
                      style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),
                    ),
                    Row(
                      children: [
                        Text(
                          "Date: ",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text("${DateFormat('dd MMMM yyyy').format(DateTime.now())}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select appropriate time:   ",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Container(
                          width: 200,
                          margin: EdgeInsets.only(top: 5),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'From',
                              border: OutlineInputBorder(),
                            ),
                            controller: dateController,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Name:   ",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Container(
                          width: 200,
                          margin: EdgeInsets.only(top: 5),
                          child: TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Enter your name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              // Handle onChanged event
                              // You can update the fromDate variable or perform any other actions here
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Mobile Number:   ",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Container(
                          width: 200,
                          margin: EdgeInsets.only(top: 5),
                          child: TextField(
                            controller: mobileController,
                            decoration: InputDecoration(
                              labelText: 'Enter your mobile number',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              // Handle onChanged event
                              // You can update the fromDate variable or perform any other actions here
                            },
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        if (dateController.text.isEmpty || nameController.text.isEmpty || mobileController.text.isEmpty) {
                          showToast(context, "Please fill all details", false, Colors.red, 100);
                        } else {
                          bookSlotPostApi(dateController.text, nameController.text, mobileController.text, index);
                        }
                      },
                      child: Container(
                        height: 50,
                        margin: EdgeInsets.only(top: 15),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade400,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            "Book The Slot",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void onReleaseDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Container(
                width: 500,
                height: 60,
                padding: EdgeInsets.all(10),
                child: Container(
                  child: Row(
                    children: [
                      Text("Are you want to release this slot ?     "),
                      InkWell(
                        onTap: (){
                          releaseSlotPostApi(index);
                        },
                          child: Text("    Release",style: TextStyle(color: Colors.red),))
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  clearFunction(){
    mobileController.clear();
    nameController.clear();
    dateController.clear();
  }
}
