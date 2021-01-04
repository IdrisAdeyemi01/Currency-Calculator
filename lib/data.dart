// To parse this JSON data, do
//
//     final apiModel = apiModelFromJson(jsonString);

import 'dart:convert';

class NetworkHelper {
  NetworkHelper({this.url, this.dropdownValue1, this.dropdownValue2, this.value});
  final String url;
  final String dropdownValue1;
  final String dropdownValue2;
  var value;

  
}

ApiModel apiModelFromJson(String str) => ApiModel.fromJson(json.decode(str));

String apiModelToJson(ApiModel data) => json.encode(data.toJson());

class ApiModel {
  ApiModel({
    this.success,
    this.timestamp,
    this.base,
    this.date,
    this.rates,
  });

  bool success;
  int timestamp;
  String base;
  DateTime date;
  Map<String, double> rates;

  factory ApiModel.fromJson(Map<String, dynamic> json) => ApiModel(
        success: json["success"],
        timestamp: json["timestamp"],
        base: json["base"],
        date: DateTime.parse(json["date"]),
        rates: Map.from(json["rates"])
            .map((k, v) => MapEntry<String, double>(k, v.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "timestamp": timestamp,
        "base": base,
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "rates": Map.from(rates).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
