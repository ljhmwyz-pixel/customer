import '../data/database.dart';
import '../models/enums.dart';
import 'reminder_scheduler.dart';

class BusinessTaskRules {
  BusinessTaskRules(this._db, this._scheduler);
  final AppDatabase _db;
  final ReminderScheduler _scheduler;

  Future<List<String>> cancelScheduledPlans(Iterable<int> planIds) async {
    final warnings = <String>[];
    for (final id in planIds) {
      try {
        await _scheduler.cancelForPlan(id);
      } catch (_) {
        warnings.add('任务 $id 已完成，但提醒清理失败');
      }
    }
    return warnings;
  }

  Future<List<int>> generateForOpportunity(
    int opportunityId, {
    required DateTime now,
  }) async {
    final opportunity = await _db.opportunityDao.findById(opportunityId);
    if (opportunity == null || _isClosed(opportunity)) return [];
    final customer = await _db.customerDao.findById(opportunity.customerId);
    if (customer == null) return [];
    final quoteRows = await _db.quoteDao.listVersions(opportunityId);
    final sampleRows = await _db.sampleDao.listOf(opportunityId);
    final registrationRows = await _db.registrationDao.listOf(opportunityId);
    final tenderRows = await _db.tenderDao.listOf(opportunityId);
    final orderRows = await _db.orderDao.listOf(customer.id);
    final candidates = <_Candidate>[
      for (final quote in quoteRows) ..._quoteCandidates(quote, now),
      for (final sample in sampleRows) ..._sampleCandidates(sample, now),
      for (final registration in registrationRows)
        ..._registrationCandidates(registration),
      for (final tender in tenderRows) ..._tenderCandidates(tender),
      for (final order in orderRows)
        if (order.opportunityId == opportunityId)
          ..._repurchaseCandidates(order),
    ];
    final created = <int>[];
    for (final candidate in candidates) {
      if (await _db.planDao.findBySourceRule(
            candidate.source,
            candidate.sourceId,
            candidate.ruleKey,
          ) !=
          null) {
        continue;
      }
      final id = await _db.planDao.insertPlan(
        customerId: customer.id,
        opportunityId: opportunity.id,
        sourceType: candidate.source,
        sourceId: candidate.sourceId,
        ruleKey: candidate.ruleKey,
        reason: candidate.reason,
        talkingDirection: candidate.direction,
        nextAction: candidate.nextAction,
        owner: opportunity.owner,
        title: candidate.nextAction,
        planAt: candidate.planAt,
        now: now,
      );
      created.add(id);
      try {
        final plan = await _db.planDao.findById(id);
        if (plan != null) {
          await _scheduler.scheduleForPlan(plan, customerName: customer.name);
        }
      } catch (_) {
        // Persisted tasks are rebuilt on next app start when scheduling fails.
      }
    }
    return created;
  }

  Future<BusinessTaskSyncResult> reconcileForOpportunity(
    int opportunityId, {
    required DateTime now,
  }) async {
    final opportunity = await _db.opportunityDao.findById(opportunityId);
    if (opportunity == null) return const BusinessTaskSyncResult();
    final existing = await _db.planDao.listOpenAutomaticOfOpportunity(
      opportunityId,
    );
    final candidateKeys = <String>{};
    if (!_isClosed(opportunity)) {
      final quoteRows = await _db.quoteDao.listVersions(opportunityId);
      final sampleRows = await _db.sampleDao.listOf(opportunityId);
      final registrationRows = await _db.registrationDao.listOf(opportunityId);
      final tenderRows = await _db.tenderDao.listOf(opportunityId);
      final orderRows = await _db.orderDao.listOf(opportunity.customerId);
      for (final candidate in <_Candidate>[
        for (final quote in quoteRows) ..._quoteCandidates(quote, now),
        for (final sample in sampleRows) ..._sampleCandidates(sample, now),
        for (final registration in registrationRows)
          ..._registrationCandidates(registration),
        for (final tender in tenderRows) ..._tenderCandidates(tender),
        for (final order in orderRows)
          if (order.opportunityId == opportunityId)
            ..._repurchaseCandidates(order),
      ]) {
        candidateKeys.add(candidate.identity);
      }
    }

    final cancelledIds = <int>[];
    final warnings = <String>[];
    for (final plan in existing) {
      final identity = '${plan.sourceType}:${plan.sourceId}:${plan.ruleKey}';
      if (candidateKeys.contains(identity)) continue;
      final affected = await _db.planDao.markCancelled(plan.id, at: now);
      if (affected == 0) continue;
      cancelledIds.add(plan.id);
      try {
        await _scheduler.cancelForPlan(plan.id);
      } catch (_) {
        warnings.add('任务 ${plan.id} 已取消，但提醒清理失败');
      }
    }

    final createdIds = await generateForOpportunity(opportunityId, now: now);
    return BusinessTaskSyncResult(
      createdIds: createdIds,
      cancelledIds: cancelledIds,
      warnings: warnings,
    );
  }

  List<_Candidate> _quoteCandidates(QuoteRow quote, DateTime now) {
    final base = _local(quote.quotedAt);
    final result = <_Candidate>[];
    if (!quote.customerReceived) {
      result.addAll([
        _quote(quote, 'after_2_workdays', _addWorkdays(base, 2), '确认客户是否收到报价'),
        _quote(
          quote,
          'after_7_days',
          base.add(const Duration(days: 7)),
          '询问内部评估、价格反馈和采购计划',
        ),
        _quote(
          quote,
          'after_14_days',
          base.add(const Duration(days: 14)),
          '确认价格、规格、数量和决策阻碍',
        ),
        _quote(
          quote,
          'stalled_30_days',
          base.add(const Duration(days: 30)),
          '报价已停滞，重新确认项目真实性',
        ),
        _quote(
          quote,
          'low_frequency_60_days',
          base.add(const Duration(days: 60)),
          '报价长期无回复，评估转低频维护',
        ),
      ]);
    }
    if (quote.validUntil != null) {
      result.add(
        _quote(
          quote,
          'validity_7_days',
          _local(quote.validUntil!).subtract(const Duration(days: 7)),
          '确认是否更新报价',
        ),
      );
    }
    return result
        .where(
          (candidate) =>
              candidate.planAt.isAfter(now.subtract(const Duration(days: 365))),
        )
        .toList();
  }

  List<_Candidate> _sampleCandidates(SampleRow sample, DateTime now) {
    if ({
      SampleStatus.failed.dbValue,
      SampleStatus.cancelled.dbValue,
    }.contains(sample.status)) {
      return [];
    }
    final result = <_Candidate>[];
    final sent = sample.sentAt == null ? null : _local(sample.sentAt!);
    final delivered = sample.deliveredAt == null
        ? null
        : _local(sample.deliveredAt!);
    if (sent != null) {
      result.add(_sample(sample, 'sent_tracking', sent, '跟踪样品物流'));
    }
    if (delivered != null) {
      result.addAll([
        _sample(
          sample,
          'delivered_3_days',
          delivered.add(const Duration(days: 3)),
          '确认样品完整及接收人',
        ),
        _sample(
          sample,
          'delivered_7_days',
          delivered.add(const Duration(days: 7)),
          '确认测试负责人和测试计划',
        ),
        _sample(
          sample,
          'delivered_14_days',
          delivered.add(const Duration(days: 14)),
          '确认测试是否开始',
        ),
      ]);
      if (sample.testResult == null || sample.testResult!.trim().isEmpty) {
        result.add(
          _sample(
            sample,
            'stalled_30_days',
            delivered.add(const Duration(days: 30)),
            '样品测试已停滞，确认测试反馈',
          ),
        );
      }
    }
    if (sample.status == SampleStatus.passed.dbValue) {
      final at = delivered ?? sent;
      if (at != null) {
        result.add(
          _sample(
            sample,
            'passed_3_days',
            at.add(const Duration(days: 3)),
            '推进报价、注册、授权及首单',
          ),
        );
      }
    }
    return result
        .where(
          (candidate) =>
              candidate.planAt.isAfter(now.subtract(const Duration(days: 365))),
        )
        .toList();
  }

  List<_Candidate> _registrationCandidates(RegistrationRow registration) {
    if ({
      RegistrationStatus.completed.dbValue,
      RegistrationStatus.cancelled.dbValue,
    }.contains(registration.status)) {
      return [];
    }
    final result = <_Candidate>[];
    if (registration.expectedCompletedAt != null) {
      result.add(
        _registration(
          registration,
          'expected-completion',
          _local(registration.expectedCompletedAt!),
          '确认注册进度和预计完成时间',
        ),
      );
    }
    if (registration.documentDueAt != null) {
      result.add(
        _registration(
          registration,
          'document-due',
          _local(registration.documentDueAt!),
          '确认注册资料已按期准备完成',
        ),
      );
    }
    if (registration.milestoneAt != null) {
      final title = registration.milestoneTitle?.trim();
      result.add(
        _registration(
          registration,
          'user-milestone',
          _local(registration.milestoneAt!),
          title == null || title.isEmpty ? '跟进注册里程碑' : title,
        ),
      );
    }
    return result;
  }

  List<_Candidate> _tenderCandidates(TenderRow tender) {
    if (tender.status != TenderStatus.open.dbValue ||
        tender.deadlineAt == null) {
      return [];
    }
    final deadline = _local(tender.deadlineAt!);
    return [
      for (final days in [30, 14, 7, 3, 1])
        _Candidate(
          TaskSourceType.tender,
          tender.id,
          'deadline-${days}d',
          deadline.subtract(Duration(days: days)),
          '招标截止提醒',
          '确认招标资料、资质、报价和投标准备进度',
          '距招标截止还有 $days 天，确认投标准备进度',
        ),
    ];
  }

  List<_Candidate> _repurchaseCandidates(OrderRow order) {
    if (order.orderResult != OrderResult.completed.dbValue ||
        order.estimatedRepurchaseAt == null) {
      return [];
    }
    return [
      _Candidate(
        TaskSourceType.repurchase,
        order.id,
        'repurchase-30d',
        _local(order.estimatedRepurchaseAt!).subtract(const Duration(days: 30)),
        '复购跟进',
        '确认客户库存、使用反馈和下一批采购计划',
        '预计复购前 30 天联系客户',
      ),
    ];
  }

  _Candidate _quote(QuoteRow q, String key, DateTime at, String action) =>
      _Candidate(
        TaskSourceType.quote,
        q.id,
        key,
        at,
        '报价跟进',
        '确认报价反馈、采购时间和项目阻碍',
        action,
      );
  _Candidate _sample(SampleRow s, String key, DateTime at, String action) =>
      _Candidate(
        TaskSourceType.sample,
        s.id,
        key,
        at,
        '样品跟进',
        '确认物流、签收、测试负责人和结果',
        action,
      );
  _Candidate _registration(
    RegistrationRow registration,
    String key,
    DateTime at,
    String action,
  ) => _Candidate(
    TaskSourceType.registration,
    registration.id,
    key,
    at,
    '注册跟进',
    '确认注册资料、进度、阻碍和下一步行动',
    action,
  );

  bool _isClosed(OpportunityRow value) =>
      OpportunityStatus.fromDb(value.status).isClosed ||
      {
        OpportunityStage.won.dbValue,
        OpportunityStage.lost.dbValue,
        OpportunityStage.paused.dbValue,
      }.contains(value.stage);

  DateTime _local(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
  DateTime _addWorkdays(DateTime date, int count) {
    var result = date;
    var remaining = count;
    while (remaining > 0) {
      result = result.add(const Duration(days: 1));
      if (result.weekday <= DateTime.friday) remaining--;
    }
    return result;
  }
}

class _Candidate {
  const _Candidate(
    this.source,
    this.sourceId,
    this.ruleKey,
    this.planAt,
    this.reason,
    this.direction,
    this.nextAction,
  );
  final TaskSourceType source;
  final int sourceId;
  final String ruleKey;
  final DateTime planAt;
  final String reason;
  final String direction;
  final String nextAction;

  String get identity => '${source.dbValue}:$sourceId:$ruleKey';
}

class BusinessTaskSyncResult {
  const BusinessTaskSyncResult({
    this.createdIds = const [],
    this.cancelledIds = const [],
    this.warnings = const [],
  });

  final List<int> createdIds;
  final List<int> cancelledIds;
  final List<String> warnings;
}
