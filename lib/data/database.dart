import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

import 'daos/attachment_dao.dart';
import 'daos/contact_dao.dart';
import 'daos/customer_dao.dart';
import 'daos/followup_dao.dart';
import 'daos/order_dao.dart';
import 'daos/opportunity_dao.dart';
import 'daos/plan_dao.dart';
import 'daos/quote_dao.dart';
import 'daos/sample_dao.dart';
import 'tables/attachments.dart';
import 'tables/contacts.dart';
import 'tables/customers.dart';
import 'tables/follow_plans.dart';
import 'tables/followups.dart';
import 'tables/orders.dart';
import 'tables/opportunities.dart';
import 'tables/quotes.dart';
import 'tables/samples.dart';
import 'tables/tags.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Customers,
    Opportunities,
    Contacts,
    Followups,
    FollowPlans,
    Orders,
    Tags,
    CustomerTags,
    Attachments,
    Quotes,
    Samples,
  ],
  daos: [
    CustomerDao,
    ContactDao,
    FollowupDao,
    PlanDao,
    OrderDao,
    OpportunityDao,
    AttachmentDao,
    QuoteDao,
    SampleDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 测试用的内存数据库。不落盘，每个测试互不干扰。
  AppDatabase.memory() : super(NativeDatabase.memory());

  /// 供测试注入自定义执行器，例如迁移测试。
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
      await _createQuoteSampleIndexes();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await _migrateV1ToV2(m);
      }
      if (from < 3) {
        await _migrateV2ToV3(m, addOpportunityLastFollowAt: from >= 2);
      }
      if (from < 4) {
        await _migrateV3ToV4(m, addOpportunityTaskFields: from >= 2);
      }
      if (from < 5) {
        await _migrateV4ToV5(m);
      }
    },
    beforeOpen: (details) async {
      // SQLite 默认不开外键约束，不执行这句的话级联删除会静默失效，
      // 而单表增删改查测试完全发现不了。这是本项目最容易踩的坑。
      //
      // 已做负面验证：把这里改成 OFF 后 test/data/cascade_test.dart 的 6 项
      // 全部失败，说明级联测试确实在检验约束本身而不是假通过。
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// 业务查询依赖的索引。
  ///
  /// 紧急度排序要在 500 客户下低于 200ms，靠这几个索引支撑。
  Future<void> _createIndexes({bool includeTaskSource = true}) async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_customers_phone '
      'ON customers(phone)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_customers_stage '
      'ON customers(stage)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_customers_last_follow '
      'ON customers(last_follow_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_opportunities_customer '
      'ON opportunities(customer_id, updated_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_opportunities_stage '
      'ON opportunities(stage)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_opportunities_next_follow '
      'ON opportunities(next_follow_at)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_opportunities_legacy_default '
      'ON opportunities(customer_id) WHERE is_legacy_default = 1',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_followups_customer '
      'ON followups(customer_id, occurred_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_followups_opportunity '
      'ON followups(opportunity_id, occurred_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_plans_plan_at '
      'ON follow_plans(plan_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_plans_customer_status '
      'ON follow_plans(customer_id, status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_plans_opportunity_status '
      'ON follow_plans(opportunity_id, status)',
    );
    if (includeTaskSource) {
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_plans_source_rule '
        'ON follow_plans(source_type, source_id, rule_key) '
        'WHERE source_id IS NOT NULL AND rule_key IS NOT NULL',
      );
    }
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_orders_customer '
      'ON orders(customer_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_orders_opportunity '
      'ON orders(opportunity_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_attachments_followup '
      'ON attachments(followup_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_attachments_order '
      'ON attachments(order_id)',
    );
  }

  /// 把 v1 的客户中心模型升级为 v2 的“客户 + 项目”模型。
  ///
  /// SQLite 允许给旧表增加可空外键列，因此无需重建跟进、计划和订单表，
  /// 也不会触碰依赖它们的附件外键。所有旧业务记录随后回填到每个客户唯一的
  /// “历史项目”，保证升级后没有失去项目归属的数据。
  Future<void> _migrateV1ToV2(Migrator m) async {
    await m.createTable(opportunities);
    await m.addColumn(followups, followups.opportunityId);
    await m.addColumn(followPlans, followPlans.opportunityId);
    await m.addColumn(orders, orders.opportunityId);

    await customStatement('''
      INSERT INTO opportunities (
        customer_id,
        name,
        stage,
        status,
        is_legacy_default,
        created_at,
        updated_at
      )
      SELECT
        id,
        '历史项目',
        CASE stage
          WHEN 'contacted' THEN 'contact_established'
          WHEN 'intent' THEN 'needs_confirmed'
          WHEN 'deal' THEN 'won'
          WHEN 'lost' THEN 'lost'
          ELSE 'new_lead'
        END,
        CASE stage
          WHEN 'deal' THEN 'won'
          WHEN 'lost' THEN 'closed'
          ELSE 'active'
        END,
        1,
        created_at,
        updated_at
      FROM customers
    ''');

    for (final tableName in ['followups', 'follow_plans', 'orders']) {
      await customStatement('''
        UPDATE $tableName
        SET opportunity_id = (
          SELECT opportunity.id
          FROM opportunities opportunity
          WHERE opportunity.customer_id = $tableName.customer_id
            AND opportunity.is_legacy_default = 1
        )
        WHERE opportunity_id IS NULL
      ''');
    }

    await _createIndexes(includeTaskSource: false);
  }

  /// 为跟进记录增加不可变五字段快照，并记录项目最近同步的跟进时间。
  ///
  /// 全部操作都是增加可空列与原位回填，不重建业务表，也不会触碰附件关系。
  Future<void> _migrateV2ToV3(
    Migrator m, {
    required bool addOpportunityLastFollowAt,
  }) async {
    await m.addColumn(followups, followups.feedback);
    await m.addColumn(followups, followups.stage);
    await m.addColumn(followups, followups.nextAction);
    await m.addColumn(followups, followups.nextFollowAt);
    await m.addColumn(followups, followups.pauseReason);
    // v1 升级时 opportunities 会直接按当前 v4 表定义创建，已经包含此列；
    // 只有真实 v2 数据库需要执行 ALTER TABLE。
    if (addOpportunityLastFollowAt) {
      await m.addColumn(opportunities, opportunities.lastFollowAt);
    }

    await customStatement('''
      UPDATE followups
      SET feedback = COALESCE(NULLIF(TRIM(conclusion), ''), content),
          stage = (
            SELECT opportunity.stage
            FROM opportunities opportunity
            WHERE opportunity.id = followups.opportunity_id
          ),
          next_action = COALESCE(
            (
              SELECT NULLIF(TRIM(opportunity.next_action), '')
              FROM opportunities opportunity
              WHERE opportunity.id = followups.opportunity_id
            ),
            '历史跟进（未记录下一步行动）'
          )
    ''');

    await customStatement('''
      UPDATE opportunities
      SET last_follow_at = (
        SELECT MAX(followup.occurred_at)
        FROM followups followup
        WHERE followup.opportunity_id = opportunities.id
      )
    ''');
  }

  /// 增加今日任务所需的客户、项目和任务基础字段。
  ///
  /// v1 升级时 opportunities 会按当前 v4 定义直接创建，已经包含 owner 和
  /// importance；真实 v2/v3 数据库才需要补这两列。其余表在所有历史版本中
  /// 都已存在，因此统一原位加列。
  Future<void> _migrateV3ToV4(
    Migrator m, {
    required bool addOpportunityTaskFields,
  }) async {
    await m.addColumn(customers, customers.country);
    if (addOpportunityTaskFields) {
      await m.addColumn(opportunities, opportunities.owner);
      await m.addColumn(opportunities, opportunities.importance);
    }
    await m.addColumn(followPlans, followPlans.sourceType);
    await m.addColumn(followPlans, followPlans.sourceId);
    await m.addColumn(followPlans, followPlans.ruleKey);
    await m.addColumn(followPlans, followPlans.reason);
    await m.addColumn(followPlans, followPlans.talkingDirection);
    await m.addColumn(followPlans, followPlans.nextAction);
    await m.addColumn(followPlans, followPlans.owner);
    await m.addColumn(followPlans, followPlans.cancelledAt);

    await customStatement('''
      UPDATE follow_plans
      SET source_type = 'legacy',
          next_action = title,
          owner = '本人'
      WHERE source_type = 'legacy'
    ''');

    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_plans_source_rule '
      'ON follow_plans(source_type, source_id, rule_key) '
      'WHERE source_id IS NOT NULL AND rule_key IS NOT NULL',
    );
  }

  Future<void> _migrateV4ToV5(Migrator m) async {
    await m.createTable(quotes);
    await m.createTable(samples);
    await _createIndexes();
    await _createQuoteSampleIndexes();
  }

  Future<void> _createQuoteSampleIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_quotes_opportunity_date '
      'ON quotes(opportunity_id, quoted_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_quotes_valid_until '
      'ON quotes(valid_until)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_samples_opportunity_status '
      'ON samples(opportunity_id, status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_samples_planned_test '
      'ON samples(planned_test_at)',
    );
  }
}

/// 打开落盘的数据库连接。
///
/// 放在应用文档目录而非缓存目录，缓存目录会被系统清理。
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'customer.sqlite'));

    // sqlite3 3.x 已内置原生库，不再需要 sqlite3_flutter_libs（已 EOL）。
    // 这里显式引用一次 sqlite3 的版本，确保原生库在启动时就绑定成功，
    // 而不是等到第一次查询才在某个后台 isolate 里报错。
    sqlite3.sqlite3.version;

    return NativeDatabase.createInBackground(file);
  });
}
