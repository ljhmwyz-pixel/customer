import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database_provider.dart';
import 'attachment_service_providers.dart';
import 'sample_data_service.dart';
import 'service_providers.dart';

final sampleDataServiceProvider = Provider<SampleDataService>(
  (ref) => SampleDataService(
    db: ref.watch(databaseProvider),
    reminderScheduler: ref.watch(reminderSchedulerProvider),
    attachmentCleaner: ref.watch(attachmentServiceProvider),
  ),
);

final sampleDataStateProvider = FutureProvider<SampleDataState>(
  (ref) => ref.watch(sampleDataServiceProvider).inspect(),
);
