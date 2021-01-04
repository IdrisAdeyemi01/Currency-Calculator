import 'package:http/http.dart' as http;
import 'dart:convert';

class FixerLatestData {
  FixerLatestData({this.url});
  final String url;
  
  Future getData() async {
    http.Response response = await http.get(url);
    var body = jsonDecode(response.body);
    if (body['success'] == true) {
      return body;
    } else {
      print(body['error']['info']);
    }
  }
}
