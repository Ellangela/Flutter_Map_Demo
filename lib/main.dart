import 'dart:io';

import 'package:amap_location/amap_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/all_people_point_entity.dart';
import 'package:flutter_app/http_request.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import 'MsgPopup.dart';

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
  var allPoint = List<AllPeoplePointData>();
  var markers = List<Marker>();
  final PopupController _popupLayerController = PopupController();

  @override
  void initState() {
    super.initState();
    getLocation();
    updateAllPoint();
  }

  updateAllPoint() async {
    await HttpRequest.request<AllPeoplePointEntity>("http://35.201.146.182:8080/test/index").then((value) {
      _center.latitude = value.data[0].latitude;
      _center.longitude = value.data[0].longitude;
      allPoint = value.data;
    });
    updateMarkers();
    Future.delayed(const Duration(seconds: 1), () {
      updateAllPoint();
    });
  }

  updateMarkers() {
    markers.clear();
    allPoint.forEach((allPeoplePointData) {
      markers.add(Marker(
        point: new LatLng(allPeoplePointData.latitude, allPeoplePointData.longitude),
        builder: (_) {
          return Icon(
            Icons.location_on,
            size: 24,
            color: Colors.primaries[allPeoplePointData.userId % Colors.primaries.length],
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
          updateAllPoint();
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
      options: new MapOptions(center: _center, plugins: [PopupMarkerPlugin()], onTap: (_) => _popupLayerController.hidePopup()),
      layers: <LayerOptions>[
        //卫星地图
        //new TileLayerOptions(urlTemplate: "http://webst0{s}.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}", subdomains: ["1", "2", "3", "4"]),
        //平面地图
        new TileLayerOptions(urlTemplate: "http://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}", subdomains: ["1", "2", "3", "4"]),
        new PopupMarkerLayerOptions(
          popupBuilder: (BuildContext _, Marker marker) {
            return MsgPopup(marker);
          },
          markers: markers,
          popupSnap: PopupSnap.top,
          popupController: _popupLayerController,
        )
      ],
    );
  }
}

class PopupMsg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      color: Colors.white,
      child: SizedBox(
        width: 120,
        height: 50,
        child: null,
      ),
    );
  }
}
