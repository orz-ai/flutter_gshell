import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xterm/xterm.dart' as xterm;
import 'package:flutter_gshell/app/modules/terminal/controllers/terminal_controller.dart';
import 'package:flutter_gshell/app/data/models/terminal_theme.dart';
import 'package:flutter_gshell/app/data/models/ssh_session.dart' as app;
import 'package:flutter_gshell/app/core/theme/app_theme.dart';

class TerminalView extends StatefulWidget {
  const TerminalView({Key? key}) : super(key: key);

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> with TickerProviderStateMixin {
  TerminalController get controller => Get.find<TerminalController>();
  TabController? _tabController;
  final isDark = Get.isDarkMode;

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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新建标签',
            onPressed: controller.addTab,
          ),
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
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
              icon: Icon(
                activeTab?.isConnected == true 
                    ? Icons.link_off 
                    : Icons.link,
                color: activeTab?.isConnected == true 
                    ? AppTheme.primaryColor 
                    : null,
              ),
              tooltip: activeTab?.isConnected == true ? '断开连接' : '连接',
              onPressed: activeTab?.isConnected == true 
                  ? controller.disconnect 
                  : () => _showConnectionDialog(context),
            );
          }),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(() {
            if (controller.tabs.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: controller.tabs.map((tab) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.isConnected ? Icons.terminal : Icons.terminal_outlined,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(tab.title),
                        const SizedBox(width: 8),
                        if (controller.tabs.length > 1)
                          InkWell(
                            onTap: () => controller.closeTab(tab.id as int),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ),
      ),
      body: Obx(() {
        if (controller.tabs.isEmpty) {
          return Center(
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
                    Icons.terminal,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '没有打开的终端',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '点击下方按钮创建新的终端会话',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('新建终端'),
                  onPressed: controller.addTab,
                ),
              ],
            ),
          );
        }
        
        return TabBarView(
          controller: _tabController,
          children: controller.tabs.map((tab) {
            return TerminalWidget(
              terminal: tab.terminal,
              theme: controller.selectedTheme.value,
              onResize: (width, height) {
                if (tab.session != null) {
                  tab.session!.resizeTerminal(width, height);
                }
              },
            );
          }).toList(),
        );
      }),
    );
  }
  
  void _showThemeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择终端主题'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: TerminalThemeData.presetThemes.length,
            itemBuilder: (context, index) {
              final theme = TerminalThemeData.presetThemes[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  controller.changeTheme(theme);
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: theme.foreground,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  prefixIcon: Icon(Icons.computer_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: portController,
                decoration: const InputDecoration(
                  labelText: '端口',
                  prefixIcon: Icon(Icons.settings_ethernet),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: '密码',
                  prefixIcon: Icon(Icons.lock_outline),
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
                  margin: const EdgeInsets.all(16),
                  borderRadius: 8,
                  icon: const Icon(Icons.error_outline, color: AppTheme.errorColor),
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