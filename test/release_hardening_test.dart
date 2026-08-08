import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String read(String path) => File(path).readAsStringSync();

  test('release signing never falls back to the debug certificate', () {
    final gradle = read('android/app/build.gradle.kts');

    expect(gradle, contains('key.properties'));
    expect(gradle, contains('signingConfigs.getByName("release")'));
    expect(gradle, isNot(contains('signingConfigs.getByName("debug")')));
  });

  test('Android automatic backup and device transfer are denied', () {
    final manifest = read('android/app/src/main/AndroidManifest.xml');
    final backupRules = read('android/app/src/main/res/xml/backup_rules.xml');
    final extractionRules = read(
      'android/app/src/main/res/xml/data_extraction_rules.xml',
    );

    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:fullBackupContent="@xml/backup_rules"'));
    expect(
      manifest,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
    expect(backupRules, contains('<exclude domain="root" path="."/>'));
    expect(
      extractionRules,
      contains('<cloud-backup disableIfNoEncryptionCapabilities="true">'),
    );
    expect(extractionRules, contains('<device-transfer>'));
  });

  test('lock-screen notifications do not expose CRM content publicly', () {
    final notificationService = read('lib/services/notification_service.dart');

    expect(
      notificationService,
      contains('visibility: NotificationVisibility.private'),
    );
    expect(
      notificationService,
      isNot(contains('visibility: NotificationVisibility.public')),
    );
  });

  test('runtime version matches the v2.2 release line', () {
    expect(read('pubspec.yaml'), contains('version: 2.2.0+3'));
  });
}
