import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gshell/app/modules/settings/controllers/settings_controller.dart';
import 'package:flutter_gshell/app/core/theme/app_theme.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // 外观设置
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.palette_outlined,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '外观设置',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Divider(),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                  title: const Text('深色模式'),
                  subtitle: const Text('启用深色主题'),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: controller.isDarkMode.value 
                          ? AppTheme.accentColor.withOpacity(0.1)
                          : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      controller.isDarkMode.value 
                          ? Icons.dark_mode_outlined 
                          : Icons.light_mode_outlined,
                      color: controller.isDarkMode.value 
                          ? AppTheme.accentColor 
                          : AppTheme.primaryColor,
                    ),
                  ),
                  value: controller.isDarkMode.value,
                  onChanged: controller.setDarkMode,
                )),
                const Divider(indent: 72, endIndent: 16),
                ListTile(
                  title: const Text('字体大小'),
                  subtitle: Obx(() => Text('${controller.fontSize.value.toInt()} px')),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.text_fields_outlined,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  trailing: SizedBox(
                    width: 200,
                    child: Obx(() => Slider(
                      value: controller.fontSize.value,
                      min: 10,
                      max: 20,
                      divisions: 10,
                      label: controller.fontSize.value.toInt().toString(),
                      activeColor: AppTheme.secondaryColor,
                      onChanged: controller.setFontSize,
                    )),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 关于
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '关于',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Divider(),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? AppTheme.primaryColor.withOpacity(0.1) 
                              : AppTheme.primaryColor.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.terminal,
                          size: 32,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GShell',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '版本 1.0.0',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'GShell 是一款功能强大的 SSH 客户端，支持终端和文件传输功能，为开发者和系统管理员提供高效的远程服务器管理工具。',
                    style: TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('开源许可'),
                    onPressed: () => Get.snackbar(
                      '功能开发中',
                      '许可证查看功能正在开发中',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 重置设置
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.restore_outlined,
                    color: AppTheme.errorColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '重置',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Divider(),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.restore_outlined,
                  color: AppTheme.errorColor,
                ),
              ),
              title: const Text('重置设置'),
              subtitle: const Text('将所有设置恢复为默认值'),
              onTap: () => _showResetConfirmation(context),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置设置'),
        content: const Text('确定要将所有设置恢复为默认值吗？'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.resetSettings();
              Navigator.of(context).pop();
              Get.snackbar(
                '已重置',
                '所有设置已恢复为默认值',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 8,
                icon: const Icon(Icons.check_circle_outline, color: AppTheme.successColor),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('重置'),
          ),
        ],
      ),
    );
  }
} 