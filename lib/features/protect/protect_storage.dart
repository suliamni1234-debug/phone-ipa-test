import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BlockedNumber {
  final String number;
  final String? name;
  final int addedAt;

  const BlockedNumber({
    required this.number,
    this.name,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'number': number,
        if (name != null) 'name': name,
        'addedAt': addedAt,
      };

  factory BlockedNumber.fromJson(Map<String, dynamic> j) => BlockedNumber(
        number: j['number'] as String,
        name: j['name'] as String?,
        addedAt: (j['addedAt'] as num?)?.toInt() ?? 0,
      );
}

class ProtectSettings {
  final bool blockSpam;
  final bool blockScam;
  final bool silenceUnknown;
  final bool intlSpamFilter;

  const ProtectSettings({
    required this.blockSpam,
    required this.blockScam,
    required this.silenceUnknown,
    required this.intlSpamFilter,
  });

  static const defaults = ProtectSettings(
    blockSpam: true,
    blockScam: true,
    silenceUnknown: false,
    intlSpamFilter: false,
  );

  ProtectSettings copyWith({
    bool? blockSpam,
    bool? blockScam,
    bool? silenceUnknown,
    bool? intlSpamFilter,
  }) =>
      ProtectSettings(
        blockSpam: blockSpam ?? this.blockSpam,
        blockScam: blockScam ?? this.blockScam,
        silenceUnknown: silenceUnknown ?? this.silenceUnknown,
        intlSpamFilter: intlSpamFilter ?? this.intlSpamFilter,
      );

  Map<String, dynamic> toJson() => {
        'blockSpam': blockSpam,
        'blockScam': blockScam,
        'silenceUnknown': silenceUnknown,
        'intlSpamFilter': intlSpamFilter,
      };
}

class ProtectStorage {
  static const _kBlockSpam = 'protect_block_spam';
  static const _kBlockScam = 'protect_block_scam';
  static const _kSilenceUnknown = 'protect_silence_unknown';
  static const _kIntlSpam = 'protect_intl_spam';
  static const _kBlockList = 'protect_block_list';
  static const _kBlockedCount = 'protect_blocked_count';

  final SharedPreferences _prefs;
  ProtectStorage(this._prefs);

  static Future<ProtectStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ProtectStorage(prefs);
  }

  ProtectSettings readSettings() {
    return ProtectSettings(
      blockSpam: _prefs.getBool(_kBlockSpam) ?? ProtectSettings.defaults.blockSpam,
      blockScam: _prefs.getBool(_kBlockScam) ?? ProtectSettings.defaults.blockScam,
      silenceUnknown:
          _prefs.getBool(_kSilenceUnknown) ?? ProtectSettings.defaults.silenceUnknown,
      intlSpamFilter:
          _prefs.getBool(_kIntlSpam) ?? ProtectSettings.defaults.intlSpamFilter,
    );
  }

  Future<void> writeSettings(ProtectSettings s) async {
    await _prefs.setBool(_kBlockSpam, s.blockSpam);
    await _prefs.setBool(_kBlockScam, s.blockScam);
    await _prefs.setBool(_kSilenceUnknown, s.silenceUnknown);
    await _prefs.setBool(_kIntlSpam, s.intlSpamFilter);
  }

  List<BlockedNumber> readBlockList() {
    final raw = _prefs.getString(_kBlockList);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(BlockedNumber.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> writeBlockList(List<BlockedNumber> list) async {
    final raw = jsonEncode(list.map((e) => e.toJson()).toList());
    await _prefs.setString(_kBlockList, raw);
  }

  int readBlockedCount() => _prefs.getInt(_kBlockedCount) ?? 0;

  Future<void> writeBlockedCount(int count) async {
    await _prefs.setInt(_kBlockedCount, count);
  }
}
