import 'dart:io';

import 'package:amap_location/amap_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/all_people_point_entity.dart';
import 'package:flutter_app/http_request.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MapView(),
    );
  }
}

class MapView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapView();
}

class _MapView extends State<MapView> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    getLocation();
    initAllPoint();
  }

  var allPoint = List<AllPeoplePointData>();
  var markers = List<Marker>();

  initAllPoint() async {
    allPoint.clear();
    var response = await HttpRequest.request<AllPeoplePointEntity>("http://192.168.124.18:8080/test/index");
    allPoint.addAll(response.data);
    initMarkers();
  }

  initMarkers() {
    markers.clear();
    var length = Colors.primaries.length;
    allPoint.forEach((element) {
      markers.add(Marker(
        point: new LatLng(element.latitude, element.longitude),
        builder: (_) {
          return Icon(
            Icons.location_on,
            size: 24,
            color: Colors.primaries[element.userId % length],
          );
        },
      ));
    });
    setState(() => null);
  }

  ///地图中心移动动画
  ///https://github.com/fleaflet/flutter_map/blob/master/example/lib/pages/animated_map_controller.dart
  void _animatedMapMove(MapController mapController, LatLng destLocation, double destZoom) {
    final _latTween = Tween<double>(begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);
    var animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this); //with TickerProviderStateMixin
    Animation<double> animation = CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn);
    animationController.addListener(() {
      mapController.move(LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)), _zoomTween.evaluate(animation));
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) animationController.dispose();
    });
    animationController.forward();
  }

  MapController mapController = MapController();

  LatLng _center = new LatLng(39.90, 116.40);

  set center(AMapLocation aMapLocation) {
    _center.longitude = aMapLocation.longitude;
    _center.latitude = aMapLocation.latitude;
  }

  //得到当前位置坐标
  getLocation() async {
    await AMapLocationClient.startup(new AMapLocationOption(desiredAccuracy: CLLocationAccuracy.kCLLocationAccuracyHundredMeters));
    //请求定位权限
    await PermissionHandler().requestPermissions([PermissionGroup.location]);
    //结果回调
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
    //当获取定位权限
    if (permission == PermissionStatus.granted) {
      //amap获取当前位置
      await AMapLocationClient.getLocation(true).then((aMapLocation) {
        center = aMapLocation;
        print("${aMapLocation.longitude}:::${aMapLocation.latitude}");
        _animatedMapMove(mapController, _center, 13);
      });
    } else {
      //当未获取定位权限
      FlutterToast(context).showToast(child: Text("没有定位权限"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _buildFlutterMap(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getLocation();
          initAllPoint();
        },
        child: Icon(Icons.my_location),
      ),
    );
  }

  ///https://github.com/fleaflet/flutter_map
  ///地图
  FlutterMap _buildFlutterMap() {
    return new FlutterMap(
      mapController: mapController,
      options: new MapOptions(
        center: _center,
      ),
      layers: [
        //卫星地图
        //new TileLayerOptions(urlTemplate: "http://webst0{s}.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}", subdomains: ["1", "2", "3", "4"]),
        //平面地图
        new TileLayerOptions(urlTemplate: "http://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}", subdomains: ["1", "2", "3", "4"]),
        //地图标记
        new MarkerLayerOptions(
          markers: markers,
        ),
      ],
    );
  }
}
