import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocationServices {
  final List<Province> _province = [];
  final List<City> _cities = [];

  _load() async {
    var provinceJson = await rootBundle.loadString('assets/provinces.json');
    var citiesJson = await rootBundle.loadString('assets/cities.json');
    List<dynamic> province = jsonDecode(provinceJson) as List;
    List<dynamic> cites = jsonDecode(citiesJson) as List;
    for (var element in province) {
      _province.add(Province(element["id"], element["name"], element["slug"]));
    }

    for (var element in cites) {
      _cities.add(City(element["id"], element["name"], element["slug"],
          element["province_id"]));
    }
  }

  Future<List<Province>> getProvince() async {
    if (_province.isEmpty) await _load();
    return _province;
  }

  List<City> getCityOfProvince(int pId)  {
    return _cities.where((element) => element.provinceId == pId).toList();
  }
}

class City {
  int id;
  String name;
  String slug;
  int provinceId;

  City(this.id, this.name, this.slug, this.provinceId);
}

class Province {
  int id;
  String name;
  String slug;

  Province(this.id, this.name, this.slug);
}
