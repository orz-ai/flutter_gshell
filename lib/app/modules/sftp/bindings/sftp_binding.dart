import 'package:get/get.dart';
import 'package:flutter_ssh_client/app/data/services/ssh_service.dart';
import 'package:flutter_ssh_client/app/modules/sftp/controllers/sftp_controller.dart';

class SftpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SSHService>(() => SSHService());
    Get.lazyPut<SftpController>(() => SftpController());
  }
} 