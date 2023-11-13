import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';


class ImportRestaurant extends StatefulWidget {
  final VoidCallback onTapCallback;

  ImportRestaurant({required this.onTapCallback});

  @override
  State<ImportRestaurant> createState() => _ImportRestaurantState();
}

class _ImportRestaurantState extends State<ImportRestaurant> {
  bool isImportSuddenPopularVisible = true;
  bool isImportRestaurantVisible = true;
  List<Map<String, dynamic>> parkingDataList = [];


  final List<RestaurantItem> restaurantItems = [
    RestaurantItem(
      image: 'assets/searchIMG/searchimg0.jpg',
      title: "#주차가능매장",
      content: "내용0",
    ),
    RestaurantItem(
      image: 'assets/searchIMG/searchimg1.jpg',
      title: "#데이트하기\n좋은",
      content: "내용1",
    ),
    RestaurantItem(
      image: 'assets/searchIMG/searchimg2.jpg',
      title: "#엘리베이터\n있는",
      content: "내용2",
    ),
    RestaurantItem(
      image: 'assets/searchIMG/searchimg3.jpg',
      title: "#재방문많은",
      content: "내용3",
    ),
    RestaurantItem(
      image: 'assets/searchIMG/searchimg4.jpg',
      title: "#숨은맛집",
      content: "내용4",
    ),
    RestaurantItem(
      image: 'assets/searchIMG/searchimg5.jpg',
      title: "#1층매장",
      content: "내용5",
    ),
    RestaurantItem(
      image: 'assets/searchIMG/searchimg6.jpg',
      title: "#키즈존",
      content: "내용6",
    ),
    RestaurantItem(
      image: 'assets/searchIMG/searchimg7.jpg',
      title: "#이국적인",
      content: "내용7",
    ),
    RestaurantItem(
      image: 'assets/searchIMG/searchimg8.jpg',
      title: "#소박한",
      content: "내용8",
    ),
    RestaurantItem(
      image: 'assets/searchIMG/searchimg9.jpg',
      title: "#아늑한",
      content: "내용9",
    ),
    RestaurantItem(
      image: 'assets/searchIMG/searchimg10.jpg',
      title: "#착한가격",
      content: "내용10",
    ),
    RestaurantItem(
      image: 'assets/searchIMG/searchimg11.jpg',
      title: "#특별한날",
      content: "내용11",
    ),
    RestaurantItem(
      image: 'assets/searchIMG/searchimg12.jpg',
      title: "#신선한",
      content: "내용12",
    ),
    RestaurantItem(
      image: 'assets/searchIMG/searchimg13.jpg',
      title: "#비오는날",
      content: "내용13",
    ),
  ];


  @override
  Widget build(BuildContext context) {
    restaurantItems.shuffle(Random());

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              "어떤 맛집 찾으세요??",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15.0,
              mainAxisSpacing: 15.0,
            ),
            itemCount: 4,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final restaurantItem = restaurantItems[index];
              return _buildItemWithImage(
                image: restaurantItem.image,
                title: restaurantItem.title,
                content: restaurantItem.content,
                onTapCallback: () => _handleItemTap(restaurantItem.title),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemWithImage({
    required String image,
    required String title,
    String content = "",
    required VoidCallback onTapCallback,
  }) {
    return GestureDetector(
      onTap: onTapCallback,
      child :Stack(
      children: [
        Container(
          margin: EdgeInsets.all(15.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 30,
          left: 10,
          right: 10,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
          top: 130,
          left: 10,
          right: 10,
          child: Text(
            content,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.lightBlueAccent,
            ),
            textAlign: TextAlign.center,
          ),
        ),


      ],
      ),
    );
  }
  void _handleItemTap(String title) {
    if (title == "#주차가능매장") {
      _fetchDataFromFirestore();
    }
    print('아이템이 눌렸습니다: $title');
    widget.onTapCallback();
  }
}


void _fetchDataFromFirestore() async {
  try {
    QuerySnapshot convenienceSnapshot = await FirebaseFirestore.instance
        .collection('T3_STORE_TBL')
        .doc('docId')
        .collection('T3_CONVENIENCE_TBL')
        .where('S_PARKING', isEqualTo: true)
        .get();

    List<Map<String, dynamic>> parkingDataList = [];
    convenienceSnapshot.docs.forEach((doc) {
      print('서브컬렉션 데이터: ${doc.data()}');
    });
  } catch (e) {
    print('데이터 가져오기 오류: $e');
  }
}

class RestaurantItem {
  final String image;
  final String title;
  final String content;

  RestaurantItem({
    required this.image,
    required this.title,
    this.content = "",
  });
}