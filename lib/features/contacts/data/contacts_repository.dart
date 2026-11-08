import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../core/network/api_client.dart';

class ContactsRepository {
  final ApiClient _api;
  ContactsRepository(this._api);

  // Pull every contact from the device and ship them in one batch.
  // Returns the count uploaded, or throws on failure.
  Future<int> uploadDeviceContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      throw Exception('Contacts permission not granted');
    }
    final all = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );
    final payload = <Map<String, String?>>[];
    for (final c in all) {
      final name = c.displayName.trim();
      for (final p in c.phones) {
        final number = p.number.trim();
        if (number.isEmpty) continue;
        payload.add({'name': name.isEmpty ? null : name, 'phone': number});
      }
    }
    if (payload.isEmpty) return 0;

    final r = await _api.dio.post('/contacts/sync', data: {'contacts': payload});
    if (r.statusCode != 200) {
      throw Exception('Sync failed (${r.statusCode})');
    }
    final data = r.data;
    if (data is Map && data['inserted_or_updated'] is num) {
      return (data['inserted_or_updated'] as num).toInt();
    }
    return payload.length;
  }

  Future<LookupResult> lookup(String phone) async {
    final r = await _api.dio.get('/lookup', queryParameters: {'phone': phone});
    if (r.statusCode == 200 && r.data is Map) {
      return LookupResult.ok(Map<String, dynamic>.from(r.data as Map));
    }
    if (r.statusCode == 429 && r.data is Map) {
      final m = Map<String, dynamic>.from(r.data as Map);
      return LookupResult.quotaExceeded(
        message: (m['message'] as String?) ?? 'Daily search limit reached',
        quota: (m['quota'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
    }
    throw Exception('Lookup failed (${r.statusCode}): ${r.data}');
  }

  Future<Map<String, dynamic>?> quotaStatus() async {
    final r = await _api.dio.get('/quota/searches');
    if (r.statusCode == 200 && r.data is Map) {
      return Map<String, dynamic>.from(r.data as Map);
    }
    return null;
  }

  // Search by name. Returns registered users + directory hits. Now subject
  // to the same 20/24h quota as /lookup, so the result also carries a
  // quota-exceeded marker.
  Future<NameSearchResult> searchByName(String query) async {
    final r = await _api.dio.get('/search', queryParameters: {'q': query});
    if (r.statusCode == 200 && r.data is Map) {
      final m = Map<String, dynamic>.from(r.data as Map);
      return NameSearchResult.ok(
        data: m,
        quota: (m['quota'] as Map?)?.cast<String, dynamic>(),
      );
    }
    if (r.statusCode == 429 && r.data is Map) {
      final m = Map<String, dynamic>.from(r.data as Map);
      return NameSearchResult.quotaExceeded(
        message: (m['message'] as String?) ?? 'Daily search limit reached',
        quota: (m['quota'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
    }
    throw Exception('Search failed (${r.statusCode}): ${r.data}');
  }

  // Notifies the server that the user finished a rewarded ad. Returns the
  // updated quota (with +1 added) on success, or null on cap-reached.
  Future<Map<String, dynamic>?> claimAdReward() async {
    final r = await _api.dio.post('/ads/reward');
    if (r.statusCode == 200 && r.data is Map) {
      return Map<String, dynamic>.from(r.data as Map);
    }
    if (r.statusCode == 429 && r.data is Map) {
      return Map<String, dynamic>.from(r.data as Map);
    }
    throw Exception('Reward call failed (${r.statusCode}): ${r.data}');
  }
}

class LookupResult {
  final bool ok;
  final Map<String, dynamic>? data;
  final String? quotaMessage;
  final Map<String, dynamic>? quota;

  const LookupResult._({
    required this.ok,
    this.data,
    this.quotaMessage,
    this.quota,
  });

  factory LookupResult.ok(Map<String, dynamic> data) =>
      LookupResult._(ok: true, data: data, quota: (data['quota'] as Map?)?.cast<String, dynamic>());

  factory LookupResult.quotaExceeded({
    required String message,
    required Map<String, dynamic> quota,
  }) =>
      LookupResult._(ok: false, quotaMessage: message, quota: quota);
}

class NameSearchResult {
  final bool ok;
  final Map<String, dynamic>? data;
  final String? quotaMessage;
  final Map<String, dynamic>? quota;

  const NameSearchResult._({
    required this.ok,
    this.data,
    this.quotaMessage,
    this.quota,
  });

  factory NameSearchResult.ok({
    required Map<String, dynamic> data,
    Map<String, dynamic>? quota,
  }) =>
      NameSearchResult._(ok: true, data: data, quota: quota);

  factory NameSearchResult.quotaExceeded({
    required String message,
    required Map<String, dynamic> quota,
  }) =>
      NameSearchResult._(ok: false, quotaMessage: message, quota: quota);
}
