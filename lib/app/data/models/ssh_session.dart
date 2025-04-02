class SSHSession {
  final String id;
  final String name;
  final String host;
  final int port;
  final String username;
  final String? password;
  final String? privateKey;
  final String? passphrase;
  final bool useKeyAuth;
  final String? group;
  final Map<String, dynamic>? extraOptions;
  
  SSHSession({
    required this.id,
    required this.name,
    required this.host,
    this.port = 22,
    required this.username,
    this.password,
    this.privateKey,
    this.passphrase,
    this.useKeyAuth = false,
    this.group,
    this.extraOptions,
  });
  
  factory SSHSession.fromJson(Map<String, dynamic> json) {
    return SSHSession(
      id: json['id'],
      name: json['name'],
      host: json['host'],
      port: json['port'] ?? 22,
      username: json['username'],
      password: json['password'],
      privateKey: json['privateKey'],
      passphrase: json['passphrase'],
      useKeyAuth: json['useKeyAuth'] ?? false,
      group: json['group'],
      extraOptions: json['extraOptions'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'host': host,
      'port': port,
      'username': username,
      'password': password,
      'privateKey': privateKey,
      'passphrase': passphrase,
      'useKeyAuth': useKeyAuth,
      'group': group,
      'extraOptions': extraOptions,
    };
  }
  
  SSHSession copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    String? username,
    String? password,
    String? privateKey,
    String? passphrase,
    bool? useKeyAuth,
    String? group,
    Map<String, dynamic>? extraOptions,
  }) {
    return SSHSession(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      privateKey: privateKey ?? this.privateKey,
      passphrase: passphrase ?? this.passphrase,
      useKeyAuth: useKeyAuth ?? this.useKeyAuth,
      group: group ?? this.group,
      extraOptions: extraOptions ?? this.extraOptions,
    );
  }
} 