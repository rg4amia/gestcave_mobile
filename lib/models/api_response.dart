class ApiResponse<T> {
  final T? data;
  final Map<String, List<String>>? errors;
  final String? message;
  final bool success;

  ApiResponse({this.data, this.errors, this.message, required this.success});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromData,
  }) {
    return ApiResponse<T>(
      data: fromData != null && json['data'] != null
          ? fromData(json['data'])
          : null,
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map((k, v) => MapEntry(k, List<String>.from(v))),
            )
          : null,
      message: json['message'] as String?,
      success: json['success'] ?? (json['errors'] == null),
    );
  }
}
