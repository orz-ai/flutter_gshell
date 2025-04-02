import 'package:get/get.dart';
import 'package:flutter_gshell/app/modules/settings/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
} 