import 'package:get/get.dart';
import 'package:flutter_gshell/app/data/services/session_service.dart';
import 'package:flutter_gshell/app/modules/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SessionService>(() => SessionService());
    Get.lazyPut<HomeController>(() => HomeController());
  }
} 