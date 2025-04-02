import 'package:get/get.dart';
import 'package:flutter_gshell/app/data/services/ssh_service.dart';
import 'package:flutter_gshell/app/modules/terminal/controllers/terminal_controller.dart';

class TerminalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SSHService>(() => SSHService());
    Get.lazyPut<TerminalController>(() => TerminalController());
  }
} 