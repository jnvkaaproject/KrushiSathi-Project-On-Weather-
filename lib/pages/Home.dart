import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:krushisathi/model/weather_model.dart';
import 'package:krushisathi/pages/search.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:weather_icons/weather_icons.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // declaring the variables.

  late Weather weather;
  bool loading = true;
  bool locationLoading = false;
  String weatherIcons = "assets/images/location-off.png";
  String weatherimage = "";
  var weatherAccentColor = const Color.fromARGB(255, 238, 65, 52);

  @override
  void initState() {
    locationInfo();
    super.initState();
  }

  weatherInfo({double long = 86.42, double lat = 20.49}) async {
    try {
      var response = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=${lat.toString()}&lon=${long.toString()}&appid=161dac9a92ceee952f60b1ecfcd83468"));
      var decodedJson = await jsonDecode(response.body);
      print(decodedJson);

      weather = Weather(
          main: decodedJson["weather"][0]["main"],
          description: decodedJson["weather"][0]["description"],
          country: decodedJson["sys"]["country"],
          icon: decodedJson["weather"][0]["icon"],
          name: decodedJson["name"],
          id: decodedJson["weather"][0]["id"],
          temp_max: decodedJson["main"]["temp_max"],
          temp_min: decodedJson["main"]["temp_min"],
          temp: decodedJson["main"]["temp"],
          humidity: decodedJson["main"]["humidity"].toString(),
          sunrise: decodedJson["sys"]["sunrise"],
          sunset: decodedJson["sys"]["sunset"]);
         
      Fluttertoast.showToast(
        msg: "Done",
        backgroundColor: Colors.grey,
      );

      setState(() {
        loading = false;
        locationLoading = false;
        setWeatherCode(weather.id);
        // Fluttertoast.cancel();
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Something went wrong!",
        backgroundColor: Colors.red.shade400,
      );
      Fluttertoast.cancel();
    }
  }

  String dateStringFT(int timestamp) {
    DateTime dateStamp = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    String dateTime =
        "${dateStamp.year}/${dateStamp.month}/${dateStamp.day} ${dateStamp.hour}:${dateStamp.minute} ${dateStamp.hour > 12 ? 'PM' : 'AM'}";
    return dateTime;
  }

  locationInfo() async {
    locationLoading = true;

    await Geolocator.checkPermission();
    await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);

    weatherInfo(long: position.longitude, lat: position.latitude);
  }

  setWeatherCode(int code) {
    if (code == 800) {
      weatherimage = "assets/images/Sunny Weather.gif";
      weatherIcons = "assets/images/sun.png";
      weatherAccentColor = const Color.fromARGB(255, 6, 86, 205);
    } else {
      switch (code ~/ 100) {
        case 8:
          weatherimage = "assets/images/89268-cloudy-weather.gif";
          weatherIcons = "assets/images/clouds.png";
          weatherAccentColor = const Color.fromARGB(255, 6, 129, 252);
          break;
        case 7:
          weatherimage = "assets/images/haze.jpg";
          weatherIcons = "assets/images/haze.png";
          weatherAccentColor = const Color.fromARGB(255, 39, 55, 96);
          break;
        case 6:
          weatherimage = "assets/images/SnowFall.gif";
          weatherIcons = "assets/images/snowflake.png";
          weatherAccentColor = const Color.fromARGB(255, 145, 174, 245);
          break;
        case 5:
          weatherimage = "assets/images/89268-cloudy-weather.gif";
          weatherAccentColor = const Color.fromARGB(255, 195, 172, 1);
          weatherIcons = "assets/images/cloudy.png";
          break;
        case 3:
          weatherimage = "assets/images/89266-rainy-weather.gif";
          weatherIcons = "assets/images/rain.png";
          weatherAccentColor = const Color.fromARGB(255, 47, 61, 255);

          break;
        case 2:
          weatherimage = "";
          weatherIcons = "assets/images/storm.png";
          weatherAccentColor = const Color.fromARGB(255, 5, 1, 1);
          break;
        default:
          weatherIcons = "assets/images/location-off.png";
          weatherAccentColor = const Color.fromARGB(255, 238, 65, 52);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: GNav(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 9),
          gap: 6,
          onTabChange: (index) {
            if (index == 0) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Home()));
            } else if (index == 1) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Search()));
            } else if (index == 2) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => locationInfo()));
            }
          },
          tabs: const [
            GButton(
              icon: Icons.home,
            ),
            GButton(icon: Icons.search),
            GButton(icon: Icons.location_pin)
          ]),
      // appBar: AppBar(
      //   backgroundColor: weatherAccentColor,
      //   title: Center(
      //     child: Text("${weather.name}, ${weather.country}"),
      //   ),
      // ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(weatherimage), fit: BoxFit.cover)),
              child: Column(
                children: [
                  const SizedBox(
                    height: 60,
                  ),
                  Text(
                    "${weather.name},",
                    style: const TextStyle(
                        fontSize: 39,
                        fontStyle: FontStyle.normal,
                        color: Color.fromRGBO(28, 115, 221, 1)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    weather.country,
                    style: const TextStyle(
                        fontSize: 35,
                        fontStyle: FontStyle.italic,
                        color: Color.fromRGBO(28, 115, 221, 1)),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        weatherIcons,
                        width: 115,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "${(weather.temp - 275).truncate()}°C",
                        style: TextStyle(
                            fontSize: 130,
                            fontStyle: FontStyle.normal,
                            color: weatherAccentColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    weather.main,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 39, 55, 96),
                      fontSize: 45,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    weather.description,
                    style: const TextStyle(
                      color: Colors.black38,
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.thermostat,
                        size: 30,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${(weather.temp_max - 275).truncate()} °C",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      const SizedBox(width: 20),
                      const Icon(
                        Icons.thermostat,
                        size: 30,
                        color: Color.fromARGB(255, 51, 109, 255),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(weather.temp_min - 275).truncate()} °C',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                     
                      
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Humidity => ${weather.humidity} %",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Sunrise => ${dateStringFT(weather.sunrise)} ",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Color.fromARGB(255, 0, 110, 255)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Sunset => ${dateStringFT(weather.sunset)} ",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Color.fromARGB(255, 27, 36, 170)),
                  ),
                ],
              ),
              
            ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            Fluttertoast.showToast(
              msg: 'Loading...',
              backgroundColor: Colors.grey,
            );
            locationInfo();
          },
          backgroundColor: weatherAccentColor,
          child: locationLoading
              ? const Icon(Icons.hourglass_bottom)
              : const Icon(Icons.location_pin),
        ),
      ),
    );
  }
}
