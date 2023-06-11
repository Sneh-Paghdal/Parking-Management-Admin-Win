import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
class booking_screen extends StatefulWidget {
  const booking_screen({Key? key}) : super(key: key);

  @override
  State<booking_screen> createState() => _booking_screenState();
}

class _booking_screenState extends State<booking_screen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  List<dynamic> parkingBoxList = [];
  int colNum = 0;
  bool isDataLoading = true;
  bool isBooking = false;

  @override
  void initState() {
    getParkingModel();
    super.initState();
  }

  getParkingModel() async {
    bool isNetOn = await checkInternetConnection();
    if(isNetOn == true){
      setState(() {
        isDataLoading = true;
      });
      final url =Uri.parse('https://script.google.com/macros/s/AKfycbyViwDqODHgk-5A4A4KsnnBdF4AsYpO-u8io5fRQSrBBjOP87DsAjVC7t7TYgSgHpU/exec');
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

  bookSlotPostApi(from,to,name,number,index) async {
    bool isNetOn = await checkInternetConnection();
    if(isNetOn == true){
      setState(() {
        isBooking = true;
      });
      var body = {
        "boxId": "${parkingBoxList[index]['boxId']}",
        "timeSlot": "${from}|${to}|${name}|${number}"
      };
      final url =Uri.parse('https://script.google.com/macros/s/AKfycbxoJAhcECoCf2CW-d0H0698Sx1razYqBujCc6L-yjWdWCBkUgyLiS5MVxUgtanN-nWk/exec');
      final response = await http.post(url,body: jsonEncode(body),headers: {
        "Content-Type": "application/json"
      });
      if(response.statusCode == 200){
        print("??????????????????");
        clearFunction();
        getParkingModel();
        Navigator.pop(context);
      }else if(response.statusCode == 302){
        print(response.statusCode);
        clearFunction();
        getParkingModel();
        Navigator.pop(context);
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
      final url =Uri.parse('https://script.google.com/macros/s/AKfycbwpFQ1FEVefCeJQfTal8zybFP-4JfpJq-8LpAiVrV9ZLHNrF2IRd-pTnN_q4G6FyqmP/exec');
      final response = await http.post(url,body: jsonEncode(body),headers: {
        "Content-Type": "application/json"
      });
      if(response.statusCode == 200){
        print("??????????????????");
        clearFunction();
        getParkingModel();
        Navigator.pop(context);
      }else if(response.statusCode == 302){
        print(response.statusCode);
        clearFunction();
        getParkingModel();
        Navigator.pop(context);
        setState(() {
          isBooking = false;
        });
        showToast(context, "Slot released successfully", true, Colors.green, 100);
      }
    }else{
      showToast(context, "Please turn on the internet", true, Colors.red, 100);
    }
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
                  if(parkingBoxList[index]['value'] == "NB" || parkingBoxList[index]['value'] == "Booked: NB"){
                    onTabDialog(context,index);
                  }else{
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
                        Container(
                          width: 200,
                          margin: EdgeInsets.only(top: 5),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'To',
                              border: OutlineInputBorder(),
                            ),
                            controller: toDateController,
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
                        if (dateController.text.isEmpty || nameController.text.isEmpty || mobileController.text.isEmpty || toDateController.text.isEmpty) {
                          showToast(context, "Please fill all details", false, Colors.red, 100);
                        } else {
                          bookSlotPostApi(dateController.text, toDateController.text, nameController.text, mobileController.text, index);
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
                      Text("This slot is booked for ${extractTimesFromInput(parkingBoxList[index]['value'])},do you want to release this ?     "),
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
    toDateController.clear();
  }

}

void showToast(BuildContext context,message,bool isBottomsheet,Color color,int height) {

  ScaffoldMessenger.of(context).showSnackBar(

    SnackBar(
      duration: Duration(seconds: 1),
      // margin: EdgeInsets.only(top: 100),
      // margin: EdgeInsets.only(bottom: isBottomsheet == true ? MediaQuery.of(context).size.height-height : 20,left: 10,right: 10),
      backgroundColor: color,
      showCloseIcon: true,
      closeIconColor: Colors.white,
      content: Text(message,style: TextStyle(color: Colors.white),),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Future<bool> checkInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      //here check device is IOS or Android
      return true;
    }
    else {
      return false;
    }
  } on SocketException catch (_) {
    return false;
  }
}

String extractTimesFromInput(String input) {
  String times = "";
  List<String> parts = input.split('|');

  if (parts.length >= 2) {
    String timePart = parts[1];
    List<String> timeTokens = timePart.split('|');

    timeTokens.forEach((timeToken) {
      String time = timeToken.trim();
      times = time;
    });
  }

  return times;
}