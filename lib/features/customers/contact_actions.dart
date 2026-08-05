import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ImportedContact {
  const ImportedContact({required this.name, this.phone, this.position});

  final String name;
  final String? phone;
  final String? position;
}

abstract interface class ContactActions {
  Future<ImportedContact?> pickContact();

  Future<void> call(String phone);
}

class ContactActionException implements Exception {
  const ContactActionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SystemContactActions implements ContactActions {
  @override
  Future<ImportedContact?> pickContact() async {
    final status = await FlutterContacts.permissions.request(
      PermissionType.read,
    );
    if (status != PermissionStatus.granted &&
        status != PermissionStatus.limited) {
      throw const ContactActionException('无法读取通讯录，请在系统设置中允许通讯录权限');
    }

    final contact = await FlutterContacts.native.showPicker(
      properties: {
        ContactProperty.name,
        ContactProperty.phone,
        ContactProperty.organization,
      },
    );
    if (contact == null) return null;

    final phone = contact.phones.isEmpty
        ? null
        : contact.phones.first.number.trim();
    if (phone == null || phone.isEmpty) {
      throw const ContactActionException('该联系人没有电话号码');
    }
    final organization = contact.organizations.firstOrNull;
    final jobTitle = organization?.jobTitle?.trim();
    final department = organization?.departmentName?.trim();
    final position = jobTitle != null && jobTitle.isNotEmpty
        ? jobTitle
        : department != null && department.isNotEmpty
        ? department
        : null;

    return ImportedContact(
      name: (contact.displayName ?? '').trim(),
      phone: phone,
      position: position,
    );
  }

  @override
  Future<void> call(String phone) async {
    final normalized = phone.trim();
    if (normalized.isEmpty) {
      throw const ContactActionException('电话号码不能为空');
    }
    final uri = Uri(scheme: 'tel', path: normalized);
    try {
      if (await canLaunchUrl(uri) &&
          await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {
      // Platform launch failures use the same user-facing message.
    }
    throw const ContactActionException('当前设备无法拨打电话');
  }
}

final contactActionsProvider = Provider<ContactActions>(
  (_) => SystemContactActions(),
);
