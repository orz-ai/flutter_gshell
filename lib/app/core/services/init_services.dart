import 'package:get/get.dart';
import 'package:flutter_ssh_client/app/data/services/ssh_service.dart';
import 'package:flutter_ssh_client/app/data/services/session_service.dart';

class InitServices {
  static Future<void> init() async {
    // 注册全局服务
    Get.lazyPut<SSHService>(() => SSHService(), fenix: true);
    Get.lazyPut<SessionService>(() => SessionService(), fenix: true);
  }
} 