import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_ssh_client/app/modules/settings/controllers/settings_controller.dart';
import 'package:flutter_ssh_client/app/core/theme/app_theme.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 外观设置
          const ListTile(
            title: Text('外观设置'),
            subtitle: Text('自定义应用的外观'),
            leading: Icon(Icons.palette, color: AppTheme.primaryColor),
          ),
          Obx(() => SwitchListTile(
            title: const Text('深色模式'),
            subtitle: const Text('启用深色主题'),
            value: controller.isDarkMode.value,
            onChanged: controller.setDarkMode,
          )),
          ListTile(
            title: const Text('字体大小'),
            subtitle: Obx(() => Text('${controller.fontSize.value.toInt()} px')),
            trailing: SizedBox(
              width: 200,
              child: Obx(() => Slider(
                value: controller.fontSize.value,
                min: 10,
                max: 20,
                divisions: 10,
                label: controller.fontSize.value.toInt().toString(),
                onChanged: controller.setFontSize,
              )),
            ),
          ),
          
          const Divider(),
          
          // 关于
          const ListTile(
            title: Text('关于'),
            subtitle: Text('应用信息'),
            leading: Icon(Icons.info, color: AppTheme.primaryColor),
          ),
          ListTile(
            title: const Text('版本'),
            subtitle: const Text('1.0.0'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('开源许可'),
            subtitle: const Text('查看第三方库许可信息'),
            onTap: () {},
          ),
          
          const Divider(),
          
          // 重置设置
          ListTile(
            title: const Text('重置设置'),
            subtitle: const Text('将所有设置恢复为默认值'),
            leading: const Icon(Icons.restore, color: AppTheme.errorColor),
            onTap: () => _showResetConfirmation(context),
          ),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              controller.resetSettings();
              Navigator.of(context).pop();
              Get.snackbar('已重置', '所有设置已恢复为默认值');
            },
            child: const Text('重置'),
          ),
        ],
      ),
    );
  }
} 