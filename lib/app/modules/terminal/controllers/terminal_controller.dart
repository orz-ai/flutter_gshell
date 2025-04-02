import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xterm/xterm.dart' as xterm;
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_gshell/app/core/utils/logger.dart';
import 'package:flutter_gshell/app/data/models/ssh_session.dart' as app;
import 'package:flutter_gshell/app/data/models/terminal_theme.dart';
import 'package:flutter_gshell/app/data/services/ssh_service.dart';

class TerminalTab {
  final String id;
  String title;
  xterm.Terminal terminal;
  SSHSession? session;
  StreamSubscription? subscription;
  bool isConnected = false;

  TerminalTab({
    required this.id,
    required this.title,
    required this.terminal,
    this.session,
  });
}

class TerminalController extends GetxController {
  final SSHService _sshService = Get.find<SSHService>();
  
  // 添加标签支持
  final tabs = <TerminalTab>[].obs;
  final activeTabIndex = 0.obs;
  
  // 终端主题
  final terminalTheme = Rx<TerminalThemeData>(TerminalThemeData.defaultTheme);
  
  // 添加 selectedTheme 属性，用于在设置中选择主题
  final selectedTheme = Rx<TerminalThemeData>(TerminalThemeData.defaultTheme);
  
  @override
  void onInit() {
    super.onInit();
    
    // 检查是否有传入的会话
    if (Get.arguments is app.SSHSession) {
      final session = Get.arguments as app.SSHSession;
      // 不要在这里添加默认标签，而是直接连接传入的会话
      connect(session);
    } else {
      // 只有在没有传入会话时才添加默认标签
      addTab();
    }
    
    // 监听主题变化
    selectedTheme.listen((theme) {
      terminalTheme.value = theme;
      // 应用主题到所有终端
      applyThemeToTerminals();
    });
  }
  
  @override
  void onClose() {
    // 关闭所有标签页
    for (final tab in tabs) {
      tab.subscription?.cancel();
      tab.session?.close();
    }
    super.onClose();
  }
  
  void addTab() {
    final terminal = xterm.Terminal(
      maxLines: 10000,
    );
    
    final tab = TerminalTab(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '终端 ${tabs.length + 1}',
      terminal: terminal,
    );
    
    tabs.add(tab);
    activeTabIndex.value = tabs.length - 1;
  }
  
  void closeTab(int tabId) {
    final index = tabs.indexWhere((tab) => tab.id == tabId.toString());
    if (index == -1) return;
    
    final tab = tabs[index];
    tab.subscription?.cancel();
    tab.session?.close();
    
    tabs.removeAt(index);
    
    // 如果关闭的是当前活动标签，切换到前一个标签
    if (tabs.isEmpty) {
      addTab();
    } else if (activeTabIndex.value >= tabs.length) {
      activeTabIndex.value = tabs.length - 1;
    }
  }
  
  void setActiveTab(int index) {
    if (index >= 0 && index < tabs.length) {
      activeTabIndex.value = index;
    }
  }
  
  void clearTerminal() {
    if (tabs.isEmpty) return;
    
    final tab = tabs[activeTabIndex.value];
    // 使用 ANSI 清屏序列来清除终端内容
    tab.terminal.write('\x1b[2J\x1b[H');
  }
  
  void setTerminalTheme(TerminalThemeData theme) {
    selectedTheme.value = theme;
  }
  
  // 添加 changeTheme 方法，作为 setTerminalTheme 的别名
  void changeTheme(TerminalThemeData theme) {
    setTerminalTheme(theme);
  }
  
  // 添加断开连接方法
  void disconnect() {
    if (tabs.isEmpty) return;
    
    final tab = tabs[activeTabIndex.value];
    if (!tab.isConnected) return;
    
    // 取消订阅
    tab.subscription?.cancel();
    
    // 关闭会话
    tab.session?.close();
    
    // 更新状态
    tab.isConnected = false;
    tab.session = null;
    
    // 在终端中显示断开连接信息
    tab.terminal.write('\r\n已断开连接\r\n');
    
    // 更新标签标题
    tab.title = '终端 ${activeTabIndex.value + 1}';
  }
  
  void applyThemeToTerminals() {
    // 更新所有终端的主题
    for (final tab in tabs) {
      // 在实际应用中，这里应该使用 xterm 库提供的方法来设置主题
      // 由于 xterm 库可能没有直接的方法来更新主题，这里只是一个示例
      // 实际实现可能需要根据 xterm 库的 API 来调整
      final theme = terminalTheme.value;
      
      // 这里可能需要创建一个新的终端实例并复制内容
      // 或者使用 xterm 库提供的方法来更新主题
    }
  }
  
  Future<void> connect(app.SSHSession session) async {
    try {
      // 如果没有标签页，先添加一个
      if (tabs.isEmpty) {
        addTab();
      }
      
      final currentTab = tabs[activeTabIndex.value];
      
      // 如果当前标签已连接，创建一个新标签
      if (currentTab.isConnected) {
        addTab();
      }
      
      final tab = tabs[activeTabIndex.value];
      tab.title = session.name;
      tab.terminal.write('正在连接到 ${session.host}:${session.port}...\r\n');
      
      // 连接到SSH服务器
      final client = await _sshService.connect(session);
      final shell = await _sshService.startShell();
      
      // 设置终端大小
      shell.resizeTerminal(80, 24);
      
      // 将shell输出重定向到终端
      tab.subscription = shell.stdout.listen((data) {
        tab.terminal.write(utf8.decode(data));
      });
      
      // 设置终端输入回调
      tab.terminal.onOutput = (data) {
        shell.stdin.add(utf8.encode(data));
      };
      
      tab.session = shell;
      tab.isConnected = true;
      
      tab.terminal.write('\r\n连接成功！\r\n\n');
    } catch (e) {
      LoggerUtil.e('SSH连接失败', e);
      
      final tab = tabs[activeTabIndex.value];
      tab.terminal.write('\r\n连接失败: $e\r\n');
      tab.isConnected = false;
    }
  }
  
  void showQuickConnect() {
    final hostController = TextEditingController();
    final portController = TextEditingController(text: '22');
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('快速连接'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hostController,
              decoration: const InputDecoration(
                labelText: '主机',
                hintText: '例如: example.com 或 192.168.1.100',
              ),
              autofocus: true,
            ),
            TextField(
              controller: portController,
              decoration: const InputDecoration(
                labelText: '端口',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: '用户名',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: '密码',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final host = hostController.text.trim();
              final port = int.tryParse(portController.text.trim()) ?? 22;
              final username = usernameController.text.trim();
              final password = passwordController.text;
              
              if (host.isEmpty || username.isEmpty) {
                Get.snackbar(
                  '错误',
                  '主机和用户名不能为空',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              
              final session = app.SSHSession(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: '$username@$host',
                host: host,
                port: port,
                username: username,
                password: password,
                useKeyAuth: false,
              );
              
              Get.back();
              connect(session);
            },
            child: const Text('连接'),
          ),
        ],
      ),
    );
  }
} 