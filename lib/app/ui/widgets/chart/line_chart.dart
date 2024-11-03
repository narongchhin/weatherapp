import 'dart:convert';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:intl/intl.dart';
import 'package:rain/app/api/weather_api.dart';
import 'package:rain/app/data/db.dart';
import 'package:rain/app/ui/widgets/weather/desc/desc_short.dart';
import 'package:rain/main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:timezone/timezone.dart';

class LineChart extends StatefulWidget {
  final WeatherCard weatherData;
  final LocationCache locationCache;
  final double? tempMax;
  final int? humidity;

  const LineChart(
      {super.key,
      required this.weatherData,
      required this.locationCache,
      required this.tempMax,
      required this.humidity});

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  late ZoomPanBehavior _zoomPanBehavior;
  Set<String> selected = {'3'};
  List<RainSum> myData = <RainSum>[];
  List<RainSum> myPsumData = <RainSum>[];
  List<RainSum> EtaData = <RainSum>[];
  List<RainSum> myDataReversed = <RainSum>[];
  List<RainSum> myPsumDataReversed = <RainSum>[];
  List<RainSum> EtaDataReversed = <RainSum>[];
  double totalRainSum = 0.0;

  DateTimeRange selectedDates =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  static const String _weatherParamsForFilter =
      'hourly=temperature_2m,relativehumidity_2m,apparent_temperature,precipitation,rain,weathercode,surface_pressure,visibility,evapotranspiration,windspeed_10m,winddirection_10m,windgusts_10m,cloudcover,uv_index,dewpoint_2m,precipitation_probability,shortwave_radiation'
      '&daily=et0_fao_evapotranspiration,weathercode,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,sunrise,sunset,precipitation_sum,precipitation_probability_max,windspeed_10m_max,windgusts_10m_max,uv_index_max,rain_sum,winddirection_10m_dominant'
      '&timezone=auto';

  @override
  void initState() {
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.x,
      enablePanning: true,
      enableMouseWheelZooming: true,
    );
    getMyData(3);
    super.initState();
  }

  void clearListData() {
    if (myData.isNotEmpty && myPsumData.isNotEmpty && EtaData.isNotEmpty) {
      myData.clear();
      myPsumData.clear();
      EtaData.clear();
    }
    if (totalRainSum > 0.0) {
      totalRainSum = 0.0;
    }
  }

  void getMyData(int day) {
    WeatherCard weatherCard = widget.weatherData;
    clearListData();
    int indexToStart = weatherCard.timeDaily!.length - day;
    int indexToLoop = indexToStart + day;
    for (var i = indexToStart; i < indexToLoop; i++) {
      var q = DateFormat.MMMd(locale.languageCode)
          .format(weatherCard.timeDaily![i]);
      var rainSum = weatherCard.rainSum?[i];
      var pSum = weatherCard.precipitationSum?[i];
      var eta = weatherCard.eta?[i];

      totalRainSum = (totalRainSum + rainSum!.toDouble());

      RainSum data = RainSum(q.toString(), rainSum!.toDouble());
      RainSum data2 = RainSum(q.toString(), pSum!.toDouble());
      RainSum data3 = RainSum(q.toString(), eta!.toDouble());
      // myDataReversed.add(data);
      // myPsumDataReversed.add(data2);
      // EtaDataReversed.add(data3);
      myData.add(data);
      myPsumData.add(data2);
      EtaData.add(data3);
      // myPsumData.add(data2);
      // EtaData.add(data3);
    }

    // myData = myDataReversed.reversed.toList();
    // myPsumData = myPsumDataReversed.reversed.toList();
    // EtaData = EtaDataReversed.reversed.toList();
  }

  void getFilterChartData(WeatherDataApi weatherDataApi) {
    clearListData();
    WeatherDataApi weatherData = weatherDataApi;
    for (var i = 0; i < weatherDataApi.daily.time!.length; i++) {
      var q = DateFormat.MMMd(locale.languageCode)
          .format(weatherDataApi.daily.time![i]);
      var rainSum = weatherData.daily.rainSum?[i];
      var pSum = weatherData.daily.precipitationSum?[i];
      var eta = weatherData.daily.uvIndexMax?[i];

      totalRainSum = (totalRainSum + rainSum!.toDouble());

      RainSum data = RainSum(q.toString(), rainSum!.toDouble());
      RainSum data2 = RainSum(q.toString(), pSum!.toDouble());
      RainSum data3 = RainSum(q.toString(), eta!.toDouble());

      setState(() {
        myData.add(data);
        myPsumData.add(data2);
        EtaData.add(data3);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: [
        Center(
          child: DescShort(
              initiallyExpanded: true,
              title: 'dailyVariables'.tr,
              apparentTemperatureMax: widget.tempMax,
              humidity: widget.humidity),
        ),
        Center(
          child: SegmentedButton(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: '3',
                label: Text("3 Days"),
                //  icon: Icon(Icons.report),
              ),
              ButtonSegment(
                value: '7',
                label: Text("7 Days"),
                //  icon: Icon(Icons.report),
              ),
              ButtonSegment(
                value: '30',
                label: Text("30 Days"),
                //icon: Icon(Icons.report),
              ),
              ButtonSegment(
                value: 'c',
                label: Text("Custom"),

                //icon: Icon(Icons.report),
              )
            ],
            selected: selected,
            onSelectionChanged: (Set<String> newSelected) {
              setState(() {
                selected = newSelected;
              });
              if (selected.first == '3') {
                getMyData(3);
              } else if (selected.first == '7') {
                getMyData(7);
              } else if (selected.first == '30') {
                getMyData(30);
              } else {
                showRangeDatePicker();
              }
            },
          ),
        ),
        Center(
            child: Container(
                //height: 300,
                //width: 350,
                child: SfCartesianChart(
          // Initialize category axis
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(
              text: "Total Rain: " + totalRainSum.toStringAsFixed(2) + " mm"),
          legend: Legend(isVisible: true),
          series: <LineSeries<RainSum, String>>[
            LineSeries<RainSum, String>(
                // Bind data source
                name: 'Rain',
                dataSource: myData.reversed.toList(),
                xValueMapper: (RainSum sales, _) => sales.date,
                yValueMapper: (RainSum sales, _) => sales.rainSum,
                dataLabelSettings: DataLabelSettings(isVisible: true)),
            LineSeries<RainSum, String>(
                // Bind data source
                name: 'Precipitation',
                dataSource: myPsumData.reversed.toList(),
                xValueMapper: (RainSum sales, _) => sales.date,
                yValueMapper: (RainSum sales, _) => sales.rainSum,
                dataLabelSettings: DataLabelSettings(isVisible: true)),
            LineSeries<RainSum, String>(
                // Bind data source
                name: 'ETO',
                dataSource: EtaData.reversed.toList(),
                xValueMapper: (RainSum sales, _) => sales.date,
                yValueMapper: (RainSum sales, _) => sales.rainSum,
                dataLabelSettings: DataLabelSettings(isVisible: true))
          ],
          primaryYAxis: NumericAxis(
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            labelFormat: "{value} mm",
          ),
          zoomPanBehavior: _zoomPanBehavior,
        )))
      ],
    ));
  }

  void showRangeDatePicker() async {
    final DateTimeRange? dateTimeRange = await showDateRangePicker(
        context: context, firstDate: DateTime(2000), lastDate: DateTime(3000));
    if (dateTimeRange != null) {
      setState(() {
        selectedDates = dateTimeRange;
      });
      String startDate = DateFormat('yyyy-MM-dd').format(dateTimeRange.start);
      String endDate = DateFormat('yyyy-MM-dd').format(dateTimeRange.end);

      fetchChartData(startDate, endDate);
    }
  }

  String _buildWeatherUrlFilter(
      double? lat, double? lon, String startdate, String enddate) {
    String url = 'latitude=$lat&longitude=$lon&$_weatherParamsForFilter';
    if (settings.measurements == 'imperial') {
      url += '&windspeed_unit=mph&precipitation_unit=inch';
    }
    if (settings.degrees == 'fahrenheit') {
      url += '&temperature_unit=fahrenheit';
    }
    url += '&start_date=$startdate&end_date=$enddate';
    return url;
  }

  Future fetchChartData(String startDate, String endDate) async {
    LocationCache locationCache = widget.locationCache;
    Dio dio = Dio()
      ..options.baseUrl = 'https://api.open-meteo.com/v1/forecast?';
    String urlWeather = _buildWeatherUrlFilter(
        locationCache.lat, locationCache.lon, startDate, endDate);
    try {
      Response response = await dio.get(urlWeather);
      WeatherDataApi weatherData = WeatherDataApi.fromJson(response.data);
      getFilterChartData(weatherData);
    } on DioException catch (e) {
      print(e);
    }
  }

  // void ShowChart() {
  //   SfCartesianChart(
  //     // Initialize category axis
  //     primaryXAxis: CategoryAxis(),
  //     title: ChartTitle(text: "Forecast"),
  //     legend: Legend(isVisible: true),
  //     series: <LineSeries<RainSum, String>>[
  //       LineSeries<RainSum, String>(
  //           // Bind data source
  //           name: 'Rain',
  //           dataSource: myData,
  //           xValueMapper: (RainSum sales, _) => sales.date,
  //           yValueMapper: (RainSum sales, _) => sales.rainSum,
  //           dataLabelSettings: DataLabelSettings(isVisible: true)),
  //       LineSeries<RainSum, String>(
  //           // Bind data source
  //           name: 'Precipitation',
  //           dataSource: myPsumData,
  //           xValueMapper: (RainSum sales, _) => sales.date,
  //           yValueMapper: (RainSum sales, _) => sales.rainSum,
  //           dataLabelSettings: DataLabelSettings(isVisible: true)),
  //       LineSeries<RainSum, String>(
  //           // Bind data source
  //           name: 'ETO',
  //           dataSource: EtaData,
  //           xValueMapper: (RainSum sales, _) => sales.date,
  //           yValueMapper: (RainSum sales, _) => sales.rainSum,
  //           dataLabelSettings: DataLabelSettings(isVisible: true))
  //     ],
  //     primaryYAxis: NumericAxis(
  //       edgeLabelPlacement: EdgeLabelPlacement.shift,
  //       labelFormat: "{value} mm",
  //     ),
  //     zoomPanBehavior: _zoomPanBehavior,
  //   );
  // }
}

class RainSum {
  RainSum(this.date, this.rainSum);
  final String date;
  final double rainSum;
}
