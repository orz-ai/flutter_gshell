import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xterm/xterm.dart' as xterm;
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_ssh_client/app/core/utils/logger.dart';
import 'package:flutter_ssh_client/app/data/models/ssh_session.dart' as app;
import 'package:flutter_ssh_client/app/data/models/terminal_theme.dart';
import 'package:flutter_ssh_client/app/data/services/ssh_service.dart';

class TerminalTab {
  final String id;
  String title;
  final xterm.Terminal terminal;
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
  
  final terminal = xterm.Terminal(maxLines: 10000).obs;
  final isConnected = false.obs;
  final isConnecting = false.obs;
  final currentSession = Rxn<app.SSHSession>();
  final selectedTheme = Rx<TerminalThemeData>(TerminalThemeData.presetThemes[0]);
  
  SSHSession? _session;
  StreamSubscription? _sessionSubscription;
  
  // 添加标签支持
  final tabs = <TerminalTab>[].obs;
  final activeTabIndex = 0.obs;


  
  @override
  void onInit() {
    super.onInit();
    _initTerminal();
    
    // 检查是否有传入的会话
    if (Get.arguments is app.SSHSession) {
      final session = Get.arguments as app.SSHSession;
      connect(session);
    }
    
    // 创建一个初始标签
    addTab();
  }
  
  @override
  void onClose() {
    _sessionSubscription?.cancel();
    disconnect();
    super.onClose();
  }
  
  void _initTerminal() {
    // 创建终端实例
    final term = xterm.Terminal(maxLines: 10000);
    
    // 设置终端输入处理
    term.onOutput = (data) {
      if (_session != null) {
        _session!.stdin.add(utf8.encode(data));
        return;
      }
    };
    
    terminal.value = term;
  }
  
  void changeTheme(TerminalThemeData theme) {
    selectedTheme.value = theme;
    
    // 创建新终端实例
    final newTerminal = xterm.Terminal(maxLines: 10000);
    
    // 设置终端输入处理
    newTerminal.onOutput = (data) {
      if (_session != null) {
        _session!.stdin.add(utf8.encode(data));
        return;
      }
    };
    
    // 复制历史内容 (简化版本)
    for (var i = 0; i < terminal.value.buffer.lines.length; i++) {
      final line = terminal.value.buffer.lines[i];
      if (line != null && line.toString().isNotEmpty) {
        newTerminal.write(line.toString() + '\r\n');
      }
    }
    
    terminal.value = newTerminal;
  }
  
  Future<void> connect(app.SSHSession session) async {
    if (tabs.isEmpty) {
      addTab();
    }
    
    final currentTab = tabs[activeTabIndex.value];
    
    if (currentTab.isConnected) {
      // 如果当前标签已连接，创建一个新标签
      addTab();
    }
    
    final tab = tabs[activeTabIndex.value];
    
    try {
      // 显示连接信息
      tab.terminal.write('Connecting to ${session.host}:${session.port} as ${session.username}...\r\n');
      
      // 建立SSH连接
      await _sshService.connect(session);
      
      // 启动Shell
      tab.session = await _sshService.startShell();
      
      // 处理Shell输出
      tab.subscription = tab.session!.stdout.listen((data) {
        tab.terminal.write(utf8.decode(data, allowMalformed: true));
      });
      
      tab.session!.stderr.listen((data) {
        tab.terminal.write(utf8.decode(data, allowMalformed: true));
      });
      
      // 设置终端输入处理
      tab.terminal.onOutput = (data) {
        if (tab.session != null) {
          tab.session!.stdin.add(utf8.encode(data));
          return;
        }
      };
      
      // 更新状态
      tab.isConnected = true;
      tab.title = session.name;
      
      // 更新标签列表以触发UI更新
      tabs.refresh();
      
      tab.terminal.write('Connected to ${session.host}\r\n');
    } catch (e) {
      tab.terminal.write('Connection failed: ${e.toString()}\r\n');
      LoggerUtil.e('Connection error', e);
    }
  }
  
  Future<void> disconnect() async {
    if (tabs.isEmpty) return;
    
    final tab = tabs[activeTabIndex.value];
    if (!tab.isConnected) return;
    
    try {
      tab.subscription?.cancel();
      tab.subscription = null;
      
      if (tab.session != null) {
        tab.session!.close();
        tab.session = null;
      }
      
      await _sshService.disconnect();
      
      tab.isConnected = false;
      tab.title = 'Terminal ${tabs.indexOf(tab) + 1}';
      
      // 更新标签列表以触发UI更新
      tabs.refresh();
      
      tab.terminal.write('Disconnected\r\n');
    } catch (e) {
      LoggerUtil.e('Disconnect error', e);
    }
  }
  
  void resizeTerminal(int cols, int rows) {
    if (tabs.isEmpty) return;
    
    final tab = tabs[activeTabIndex.value];
    if (tab.session != null) {
      tab.session!.resizeTerminal(cols, rows);
    }
  }
  
  void clearTerminal() {
    if (tabs.isEmpty) return;
    
    // 使用 ANSI 清屏序列
    tabs[activeTabIndex.value].terminal.write('\x1b[2J\x1b[H');
  }
  
  void addTab() {
    final term = xterm.Terminal(maxLines: 10000);
    final tab = TerminalTab(
      id: 'tab_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Terminal ${tabs.length + 1}',
      terminal: term,
    );
    
    tabs.add(tab);
    activeTabIndex.value = tabs.length - 1;
  }
  
  void closeTab(int index) {
    if (index < 0 || index >= tabs.length) return;
    
    final tab = tabs[index];
    
    // 断开连接
    if (tab.session != null) {
      tab.subscription?.cancel();
      tab.session?.close();
    }
    
    tabs.removeAt(index);
    
    // 如果关闭了所有标签，创建一个新标签
    if (tabs.isEmpty) {
      addTab();
    } else if (activeTabIndex.value >= tabs.length) {
      activeTabIndex.value = tabs.length - 1;
    }
  }
  
  void switchTab(int index) {
    if (index >= 0 && index < tabs.length) {
      activeTabIndex.value = index;
    }
  }
} 