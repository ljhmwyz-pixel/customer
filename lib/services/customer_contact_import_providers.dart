import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database_provider.dart';
import 'customer_contact_import_service.dart';

final customerContactImportServiceProvider =
    Provider<CustomerContactImportService>(
      (ref) => CustomerContactImportService(ref.watch(databaseProvider)),
    );
