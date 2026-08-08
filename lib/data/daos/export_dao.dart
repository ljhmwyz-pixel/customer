import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../database.dart';
import '../tables/customers.dart';
import '../tables/contacts.dart';
import '../tables/follow_plans.dart';
import '../tables/followups.dart';
import '../tables/opportunities.dart';
import '../tables/orders.dart';
import '../tables/quotes.dart';
import '../tables/registrations.dart';
import '../tables/samples.dart';
import '../tables/tenders.dart';

part 'export_dao.g.dart';

class ExcelExportSnapshot {
  const ExcelExportSnapshot({
    required this.todayTasks,
    required this.customerProjects,
    required this.followups,
    required this.businessEvents,
  });

  final List<TaskExportRow> todayTasks;
  final List<CustomerProjectExportRow> customerProjects;
  final List<FollowupExportRow> followups;
  final List<BusinessExportRow> businessEvents;
}

class TaskExportRow {
  const TaskExportRow({
    required this.id,
    required this.planAt,
    required this.statusLabel,
    required this.customerName,
    required this.opportunityName,
    required this.reason,
    required this.nextAction,
    required this.owner,
    required this.talkingDirection,
  });

  final int id;
  final DateTime planAt;
  final String statusLabel;
  final String customerName;
  final String? opportunityName;
  final String? reason;
  final String nextAction;
  final String owner;
  final String? talkingDirection;
}

class CustomerProjectExportRow {
  const CustomerProjectExportRow({
    required this.customerId,
    required this.customerName,
    required this.company,
    required this.country,
    required this.customerStageLabel,
    required this.grade,
    required this.opportunityId,
    required this.opportunityName,
    required this.owner,
    required this.opportunityStageLabel,
    required this.opportunityStatusLabel,
    required this.productCategory,
    required this.productModel,
    required this.equipmentBrand,
    required this.forecastAmountMinor,
    required this.currency,
    required this.probabilityPercent,
    required this.expectedCloseAt,
    required this.currentSupplier,
    required this.latestFeedback,
    required this.currentObstacle,
    required this.nextAction,
    required this.nextFollowAt,
    this.customerNo,
    this.customerType,
    this.customerOwner,
    this.tenderExperience,
    this.tenderQualification,
    this.tenderBidder,
    this.localTeamStatus,
    this.fundingStatus,
  });

  final int customerId;
  final String customerName;
  final String? company;
  final String? country;
  final String customerStageLabel;
  final String grade;
  final int? opportunityId;
  final String? opportunityName;
  final String? owner;
  final String? opportunityStageLabel;
  final String? opportunityStatusLabel;
  final String? productCategory;
  final String? productModel;
  final String? equipmentBrand;
  final int? forecastAmountMinor;
  final String? currency;
  final int? probabilityPercent;
  final DateTime? expectedCloseAt;
  final String? currentSupplier;
  final String? latestFeedback;
  final String? currentObstacle;
  final String? nextAction;
  final DateTime? nextFollowAt;
  final String? customerNo;
  final String? customerType;
  final String? customerOwner;
  final String? tenderExperience;
  final String? tenderQualification;
  final String? tenderBidder;
  final String? localTeamStatus;
  final String? fundingStatus;
}

class FollowupExportRow {
  const FollowupExportRow({
    required this.id,
    required this.occurredAt,
    required this.customerName,
    required this.opportunityName,
    required this.methodLabel,
    required this.content,
    required this.conclusion,
    required this.feedback,
    required this.stageLabel,
    required this.nextAction,
    required this.nextFollowAt,
    this.contactName,
    this.attitudeLabel,
    this.owner,
  });

  final int id;
  final DateTime occurredAt;
  final String customerName;
  final String? opportunityName;
  final String methodLabel;
  final String content;
  final String? conclusion;
  final String? feedback;
  final String? stageLabel;
  final String? nextAction;
  final DateTime? nextFollowAt;
  final String? contactName;
  final String? attitudeLabel;
  final String? owner;
}

enum BusinessExportType { quote, sample, registration, tender, order }

class BusinessExportRow {
  const BusinessExportRow({
    required this.type,
    required this.sourceId,
    required this.eventAt,
    required this.customerName,
    required this.opportunityName,
    required this.reference,
    required this.statusLabel,
    required this.product,
    required this.quantity,
    required this.currency,
    required this.amountMinor,
    required this.nextAt,
    required this.detail,
  });

  final BusinessExportType type;
  final int sourceId;
  final DateTime eventAt;
  final String customerName;
  final String opportunityName;
  final String reference;
  final String statusLabel;
  final String? product;
  final int? quantity;
  final String? currency;
  final int? amountMinor;
  final DateTime? nextAt;
  final String? detail;
}

@DriftAccessor(
  tables: [
    Customers,
    Opportunities,
    FollowPlans,
    Followups,
    Contacts,
    Quotes,
    Samples,
    Registrations,
    Tenders,
    Orders,
  ],
)
class ExportDao extends DatabaseAccessor<AppDatabase> with _$ExportDaoMixin {
  ExportDao(super.db);

  Future<ExcelExportSnapshot> loadExcelSnapshot({required DateTime now}) =>
      transaction(() async {
        final tasks = await _loadTasks(now);
        final projects = await _loadProjects();
        final followupRows = await _loadFollowups();
        final events =
            <BusinessExportRow>[
              ...await _loadQuotes(),
              ...await _loadSamples(),
              ...await _loadRegistrations(),
              ...await _loadTenders(),
              ...await _loadOrders(),
            ]..sort((a, b) {
              final byDate = a.eventAt.compareTo(b.eventAt);
              if (byDate != 0) return byDate;
              final byType = a.type.index.compareTo(b.type.index);
              return byType != 0 ? byType : a.sourceId.compareTo(b.sourceId);
            });
        return ExcelExportSnapshot(
          todayTasks: List.unmodifiable(tasks),
          customerProjects: List.unmodifiable(projects),
          followups: List.unmodifiable(followupRows),
          businessEvents: List.unmodifiable(events),
        );
      });

  Future<List<TaskExportRow>> _loadTasks(DateTime now) async {
    final end = now.isUtc
        ? DateTime.utc(now.year, now.month, now.day, 23, 59, 59, 999)
        : DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final rows = await customSelect(
      '''
        SELECT plan.*, customer.name AS customer_name,
               opportunity.name AS opportunity_name
        FROM follow_plans plan
        JOIN customers customer ON customer.id = plan.customer_id
        LEFT JOIN opportunities opportunity ON opportunity.id = plan.opportunity_id
        WHERE plan.status IN ('pending', 'notified', 'overdue')
          AND plan.plan_at <= ?
        ORDER BY plan.plan_at, plan.id
      ''',
      variables: [Variable.withInt(end.toUtc().millisecondsSinceEpoch)],
      readsFrom: {followPlans, customers, opportunities},
    ).get();
    return [
      for (final row in rows)
        TaskExportRow(
          id: row.read<int>('id'),
          planAt: _date(row.read<int>('plan_at')),
          statusLabel: PlanStatus.fromDb(row.read<String>('status')).label,
          customerName: row.read<String>('customer_name'),
          opportunityName: row.readNullable<String>('opportunity_name'),
          reason: row.readNullable<String>('reason'),
          nextAction:
              row.readNullable<String>('next_action') ??
              row.read<String>('title'),
          owner: row.read<String>('owner'),
          talkingDirection: row.readNullable<String>('talking_direction'),
        ),
    ];
  }

  Future<List<CustomerProjectExportRow>> _loadProjects() async {
    final rows = await customSelect(
      '''
      SELECT customer.id AS customer_id, customer.name AS customer_name,
             customer.company, customer.country, customer.customer_no,
             customer.customer_type, customer.owner AS customer_owner,
             customer.tender_experience, customer.tender_qualification,
             customer.tender_bidder, customer.local_team_status,
             customer.funding_status,
             customer.stage AS customer_stage, customer.grade,
             opportunity.id AS opportunity_id,
             opportunity.name AS opportunity_name, opportunity.owner,
             opportunity.stage AS opportunity_stage,
             opportunity.status AS opportunity_status,
             opportunity.product_category, opportunity.product_model,
             opportunity.equipment_brand, opportunity.forecast_amount_minor,
             opportunity.currency, opportunity.probability_percent,
             opportunity.expected_close_at, opportunity.current_supplier,
             opportunity.latest_feedback, opportunity.current_obstacle,
             opportunity.next_action, opportunity.next_follow_at
      FROM customers customer
      LEFT JOIN opportunities opportunity ON opportunity.customer_id = customer.id
      ORDER BY customer.id, opportunity.id
    ''',
      readsFrom: {customers, opportunities},
    ).get();
    return [
      for (final row in rows)
        CustomerProjectExportRow(
          customerId: row.read<int>('customer_id'),
          customerName: row.read<String>('customer_name'),
          company: row.readNullable<String>('company'),
          country: row.readNullable<String>('country'),
          customerStageLabel: CustomerStage.fromDb(
            row.read<String>('customer_stage'),
          ).label,
          grade: row.read<String>('grade').toUpperCase(),
          opportunityId: row.readNullable<int>('opportunity_id'),
          opportunityName: row.readNullable<String>('opportunity_name'),
          owner: row.readNullable<String>('owner'),
          opportunityStageLabel: _opportunityStageLabel(
            row.readNullable<String>('opportunity_stage'),
          ),
          opportunityStatusLabel: _opportunityStatusLabel(
            row.readNullable<String>('opportunity_status'),
          ),
          productCategory: row.readNullable<String>('product_category'),
          productModel: row.readNullable<String>('product_model'),
          equipmentBrand: row.readNullable<String>('equipment_brand'),
          forecastAmountMinor: row.readNullable<int>('forecast_amount_minor'),
          currency: row.readNullable<String>('currency'),
          probabilityPercent: row.readNullable<int>('probability_percent'),
          expectedCloseAt: _nullableDate(row, 'expected_close_at'),
          currentSupplier: row.readNullable<String>('current_supplier'),
          latestFeedback: row.readNullable<String>('latest_feedback'),
          currentObstacle: row.readNullable<String>('current_obstacle'),
          nextAction: row.readNullable<String>('next_action'),
          nextFollowAt: _nullableDate(row, 'next_follow_at'),
          customerNo: row.readNullable<String>('customer_no'),
          customerType: row.readNullable<String>('customer_type'),
          customerOwner: row.readNullable<String>('customer_owner'),
          tenderExperience: row.readNullable<String>('tender_experience'),
          tenderQualification: row.readNullable<String>('tender_qualification'),
          tenderBidder: row.readNullable<String>('tender_bidder'),
          localTeamStatus: row.readNullable<String>('local_team_status'),
          fundingStatus: row.readNullable<String>('funding_status'),
        ),
    ];
  }

  Future<List<FollowupExportRow>> _loadFollowups() async {
    final rows = await customSelect(
      '''
      SELECT followup.*, customer.name AS customer_name,
             opportunity.name AS opportunity_name,
             COALESCE(
               NULLIF(TRIM(followup.contact_name_snapshot), ''),
               contact.name
             ) AS contact_name
      FROM followups followup
      JOIN customers customer ON customer.id = followup.customer_id
      LEFT JOIN opportunities opportunity ON opportunity.id = followup.opportunity_id
      LEFT JOIN contacts contact ON contact.id = followup.contact_id
      ORDER BY followup.occurred_at, followup.id
    ''',
      readsFrom: {followups, customers, opportunities, contacts},
    ).get();
    return [
      for (final row in rows)
        FollowupExportRow(
          id: row.read<int>('id'),
          occurredAt: _date(row.read<int>('occurred_at')),
          customerName: row.read<String>('customer_name'),
          opportunityName: row.readNullable<String>('opportunity_name'),
          methodLabel: FollowMethod.fromDb(row.read<String>('method')).label,
          content: row.read<String>('content'),
          conclusion: row.readNullable<String>('conclusion'),
          feedback: row.readNullable<String>('feedback'),
          stageLabel: _opportunityStageLabel(row.readNullable<String>('stage')),
          nextAction: row.readNullable<String>('next_action'),
          nextFollowAt: _nullableDate(row, 'next_follow_at'),
          contactName: row.readNullable<String>('contact_name'),
          attitudeLabel: row.readNullable<String>('attitude') == null
              ? null
              : CustomerAttitude.fromDb(row.read<String>('attitude')).label,
          owner: row.readNullable<String>('owner'),
        ),
    ];
  }

  Future<List<BusinessExportRow>> _loadQuotes() => _loadBusiness(
    type: BusinessExportType.quote,
    sql: '''
      SELECT quote.id, quote.quoted_at AS event_at,
             customer.name AS customer_name, opportunity.name AS opportunity_name,
             quote.quote_no || ' v' || quote.version AS reference,
             COALESCE(quote.result, '已报价') AS status_label,
             quote.product_model AS product, quote.quantity, quote.currency,
             quote.total_amount_minor AS amount_minor,
             quote.next_follow_at AS next_at, quote.customer_feedback AS detail
      FROM quotes quote
      JOIN opportunities opportunity ON opportunity.id = quote.opportunity_id
      JOIN customers customer ON customer.id = opportunity.customer_id
    ''',
  );

  Future<List<BusinessExportRow>> _loadSamples() => _loadBusiness(
    type: BusinessExportType.sample,
    sql: '''
      SELECT sample.id, sample.created_at AS event_at,
             customer.name AS customer_name, opportunity.name AS opportunity_name,
             COALESCE(sample.tracking_no, '样品 #' || sample.id) AS reference,
             sample.status AS status_label, sample.sample_model AS product,
             sample.quantity, opportunity.currency, sample.fee_minor AS amount_minor,
             sample.planned_test_at AS next_at, sample.test_result AS detail
      FROM samples sample
      JOIN opportunities opportunity ON opportunity.id = sample.opportunity_id
      JOIN customers customer ON customer.id = opportunity.customer_id
    ''',
    statusLabel: (value) => SampleStatus.fromDb(value).label,
  );

  Future<List<BusinessExportRow>> _loadRegistrations() => _loadBusiness(
    type: BusinessExportType.registration,
    sql: '''
      SELECT registration.id, registration.created_at AS event_at,
             customer.name AS customer_name, opportunity.name AS opportunity_name,
             COALESCE(registration.country, '注册 #' || registration.id) AS reference,
             registration.status AS status_label, opportunity.product_model AS product,
             NULL AS quantity, opportunity.currency, NULL AS amount_minor,
             COALESCE(registration.milestone_at, registration.expected_completed_at) AS next_at,
             registration.current_obstacle AS detail
      FROM registrations registration
      JOIN opportunities opportunity ON opportunity.id = registration.opportunity_id
      JOIN customers customer ON customer.id = opportunity.customer_id
    ''',
    statusLabel: (value) => RegistrationStatus.fromDb(value).label,
  );

  Future<List<BusinessExportRow>> _loadTenders() => _loadBusiness(
    type: BusinessExportType.tender,
    sql: '''
      SELECT tender.id, tender.created_at AS event_at,
             customer.name AS customer_name, opportunity.name AS opportunity_name,
             COALESCE(tender.project_no, tender.name, '招标 #' || tender.id) AS reference,
             tender.status AS status_label, opportunity.product_model AS product,
             NULL AS quantity, opportunity.currency, tender.deposit_minor AS amount_minor,
             tender.deadline_at AS next_at, tender.next_action AS detail
      FROM tenders tender
      JOIN opportunities opportunity ON opportunity.id = tender.opportunity_id
      JOIN customers customer ON customer.id = opportunity.customer_id
    ''',
    statusLabel: (value) => TenderStatus.fromDb(value).label,
  );

  Future<List<BusinessExportRow>> _loadOrders() => _loadBusiness(
    type: BusinessExportType.order,
    sql: '''
      SELECT orders.id, orders.ordered_at AS event_at,
             customer.name AS customer_name,
             COALESCE(opportunity.name, '未关联项目') AS opportunity_name,
             orders.order_no AS reference, orders.order_result AS status_label,
             opportunity.product_model AS product, NULL AS quantity, orders.currency,
             orders.amount_cents AS amount_minor,
             orders.estimated_repurchase_at AS next_at, orders.description AS detail
      FROM orders
      JOIN customers customer ON customer.id = orders.customer_id
      LEFT JOIN opportunities opportunity ON opportunity.id = orders.opportunity_id
    ''',
    statusLabel: (value) => OrderResult.fromDb(value).label,
  );

  Future<List<BusinessExportRow>> _loadBusiness({
    required BusinessExportType type,
    required String sql,
    String Function(String value)? statusLabel,
  }) async {
    final rows = await customSelect(sql).get();
    return [
      for (final row in rows)
        BusinessExportRow(
          type: type,
          sourceId: row.read<int>('id'),
          eventAt: _date(row.read<int>('event_at')),
          customerName: row.read<String>('customer_name'),
          opportunityName: row.read<String>('opportunity_name'),
          reference: row.read<String>('reference'),
          statusLabel:
              statusLabel?.call(row.read<String>('status_label')) ??
              row.read<String>('status_label'),
          product: row.readNullable<String>('product'),
          quantity: row.readNullable<int>('quantity'),
          currency: row.readNullable<String>('currency'),
          amountMinor: row.readNullable<int>('amount_minor'),
          nextAt: _nullableDate(row, 'next_at'),
          detail: row.readNullable<String>('detail'),
        ),
    ];
  }

  DateTime _date(int milliseconds) =>
      DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);

  DateTime? _nullableDate(QueryRow row, String column) {
    final value = row.readNullable<int>(column);
    return value == null ? null : _date(value);
  }

  String? _opportunityStageLabel(String? value) =>
      value == null ? null : OpportunityStage.fromDb(value).label;

  String? _opportunityStatusLabel(String? value) =>
      value == null ? null : OpportunityStatus.fromDb(value).label;
}
