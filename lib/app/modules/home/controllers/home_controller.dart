import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_gshell/app/data/models/ssh_session.dart';
import 'package:flutter_gshell/app/data/services/session_service.dart';
import 'package:flutter_gshell/app/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeController extends GetxController {
  final SessionService sessionService = Get.find<SessionService>();
  
  final sessions = <SSHSession>[].obs;
  final isLoading = false.obs;
  final selectedSession = Rxn<SSHSession>();
  final groups = <String>[].obs;
  final expandedGroups = <String>{}.obs;
  
  // 当前选中的会话ID
  final selectedSessionId = RxnString();
  
  // 当前选中的分组
  final selectedGroup = RxnString();
  
  // 右侧内容区域显示的内容类型
  final contentType = Rx<ContentType>(ContentType.welcome);
  
  @override
  void onInit() {
    super.onInit();
    loadSessions();
    loadGroups();
  }
  
  Future<void> loadSessions() async {
    try {
      isLoading.value = true;
      final loadedSessions = await sessionService.getSessions();
      sessions.value = loadedSessions;
      
      // 提取所有分组
      final groupSet = <String>{};
      for (final session in loadedSessions) {
        if (session.group != null && session.group!.isNotEmpty) {
          groupSet.add(session.group!);
        }
      }
      groups.value = groupSet.toList()..sort();
      
    } catch (e) {
      // 处理错误
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expandedGroupsJson = prefs.getStringList('expanded_groups') ?? [];
      
      final expandedGroupsSet = <String>{};
      for (final group in expandedGroupsJson) {
        expandedGroupsSet.add(group);
      }
      
      expandedGroups.value = expandedGroupsSet;
    } catch (e) {
      // 处理错误
    }
  }
  
  Future<void> saveExpandedGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('expanded_groups', expandedGroups.toList());
    } catch (e) {
      // 处理错误
    }
  }
  
  void toggleGroupExpansion(String group) {
    if (expandedGroups.contains(group)) {
      expandedGroups.remove(group);
    } else {
      expandedGroups.add(group);
    }
    saveExpandedGroups();
  }
  
  void selectSession(SSHSession session) {
    selectedSessionId.value = session.id;
    selectedSession.value = session;
    contentType.value = ContentType.sessionDetail;
  }
  
  void selectGroup(String group) {
    selectedGroup.value = group;
    selectedSessionId.value = null;
    contentType.value = ContentType.groupDetail;
  }
  
  void clearSelection() {
    selectedSessionId.value = null;
    selectedGroup.value = null;
    contentType.value = ContentType.welcome;
  }
  
  void openTerminal(SSHSession session) {
    Get.toNamed(Routes.TERMINAL, arguments: session);
  }
  
  void openSftp(SSHSession session) {
    Get.toNamed(Routes.SFTP, arguments: session);
  }
  
  void openSettings() {
    Get.toNamed(Routes.SETTINGS);
  }
  
  Future<void> deleteSession(String sessionId) async {
    try {
      await sessionService.deleteSession(sessionId);
      
      // 如果删除的是当前选中的会话，清除选择
      if (selectedSessionId.value == sessionId) {
        clearSelection();
      }
      
      await loadSessions();
    } catch (e) {
      // 处理错误
    }
  }
  
  Future<void> addGroup(String groupName) async {
    if (groups.contains(groupName)) {
      Get.snackbar(
        '错误',
        '分组 "$groupName" 已存在',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return;
    }
    
    groups.add(groupName);
    groups.sort();
    
    // 默认展开新添加的分组
    expandedGroups.add(groupName);
    saveExpandedGroups();
    
    Get.snackbar(
      '成功',
      '分组 "$groupName" 已添加',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
  
  Future<void> deleteGroup(String groupName) async {
    try {
      // 将该分组下的所有会话移到未分组
      final sessionsInGroup = sessions.where((s) => s.group == groupName).toList();
      for (final session in sessionsInGroup) {
        final updatedSession = session.copyWith(group: null);
        await sessionService.saveSession(updatedSession);
      }
      
      // 从分组列表中移除
      groups.remove(groupName);
      expandedGroups.remove(groupName);
      saveExpandedGroups();
      
      // 如果删除的是当前选中的分组，清除选择
      if (selectedGroup.value == groupName) {
        clearSelection();
      }
      
      await loadSessions();
      
      Get.snackbar(
        '成功',
        '分组 "$groupName" 已删除',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '删除分组失败: $e',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }
  
  Future<void> moveSessionToGroup(SSHSession session, String? groupName) async {
    try {
      final updatedSession = session.copyWith(group: groupName);
      await sessionService.saveSession(updatedSession);
      await loadSessions();
      
      Get.snackbar(
        '成功',
        '会话已移动到${groupName ?? '未分组'}',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '移动会话失败: $e',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }
}

enum ContentType {
  welcome,
  sessionDetail,
  groupDetail,
} 