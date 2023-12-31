import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Event1.dart';

class ImportEvent extends StatefulWidget {
  @override
  State<ImportEvent> createState() => _ImportEventState();
}

class _ImportEventState extends State<ImportEvent> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<String> images = [
    'assets/main/fine.jpg',
    'assets/main/gong.jpg',
    'assets/main/steak.jpg',
    'assets/main/whine.jpg',
    'assets/main/whisky.png',
  ];

  final pages = [
    Event1(),
    Event2(),
    Event3(),
    Event4(),
    Event5(),
  ];

  Timer? _timer;
  void initState() {
    super.initState();
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  void navigateEventPage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pages[index]),
    );

  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      child: Column(
        children: [
          CarouselSlider(
            items: images.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.0),
                child: InkWell(
                  onTap: () {
                    String url;
                    switch (entry.key) {
                      case 0:
                        url = 'https://www.bluer.co.kr/magazine/303'; // 파인
                        break;
                      case 1:
                        url = 'https://www.bluer.co.kr/magazine/346'; // 한정식
                        break;
                      case 2:
                        url =
                        'https://magazine.hankyung.com/money/article/202101214003c'; // 스테이크
                        break;
                      case 3:
                        url =
                        'https://www.story-w.co.kr/story-w/1426/2023-wine-referral'; // 와인
                        break;
                      case 4:
                        url = 'https://the-edit.co.kr/50593'; // 위스키
                        break;
                      default:
                        url = 'https://www.defaulturl.com'; // 필요한 경우 기본 URL
                        break;
                    }
                    launchURL(url);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Stack(
                      children: [
                        Image.asset(
                          images[entry.key],
                          height: 300.0,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 17,
                          left: 40,
                          child: Container(
                            color: Colors.white.withAlpha(150),
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'BEST & NEW',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          left: 40,
                          child: Container(
                            color: Colors.black54,
                            padding: EdgeInsets.all(8),
                            child: Text(
                              '이번주 매거진을 확인하세요',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: 240,
              aspectRatio: 16 / 9,
              enlargeCenterPage: false,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 7),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
          ),
          SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == entry.key ? Color(0xFFFF6347) : Colors.black12,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}