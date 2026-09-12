import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rates_model.dart';

const String _kSetupDoneKey = 'rates_setup_done';

class RatesProvider extends ChangeNotifier {
  RatesModel _rates = RatesModel(); // defaults
  bool _isSetupDone = false;
  bool _isLoading = true;
  String _currencySymbol = 'Rs';

  RatesModel get rates => _rates;
  bool get isSetupDone => _isSetupDone;
  bool get isLoading => _isLoading;
  String get currencySymbol => _currencySymbol;

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadRates() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      _isSetupDone = prefs.getBool(_kSetupDoneKey) ?? false;
      _currencySymbol = prefs.getString('currency_symbol') ?? 'Rs';

      if (_isSetupDone) {
        // Build map from all stored keys
        final Map<String, double> stored = {};
        for (final key in _rates.toPrefsMap().keys) {
          final val = prefs.getDouble(key);
          if (val != null) stored[key] = val;
        }
        _rates = RatesModel.fromPrefsMap(stored);
      }
    } catch (e) {
      debugPrint('RatesProvider load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> saveRates(RatesModel rates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final entry in rates.toPrefsMap().entries) {
        await prefs.setDouble(entry.key, entry.value);
      }
      await prefs.setBool(_kSetupDoneKey, true);
      _rates = rates;
      _isSetupDone = true;
      notifyListeners();
    } catch (e) {
      debugPrint('RatesProvider save error: $e');
    }
  }

  // ── Currency Format ───────────────────────────────────────────────────────

  Future<void> setCurrencySymbol(String symbol) async {
    if (_currencySymbol == symbol) return;
    _currencySymbol = symbol;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency_symbol', symbol);
    } catch (e) {
      debugPrint('RatesProvider setCurrencySymbol error: $e');
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  Future<void> resetToDefaults() async {
    // Update UI immediately — don't wait for the async storage writes.
    _rates = RatesModel.zero();
    _currencySymbol = 'Rs';
    _isSetupDone = true;
    notifyListeners();

    // Persist the default values in the background.
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final entry in _rates.toPrefsMap().entries) {
        await prefs.setDouble(entry.key, entry.value);
      }
      await prefs.setString('currency_symbol', 'Rs');
      await prefs.setBool(_kSetupDoneKey, true);
    } catch (e) {
      debugPrint('RatesProvider reset error: $e');
    }
  }
}
