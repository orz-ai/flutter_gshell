import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gshell/app/modules/sftp/controllers/sftp_controller.dart';
import 'package:flutter_gshell/app/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class SftpView extends GetView<SftpController> {
  const SftpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.currentSession.value?.name ?? 'SFTP')),
        elevation: 0,
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.isConnected.value ? Icons.link_off : Icons.link,
              color: controller.isConnected.value ? AppTheme.primaryColor : null,
            ),
            tooltip: controller.isConnected.value ? '断开连接' : '连接',
            onPressed: controller.isConnected.value 
                ? controller.disconnect 
                : () => Get.snackbar(
                    '功能开发中',
                    '连接功能正在开发中',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 8,
                  ),
          )),
        ],
      ),
      body: Column(
        children: [
          // 路径导航栏
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.currentPath.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_outlined),
                  tooltip: '刷新',
                  onPressed: controller.listFiles,
                ),
              ],
            ),
          )),
          
          // 文件列表
          Expanded(
            child: Obx(() {
              if (controller.isConnecting.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '连接中...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }
              
              if (!controller.isConnected.value) {
                return Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? AppTheme.primaryColor.withOpacity(0.1) 
                                : AppTheme.primaryColor.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.folder_outlined,
                            size: 64,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          '文件传输',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '未连接到服务器',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '请先建立 SSH 连接，然后使用 SFTP 功能传输文件',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: controller.files.length,
                itemBuilder: (context, index) {
                  final file = controller.files[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: file['isDirectory'] 
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : AppTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          file['isDirectory'] 
                              ? Icons.folder_outlined 
                              : Icons.insert_drive_file_outlined,
                          color: file['isDirectory'] 
                              ? AppTheme.primaryColor 
                              : AppTheme.secondaryColor,
                        ),
                      ),
                      title: Text(
                        file['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        file['isDirectory'] 
                            ? '目录' 
                            : '${_formatFileSize(file['size'])} - ${DateFormat('yyyy-MM-dd HH:mm').format(file['modified'])}',
                      ),
                      trailing: file['isDirectory'] 
                          ? null 
                          : IconButton(
                              icon: const Icon(Icons.download_outlined),
                              tooltip: '下载',
                              onPressed: () => Get.snackbar(
                                '功能开发中',
                                '下载功能正在开发中',
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 8,
                              ),
                            ),
                      onTap: () {
                        if (file['isDirectory']) {
                          controller.changeDirectory(file['name']);
                        } else {
                          // 处理文件点击
                          Get.snackbar(
                            '功能开发中',
                            '文件操作功能正在开发中',
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 8,
                          );
                        }
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() => controller.isConnected.value 
          ? FloatingActionButton.extended(
              onPressed: () => Get.snackbar(
                '功能开发中',
                '上传功能正在开发中',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 8,
              ),
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('上传文件'),
              backgroundColor: AppTheme.primaryColor,
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