import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_ssh_client/app/modules/home/controllers/home_controller.dart';
import 'package:flutter_ssh_client/app/data/models/ssh_session.dart';
import 'package:flutter_ssh_client/app/core/theme/app_theme.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_ssh_client/app/modules/home/widgets/session_form_dialog.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSH Client'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: controller.openSettings,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  MdiIcons.serverNetworkOff,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '没有保存的会话',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('创建新会话'),
                  onPressed: () => _showAddSessionDialog(context),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.sessions.length,
          itemBuilder: (context, index) {
            final session = controller.sessions[index];
            return _buildSessionCard(context, session);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSessionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildSessionCard(BuildContext context, SSHSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => controller.openTerminal(session),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    MdiIcons.server,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'terminal':
                          controller.openTerminal(session);
                          break;
                        case 'sftp':
                          controller.openSftp(session);
                          break;
                        case 'edit':
                          _showEditSessionDialog(context, session);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context, session);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'terminal',
                        child: Row(
                          children: [
                            Icon(Icons.terminal),
                            SizedBox(width: 8),
                            Text('打开终端'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'sftp',
                        child: Row(
                          children: [
                            Icon(Icons.folder),
                            SizedBox(width: 8),
                            Text('打开SFTP'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('编辑'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('删除', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${session.username}@${session.host}:${session.port}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.terminal),
                      label: const Text('终端'),
                      onPressed: () => controller.openTerminal(session),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.folder),
                      label: const Text('SFTP'),
                      onPressed: () => controller.openSftp(session),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showAddSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SessionFormDialog(
        onSave: (session) async {
          try {
            await controller.sessionService.saveSession(session);
            await controller.loadSessions();
            Get.snackbar('成功', '会话已保存');
          } catch (e) {
            Get.snackbar('错误', '保存会话失败: $e');
          }
        },
      ),
    );
  }
  
  void _showEditSessionDialog(BuildContext context, SSHSession session) {
    showDialog(
      context: context,
      builder: (context) => SessionFormDialog(
        session: session,
        onSave: (updatedSession) async {
          try {
            await controller.sessionService.saveSession(updatedSession);
            await controller.loadSessions();
            Get.snackbar('成功', '会话已更新');
          } catch (e) {
            Get.snackbar('错误', '更新会话失败: $e');
          }
        },
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, SSHSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除会话'),
        content: Text('确定要删除会话 "${session.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteSession(session.id);
              Navigator.of(context).pop();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 