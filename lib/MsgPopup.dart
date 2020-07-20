import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MsgPopup extends StatefulWidget {
  final Marker marker;

  MsgPopup(this.marker, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MsgPopupState(this.marker);
}

class _MsgPopupState extends State<MsgPopup> {
  _MsgPopupState(this._marker);

  final Marker _marker;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5),
          ),
          InkWell(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.child_care),
            ),
            onTap: () {},
          ),
          _cardDescription(context),
          InkWell(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.call),
            ),
            onTap: () {},
          ),
          InkWell(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.navigation),
            ),
            onTap: () {},
          ),
          Padding(
            padding: EdgeInsets.all(5),
          ),
        ],
      ),
    );
  }

  Widget _cardDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        constraints: BoxConstraints(minWidth: 100, maxWidth: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "用户名",
              overflow: TextOverflow.fade,
              softWrap: false,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            Text(
              "纬度:${_marker.point.latitude}\n经度:${_marker.point.longitude}",
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }
}
