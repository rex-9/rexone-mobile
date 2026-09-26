class ApiResponse<T> {
  final int statusCode;
  final bool success;
  final String message;
  final String? error;
  final T? data;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    this.error,
    this.data,
    this.meta,
  });

  factory ApiResponse.success({
    required String message,
    required int statusCode,
    T? data,
    Map<String, dynamic>? meta,
  }) = SuccessApiResponse<T>;

  factory ApiResponse.error({
    required String message,
    required int statusCode,
    T? data,
    String? error,
    Map<String, dynamic>? meta,
  }) = ErrorApiResponse<T>;
}

class SuccessApiResponse<T> extends ApiResponse<T> {
  const SuccessApiResponse({
    required super.message,
    required super.statusCode,
    super.data,
    super.meta,
  }) : super(success: true, error: null);
}

class ErrorApiResponse<T> extends ApiResponse<T> {
  const ErrorApiResponse({
    required super.message,
    required super.statusCode,
    super.data,
    super.error,
    super.meta,
  }) : super(success: false);
}