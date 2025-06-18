import 'dart:convert';

class SyncQueue {
  final int id;
  final String action; // create, update, delete
  final String entity; // product, transaction, category
  final Map<String, dynamic> data;

  SyncQueue({
    required this.id,
    required this.action,
    required this.entity,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'entity': entity,
      'data': jsonEncode(data),
    };
  }

  factory SyncQueue.fromJson(Map<String, dynamic> json) {
    return SyncQueue(
      id: json['id'],
      action: json['action'],
      entity: json['entity'],
      data: jsonDecode(json['data']),
    );
  }
}
