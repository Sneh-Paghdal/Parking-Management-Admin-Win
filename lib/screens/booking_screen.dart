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

  @override
  void initState() {
    getParkingModel();
    super.initState();
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  List<dynamic> parkingBoxList = [];
  int colNum = 0;
  bool isDataLoading = true;
  String fromDate = "";
  String toDate = "";
  bool isBooking = false;

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
        getParkingModel();
        Navigator.pop(context);
        Navigator.pop(context);
      }else if(response.statusCode == 302){
        print(response.statusCode);
        getParkingModel();
        Navigator.pop(context);
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
                    crossAxisCount: colNum, mainAxisExtent: 100, crossAxisSpacing: 10),
                itemCount: parkingBoxList.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      if(parkingBoxList[index]['value'] == "NB"){
                        onTabBottomSheet(context ,index);
                      }else{
                        bookedBottomSheet(context,index);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          color: (parkingBoxList[index]['value'] == "NB") ? Colors.green.shade100 : Colors.red.shade100,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade200,
                                spreadRadius: 0.5,
                                blurRadius: 8)
                          ],
                          borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (parkingBoxList[index]['value'] == "NB") ? Colors.green : Colors.red, // Set the border color here
                          width: 0.5, // Set the border width (optional)
                        ),
                      ),
                      padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Center(
                        child: Text((parkingBoxList[index]['value'] == "NB") ? "${parkingBoxList[index]['boxId']}" : "Booked"),
                      ),
                    ),
                  );
                }),
          );
  }

  void onTabBottomSheet(BuildContext context , index) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: double.infinity,
              height: 200,
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Do you want to book this slot ?",style: TextStyle(fontWeight: FontWeight.w500),),
                  Row(
                    children: [
                      Text("Date : ",style: TextStyle(fontWeight: FontWeight.w500),),
                      Text("${DateFormat('dd MMMM yyyy').format(DateTime.now())}"),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Select appropriate time : ",style: TextStyle(fontWeight: FontWeight.w500),),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(flex : 1,child: Container()),
                            Expanded(
                              flex: 3,
                              child: InkWell(
                                onTap: () async {
                                  final selectedTime = await showTimePickerDialog(context);
                                  setState(() {
                                    fromDate = selectedTime;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(top: 3,bottom: 3,left: 5,right: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:  Colors.black, // Set the border color here
                                      width: 1, // Set the border width (optional)
                                    ),
                                    borderRadius : BorderRadius.circular(10),
                                  ),
                                    child: Center(child: Text((fromDate == "") ? "From" : fromDate))
                                ),
                              ),
                            ),
                            Expanded(flex : 1,child: Container()),
                            Expanded(
                              flex: 3,
                              child: InkWell(
                                onTap: () async {
                                  final selectedTime = await showTimePickerDialog(context);
                                  setState(() {
                                    toDate = selectedTime;
                                  });
                                },
                                child: Container(
                                    padding: EdgeInsets.only(top: 3,bottom: 3,left: 5,right: 5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black, // Set the border color here
                                        width: 1, // Set the border width (optional)
                                      ),
                                      borderRadius : BorderRadius.circular(10),
                                    ),
                                    child: Center(child: Text((toDate == "") ? "  To " : toDate))
                                ),
                              ),
                            ),
                            Expanded(flex : 1,child: Container()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: (){
                      if(fromDate == "" || toDate == ""){
                        showToast(context, "Please fill time in from and to", false, Colors.red, 100);
                      }else{
                        showDialogBox(context,index);
                      }
                    },
                    child: Container(
                      height: 50,
                      margin: EdgeInsets.only(top: 15),
                      width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.circular(50)),
                        child: Center(child: Text("Book The Slot",style: TextStyle(color: Colors.white),))),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String> showTimePickerDialog(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    DateTime selectedTime = now;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Time'),
          content: Container(
            height: 300,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: now,
              minimumDate: today,
              maximumDate: today.add(Duration(days: 1)),
              onDateTimeChanged: (DateTime newDateTime) {
                selectedTime = newDateTime;
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );

    final formattedTime = DateFormat('h:mm a').format(selectedTime);
    print('Selected Time: $formattedTime');
    return formattedTime;
  }

  void showDialogBox(BuildContext context,index) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Name:  ',
                  ),
                  Container(
                    width: 130,
                    child: CupertinoTextField(
                      textCapitalization: TextCapitalization.words,
                      controller: nameController,
                      style: TextStyle(fontSize: 13),
                      padding: EdgeInsets.symmetric(vertical: 0.5),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: CupertinoColors.black,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(height: 10,),
              Row(
                children: [
                  Text(
                    'Mobile No:  ',
                  ),
                  Container(
                    width: 130,
                    child: CupertinoTextField(
                      controller: mobileController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 13),
                      padding: EdgeInsets.symmetric(vertical: 0.5),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: CupertinoColors.black,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('OK',style: TextStyle(color: isBooking == true ? Colors.blue.shade50 : Colors.blue),),
              onPressed: () {
                if(nameController.text == "" || nameController.text.isEmpty || mobileController.text.isEmpty || mobileController.text == ""){
                  showToast(context, "Please enter name and number", true, Colors.red, 100);
                }else{
                  bookSlotPostApi(fromDate,toDate,nameController.text.toString(),mobileController.text.toString(),index );
                }
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void bookedBottomSheet(BuildContext context , index) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: double.infinity,
              height: 80,
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("This slot is booked: ",style: TextStyle(fontWeight: FontWeight.w500),),
                  Text("Expected availability time : ${extractTimesFromInput(parkingBoxList[index]['value'])}",style: TextStyle(fontWeight: FontWeight.w500),),
                ],
              ),
            );
          },
        );
      },
    );
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
