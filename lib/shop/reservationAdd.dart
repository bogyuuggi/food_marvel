import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../user/userModel.dart';
import '../user/userUnlogin.dart';
import 'package:http/http.dart' as http;

class ReservationAdd extends StatefulWidget {
  final String addr;
  final String sName;
  final String doc;
  final String shopId;
  final dynamic time;


  ReservationAdd({required this.addr, required this.sName, required this.doc, required this.time, required this.shopId});

  @override
  State<ReservationAdd> createState() => _ReservationAddState();
}

class _ReservationAddState extends State<ReservationAdd> {
  Map<String, dynamic> timelist = {};

  @override
  void initState() {
    _fetchAllUserData(widget.doc);
    super.initState();
    timelist = widget.time;
  }

  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  int? selectedNumber;
  String? timeSet;

  Map<CalendarFormat, String> _availableCalendarFormats = {
    CalendarFormat.month: '월',
    CalendarFormat.twoWeeks: '2주',
    CalendarFormat.week: '주',
  };

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  List<Map<String, dynamic>> userDataList = [];
  List<Map<String, dynamic>> reservationDataList = [];

  Future<List<Object>> _fetchAllUserData(String docId) async {
    try {
      DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance
          .collection('T3_STORE_TBL')
          .doc(docId)
          .get();

      QuerySnapshot reservation = await FirebaseFirestore.instance
          .collection('T3_STORE_RESERVATION')
          .get();
      reservation.docs.forEach((QueryDocumentSnapshot doc) {
        Map<String, dynamic> data = {
          'R_DATE': doc['R_DATE'],
          'R_TIME': doc['R_TIME'],
          'R_S_ID': doc['R_S_ID'],
        };
        reservationDataList.add(data);
      });

      if (storeSnapshot.exists) {
        CollectionReference timeCollection = FirebaseFirestore.instance
            .collection('T3_STORE_TBL')
            .doc(docId)
            .collection('T3_TIME_TBL');

        QuerySnapshot timeSnapshots = await timeCollection.get();

        userDataList = timeSnapshots.docs.map((timeSnapshot) {
          return timeSnapshot.data() as Map<String, dynamic>;
        }).toList();
      } else {
        print('문서가 존재하지 않습니다.');
      }

      return userDataList;
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
      return [];
    }
  }

  Future<void> _saveReservation(UserModel userModel) async {
    String? userId = userModel.userId;
    String? usernick = userModel.name;

    await FirebaseFirestore.instance.collection('T3_STORE_RESERVATION').add({
      'R_S_ID': widget.shopId,
      'R_S_ADDR': widget.addr,
      'R_S_name': widget.sName,
      'R_DATE' : DateFormat('yyyy-MM-dd (E)', 'ko_KR').format(_selectedDay!),
      'R_TIME': timeSet,
      'R_number': selectedNumber,
      'R_id': userId,
      'R_name': usernick,
      'R_state': null,
    });

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmToken = await messaging.getToken();
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAH6_c1yw:APA91bEJTMrIJhVjJa4MBP76N_XncTlXQvXnOQB4aBv_9nrqEJP6dbJbiLZi-DQMGfg3PAXkXJwZHcxlJjW6PLLjaLGz34LBpXxYONkF9Xqlltb4FBqpW8P99ua-8opTVXUKeaQGZjPK', // FCM 서버 키를 넣어주세요
      },
      body: jsonEncode({
        'notification': {
          'title': '푸드마블 ',
          'body': '예약이 성공적으로 완료되었습니다.',
        },
        'to': fcmToken,
      }),
    );


    Navigator.of(context).pop();
    _secondModalSheet2(context);
  }

  bool _showClockButtons = false; // 초기에는 _clockbutton를 숨기도록 설정

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      child: TableCalendar(
                        availableCalendarFormats: _availableCalendarFormats,
                        focusedDay: _focusedDay,
                        firstDay: DateTime(1800),
                        lastDay: DateTime(3000),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            selectedNumber = null;
                            _showClockButtons = true;
                          });
                        },
                        selectedDayPredicate: (DateTime date) {
                          if (_selectedDay == null) {
                            return false;
                          }
                          return date.year == _selectedDay!.year &&
                              date.month == _selectedDay!.month &&
                              date.day == _selectedDay!.day;
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarFormat: CalendarFormat.month,
                        enabledDayPredicate: (DateTime date) {
                          return date.isAfter(DateTime.now());
                        },
                        locale: 'ko_KR',
                        calendarStyle: CalendarStyle(
                          weekendTextStyle: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(width: 12),
                          _numberpeople('1'), SizedBox(width: 6),
                          _numberpeople('2'), SizedBox(width: 6),
                          _numberpeople('3'), SizedBox(width: 6),
                          _numberpeople('4'), SizedBox(width: 6),
                          _numberpeople('5'), SizedBox(width: 6),
                          _numberpeople('6'), SizedBox(width: 6),
                          _numberpeople('7'), SizedBox(width: 6),
                          _numberpeople('8'), SizedBox(width: 6),
                          _numberpeople('9'), SizedBox(width: 6),
                          _numberpeople('10'),
                        ],
                      ),
                    ),
                    SizedBox(height: 13,),
                    ElevatedButton(
                      onPressed: _selectedDay != null && selectedNumber != null
                          ? () {
                        setState(() {
                          _showClockButtons = true;
                        });
                        Navigator.of(context).pop();
                      }
                          : null,
                      child: Text('확인'),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFFF6347),
                        fixedSize: Size(200, 30),// 원하는 색상으로 변경
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

  Widget _numberpeople(String num) {
    bool isSelected = selectedNumber == int.parse(num);
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedNumber = int.parse(num);
                  Navigator.of(context).pop();
                  _showModalBottomSheet(context);
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Text(
                  '$num명',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                minimumSize: MaterialStateProperty.all(Size(40, 40)),
                backgroundColor: MaterialStateProperty.all(
                  isSelected ? Color(0xFFFF6347) : Colors.white,
                ),
                side: MaterialStateProperty.all(
                  BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  List<Map<String, dynamic>> datatime = [];

  Widget _clockbutton(String time) { // 시간 버튼 11:00 12:00
    if (!_showClockButtons) {
      return SizedBox(); // _showClockButtons가 false이면 아무것도 표시하지 않음
    }
    bool isSelected = time == timeSet;
    bool isDisabled = false;
    // 필요한 시간 목록을 가져와서 중복 여부를 확인
    List<Map<String, dynamic>> datatime = [];
    for (Map<String, dynamic> reservationData in reservationDataList) {
      if (reservationData['R_S_ID'] == widget.sName && reservationData['R_DATE'] == DateFormat('yyyy-MM-dd (E)', 'ko_KR').format(_selectedDay!)) {
        datatime.add(reservationData);
      }
    }

    // 중복되는 경우 버튼 비활성화
    if (datatime.any((data) => data['R_TIME'] == time)) {
      isDisabled = true;
    }
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            TextButton(
              onPressed: () {
                if (!isDisabled) {
                  setState(() {
                    if (isSelected) {
                      timeSet = null; // 이미 선택된 경우 선택 해제 (null 값 설정)
                    } else {
                      timeSet = time; // 선택되지 않은 경우 선택
                    }
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  time,
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDisabled ? Colors.grey[700] : Colors.black),
                  ),
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  isSelected ? Color(0xFFFF6347) : (isDisabled ? Colors.grey[400] : Colors.white), // 비활성화된 경우 회색 배경
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                side: MaterialStateProperty.all(
                  isSelected
                      ? BorderSide.none // 선택된 경우 테두리 없음
                      : BorderSide(
                    color: isDisabled ? Colors.grey[800]! : Colors.black,
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _secondModalSheet2(BuildContext context) { // 예약완료되면 나오는 창
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('예약 성공'),
          content: Text('예약이 성공적으로 완료되었습니다.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFFF6347)
                ,
              ),
            ),
          ],
        );
      },
    );
  }

  void _secondModalSheet(userModel) { // 예약 완료하는창
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 900,
          child: Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text('예약 날짜 정확한가요?',style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('방문 일정을 다시 한번 확인해 주세요.'),
                          SizedBox(height: 10,),
                          Container(
                            width: 350,
                            padding: EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(widget.sName,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                Text(widget.addr,style: TextStyle(fontSize: 12,color: Colors.grey),),
                                SizedBox(height: 20,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          child: Image.asset('assets/amenities/1.png'),
                                        ),
                                        Text(
                                          '${_selectedDay != null ? DateFormat('yyyy-MM-dd (E)', 'ko_KR').format(_selectedDay!) : '날짜 선택 필수'}',
                                          style: TextStyle(
                                            color: _selectedDay != null ? Colors.black : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 30,),

                                    Column(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          child: Image.asset('assets/amenities/2.png'),
                                        ),
                                        Text(timeSet != null ? timeSet! : '선택 안 됨')
                                      ],
                                    ),
                                    SizedBox(width: 30,),

                                    Column(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          child: Image.asset('assets/amenities/3.png'),
                                        ),
                                        Text(
                                          '${selectedNumber != null ? '$selectedNumber명' : '0명'}',
                                          style: TextStyle(
                                            color: selectedNumber != null && selectedNumber == 0 ? Colors.red : Colors.black,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text('당일취소및 노쇼는 가게뿐만 아니라 다른 고객님들께도'),
                          Text('피해가 될수 있으므로 신중히 예약 부탁드립니다. :)'),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('취소'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.black,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: selectedNumber != null && _selectedDay != null && timeSet != null
                          ? () {
                        _saveReservation(userModel);
                      }
                          : null,
                      child: Text(
                        selectedNumber != null && _selectedDay != null && timeSet != null
                            ? '예약하기'
                            : '예약 정보를 선택해 주세요',
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: selectedNumber != null && _selectedDay != null && timeSet != null
                            ? const Color(0xFFFF6347)
                            : Colors.grey,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    UserModel userModel = Provider.of<UserModel>(context);
    String? userId = userModel.userId;
    return Container(
      child: Container(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('예약 일시',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            SizedBox(height: 10,),
            TextButton(
              onPressed: () {
                _showModalBottomSheet(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Colors.black,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${_selectedDay != null
                          ? DateFormat('yyyy-MM-dd (E)', 'ko_KR').format(
                          _selectedDay!)
                          : '날짜 선택 필수'}',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      ' / ',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      '${selectedNumber != null
                          ? '$selectedNumber 명'
                          : '인원 선택 필수'}',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                side: MaterialStateProperty.all(
                  BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
              ),
            ),

            SizedBox(height: 8,),
          Container(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                  children: [
                  for (int i = 1; i <= 14; i++)
                  if (timelist['S_RE_TIME$i'] != null) ...[
                      if (!datatime.any((data) => data['R_TIME'] == timelist['S_RE_TIME$i']))
                      _clockbutton(timelist['S_RE_TIME$i']),
                       if (i < 14) SizedBox(width: 6),
                    ],
                  ],
                 ),
               ),
            ),
            SizedBox(height: 15,),

            Center(
              child: TextButton(
                onPressed: userId != null
                    ? () {
                  _secondModalSheet(userModel);
                }
                    : () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserUnlogin()));
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(Size(180, 40)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(color: Color(0xFFFF6347), width: 1),
                  )),
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(width: 3),
                      Text(
                        userId != null ? '예약하러가기' : '로그인 하러가기',
                        style: TextStyle(
                          color: Color(0xFFFF6347),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Color(0xFFFF6347),
                      ),
                    ],
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}


