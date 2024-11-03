import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rain/app/ui/widgets/weather/desc/desc.dart';
import 'package:rain/app/ui/widgets/weather/desc/message.dart';
import 'package:rain/app/ui/widgets/weather/status/status_data.dart';

class DescShort extends StatefulWidget {
  const DescShort({
    super.key,
    this.humidity,
    this.apparentTemperatureMax,
    required this.initiallyExpanded,
    required this.title,
  });

  final int? humidity;
  final double? apparentTemperatureMax;

  final bool initiallyExpanded;
  final String title;

  @override
  State<DescShort> createState() => _DescContainerState();
}

class _DescContainerState extends State<DescShort> {
  final statusData = StatusData();
  final message = Message();

  @override
  Widget build(BuildContext context) {
    final humidity = widget.humidity;

    final apparentTemperatureMax = widget.apparentTemperatureMax;

    final initiallyExpanded = widget.initiallyExpanded;
    final title = widget.title;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ExpansionTile(
        shape: const Border(),
        title: Text(
          title,
          style: context.textTheme.labelLarge,
        ),
        initiallyExpanded: initiallyExpanded,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 5),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 5,
              children: [
                apparentTemperatureMax == null
                    ? Container()
                    : DescWeather(
                        imageName: 'assets/images/hot.png',
                        value: statusData
                            .getDegree(apparentTemperatureMax.round()),
                        desc: 'maxTemp'.tr,
                      ),
                humidity == null
                    ? Container()
                    : DescWeather(
                        imageName: 'assets/images/humidity.png',
                        value: '$humidity%',
                        desc: 'humidity'.tr,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
