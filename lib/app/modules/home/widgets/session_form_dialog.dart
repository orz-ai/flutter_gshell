import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_gshell/app/data/models/ssh_session.dart';
import 'package:flutter_gshell/app/data/services/session_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gshell/app/core/theme/app_theme.dart';
import 'package:flutter_gshell/app/modules/home/controllers/home_controller.dart';
import 'dart:io';

class SessionFormDialog extends StatefulWidget {
  final SSHSession? session;
  final Function(SSHSession) onSave;
  final String? initialGroup;

  const SessionFormDialog({
    Key? key,
    this.session,
    required this.onSave,
    this.initialGroup,
  }) : super(key: key);

  @override
  State<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<SessionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passphraseController = TextEditingController();
  
  bool _useKeyAuth = false;
  String? _privateKeyPath;
  String? _privateKeyContent;
  bool _showPassword = false;
  bool _showPassphrase = false;
  String? _selectedGroup;
  
  final HomeController _homeController = Get.find<HomeController>();
  
  @override
  void initState() {
    super.initState();
    
    // 如果是编辑模式，填充表单
    if (widget.session != null) {
      _nameController.text = widget.session!.name;
      _hostController.text = widget.session!.host;
      _portController.text = widget.session!.port.toString();
      _usernameController.text = widget.session!.username;
      _passwordController.text = widget.session!.password ?? '';
      _passphraseController.text = widget.session!.passphrase ?? '';
      _useKeyAuth = widget.session!.useKeyAuth;
      _privateKeyContent = widget.session!.privateKey;
      _selectedGroup = widget.session!.group;
      
      if (_privateKeyContent != null && _privateKeyContent!.isNotEmpty) {
        _privateKeyPath = '已加载密钥';
      }
    } else {
      // 默认端口
      _portController.text = '22';
      // 如果有初始分组，设置选中
      _selectedGroup = widget.initialGroup;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      title: Text(
        widget.session == null ? '添加新会话' : '编辑会话',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 基本信息
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppTheme.primaryColor.withOpacity(0.05) 
                      : AppTheme.primaryColor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark 
                        ? AppTheme.primaryColor.withOpacity(0.1) 
                        : AppTheme.primaryColor.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '基本信息',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '会话名称',
                        hintText: '例如：开发服务器',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入会话名称';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        labelText: '主机地址',
                        hintText: '例如: example.com 或 192.168.1.100',
                        prefixIcon: Icon(Icons.computer_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入主机地址';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _portController,
                      decoration: const InputDecoration(
                        labelText: '端口',
                        prefixIcon: Icon(Icons.settings_ethernet),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入端口';
                        }
                        final port = int.tryParse(value);
                        if (port == null || port <= 0 || port > 65535) {
                          return '端口必须是1-65535之间的数字';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // 分组选择
                    DropdownButtonFormField<String?>(
                      value: _selectedGroup,
                      decoration: const InputDecoration(
                        labelText: '分组',
                        prefixIcon: Icon(Icons.folder_outlined),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('未分组'),
                        ),
                        ..._homeController.groups.map((group) => DropdownMenuItem<String?>(
                          value: group,
                          child: Text(group),
                        )).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGroup = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 认证信息
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppTheme.secondaryColor.withOpacity(0.05) 
                      : AppTheme.secondaryColor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark 
                        ? AppTheme.secondaryColor.withOpacity(0.1) 
                        : AppTheme.secondaryColor.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '认证信息',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入用户名';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // 认证方式选择
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('密码认证'),
                            value: false,
                            groupValue: _useKeyAuth,
                            onChanged: (value) {
                              setState(() {
                                _useKeyAuth = value!;
                              });
                            },
                            activeColor: AppTheme.secondaryColor,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('密钥认证'),
                            value: true,
                            groupValue: _useKeyAuth,
                            onChanged: (value) {
                              setState(() {
                                _useKeyAuth = value!;
                              });
                            },
                            activeColor: AppTheme.secondaryColor,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 根据认证方式显示不同的输入框
                    if (!_useKeyAuth) ...[
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: '密码',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: !_showPassword,
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: '私钥文件',
                                hintText: '选择私钥文件',
                                prefixIcon: const Icon(Icons.key_outlined),
                                suffixText: _privateKeyPath,
                              ),
                              validator: (value) {
                                if (_useKeyAuth && _privateKeyContent == null) {
                                  return '请选择私钥文件';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.upload_file_outlined, size: 18),
                            label: const Text('选择'),
                            onPressed: _pickPrivateKey,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              backgroundColor: AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passphraseController,
                        decoration: InputDecoration(
                          labelText: '密钥密码（如果有）',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassphrase ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassphrase = !_showPassphrase;
                              });
                            },
                          ),
                        ),
                        obscureText: !_showPassphrase,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('保存'),
          onPressed: _saveSession,
        ),
      ],
    );
  }
  
  Future<void> _pickPrivateKey() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        if (file.path != null) {
          final content = await File(file.path!).readAsString();
          setState(() {
            _privateKeyPath = file.name;
            _privateKeyContent = content;
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '无法读取密钥文件: $e',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error_outline, color: AppTheme.errorColor),
      );
    }
  }
  
  void _saveSession() {
    if (_formKey.currentState!.validate()) {
      // 如果使用密钥认证，但没有选择密钥
      if (_useKeyAuth && _privateKeyContent == null) {
        Get.snackbar(
          '错误',
          '请选择密钥文件',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.error_outline, color: AppTheme.errorColor),
        );
        return;
      }
      
      final session = SSHSession(
        id: widget.session?.id ?? const Uuid().v4(),
        name: _nameController.text,
        host: _hostController.text,
        port: int.parse(_portController.text),
        username: _usernameController.text,
        password: _useKeyAuth ? null : _passwordController.text,
        privateKey: _useKeyAuth ? _privateKeyContent : null,
        passphrase: _useKeyAuth ? _passphraseController.text : null,
        useKeyAuth: _useKeyAuth,
        group: _selectedGroup,
      );
      
      widget.onSave(session);
      Navigator.of(context).pop();
    }
  }
} 