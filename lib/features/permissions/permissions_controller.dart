import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class PermStatus {
  final bool contacts;
  final bool location;
  final bool phone;
  const PermStatus({
    this.contacts = false,
    this.location = false,
    this.phone = false,
  });

  PermStatus copyWith({bool? contacts, bool? location, bool? phone}) =>
      PermStatus(
        contacts: contacts ?? this.contacts,
        location: location ?? this.location,
        phone: phone ?? this.phone,
      );

  bool get anyGranted => contacts || location || phone;
}

class PermissionsController extends StateNotifier<PermStatus> {
  PermissionsController() : super(const PermStatus()) {
    refresh();
  }

  Future<void> refresh() async {
    final c = await Permission.contacts.status;
    final l = await Permission.locationWhenInUse.status;
    final p = await Permission.phone.status;
    state = PermStatus(
      contacts: c.isGranted,
      location: l.isGranted,
      phone: p.isGranted,
    );
  }

  Future<void> requestContacts() async {
    final r = await Permission.contacts.request();
    state = state.copyWith(contacts: r.isGranted);
    // Note: actual contact upload happens AFTER login (no JWT exists yet here).
    // The Home screen + OTP-success handler trigger the upload.
  }

  Future<void> requestLocation() async {
    final r = await Permission.locationWhenInUse.request();
    state = state.copyWith(location: r.isGranted);
  }

  Future<void> requestPhone() async {
    final r = await Permission.phone.request();
    state = state.copyWith(phone: r.isGranted);
  }
}

final permissionsControllerProvider =
    StateNotifierProvider<PermissionsController, PermStatus>(
  (ref) => PermissionsController(),
);
