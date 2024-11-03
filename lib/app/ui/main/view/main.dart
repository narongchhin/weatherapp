import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rain/app/controller/controller.dart';
import 'package:rain/app/data/db.dart';
import 'package:rain/app/ui/widgets/chart/line_chart.dart';
import 'package:rain/app/ui/widgets/weather/daily/daily_card_list.dart';
import 'package:rain/app/ui/widgets/weather/daily/daily_container.dart';
import 'package:rain/app/ui/widgets/weather/desc/desc_container.dart';
import 'package:rain/app/ui/widgets/weather/desc/desc_short.dart';
import 'package:rain/app/ui/widgets/weather/hourly.dart';
import 'package:rain/app/ui/widgets/weather/now.dart';
import 'package:rain/app/ui/widgets/shimmer.dart';
import 'package:rain/app/ui/widgets/weather/sunset_sunrise.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final weatherController = Get.put(WeatherController());
  late Isar isar;
  late LocationCache locationCache;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await weatherController.deleteAll(false);
        await weatherController.setLocation();
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Obx(() {
          if (weatherController.isLoading.isTrue) {
            return ListView(
              children: const [
                MyShimmer(
                  hight: 200,
                ),
                MyShimmer(
                  hight: 130,
                  edgeInsetsMargin: EdgeInsets.symmetric(vertical: 15),
                ),
                MyShimmer(
                  hight: 90,
                  edgeInsetsMargin: EdgeInsets.only(bottom: 15),
                ),
                MyShimmer(
                  hight: 400,
                  edgeInsetsMargin: EdgeInsets.only(bottom: 15),
                ),
                MyShimmer(
                  hight: 450,
                  edgeInsetsMargin: EdgeInsets.only(bottom: 15),
                )
              ],
            );
          }

          final mainWeather = weatherController.mainWeather;
          final weatherCard = WeatherCard.fromJson(mainWeather.toJson());
          final hourOfDay = weatherController.hourOfDay.value;
          final dayOfNow = weatherController.dayOfNow.value;
          final sunrise = mainWeather.sunrise![dayOfNow];
          final sunset = mainWeather.sunset![dayOfNow];
          final tempMax = mainWeather.temperature2MMax![dayOfNow];
          final tempMin = mainWeather.temperature2MMin![dayOfNow];
          final humidity = mainWeather.relativehumidity2M?[hourOfDay];

          LocationCache locationCache = weatherController.getLocationCached();

          return LineChart(
            weatherData: weatherCard,
            locationCache: locationCache,
            tempMax: tempMax,
            humidity: humidity,
          );

          // return LineChart(
          //     weatherData: weatherCard, locationCache: locationCache);
          // return DailyContainer(
          //     weatherData: weatherCard,
          //     onTap: () => Get.to(
          //           () => DailyCardList(
          //             weatherData: weatherCard,
          //           ),
          //           transition: Transition.downToUp,
          //         ));

          // return ListView(
          //   children: [
          // LineChart(weatherData: weatherCard, locationCache: locationCache),
          // Now(
          //   time: mainWeather.time![hourOfDay],
          //   weather: mainWeather.weathercode![hourOfDay],
          //   degree: mainWeather.temperature2M![hourOfDay],
          //   feels: mainWeather.apparentTemperature![hourOfDay]!,
          //   timeDay: sunrise,
          //   timeNight: sunset,
          //   tempMax: tempMax!,
          //   tempMin: tempMin!,
          // ),
          // Card(
          //   margin: const EdgeInsets.only(bottom: 15),
          //   child: Padding(
          //     padding:
          //         const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //     child: SizedBox(
          //       height: 135,
          //       child: ScrollablePositionedList.separated(
          //         key: const PageStorageKey(0),
          //         separatorBuilder: (BuildContext context, int index) {
          //           return const VerticalDivider(
          //             width: 10,
          //             indent: 40,
          //             endIndent: 40,
          //           );
          //         },
          //         scrollDirection: Axis.horizontal,
          //         itemScrollController:
          //             weatherController.itemScrollController,
          //         itemCount: mainWeather.time!.length,
          //         itemBuilder: (ctx, i) {
          //           final i24 = (i / 24).floor();

          //           return GestureDetector(
          //             onTap: () {
          //               weatherController.hourOfDay.value = i;
          //               weatherController.dayOfNow.value = i24;
          //               setState(() {});
          //             },
          //             child: Container(
          //               margin: const EdgeInsets.symmetric(vertical: 5),
          //               padding: const EdgeInsets.symmetric(
          //                 horizontal: 20,
          //                 vertical: 5,
          //               ),
          //               decoration: BoxDecoration(
          //                 color: i == hourOfDay
          //                     ? context.theme.colorScheme.secondaryContainer
          //                     : Colors.transparent,
          //                 borderRadius: const BorderRadius.all(
          //                   Radius.circular(20),
          //                 ),
          //               ),
          //               child: Hourly(
          //                 time: mainWeather.time![i],
          //                 weather: mainWeather.weathercode![i],
          //                 degree: mainWeather.temperature2M![i],
          //                 timeDay: mainWeather.sunrise![i24],
          //                 timeNight: mainWeather.sunset![i24],
          //               ),
          //             ),
          //           );
          //         },
          //       ),
          //     ),
          //   ),
          // ),
          // SunsetSunrise(
          //   timeSunrise: sunrise,
          //   timeSunset: sunset,
          // ),
          // DescShort(
          //     humidity: mainWeather.relativehumidity2M?[hourOfDay],
          //     apparentTemperatureMax: tempMax,
          //     initiallyExpanded: true,
          //     title: 'dailyVariables'.tr),
          // LineChart(weatherData: weatherCard, locationCache: locationCache),

          // DescContainer(
          //   rain: mainWeather.rain?[hourOfDay],
          //   evaporation: mainWeather.evapotranspiration?[hourOfDay],
          //   precipitation: mainWeather.precipitation?[hourOfDay],
          //   shortwaveRadiation: mainWeather.shortwaveRadiation?[hourOfDay],
          //   initiallyExpanded: true,
          //   title: 'hourlyVariables'.tr,
          // ),
          // DailyContainer(
          //   weatherData: weatherCard,
          //   onTap: () => Get.to(
          //     () => DailyCardList(
          //       weatherData: weatherCard,
          //     ),
          //     transition: Transition.downToUp,
          //   ),
          // ),
          //   ],
          // );
        }),
      ),
    );
  }

  Future<void> isarInit() async {
    isar = await Isar.open([
      SettingsSchema,
      MainWeatherCacheSchema,
      LocationCacheSchema,
      WeatherCardSchema,
    ], directory: (await getApplicationSupportDirectory()).path);
    locationCache =
        isar.locationCaches.where().findFirstSync() ?? LocationCache();
  }
}
