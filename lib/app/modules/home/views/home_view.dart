import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gshell/app/modules/home/controllers/home_controller.dart';
import 'package:flutter_gshell/app/data/models/ssh_session.dart';
import 'package:flutter_gshell/app/core/theme/app_theme.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_gshell/app/modules/home/widgets/session_form_dialog.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;
    
    // 侧边栏宽度根据屏幕大小调整
    final sidebarWidth = isLargeScreen ? 280.0 : (isMediumScreen ? 240.0 : 220.0);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('GShell'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '设置',
            onPressed: controller.openSettings,
          ),
        ],
      ),
      body: Row(
        children: [
          // 侧边栏
          Container(
            width: sidebarWidth,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              border: Border(
                right: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // 侧边栏顶部操作区
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '会话管理',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: '添加会话',
                        onPressed: () => _showAddSessionDialog(context),
                        color: AppTheme.primaryColor,
                        iconSize: 22,
                      ),
                      IconButton(
                        icon: const Icon(Icons.folder_outlined),
                        tooltip: '添加分组',
                        onPressed: () => _showAddGroupDialog(context),
                        color: AppTheme.secondaryColor,
                        iconSize: 22,
                      ),
                    ],
                  ),
                ),
                
                // 会话列表
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      );
                    }
                    
                    if (controller.sessions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              MdiIcons.serverNetwork,
                              size: 48,
                              color: isDark ? Colors.white38 : Colors.black26,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '没有保存的会话',
                              style: TextStyle(
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('添加会话'),
                              onPressed: () => _showAddSessionDialog(context),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // 分组会话
                    final Map<String, List<SSHSession>> groupedSessions = {};
                    final List<SSHSession> ungroupedSessions = [];
                    
                    // 将会话分组
                    for (final session in controller.sessions) {
                      final group = session.group ?? '';
                      if (group.isEmpty) {
                        ungroupedSessions.add(session);
                      } else {
                        if (!groupedSessions.containsKey(group)) {
                          groupedSessions[group] = [];
                        }
                        groupedSessions[group]!.add(session);
                      }
                    }
                    
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // 未分组会话
                        if (ungroupedSessions.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              '未分组',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          ...ungroupedSessions.map((session) => _buildSessionTile(context, session)),
                        ],
                        
                        // 分组会话
                        ...groupedSessions.entries.map((entry) {
                          return _buildGroupExpansionTile(context, entry.key, entry.value);
                        }),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          
          // 主内容区 - 欢迎页或会话详情
          Expanded(
            child: Obx(() {
              if (controller.selectedSession.value == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? AppTheme.primaryColor.withOpacity(0.1) 
                              : AppTheme.primaryColor.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          MdiIcons.console,
                          size: 64,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        '欢迎使用 GShell',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 500,
                        child: Text(
                          '从左侧选择一个会话连接，或者创建一个新的会话。',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('新建会话'),
                            onPressed: () => _showAddSessionDialog(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            icon: Icon(Icons.help_outline, 
                              size: 18,
                              color: isDark ? AppTheme.primaryColor : const Color(0xFF64748B),
                            ),
                            label: Text('查看帮助', 
                              style: TextStyle(
                                color: isDark ? AppTheme.primaryColor : const Color(0xFF64748B),
                              ),
                            ),
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              side: BorderSide(
                                color: isDark 
                                    ? AppTheme.primaryColor.withOpacity(0.5) 
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                // 显示会话详情
                final session = controller.selectedSession.value!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 会话详情头部
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surfaceDark : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? AppTheme.primaryColor.withOpacity(0.1) 
                                  : AppTheme.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              MdiIcons.serverNetwork,
                              color: AppTheme.primaryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${session.username}@${session.host}:${session.port}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('编辑'),
                                onPressed: () => _showEditSessionDialog(context, session),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.terminal, size: 18),
                                label: const Text('连接'),
                                onPressed: () => controller.openTerminal(session),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // 会话详情内容
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '连接选项',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                _buildConnectionOptionCard(
                                  context,
                                  icon: Icons.terminal,
                                  title: '终端',
                                  description: '打开 SSH 终端连接',
                                  onTap: () => controller.openTerminal(session),
                                ),
                                const SizedBox(width: 16),
                                _buildConnectionOptionCard(
                                  context,
                                  icon: MdiIcons.folderNetwork,
                                  title: 'SFTP',
                                  description: '文件传输',
                                  onTap: () => controller.openSftp(session),
                                ),
                                const SizedBox(width: 16),
                                _buildConnectionOptionCard(
                                  context,
                                  icon: MdiIcons.console,
                                  title: '端口转发',
                                  description: '设置 SSH 隧道',
                                  onTap: () => Get.snackbar(
                                    '功能开发中',
                                    '端口转发功能正在开发中',
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(16),
                                    borderRadius: 8,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            }),
          ),
        ],
      ),
    );
  }
  
  // 构建会话列表项
  Widget _buildSessionTile(BuildContext context, SSHSession session) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = controller.selectedSession.value?.id == session.id;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.2)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          MdiIcons.serverNetwork,
          color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white70 : const Color(0xFF64748B)),
          size: 20,
        ),
      ),
      title: Text(
        session.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected 
              ? AppTheme.primaryColor 
              : (isDark ? Colors.white : const Color(0xFF334155)),
        ),
      ),
      subtitle: Text(
        '${session.username}@${session.host}',
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white54 : const Color(0xFF64748B),
        ),
      ),
      selected: isSelected,
      selectedTileColor: isDark 
          ? AppTheme.primaryColor.withOpacity(0.1) 
          : AppTheme.primaryColor.withOpacity(0.05),
      onTap: () => controller.selectSession(session),
      trailing: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          color: isDark ? Colors.white54 : const Color(0xFF64748B),
        ),
        onSelected: (value) {
          switch (value) {
            case 'edit':
              _showEditSessionDialog(context, session);
              break;
            case 'terminal':
              controller.openTerminal(session);
              break;
            case 'sftp':
              controller.openSftp(session);
              break;
            case 'delete':
              _showDeleteConfirmation(context, session);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18),
                SizedBox(width: 8),
                Text('编辑'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'terminal',
            child: Row(
              children: [
                Icon(Icons.terminal, size: 18),
                SizedBox(width: 8),
                Text('终端'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'sftp',
            child: Row(
              children: [
                Icon(Icons.folder_outlined, size: 18),
                SizedBox(width: 8),
                Text('SFTP'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: AppTheme.errorColor),
                SizedBox(width: 8),
                Text('删除', style: TextStyle(color: AppTheme.errorColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建分组展开项
  Widget _buildGroupExpansionTile(BuildContext context, String groupName, List<SSHSession> sessions) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ExpansionTile(
      title: Text(
        groupName,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF334155),
        ),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.folder_outlined,
          color: isDark ? Colors.white70 : const Color(0xFF64748B),
          size: 20,
        ),
      ),
      childrenPadding: const EdgeInsets.only(left: 16),
      initiallyExpanded: true,
      children: sessions.map((session) => _buildSessionTile(context, session)).toList(),
    );
  }
  
  // 构建连接选项卡片
  Widget _buildConnectionOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppTheme.primaryColor.withOpacity(0.1) 
                      : AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 显示添加会话对话框
  void _showAddSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SessionFormDialog(
        onSave: (session) async {
          try {
            await controller.sessionService.saveSession(session);
            await controller.loadSessions();
            Get.snackbar(
              '成功',
              '会话已添加',
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
              icon: const Icon(Icons.check_circle_outline, color: AppTheme.successColor),
            );
          } catch (e) {
            Get.snackbar(
              '错误',
              '添加会话失败: $e',
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
              icon: const Icon(Icons.error_outline, color: AppTheme.errorColor),
            );
          }
        },
      ),
    );
  }
  
  // 显示编辑会话对话框
  void _showEditSessionDialog(BuildContext context, SSHSession session) {
    showDialog(
      context: context,
      builder: (context) => SessionFormDialog(
        session: session,
        onSave: (updatedSession) async {
          try {
            await controller.sessionService.saveSession(updatedSession);
            await controller.loadSessions();
            Get.snackbar(
              '成功',
              '会话已更新',
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
              icon: const Icon(Icons.check_circle_outline, color: AppTheme.successColor),
            );
          } catch (e) {
            Get.snackbar(
              '错误',
              '更新会话失败: $e',
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
              icon: const Icon(Icons.error_outline, color: AppTheme.errorColor),
            );
          }
        },
      ),
    );
  }
  
  // 显示添加分组对话框
  void _showAddGroupDialog(BuildContext context) {
    final textController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加分组'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: '分组名称',
            hintText: '输入分组名称',
            prefixIcon: Icon(Icons.folder_outlined),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消', style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            )),
          ),
          ElevatedButton(
            onPressed: () {
              final groupName = textController.text.trim();
              if (groupName.isNotEmpty) {
                controller.addGroup(groupName);
                Navigator.of(context).pop();
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
  
  // 显示删除确认对话框
  void _showDeleteConfirmation(BuildContext context, SSHSession session) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除会话'),
        content: Text('确定要删除会话 "${session.name}" 吗？'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消', style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            )),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteSession(session.id);
              Navigator.of(context).pop();
              Get.snackbar(
                '已删除',
                '会话已成功删除',
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
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
} 