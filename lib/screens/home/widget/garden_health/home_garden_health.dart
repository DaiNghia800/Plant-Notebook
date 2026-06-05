import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:plant_notebook/controller/profile_controller.dart';
import 'package:plant_notebook/screens/home/widget/garden_health/health_card.dart';

class HomeGardenHealth extends StatefulWidget {
  const HomeGardenHealth({super.key});

  @override
  State<HomeGardenHealth> createState() => _HomeGardenHealthState();
}

class _HomeGardenHealthState extends State<HomeGardenHealth> {
  bool _isLoading = true;
  String _temperature = '--°C';
  String _humidity = '--%';
  bool _isDay = true;

  @override
  void initState() {
    super.initState();
    _fetchRealWeather();
  }

  Future<void> _fetchRealWeather() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setFallbackData();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _setFallbackData();
          return;
        }
      }

      // Lấy tọa độ hiện tại (timeout 5s để không bị treo UI quá lâu)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      // Gọi API Open-Meteo
      final dio = Dio();
      final response = await dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'current': 'temperature_2m,relative_humidity_2m,is_day',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final current = response.data['current'];
        if (mounted) {
          setState(() {
            _temperature = '${current['temperature_2m']}°C';
            _humidity = '${current['relative_humidity_2m']}%';
            _isDay = current['is_day'] == 1;
            _isLoading = false;
          });
        }
      } else {
        _setFallbackData();
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      _setFallbackData();
    }
  }

  void _setFallbackData() {
    if (mounted) {
      setState(() {
        _temperature = '32°C';
        _humidity = '65%';
        _isDay = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = context.watch<ProfileController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang.tr('current_weather'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (_isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2E7D32),
                ),
              )
            else
              const Icon(
                Icons.cloud_done_outlined,
                color: Color(0xFF757575),
                size: 20,
              ),
          ],
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              SizedBox(
                width: 140,
                child: HealthCard(
                  icon: Icons.thermostat_outlined,
                  iconColor: isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
                  backgroundColor: isDark ? const Color(0xFF3E2723) : const Color(0xFFFFF3E0),
                  label: lang.tr('temperature'),
                  value: _temperature,
                  valueStyle: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 140,
                child: HealthCard(
                  icon: Icons.water_drop_outlined,
                  iconColor: isDark ? const Color(0xFF4FC3F7) : const Color(0xFF0277BD),
                  backgroundColor: isDark ? const Color(0xFF0D2D44) : const Color(0xFFE1F5FE),
                  label: lang.tr('humidity'),
                  value: _humidity,
                  valueStyle: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 140,
                child: HealthCard(
                  icon: _isDay
                      ? Icons.wb_sunny_outlined
                      : Icons.nights_stay_outlined,
                  iconColor: isDark ? const Color(0xFFFFD54F) : const Color(0xFFF57F17),
                  backgroundColor: isDark ? const Color(0xFF3E3623) : const Color(0xFFFFFDE7),
                  label: lang.tr('sky'),
                  value: _isDay ? lang.tr('sky_day') : lang.tr('sky_night'),
                  valueStyle: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
