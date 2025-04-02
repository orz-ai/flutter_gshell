import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ssh_client/app/core/utils/logger.dart';
import 'package:flutter_ssh_client/app/data/models/ssh_session.dart';

class SessionService {
  static const String _sessionsKey = 'ssh_sessions';
  static const String _secureStoragePrefix = 'ssh_session_';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  Future<List<SSHSession>> getSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList(_sessionsKey) ?? [];
      
      final List<SSHSession> sessions = [];
      for (final sessionJson in sessionsJson) {
        final sessionData = json.decode(sessionJson);
        final String id = sessionData['id'];
        
        // 从安全存储中获取敏感信息
        final password = await _secureStorage.read(key: '${_secureStoragePrefix}${id}_password');
        final privateKey = await _secureStorage.read(key: '${_secureStoragePrefix}${id}_privateKey');
        final passphrase = await _secureStorage.read(key: '${_secureStoragePrefix}${id}_passphrase');
        
        sessionData['password'] = password;
        sessionData['privateKey'] = privateKey;
        sessionData['passphrase'] = passphrase;
        
        sessions.add(SSHSession.fromJson(sessionData));
      }
      
      return sessions;
    } catch (e) {
      LoggerUtil.e('Error loading sessions', e);
      return [];
    }
  }
  
  Future<void> saveSession(SSHSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessions = await getSessions();
      
      // 检查是否已存在相同ID的会话
      final existingIndex = sessions.indexWhere((s) => s.id == session.id);
      if (existingIndex >= 0) {
        sessions[existingIndex] = session;
      } else {
        sessions.add(session);
      }
      
      // 保存敏感信息到安全存储
      if (session.password != null) {
        await _secureStorage.write(
          key: '${_secureStoragePrefix}${session.id}_password',
          value: session.password,
        );
      }
      
      if (session.privateKey != null) {
        await _secureStorage.write(
          key: '${_secureStoragePrefix}${session.id}_privateKey',
          value: session.privateKey,
        );
      }
      
      if (session.passphrase != null) {
        await _secureStorage.write(
          key: '${_secureStoragePrefix}${session.id}_passphrase',
          value: session.passphrase,
        );
      }
      
      // 移除敏感信息后保存会话元数据
      final sessionWithoutSensitiveData = session.copyWith(
        password: null,
        privateKey: null,
        passphrase: null,
      );
      
      final sessionsJson = sessions.map((s) {
        if (s.id == session.id) {
          return json.encode(sessionWithoutSensitiveData.toJson());
        } else {
          return json.encode(s.copyWith(
            password: null,
            privateKey: null,
            passphrase: null,
          ).toJson());
        }
      }).toList();
      
      await prefs.setStringList(_sessionsKey, sessionsJson);
      LoggerUtil.i('Session saved: ${session.name}');
    } catch (e) {
      LoggerUtil.e('Error saving session', e);
      rethrow;
    }
  }
  
  Future<void> deleteSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessions = await getSessions();
      
      final filteredSessions = sessions.where((s) => s.id != sessionId).toList();
      
      // 从安全存储中删除敏感信息
      await _secureStorage.delete(key: '${_secureStoragePrefix}${sessionId}_password');
      await _secureStorage.delete(key: '${_secureStoragePrefix}${sessionId}_privateKey');
      await _secureStorage.delete(key: '${_secureStoragePrefix}${sessionId}_passphrase');
      
      final sessionsJson = filteredSessions.map((s) => json.encode(s.copyWith(
        password: null,
        privateKey: null,
        passphrase: null,
      ).toJson())).toList();
      
      await prefs.setStringList(_sessionsKey, sessionsJson);
      LoggerUtil.i('Session deleted: $sessionId');
    } catch (e) {
      LoggerUtil.e('Error deleting session', e);
      rethrow;
    }
  }
} 