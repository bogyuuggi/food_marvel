import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';


class ReservationAdd extends StatefulWidget {
  const ReservationAdd({super.key});

  @override
  State<ReservationAdd> createState() => _ReservationAddState();
}

class _ReservationAddState extends State<ReservationAdd> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();



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

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              height: 900,
              child: Container(
                child: Column(
                  children: [
                    TableCalendar(
                      availableCalendarFormats: _availableCalendarFormats,
                      focusedDay: DateTime.now(),
                      firstDay: DateTime(1800),
                      lastDay: DateTime(3000),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onDaySelected: _onDaySelected,

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
                      // 초기 달력 형식을 월로 설정
                      enabledDayPredicate: (DateTime date) {
                        // 이전 날짜는 비활성화
                        return date.isAfter(DateTime.now());
                      },
                      locale: 'ko_KR',
                      calendarStyle: CalendarStyle(
                        weekendTextStyle: TextStyle(color: Colors.blue),
                      ),
                    ),


                    SizedBox(height: 15
                      ,),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(width: 12,),
                          _numberpeople('1'), SizedBox(width: 6,),
                          _numberpeople('2'), SizedBox(width: 6,),
                          _numberpeople('3'), SizedBox(width: 6,),
                          _numberpeople('4'), SizedBox(width: 6,),
                          _numberpeople('5'), SizedBox(width: 6,),
                          _numberpeople('6'), SizedBox(width: 6,),
                          _numberpeople('7'), SizedBox(width: 6,),
                          _numberpeople('8'), SizedBox(width: 6,),
                          _numberpeople('9'), SizedBox(width: 6,),
                          _numberpeople('10'),

                        ],
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // 모달 닫기
                        if (_selectedDay != null && selectedNumber != null) {
                          // 예약 일시 및 인원을 사용하여 작업 수행
                          // 예: 예약 일시 및 인원을 API 호출 등에 사용
                        }
                      },
                      child: Text('확인'),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _numberpeople(String num) {
    bool isSelected = selectedNumber == int.parse(num); // 현재 숫자가 선택된 숫자와 같은지 확인
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedNumber = int.parse(num);
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

  Widget _clockbutton(String time) {
    bool isSelected = time == timeSet;

    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (isSelected) {
                    timeSet = null; // 이미 선택된 경우 선택 해제
                  } else {
                    timeSet = time; // 선택되지 않은 경우 선택
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  time,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  isSelected ? Color(0xFFFF6347) : Colors.white,
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
                    color: Colors.black, // 선택되지 않은 경우 검은색 테두리
                    width: 1, // 테두리 두께
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _secondModalSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 900, // 원하는 높이로 설정
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
                              border: Border.all(color: Colors.grey, width: 1.0), // 테두리선 색 및 너비 조절
                              borderRadius: BorderRadius.circular(10), // 레디우스 조절
                            ),
                            child: Column(
                              children: [
                                Text('가게이름',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                Text('주소/카테고리',style: TextStyle(fontSize: 12,color: Colors.grey),),
                                SizedBox(height: 20,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 50, // 원하는 가로폭 설정
                                          height: 50, // 원하는 세로 높이 설정 (옵션)
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
                                          width: 50, // 원하는 가로폭 설정
                                          height: 50, // 원하는 세로 높이 설정 (옵션)
                                          child: Image.asset('assets/amenities/2.png'),
                                        ),
                                        Text(timeSet != null ? timeSet! : '선택 안 됨')
                                      ],
                                    ),
                                    SizedBox(width: 30,),

                                    Column(
                                      children: [
                                        Container(
                                          width: 50, // 원하는 가로폭 설정
                                          height: 50, // 원하는 세로 높이 설정 (옵션)
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

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 모달 닫기
                  },
                  child: Text('닫기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget underlineBox(x) {
    return SizedBox(
      width: double.infinity,
      height: x,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey[400],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
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
                    Icon(Icons.calendar_today_outlined, size: 18,
                        color: Colors.black),
                    SizedBox(width: 8),
                    Text('${_selectedDay != null
                        ? DateFormat('yyyy-MM-dd (E)', 'ko_KR').format(
                        _selectedDay!)
                        : '날짜 선택 안 함'}', style: TextStyle(color: Colors.black),
                    ),
                    Text(' / ', style: TextStyle(color: Colors.black),),
                    Text('${selectedNumber != null
                        ? '$selectedNumber 명'
                        : '인원 선택 안 함'}', style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                side: MaterialStateProperty.all(
                    BorderSide(color: Colors.black, width: 1)),
              ),
            ),

            SizedBox(height: 8,),
            Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _clockbutton('11:00'),
                    SizedBox(width: 8,),
                    _clockbutton('13:00'),
                    SizedBox(width: 8,),
                    _clockbutton('14:00'),
                    SizedBox(width: 8,),
                    _clockbutton('15:00'),
                    SizedBox(width: 8,),
                    _clockbutton('16:00'),
                    SizedBox(width: 8,),
                    _clockbutton('17:00'),
                    SizedBox(width: 8,),
                    _clockbutton('19:00'),
                    SizedBox(width: 8,),
                    _clockbutton('20:00'),
                    SizedBox(width: 8,),
                    _clockbutton('21:00'),
                    SizedBox(width: 8,),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15,),

            Center(
                child: TextButton(
                  onPressed: () {
                    _secondModalSheet();
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(Size(180, 40)),
                    // 버튼의 최소 크기 설정
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // 꼭지점을 둥글게 설정
                      side: BorderSide(
                          color: Color(0xFFFF6347), width: 1), // 1픽셀 두꺼운 테두리 설정
                    )),
                    backgroundColor: MaterialStateProperty.all(
                        Colors.white), // 배경색 설정
                  ),
                  child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(width: 3,),
                          Text('예약하러가기', style: TextStyle(color: Color(
                              0xFFFF6347)),),
                          Icon(Icons.keyboard_arrow_right,
                            color: Color(0xFFFF6347),)
                        ],
                      )

                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
