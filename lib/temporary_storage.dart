import 'package:shared_preferences/shared_preferences.dart';

/// Abstract interface for the App Settings and user data.
abstract class IDataBase {
  /// Implementations can override this method to perform
  /// the necessary initialization and configuration.
  Future<void> init();

  /// Loads a setting from service, stored with `key` string.
  Future<T> get<T>(String key, T defaultValue);

  /// Save a setting to service, using `key` as its storage key.
  Future<void> set<T>(String key, T value);
}

class DataBasePrefs implements IDataBase {
  DataBasePrefs();

  late final SharedPreferences _prefs;

  @override
  Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  bool sameTypes<S, V>() {
    void func<X extends S>() {}
    return func is void Function<X extends V>();
  }

  @override
  Future<T> get<T>(String key, T defaultValue) async {
    Object? value;
    try {
      // List<String> is special, if not handled as this, then:
      // Error: type 'List<dynamic>' is not a subtype of type 'List<String>' in type cast
      if (sameTypes<T, List<String>>()) {
        value = _prefs.getStringList(key);
      } else {
        value = _prefs.get(key);
      }

      // значения ещё нет в бд
      if (value == null) {
        return defaultValue;
      }

      return value as T;
    } catch (e) {
      return defaultValue;
    }
  }

  @override
  Future<bool> set<T>(String key, T value) async {
    if (sameTypes<T, bool>()) {
      return _prefs.setBool(key, value as bool);
    }

    if (sameTypes<T, int>()) {
      return _prefs.setInt(key, value as int);
    }

    if (sameTypes<T, double>()) {
      return _prefs.setDouble(key, value as double);
    }

    if (sameTypes<T, String>()) {
      return _prefs.setString(key, value as String);
    }

    if (sameTypes<T, List<String>>()) {
      return _prefs.setStringList(key, value as List<String>);
    }

    if (value is Enum) {
      return _prefs.setInt(key, value.index);
    }

    throw Exception('Wrong type for saving to database');
  }
}

class KeyStore {
  KeyStore._();

  static const String useMaterial3 = 'useMaterial3';
  static const bool useMaterial3Default = true;

  static const String appLocale = 'appLocale';
  static const String appLocaleDefault = 'ru';

  static const String textScaleFactor = 'textScaleFactor';
  static const double textScaleFactorDefault = 1.1;
}
