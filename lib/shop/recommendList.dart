import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_marvel/reservation/soloreservation.dart';
import 'package:provider/provider.dart';

import '../../user/userModel.dart';
import 'detailpage.dart';
import 'loading.dart';



class RecommendListShop extends StatefulWidget {
  final String category;

  RecommendListShop(this.category, {Key? key}) : super(key: key);

 
  @override
  State<RecommendListShop> createState() => _RecommendListShopShopState();
}

class _RecommendListShopShopState extends State<RecommendListShop> {


  @override
  void initState() {
    super.initState();


  }

  List<Map<String, dynamic>> userDataList = [];

  Future<void> fetchUserData() async {
    try {
      QuerySnapshot storeSnapshot = await FirebaseFirestore.instance
          .collection('T3_STORE_TBL')
          .get();

      if (storeSnapshot.docs.isNotEmpty) {
        for (var storeDoc in storeSnapshot.docs) {
          Map<String, dynamic> storeData = storeDoc.data() as Map<String, dynamic>;
          String docId = storeDoc.id;

          // 해당 상점의 별점 정보 가져오기
          QuerySnapshot starSnapshot = await FirebaseFirestore.instance
              .collection('T3_STORE_TBL')
              .doc(docId)
              .collection('T3_STAR_TBL')
              .get();

          List<String> starList = [];
          double x = 0;
          int y = 0;

          if (starSnapshot.docs.isNotEmpty) {
            for (var starDoc in starSnapshot.docs) {
              Map<String, dynamic> starData = starDoc.data() as Map<String, dynamic>;

              starData.forEach((key, value) {
                if (value is String) {
                  // 문자열을 숫자로 변환하여 평균을 계산합니다
                  double numericValue = double.parse(value);
                  if (numericValue != null) {
                    starList.add(value);
                    x += numericValue;
                    y++;
                  }
                }
              });
            }
          } else {
            starList.add('0');
          }

          if (y > 0) {
            x = x / y;
          }

          // S_INFO1 필드가 '양식'인 경우에만 userDataList에 추가
            storeData['STARlength'] = y;
            storeData['STARage'] = x.toStringAsFixed(1);
            storeData['STARlist'] = starList;
            storeData['docId'] = docId;
            userDataList.add(storeData);


        }
        userDataList.sort((a, b) {
          int starLengthA = int.tryParse(a['STARlength']) ?? 0;
          int starLengthB = int.tryParse(b['STARlength']) ?? 0;
          return starLengthB.compareTo(starLengthA); // 리뷰 수 내림차순으로 정렬
        });

        setState(() {
          // 상태 업데이트 등 다른 작업 수행
        });
      } else {
        print('상점 데이터를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: fetchUserData(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return LoadingSpinner(); // 로딩 스피너 표시
    } else if (snapshot.hasError) {
    return Text('에러 발생: ${snapshot.error}');
    } else {
    return ListView.builder(
    itemCount: userDataList.length,
    itemBuilder: (context, index) {
    final documentData = userDataList[index];

    if (true) {
    final ranking = index + 1;
    final isGrayBackground = ranking >= 4;


    return ListTile(
    title: Container(
    margin: EdgeInsets.symmetric(vertical: 10),
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    SizedBox(width: 10,),
    SizedBox(width: 25,
    height: 25,
    child: Container(
    decoration: BoxDecoration(
    color: isGrayBackground ? Colors.grey : Color(0xFFFF6347),
    borderRadius: BorderRadius.circular(5),
    ),
    child: Center(
    child: Text(
    '$ranking',
    style: TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    ),
    ),
    SizedBox(width: 5,),
    Container(
    width: 80,
    height: 110, // 원하는 높이 설정
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(5),
    ),
    child: Image.asset(
    'assets/storePageIMG/${documentData['S_IMG']}',
    fit: BoxFit.cover,
    ),
    ),
    SizedBox(width: 13),
    Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Container(
    width: 200,
    child: InkWell(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    '${documentData['S_NAME']}',
    style: TextStyle(fontSize: 20,
    fontWeight: FontWeight.bold),
    ),
    Text('${documentData['S_SILPLEMONO']}',
    maxLines: 3, // 표시할 최대 라인 수
    overflow: TextOverflow.ellipsis,), // 넘치는 부분에 "..."을 표시
    Row(
    children: [
    Icon(Icons.star, size: 25,
    color: Colors.yellow[600]),
    Text(
    '${documentData['STARage']}', // 평균 별점 표시
    style: TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    ),
    ),
    SizedBox(width: 8),
    Text(
    '(${documentData['STARlength']})',
    // 별점 개수 표시
    style: TextStyle(
    fontSize: 11, color: Colors.grey),
    ),
    ],
    ),
    Text(
    '${documentData['S_ADDR1']} ${documentData['S_ADDR2']} ${documentData['S_ADDR3']}',
    style: TextStyle(
    fontSize: 11, color: Colors.grey),
    ),
    Text(
    '${documentData['S_TIME']}',
    style: TextStyle(
    fontSize: 11, color: Colors.grey),
    ),
    ],
    ),
    onTap: () {
    Navigator.push(context, MaterialPageRoute(
    builder: (context) =>
    DetailPage(
    docId: documentData['docId'])));
    },
    ),
    ),
    SizedBox(height: 20),
    Row(
    children: [
    ],
    ),

    ],
    )
    ],
    ),
    ),
    );
    }
    },
    );
    }
    }
    );

    }
}
