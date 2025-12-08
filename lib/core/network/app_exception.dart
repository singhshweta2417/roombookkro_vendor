class AppException implements Exception {
  final String? message;
  final String? prefix;
  final int? statusCode;

  AppException([this.message, this.prefix, this.statusCode]);

  @override
  String toString() {
    final codeInfo = statusCode != null ? " (Code: $statusCode)" : "";
    final prefixText = prefix ?? "Error";
    final messageText = message ?? "Something went wrong";
    return "$prefixText$codeInfo: $messageText";
  }
  Map<String, dynamic> toJson() {
    return {
      "prefix": prefix,
      "message": message,
      "statusCode": statusCode,
    };
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message, int? code])
      : super(message, "Error During Communication", code);
}
class CreatedException extends AppException {
  CreatedException([String? message, int? code])
      : super(message, "Error During Communication", code);
}
class BadRequestException extends AppException {
  BadRequestException([String? message, int? code])
      : super(message, "Invalid Request", code);
}

class UnauthorisedException extends AppException {
  UnauthorisedException([String? message, int? code])
      : super(message, "Unauthorised Request", code);
}

class FetchNotFoundException extends AppException {
  FetchNotFoundException([String? message, int? code])
      : super(message, "Page Not Found", code);
}

class NotFoundException extends AppException {
  NotFoundException([String? message, int? code])
      : super(message, "Resource Not Found", code);
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message, int? code])
      : super(message, "Invalid Input", code);
}

class ServerException extends AppException {
  ServerException([String? message, int? code])
      : super(message, "Internal Server Error", code);
}

