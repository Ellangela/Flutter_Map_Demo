import 'package:flutter_app/all_people_point_entity.dart';

allPeoplePointEntityFromJson(AllPeoplePointEntity data, Map<String, dynamic> json) {
  if (json['data'] != null) {
    data.data = new List<AllPeoplePointData>();
    (json['data'] as List).forEach((v) {
      data.data.add(new AllPeoplePointData().fromJson(v));
    });
  }
  return data;
}

Map<String, dynamic> allPeoplePointEntityToJson(AllPeoplePointEntity entity) {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  if (entity.data != null) {
    data['data'] = entity.data.map((v) => v.toJson()).toList();
  }
  return data;
}

allPeoplePointDataFromJson(AllPeoplePointData data, Map<String, dynamic> json) {
  if (json['longitude'] != null) {
    data.longitude = json['longitude']?.toDouble();
  }
  if (json['latitude'] != null) {
    data.latitude = json['latitude']?.toDouble();
  }
  if (json['userId'] != null) {
    data.userId = json['userId']?.toInt();
  }
  return data;
}

Map<String, dynamic> allPeoplePointDataToJson(AllPeoplePointData entity) {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['longitude'] = entity.longitude;
  data['latitude'] = entity.latitude;
  data['userId'] = entity.userId;
  return data;
}
