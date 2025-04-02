import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_ssh_client/app/modules/sftp/controllers/sftp_controller.dart';
import 'package:flutter_ssh_client/app/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class SftpView extends GetView<SftpController> {
  const SftpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.currentSession.value?.name ?? 'SFTP')),
        actions: [
          Obx(() => IconButton(
            icon: Icon(controller.isConnected.value ? Icons.link_off : Icons.link),
            tooltip: controller.isConnected.value ? '断开连接' : '连接',
            onPressed: controller.isConnected.value 
                ? controller.disconnect 
                : () => Get.snackbar('功能开发中', '连接功能正在开发中'),
          )),
        ],
      ),
      body: Column(
        children: [
          // 路径导航栏
          Obx(() => Container(
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                const Icon(Icons.folder, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.currentPath.value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.listFiles,
                ),
              ],
            ),
          )),
          
          // 文件列表
          Expanded(
            child: Obx(() {
              if (controller.isConnecting.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (!controller.isConnected.value) {
                return const Center(
                  child: Text('未连接到服务器'),
                );
              }
              
              return ListView.builder(
                itemCount: controller.files.length,
                itemBuilder: (context, index) {
                  final file = controller.files[index];
                  return ListTile(
                    leading: Icon(
                      file['isDirectory'] ? Icons.folder : Icons.insert_drive_file,
                      color: file['isDirectory'] ? AppTheme.primaryColor : null,
                    ),
                    title: Text(file['name']),
                    subtitle: Text(
                      file['isDirectory'] 
                          ? '目录' 
                          : '${_formatFileSize(file['size'])} - ${DateFormat('yyyy-MM-dd HH:mm').format(file['modified'])}',
                    ),
                    onTap: () {
                      if (file['isDirectory']) {
                        controller.changeDirectory(file['name']);
                      } else {
                        // 处理文件点击
                        Get.snackbar('功能开发中', '文件操作功能正在开发中');
                      }
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() => controller.isConnected.value 
          ? FloatingActionButton(
              onPressed: () => Get.snackbar('功能开发中', '上传功能正在开发中'),
              child: const Icon(Icons.upload_file),
            )
          : const SizedBox.shrink()),
    );
  }
  
  String _formatFileSize(int size) {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
} 