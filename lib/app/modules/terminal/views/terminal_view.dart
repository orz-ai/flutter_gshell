import 'package:flutter/material.dart';
import 'package:flutter_ssh_client/app/modules/terminal/views/terminal_view.dart';
import 'package:flutter_ssh_client/app/modules/terminal/views/terminal_view.dart';
import 'package:get/get.dart';
import 'package:xterm/xterm.dart' as xterm;
import 'package:flutter_ssh_client/app/modules/terminal/controllers/terminal_controller.dart';
import 'package:flutter_ssh_client/app/data/models/terminal_theme.dart';
import 'package:flutter_ssh_client/app/data/models/ssh_session.dart' as app;

class TerminalView extends StatefulWidget {
  const TerminalView({Key? key}) : super(key: key);

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> with TickerProviderStateMixin {
  TerminalController get controller => Get.find<TerminalController>();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _updateTabController();
    
    // 监听标签变化，更新 TabController
    controller.tabs.listen((_) {
      _updateTabController();
    });
    
    controller.activeTabIndex.listen((index) {
      if (_tabController != null && 
          index < _tabController!.length && 
          _tabController!.index != index) {
        _tabController!.animateTo(index);
      }
    });
  }
  
  void _updateTabController() {
    if (controller.tabs.isEmpty) return;
    
    _tabController = TabController(
      length: controller.tabs.length,
      vsync: this,
      initialIndex: controller.activeTabIndex.value < controller.tabs.length 
          ? controller.activeTabIndex.value 
          : 0,
    );
    
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        controller.activeTabIndex.value = _tabController!.index;
      }
    });
  }
  
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新建标签',
            onPressed: controller.addTab,
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            tooltip: '更改主题',
            onPressed: () => _showThemeSelector(context),
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: '清除终端',
            onPressed: controller.clearTerminal,
          ),
          Obx(() {
            final activeTab = controller.activeTabIndex.value < controller.tabs.length 
                ? controller.tabs[controller.activeTabIndex.value] 
                : null;
            
            return IconButton(
              icon: Icon(activeTab?.isConnected == true ? Icons.link_off : Icons.link),
              tooltip: activeTab?.isConnected == true ? '断开连接' : '连接',
              onPressed: activeTab?.isConnected == true 
                  ? controller.disconnect 
                  : () => _showConnectionDialog(context),
            );
          }),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Obx(() {
            if (controller.tabs.isEmpty) {
              return const SizedBox.shrink();
            }
            
            // 确保 _tabController 与当前标签数量匹配
            if (_tabController == null || _tabController!.length != controller.tabs.length) {
              _updateTabController();
            }
            
            return TabBar(
              isScrollable: true,
              controller: _tabController,
              tabs: controller.tabs.map((tab) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tab.title),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => controller.closeTab(controller.tabs.indexOf(tab)),
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ),
              )).toList(),
            );
          }),
        ),
      ),
      body: Obx(() {
        if (controller.tabs.isEmpty) {
          return const Center(child: Text('No terminals open'));
        }
        
        // 确保 _tabController 与当前标签数量匹配
        if (_tabController == null || _tabController!.length != controller.tabs.length) {
          _updateTabController();
        }
        
        return TabBarView(
          controller: _tabController,
          children: controller.tabs.map((tab) => TerminalWidget(
            terminal: tab.terminal,
            theme: controller.selectedTheme.value,
            onResize: controller.resizeTerminal,
          )).toList(),
        );
      }),
    );
  }
  
  void _showThemeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择终端主题'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: TerminalThemeData.presetThemes.length,
            itemBuilder: (context, index) {
              final theme = TerminalThemeData.presetThemes[index];
              return ListTile(
                title: Text(theme.name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: theme.background,
                  child: Center(
                    child: Text(
                      'A',
                      style: TextStyle(color: theme.foreground, fontSize: 16),
                    ),
                  ),
                ),
                onTap: () {
                  controller.changeTheme(theme);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showConnectionDialog(BuildContext context) {
    final hostController = TextEditingController();
    final portController = TextEditingController(text: '22');
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SSH 连接'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hostController,
                decoration: const InputDecoration(
                  labelText: '主机',
                  hintText: '例如: example.com 或 192.168.1.100',
                ),
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final host = hostController.text.trim();
              final port = int.tryParse(portController.text.trim()) ?? 22;
              final username = usernameController.text.trim();
              final password = passwordController.text;
              
              if (host.isEmpty || username.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('主机和用户名不能为空')),
                );
                return;
              }
              
              // 创建会话对象
              final session = app.SSHSession(
                id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                name: '$username@$host:$port',
                host: host,
                port: port,
                username: username,
                password: password,
                useKeyAuth: false,
              );
              
              // 关闭对话框
              Navigator.of(context).pop();
              
              // 连接到服务器
              controller.connect(session);
            },
            child: const Text('连接'),
          ),
        ],
      ),
    );
  }
}

class TerminalWidget extends StatefulWidget {
  final xterm.Terminal terminal;
  final TerminalThemeData theme;
  final Function(int, int) onResize;

  const TerminalWidget({
    Key? key,
    required this.terminal,
    required this.theme,
    required this.onResize,
  }) : super(key: key);

  @override
  State<TerminalWidget> createState() => _TerminalWidgetState();
}

class _TerminalWidgetState extends State<TerminalWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.theme.background,
      child: xterm.TerminalView(
        widget.terminal,
        autoResize: true,
      ),
    );
  }
  
  @override
  void initState() {
    super.initState();
    
    // 在下一帧调用 onResize，以确保终端已经布局完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 假设终端的初始大小为 80x24
      widget.onResize(80, 24);
    });
  }
} 