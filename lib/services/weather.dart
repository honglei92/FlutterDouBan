import 'package:services/location.dart';
import 'package:clima/services/networking.dart';


const apiKey = '0ca92484d26657567ffaf07472e1d075';
const openWeatherMapURL = 'http://v.juhe.cn/weather/geo';
const openCityWeatherMapURL = 'http://v.juhe.cn/weather/index';

class WeatherModel {

  Future<dynamic> getCityWeather(String cityName) async{
    NetworkHelper networkHelper = NetworkHelper('$openCityWeatherMapURL?format=1&key=$apiKey&cityname=$cityName&dtype=json');
    var weatherData =await networkHelper.getData();
    return weatherData;
  }

  Future<dynamic> getLocationWeather() async{
    Location location = Location();
    await location.getCurrentLocation();
    NetworkHelper networkHelper = NetworkHelper(
        '$openWeatherMapURL?format=2&key=$apiKey&dtype=json&lat=${location.latitude}&lon=${location.longitude}');
    var weatherData = await networkHelper.getData();
    return weatherData;
  }


  String getWeatherIcon(String condition) {
    if ("小雨"==condition) {
      return '🌩';
    } else if ("中雨"==condition) {
      return '🌧';
    } else if ("大雨"==condition) {
      return '☔️';
    } else if ("暴雨"==condition) {
      return '☃️';
    } else if ("雷阵雨"==condition) {
      return '🌫';
    } else if ("晴" == condition) {
      return '☀️';
    } else if ("多云" == condition) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  String getMessage(int temp) {
    if (temp > 25) {
      return 'It\'s 🍦 time';
    } else if (temp > 20) {
      return 'Time for shorts and 👕';
    } else if (temp < 10) {
      return 'You\'ll need 🧣 and 🧤';
    } else {
      return 'Bring a 🧥 just in case';
    }
  }


}
