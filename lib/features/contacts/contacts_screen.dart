import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import 'sync_status.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  bool _loading = true;
  bool _denied = false;
  String _query = '';
  List<Contact> _all = const [];
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _denied = false;
    });
    final granted = await Permission.contacts.isGranted ||
        await FlutterContacts.requestPermission(readonly: true);
    if (!granted) {
      setState(() {
        _loading = false;
        _denied = true;
      });
      return;
    }
    final all = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
      sorted: true,
    );
    setState(() {
      _all = all;
      _loading = false;
    });
  }

  List<Contact> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all.where((c) {
      if (c.displayName.toLowerCase().contains(q)) return true;
      for (final p in c.phones) {
        if (p.number.replaceAll(RegExp(r'\s+'), '').contains(q)) return true;
      }
      return false;
    }).toList();
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final sync = ref.watch(syncStatusProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.contactsTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: l.contactsSyncNow,
            onPressed: sync.running
                ? null
                : () async {
                    final n = await ref.read(syncStatusProvider.notifier).sync();
                    if (!mounted) return;
                    final s = ref.read(syncStatusProvider);
                    if (s.lastError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.contactsSyncFailed(s.lastError!)),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    } else if (n != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.contactsUploadedCount(n))),
                      );
                    }
                  },
            icon: sync.running
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.cloud_upload_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveBox(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    context.pagePadding, 8, context.pagePadding, 12),
                child: TextField(
                  controller: _ctrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: l.contactsSearchHint,
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _ctrl.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
              if (sync.lastError != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
                  child: _ErrorBanner(message: sync.lastError!),
                ),
              if (_loading)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else if (_denied)
                Expanded(child: _PermissionDenied(onRetry: _load))
              else if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      _query.isEmpty
                          ? l.contactsEmpty
                          : l.contactsNoMatches(_query),
                      style: GoogleFonts.inter(
                          color: AppColors.textSecondaryLight),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                        context.pagePadding, 0, context.pagePadding, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (ctx, i) {
                      final c = filtered[i];
                      final phone = c.phones.isNotEmpty
                          ? c.phones.first.number
                          : l.contactsNoPhone;
                      return _ContactTile(
                        initials: _initials(c.displayName),
                        name: c.displayName.isEmpty
                            ? l.contactsNoName
                            : c.displayName,
                        phone: phone,
                      );
                    },
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  border: Border(
                      top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_done_outlined,
                        size: 18, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sync.hasEverSynced
                            ? 'Last upload: ${sync.lastUploaded ?? 0} contacts at ${_fmtTime(sync.lastSuccessAt!)}'
                            : 'Not uploaded yet — tap the cloud icon to sync.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final today = DateTime.now();
    final isToday =
        t.year == today.year && t.month == today.month && t.day == today.day;
    if (isToday) return '$h:$m';
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} $h:$m';
  }
}

class _ContactTile extends StatelessWidget {
  final String initials;
  final String name;
  final String phone;
  const _ContactTile(
      {required this.initials, required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.tint,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 14.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(phone,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionDenied extends StatelessWidget {
  final VoidCallback onRetry;
  const _PermissionDenied({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 56, color: AppColors.textSecondaryLight),
            const SizedBox(height: 12),
            Text('Contacts permission is needed.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Open settings → Yellow Fast Call → Permissions → Contacts → Allow.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: AppColors.textSecondaryLight, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Wrap(spacing: 8, children: [
              OutlinedButton(
                  onPressed: () => openAppSettings(),
                  child: const Text('Open settings')),
              ElevatedButton(
                  onPressed: onRetry, child: const Text('Try again')),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Last sync failed: $message',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
