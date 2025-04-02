import 'package:get/get.dart';
import 'package:flutter_ssh_client/app/data/models/ssh_session.dart';
import 'package:flutter_ssh_client/app/data/services/session_service.dart';
import 'package:flutter_ssh_client/app/routes/app_routes.dart';

class HomeController extends GetxController {
  final SessionService sessionService = Get.find<SessionService>();
  
  final sessions = <SSHSession>[].obs;
  final isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadSessions();
  }
  
  Future<void> loadSessions() async {
    try {
      isLoading.value = true;
      final loadedSessions = await sessionService.getSessions();
      sessions.value = loadedSessions;
    } catch (e) {
      // 处理错误
    } finally {
      isLoading.value = false;
    }
  }
  
  void openTerminal(SSHSession session) {
    Get.toNamed(Routes.TERMINAL, arguments: session);
  }
  
  void openSftp(SSHSession session) {
    Get.toNamed(Routes.SFTP, arguments: session);
  }
  
  void openSettings() {
    Get.toNamed(Routes.SETTINGS);
  }
  
  Future<void> deleteSession(String sessionId) async {
    try {
      await sessionService.deleteSession(sessionId);
      await loadSessions();
    } catch (e) {
      // 处理错误
    }
  }
} 