import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_ssh_client/app/data/models/ssh_session.dart';
import 'package:flutter_ssh_client/app/data/services/session_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SessionFormDialog extends StatefulWidget {
  final SSHSession? session;
  final Function(SSHSession) onSave;

  const SessionFormDialog({
    Key? key,
    this.session,
    required this.onSave,
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
    } else {
      // 默认端口
      _portController.text = '22';
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
    return AlertDialog(
      title: Text(widget.session == null ? '添加新会话' : '编辑会话'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '会话名称',
                  hintText: '例如：开发服务器',
                  prefixIcon: Icon(Icons.label),
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
                  hintText: '例如：192.168.1.100 或 example.com',
                  prefixIcon: Icon(Icons.computer),
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
                  hintText: '例如：22',
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
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  hintText: '例如：root',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('使用密钥认证'),
                value: _useKeyAuth,
                onChanged: (value) {
                  setState(() {
                    _useKeyAuth = value;
                  });
                },
              ),
              if (!_useKeyAuth) ...[
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '密码',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: !_showPassword,
                  validator: (value) {
                    if (_useKeyAuth) return null;
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    return null;
                  },
                ),
              ] else ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _privateKeyPath ?? (_privateKeyContent != null ? '已加载密钥' : '未选择密钥文件'),
                        style: TextStyle(
                          color: _privateKeyContent != null ? Colors.green : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('选择密钥'),
                      onPressed: _pickPrivateKey,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passphraseController,
                  decoration: InputDecoration(
                    labelText: '密钥口令（如果有）',
                    prefixIcon: const Icon(Icons.vpn_key),
                    suffixIcon: IconButton(
                      icon: Icon(_showPassphrase ? Icons.visibility_off : Icons.visibility),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveSession,
          child: const Text('保存'),
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
      Get.snackbar('错误', '无法读取密钥文件: $e');
    }
  }
  
  void _saveSession() {
    if (_formKey.currentState!.validate()) {
      // 如果使用密钥认证，但没有选择密钥
      if (_useKeyAuth && _privateKeyContent == null) {
        Get.snackbar('错误', '请选择密钥文件');
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
      );
      
      widget.onSave(session);
      Navigator.of(context).pop();
    }
  }
} 