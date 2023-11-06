import 'package:flutter/material.dart';
import 'package:food_marvel/user/allCollection.dart';
import 'package:food_marvel/user/follower.dart';
import 'package:food_marvel/user/following.dart';
import 'package:food_marvel/user/newCollection.dart';
import 'package:food_marvel/user/notification.dart';
import 'package:food_marvel/user/profileEdit.dart';
import 'package:food_marvel/user/userModel.dart';
import 'package:food_marvel/user/userSetting.dart';
import 'package:provider/provider.dart';

import '../main/importbottomBar.dart';
import 'bdayRegister.dart';
import 'myCollection.dart';

class UserMain extends StatefulWidget {
  final String? collectionName;
  final String? description;
  final bool? isPublic;


  const UserMain({
    super.key,
    this.collectionName, // NewCollection 화면에서 전달된 데이터
    this.description, // NewCollection 화면에서 전달된 데이터
    this.isPublic,

  });

  @override
  State<UserMain> createState() => _UserMainState();
}

class _UserMainState extends State<UserMain>with SingleTickerProviderStateMixin{
  String? description;
  String? collectionName;
  bool? isPublic;
  late TabController _tabController;
  late String? nickname; // 추가

  @override
  void initState() {
    super.initState();
    description = widget.description;
    isPublic = widget.isPublic;
    collectionName = widget.collectionName;
    _tabController = TabController(length: 2, vsync: this);

    UserModel userModel = Provider.of<UserModel>(context, listen: false);
    nickname = userModel.nickname; // UserModel에서 닉네임 가져오기
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? userId = Provider.of<UserModel>(context).userId; // UserModel에서 사용자 아이디 받아오기
    String? nickname = Provider.of<UserModel>(context).nickname;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text('마이페이지',style: TextStyle(color: Colors.black),),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications,color: Colors.grey),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationPage()));
            },
          ),IconButton(
            icon: Icon(Icons.settings,color: Colors.grey),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserSetting()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: Image.asset('assets/user/userProfile.png', width: 100, height: 100),
              ),
              Column(
                children: [
                  Text('$nickname', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                  Row(
                    children: [
                      TextButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (_) => Following()));
                          },
                          child: Text('팔로잉 |',style: TextStyle(color: Colors.grey),)),
                      Divider(color: Colors.black, thickness: 5, height: 50),
                      TextButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (_) => Follower()));
                          },
                          child: Text('팔로워',style: TextStyle(color: Colors.grey),)),
                    ],
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileEdit(userId: userId)));
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size>(
                  Size(double.infinity, 50), // 버튼의 너비와 높이를 조절
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(10.0)),
                minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 0)),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                elevation: MaterialStateProperty.all<double>(0),
                overlayColor: MaterialStateProperty.all<Color>(Colors.grey[200]!), // 터치 효과 색상
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey), // border 색상 black
                    borderRadius: BorderRadius.circular(30), // 버튼 테두리 모양 조정
                  ),
                ),
              ),
              child: Text('프로필 수정', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(5),
            color: Colors.white,
            child: Row(
              children: [
                InkWell(
                  onTap: () {},
                  child: Image.asset('assets/main/cake3-removebg-preview (1).png', width: 100, height: 100),
                ),
                SizedBox(width: 15,),
                Column(
                  children: [
                    Text('푸드마블이 특별한 날을 축하해드릴게요', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                    Row(
                      children: [
                        TextButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (_) => BdayRegister()));
                            },
                            child: Text('생일/기념일 등록하기 >',style: TextStyle(color: Colors.grey),)),
                        Divider(color: Colors.black, thickness: 5, height: 50),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: '나의 저장'),
              Tab(text: '리뷰'),
            ],
          ),
          SizedBox(height: 10),
          Container(
            height: 300,
            padding: EdgeInsets.all(10),
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AllCollection(
                          collectionName: collectionName,
                          description: description,
                          isPublic: isPublic,
                        )));
                      },
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('컬렉션', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                          Text('전체보기 > ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,color: Colors.grey),)
                        ],
                      ),

                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_) => MyCollection(
                          collectionName: collectionName,
                          description: description,
                          isPublic: isPublic,
                        ),
                        ),
                        );
                      },
                      child: Row(
                        children: [
                          if (description != null)
                            Column(
                              children: [
                                Container(
                                  height: 70,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10.0),
                                    ),
                                    gradient: LinearGradient(
                                      colors: [Colors.white10, Colors.grey],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'FOOD MARVEL',
                                      style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 1),
                                Container(
                                  height: 30,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(10.0),
                                    ),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('  $description', style: TextStyle(color: Colors.deepOrange)),
                                      Icon(
                                        Icons.turned_in_not_outlined,
                                        color: Colors.deepOrange,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          if (description == null)
                            Text('컬렉션이 존재하지 않습니다.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                    Row(
                      children: isPublic == true
                          ? [
                        Icon(
                          Icons.lock_open,
                          color: Colors.black, // 색상을 조정하세요.
                        ),
                        Text(' $collectionName', style: TextStyle(fontWeight: FontWeight.bold)),
                      ]
                          : [], // isPublic이 true인 경우에만 표시
                    ),

                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.white), // 백그라운드 색상을 white로 설정
                        overlayColor: MaterialStateProperty.all<Color>(Colors.grey[200]!), // 터치 효과 색상
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey), // 보더 색상을 grey로 설정
                            borderRadius: BorderRadius.circular(10), // 버튼 테두리 모양 조정
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => NewCollection()));
                      },
                      child: Text('+ 새 컬렉션 만들기',style: TextStyle(color: Colors.black),),
                    ),
                    SizedBox(height: 30),
                    Text('저장한 레스토랑', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                    SizedBox(height: 10),
                    Text('저장한 레스토랑이 없습니다.', style: TextStyle(color: Colors.grey[400]!),textAlign: TextAlign.center,),
                    Text('요즘 많이 저장하는 레스토랑을 확인해보세요.', style: TextStyle(color: Colors.grey[400]!),textAlign: TextAlign.center,),
                  ],
                ),
                Text('등록된 리뷰가 없습니다', style: TextStyle(color: Colors.grey[400]!),textAlign: TextAlign.center,)
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}