class FilteredWeatherData {
  List<double?>? rainSum;
  List<double?>? precipitationSum;
  List<double?>? eto;

  FilteredWeatherData({this.rainSum, this.precipitationSum, this.eto});

  Map<String, dynamic> toJson() => {
        'precipitationSum': precipitationSum,
        'rainSum': rainSum,
        'et0_fao_evapotranspiration': eto,
      };
}
