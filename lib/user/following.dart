import 'package:flutter/material.dart';
import 'package:food_marvel/user/followList.dart';
import 'package:food_marvel/user/userModel.dart';
import 'package:provider/provider.dart';

import '../board/function/Board.dart';
import 'function/Follow.dart';

class Following extends StatefulWidget {
  const Following({super.key});

  @override
  State<Following> createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  String? uId;
  List<String> followings = []; // 팔로워 리스트 추가

  @override
  void initState() {
    super.initState();
    _loadFollowings(); // initState에서 호출하여 화면이 로드될 때 팔로워를 불러옴
  }

  // 팔로워 호출
  Future<void> _loadFollowings() async {
    print('initState 동작 확인');
    UserModel userModel = Provider.of<UserModel>(context, listen: false);
    String? userId = userModel.userId;

    if (userId != null) {
      List<String> fetchedFollowings = await getUserFollowings(userId);

      setState(() {
        print('setState 동작 확인');
        followings = fetchedFollowings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // UserModel에서 사용자 아이디 받아오기
    UserModel userModel = Provider.of<UserModel>(context);
    String? userId = userModel.userId;
    uId = userId;
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
        title: Text('팔로잉', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white,elevation: 0, // 그림자를 제거
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              InkWell(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_) => FollowList()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_alt_1_sharp, size: 50),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('팔로잉할 친구를 찾아서 팔로우 하고, \n함께 갈 레스토랑을 찾아보세요'),
                            SizedBox(height: 5),
                            Text('친구 연결하기 >', style: TextStyle(color: Colors.deepOrange))
                          ],
                        )
                      ],
                    ),
                  )
                ),
              ),
              followings.isEmpty ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('아직 아무도 팔로우 하지 않았습니다.'),
                    Text('다른 사람을 팔로우 하면 여기에 표시됩니다.',
                        style: TextStyle(fontSize: 10)),
                  ],
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: followings.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          child: ClipOval(
                            child: FutureBuilder<String?>(
                              future: fetchProfileImageUrl(uId!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator(); // 데이터를 기다리는 동안 로딩 표시
                                } else if (snapshot.hasError) {
                                  return Text('오류 발생: ${snapshot.error}');
                                } else {
                                  String? imageUrl = snapshot.data;
                                  if (imageUrl != null) {
                                    return Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover, // 이미지가 원 안에 꽉 차게 표시됩니다.
                                      width: 50,
                                      height: 50,
                                    );
                                  } else {
                                    return Image.asset('assets/user/userProfile.png');
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                        Text('Following 문서 ID: ${followings[index]}')
                      ],
                    )
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
