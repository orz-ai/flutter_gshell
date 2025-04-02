import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final isDarkMode = false.obs;
  final fontSize = 14.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }
  
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 加载主题设置
    final themeMode = prefs.getString('theme_mode') ?? 'system';
    if (themeMode == 'dark') {
      isDarkMode.value = true;
    } else if (themeMode == 'light') {
      isDarkMode.value = false;
    } else {
      // 系统主题
      final brightness = Get.mediaQuery.platformBrightness;
      isDarkMode.value = brightness == Brightness.dark;
    }
    
    // 加载字体大小
    fontSize.value = prefs.getDouble('font_size') ?? 14.0;
  }
  
  Future<void> setDarkMode(bool value) async {
    isDarkMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', value ? 'dark' : 'light');
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
  
  Future<void> setFontSize(double value) async {
    fontSize.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', value);
  }
  
  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('theme_mode');
    await prefs.remove('font_size');
    
    // 重新加载设置
    await loadSettings();
  }
} 