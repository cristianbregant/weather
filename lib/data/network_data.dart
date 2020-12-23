import 'package:weather_app/model/weather_json.dart';
import 'package:http/http.dart' as http;

class NetworkData {
  static Future<CompleteWeather> getWeather(String city) async {
    try {
      var result;
      var uri = new Uri.https("api.openweathermap.org", "/data/2.5/forecast", {
        "q": city,
        "appid": "ac25428718da73862cc776a576d85df9",
        "units": "metric",
        "lang": "it"
      });

      print("Uri: $uri");

      var response = await http.get(uri);

      if (response.statusCode == 200) {
        result = completeWeatherFromJson(response.body);
        print("$result ${result.list.length}");
      } else {
        throw Exception(["${response.statusCode} - ${response.body}"]);
      }
      return result;
    } catch (err) {
      print(err);
    }
  }
}
