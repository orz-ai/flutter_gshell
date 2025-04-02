import 'package:get/get.dart';
import 'package:flutter_ssh_client/app/data/models/ssh_session.dart';
import 'package:flutter_ssh_client/app/data/services/ssh_service.dart';

class SftpController extends GetxController {
  final SSHService _sshService = Get.find<SSHService>();
  
  final isConnected = false.obs;
  final isConnecting = false.obs;
  final currentSession = Rxn<SSHSession>();
  final currentPath = ''.obs;
  final files = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // 检查是否有传入的会话
    if (Get.arguments is SSHSession) {
      final session = Get.arguments as SSHSession;
      connect(session);
    }
  }
  
  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
  
  Future<void> connect(SSHSession session) async {
    if (isConnecting.value) return;
    
    try {
      isConnecting.value = true;
      
      // 建立SSH连接
      await _sshService.connect(session);
      
      // 更新状态
      isConnected.value = true;
      currentSession.value = session;
      currentPath.value = '/';
      
      // 列出文件
      await listFiles();
    } catch (e) {
      // 处理错误
    } finally {
      isConnecting.value = false;
    }
  }
  
  Future<void> disconnect() async {
    if (!isConnected.value) return;
    
    try {
      await _sshService.disconnect();
      
      isConnected.value = false;
      currentSession.value = null;
      files.clear();
    } catch (e) {
      // 处理错误
    }
  }
  
  Future<void> listFiles() async {
    if (!isConnected.value) return;
    
    try {
      // 这里应该使用SFTP来列出文件
      // 但现在我们只是使用一个示例
      files.value = [
        {'name': '..', 'isDirectory': true, 'size': 0, 'modified': DateTime.now()},
        {'name': 'Documents', 'isDirectory': true, 'size': 0, 'modified': DateTime.now()},
        {'name': 'Downloads', 'isDirectory': true, 'size': 0, 'modified': DateTime.now()},
        {'name': 'Pictures', 'isDirectory': true, 'size': 0, 'modified': DateTime.now()},
        {'name': 'example.txt', 'isDirectory': false, 'size': 1024, 'modified': DateTime.now()},
        {'name': 'readme.md', 'isDirectory': false, 'size': 2048, 'modified': DateTime.now()},
      ];
    } catch (e) {
      // 处理错误
    }
  }
  
  Future<void> changeDirectory(String path) async {
    if (!isConnected.value) return;
    
    try {
      // 这里应该使用SFTP来更改目录
      // 但现在我们只是更新路径
      if (path == '..') {
        final parts = currentPath.value.split('/');
        if (parts.length > 1) {
          parts.removeLast();
          currentPath.value = parts.join('/');
          if (currentPath.value.isEmpty) {
            currentPath.value = '/';
          }
        }
      } else if (path.startsWith('/')) {
        currentPath.value = path;
      } else {
        if (currentPath.value.endsWith('/')) {
          currentPath.value = '${currentPath.value}$path';
        } else {
          currentPath.value = '${currentPath.value}/$path';
        }
      }
      
      await listFiles();
    } catch (e) {
      // 处理错误
    }
  }
} 