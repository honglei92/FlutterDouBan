import 'dart:html';

import 'package:flutter/material.dart';
import 'package:doubanapp/widgets/search_text_field_widget.dart';
import 'package:doubanapp/pages/home/home_app_bar.dart' as myapp;
import 'package:doubanapp/http/http_request.dart';
import 'package:doubanapp/http/mock_request.dart';
import 'package:doubanapp/http/API.dart';
import 'package:doubanapp/bean/subject_entity.dart';
import 'package:doubanapp/widgets/image/radius_img.dart';
import 'package:doubanapp/constant/constant.dart';
import 'package:doubanapp/widgets/video_widget.dart';
import 'package:doubanapp/router.dart';

///首页，TAB页面，显示动态和推荐TAB
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    print('build HomePage');
    return getWidget();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationData();
  }

  void getLocationData() async {
    Location location = Location();
    await location.getcurrentLcoation();
    NetworkHepler networkHepler = NetworkHelper(
        'http://v.juhe.cn/weather/geo?format=2&key=0ca92484d26657567ffaf07472e1d075&dtype=json&lat=${location.latitude}&lon=${location.longitude}');
    var weatherData = await networkHepler.getData();
    updateUI(weatherData);
  }
}

var _tabs = ['推荐', '科技', '财经'];
double temperature;
String cityName;

void updateUI(dynamic weatherData) {
  if (weatherData != null) {
    if (weatherData['resultcode'] == 200) {
      temperature = weatherData['main']['temp'];
      cityName = weatherData['name'];
      print(temperature);
    }
  }
}

DefaultTabController getWidget() {
  return DefaultTabController(
    initialIndex: 0,
    length: _tabs.length, // This is the number of tabs.
    child: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        // These are the slivers that show up in the "outer" scroll view.
        return <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: myapp.SliverAppBar(
              pinned: true,
              expandedHeight: 120.0,
              primary: true,
              titleSpacing: 0.0,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  color: Colors.green,
                  child: new Row(children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Image.asset(
                          Constant.ASSETS_IMG + 'ic_launcher.png',
                          width: 40.0,
                          height: 40.0,
                        )),
                    Expanded(
                      child: SearchTextFieldWidget(
                        hintText: '搜索',
                        margin: const EdgeInsets.only(left: 7.0, right: 15.0),
                        onTab: () {
                          RouterDouB.push(context, RouterDouB.searchPage, '搜索');
                        },
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Image.asset(
                          Constant.ASSETS_IMG + 'ic_launcher.png',
                          width: 40.0,
                          height: 40.0,
                        )),
                  ]),
                  alignment: Alignment(0.0, 0.0),
                ),
              ),
              bottomTextString: _tabs,
              bottom: TabBar(
                // These are the widgets to put in each tab in the tab bar.
                tabs: _tabs
                    .map((String name) => Container(
                          child: Text(
                            name,
                          ),
                          padding: const EdgeInsets.only(bottom: 5.0),
                        ))
                    .toList(),
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        // These are the contents of the tab views, below the tabs.
        children: _tabs.map((String name) {
          return SliverContainer(
            name: name,
          );
        }).toList(),
      ),
    ),
  );
}

class SliverContainer extends StatefulWidget {
  final String name;

  SliverContainer({Key key, @required this.name}) : super(key: key);

  @override
  _SliverContainerState createState() => _SliverContainerState();
}

class _SliverContainerState extends State<SliverContainer> {
  @override
  void initState() {
    super.initState();
    print('init state${widget.name}');

    ///请求动态数据
    if (list == null || list.isEmpty) {
      if (_tabs[0] == widget.name) {
        requestAPI();
      } else {
        ///请求推荐数据
        requestAPI();
      }
    }
  }

  List<Subject> list;

  void requestAPI() async {
    var _request = MockRequest();
    var result = await _request.get(API.TOP_250);
    var resultList = result['subjects'];
    list = resultList.map<Subject>((item) => Subject.fromMap(item)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return getContentSliver(context, list);
  }

  getContentSliver(BuildContext context, List<Subject> list) {
    if (widget.name == _tabs[1]) {
      return _loginContainer(context);
    }
    if (widget.name == _tabs[2]) {
      return _loginContainer(context);
    }

    print('getContentSliver');
    if (list == null || list.length == 0) {
      return Text('暂无数据');
    }
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            key: PageStorageKey<String>(widget.name),
            slivers: <Widget>[
              SliverOverlapInjector(
                // This is the flip side of the SliverOverlapAbsorber above.
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                      ((BuildContext context, int index) {
                return getCommonItem(list, index);
              }), childCount: list.length)),
            ],
          );
        },
      ),
    );
  }

  ///没有视频的高度
  double singleLineImgHeight = 380.0;

  ///有视频的高度
  double contentVideoHeight = 350.0;

  ///列表的普通单个item
  getCommonItem(List<Subject> items, int index) {
    Subject item = items[index];
    bool showVideo = index == 1 || index == 3;
    return Container(
      height: showVideo ? contentVideoHeight : singleLineImgHeight,
      // height: double.infinity,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.only(
          left: Constant.MARGIN_LEFT,
          right: Constant.MARGIN_RIGHT,
          top: Constant.MARGIN_RIGHT,
          bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
                // contentPadding: const EdgeInsets.only(top: 8.0),
                contentPadding: EdgeInsets.all(0),
                border: InputBorder.none,
                hintText: item.title,
                hintStyle: TextStyle(
                    fontSize: 17, color: Color.fromARGB(255, 192, 191, 191))),
            style: TextStyle(fontSize: 17),
          ),
          Expanded(
              child: Container(
            child: showVideo ? getContentVideo(index) : getItemCenterImg(item),
          )),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("2020-10-29 20:55:11"),
                Image.asset(
                  Constant.ASSETS_IMG + 'ic_vote.png',
                  width: 25.0,
                  height: 25.0,
                ),
                Image.asset(
                  Constant.ASSETS_IMG +
                      'ic_notification_tv_calendar_comments.png',
                  width: 20.0,
                  height: 20.0,
                ),
                Image.asset(
                  Constant.ASSETS_IMG + 'ic_status_detail_reshare_icon.png',
                  width: 25.0,
                  height: 25.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 图片类型的布局
  getItemCenterImg(Subject item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Expanded(
          child: RadiusImg.get(item.images.large, null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5.0),
                    bottomLeft: Radius.circular(5.0)),
              )),
        ),
        Column(children: <Widget>[
          Expanded(
            child:
                RadiusImg.get(item.casts[1].avatars.medium, null, radius: 0.0),
          ),
          Expanded(
            child: RadiusImg.get(item.casts[2].avatars.medium, null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5.0),
                        bottomRight: Radius.circular(5.0)))),
          )
        ]),
      ],
    );
  }

  getContentVideo(int index) {
    if (!mounted) {
      return Container();
    }
    return VideoWidget(
      index == 1 ? Constant.URL_MP4_DEMO_0 : Constant.URL_MP4_DEMO_1,
      showProgressBar: false,
    );
  }
}

///动态 TAB
_loginContainer(BuildContext context) {
  return Align(
    alignment: Alignment(0.0, 0.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          Constant.ASSETS_IMG + 'ic_new_empty_view_default.png',
          width: 120.0,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 25.0),
          child: Text(
            '登录后查看关注人动态',
            style: TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
        ),
        GestureDetector(
          child: Container(
            child: Text(
              '去登录',
              style: TextStyle(fontSize: 16.0, color: Colors.green),
            ),
            padding: const EdgeInsets.only(
                left: 35.0, right: 35.0, top: 8.0, bottom: 8.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: const BorderRadius.all(Radius.circular(6.0))),
          ),
          onTap: () {
            RouterDouB.push(context, RouterDouB.searchPage, '搜索笨啦灯');
          },
        )
      ],
    ),
  );
}
