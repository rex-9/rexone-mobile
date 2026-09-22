/// Request keys for client log payloads sent to RexOne Core.
class LogKeys {
  const LogKeys._();

  static const message = 'message';
  static const severity = 'severity';
  static const platform = 'platform';
  static const environment = 'environment';
  static const appVersion = 'app_version';
  static const os = 'os';
  static const osVersion = 'os_version';
  static const device = 'device';
  static const url = 'url';
  static const method = 'method';
  static const stackTrace = 'stack_trace';
  static const localStorageKeys = 'local_storage_keys';
  static const context = 'context';
}
