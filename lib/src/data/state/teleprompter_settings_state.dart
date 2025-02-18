import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teleprompter/src/shared/app_logger.dart';

mixin TeleprompterSettingsState {
  static const int indexOpacity = 0;
  static const int indexSpeed = 1;
  static const int indexTextSize = 2;

  static const String settingsOpacity = 'SETTINGS_OPACITY';
  static const String settingsSpeed = 'SETTINGS_SPEED';
  static const String settingsTextSize = 'SETTINGS_TEXT_SIZE';
  static const String settingsTextColor = 'SETTINGS_TEXT_COLOR';

  static const Map<int, double> step = {
    indexOpacity: 0.05,
    indexSpeed: 1,
    indexTextSize: 1,
  };

  static const Map<int, double> minValue = {
    indexOpacity: 0,
    indexSpeed: 1,
    indexTextSize: 1,
  };

  static const Map<int, double> maxValue = {
    indexOpacity: 1.0,
    indexSpeed: 100.0,
    indexTextSize: 80.0,
  };

  double _opacity = 0.7;
  double _speedFactor = 5;
  double _textSize = 14;
  Color _textColor = Colors.greenAccent;

  Future<void> loadSettings(BuildContext context, Color defaultTextColor) async {
    _textColor = defaultTextColor;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Speed
    final double? prefSpeed = prefs.getDouble(settingsSpeed);
    if (prefSpeed != null) {
      _speedFactor = prefSpeed;
    }

    // Opacity
    final double? prefOpacity = prefs.getDouble(settingsOpacity);
    if (prefOpacity != null) {
      _opacity = prefOpacity;
    }

    // Text size
    final double? prefTextSize = prefs.getDouble(settingsTextSize);
    if (prefTextSize != null) {
      _textSize = prefTextSize;
    }

    // Text color
    final int? prefTextColor = prefs.getInt(settingsTextColor);
    if (prefTextColor != null) {
      _textColor = Color(prefTextColor);
    }
  }

  double getOpacity() => min(1, max(0.25, _opacity));

  double getSpeedFactor() => _speedFactor;

  double getTextSize() => _textSize;

  Color getTextColor() => _textColor;

  Future<void> setTextColor(Color color) async {
    _textColor = color;
    int floatToInt8(double x) => (x * 255.0).round() & 0xff;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(settingsTextColor, floatToInt8(color.a) << 24 | floatToInt8(color.r) << 16 | floatToInt8(color.g) << 8 | floatToInt8(color.b) << 0);
  }

  double getValueForIndex(int index) {
    switch (index) {
      case indexOpacity:
        return _opacity;
      case indexSpeed:
        return _speedFactor;
      case indexTextSize:
        return _textSize;
      default:
        return -1;
    }
  }

  double minValueForIndex(int index) => minValue[index]!;

  double maxValueForIndex(int index) => maxValue[index]!;

  Future<void> setStepValueForIndex(int index, double step) async {
    switch (index) {
      case indexOpacity:
        _opacity += step;
        _opacity = double.parse(_opacity.toStringAsFixed(2));
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setDouble(settingsOpacity, _opacity);
        break;
      case indexSpeed:
        _speedFactor += step.toInt();
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setDouble(settingsSpeed, _speedFactor);
        break;
      case indexTextSize:
        _textSize += step;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setDouble(settingsTextSize, _textSize);
        break;
      default:
        AppLogger().debug('unable to set index $index');
    }
  }

  Map<int, double> getSteps() => step;
}
