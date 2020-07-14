import 'package:flutter_app/generated/json/base/json_convert_content.dart';

class AllPeoplePointEntity with JsonConvert<AllPeoplePointEntity> {
  List<AllPeoplePointData> data;
}

class AllPeoplePointData with JsonConvert<AllPeoplePointData> {
  double longitude;
  double latitude;
  int userId;
}
