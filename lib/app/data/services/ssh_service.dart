import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_gshell/app/core/utils/logger.dart';
import 'package:flutter_gshell/app/data/models/ssh_session.dart' as app;

class SSHService {
  SSHClient? _client;
  app.SSHSession? _currentSession;
  
  bool get isConnected => _client != null && !_client!.isClosed;
  app.SSHSession? get currentSession => _currentSession;
  
  Future<SSHClient> connect(app.SSHSession session) async {
    try {
      LoggerUtil.i('Connecting to ${session.host}:${session.port} as ${session.username}');
      
      // 关闭现有连接
      await disconnect();
      
      // 准备认证方法
      dynamic auth;
      if (session.useKeyAuth && session.privateKey != null) {
        final keyPair = SSHKeyPair.fromPem(session.privateKey!);
        auth = keyPair;
      } else if (session.password != null) {
        auth = session.password;
      } else {
        throw Exception('No authentication method provided');
      }
      
      // 建立连接
      final socket = await SSHSocket.connect(session.host, session.port);
      _client = SSHClient(
        socket,
        username: session.username,
        onPasswordRequest: () => auth is String ? auth : null,
        identities: auth is SSHKeyPair ? [auth] : [],
      );
      
      _currentSession = session;
      LoggerUtil.i('Connected to ${session.host}');
      return _client!;
    } catch (e) {
      LoggerUtil.e('SSH connection error', e);
      rethrow;
    }
  }
  
  Future<void> disconnect() async {
    if (_client != null && !_client!.isClosed) {
      _client!.close();
      _client = null;
      _currentSession = null;
      LoggerUtil.i('SSH connection closed');
    }
  }
  
  Future<app.SSHSession> testConnection(app.SSHSession session) async {
    SSHClient? testClient;
    try {
      // 准备认证方法
      dynamic auth;
      if (session.useKeyAuth && session.privateKey != null) {
        final keyPair = SSHKeyPair.fromPem(session.privateKey!);
        auth = keyPair;
      } else if (session.password != null) {
        auth = session.password;
      } else {
        throw Exception('No authentication method provided');
      }
      
      // 建立测试连接
      final socket = await SSHSocket.connect(session.host, session.port);
      testClient = SSHClient(
        socket,
        username: session.username,
        onPasswordRequest: () => auth is String ? auth : null,
        identities: auth is SSHKeyPair ? [auth] : [],
      );
      
      // 执行简单命令验证连接
      final result = await testClient.run('echo "Connection test successful"');
      final output = utf8.decode(result);
      
      LoggerUtil.i('Connection test result: $output');
      return session;
    } catch (e) {
      LoggerUtil.e('Connection test failed', e);
      rethrow;
    } finally {
      if (testClient != null && !testClient.isClosed) {
        testClient.close();
      }
    }
  }
  
  Future<SSHSession> startShell() async {
    if (_client == null || _client!.isClosed) {
      throw Exception('Not connected to SSH server');
    }
    
    try {
      final shell = await _client!.shell();
      
      LoggerUtil.i('Shell started');
      return shell;
    } catch (e) {
      LoggerUtil.e('Failed to start shell', e);
      rethrow;
    }
  }
  
  Future<List<int>> executeCommand(String command) async {
    if (_client == null || _client!.isClosed) {
      throw Exception('Not connected to SSH server');
    }
    
    try {
      LoggerUtil.i('Executing command: $command');
      final result = await _client!.run(command);
      return result;
    } catch (e) {
      LoggerUtil.e('Command execution failed', e);
      rethrow;
    }
  }
} 