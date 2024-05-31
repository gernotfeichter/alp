// to make LogRecords serializable
import 'package:logging/logging.dart';

extension Jsonify on LogRecord {
  static LogRecord fromJson(Map<String, dynamic> json) {
    return LogRecord(Level.LEVELS.firstWhere( (l) => l.toString() == json["level"]), json["message"], "");
  }
  toJson() {
    return {
      "level": level.toString(),
      "message": message,
    };
  }
}