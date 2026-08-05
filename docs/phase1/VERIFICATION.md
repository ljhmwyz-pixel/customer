# 阶段 1 回归验收报告

验收日期 2026-08-04　　依据 [PLAN.md](PLAN.md) 第 5 节的 6 项验收标准 + 3 项自查

**结论：9 项全部通过，可进入阶段 2。**

验收环境：macOS 26.5.2 arm64，Flutter 3.44.8 / Dart 3.12.2。本期为纯数据层，
不涉及界面，全部验证在宿主机完成，无需真机。

总计 **88 项单元测试全部通过**，`flutter analyze` 无问题。

```
00:01 +88: All tests passed!
Analyzing customer... No issues found! (ran in 4.0s)
```

## 逐条结论

### 1. 八张表建表成功，外键约束生效　✅

`test/data/migration_test.dart` 直接查 `sqlite_master` 断言表名集合，八张表齐全：
`customers` `contacts` `followups` `follow_plans` `orders` `tags`
`customer_tags` `attachments`。

外键生效做了三个方向的验证，不只是「删除没报错」：

- `PRAGMA foreign_keys` 实测返回 1（内存库与落盘库各验一次）
- 插入指向不存在客户的联系人与计划，均按预期抛异常
- 级联删除后子表记录数归零，见第 3 项

**并做了负面验证**：把 `database.dart` 的 `beforeOpen` 临时改成
`PRAGMA foreign_keys = OFF`，`cascade_test.dart` 的 6 项**全部失败**。
这说明这组测试确实在检验约束本身，而不是在约束失效时假通过。改回 ON 后重新全绿。

这一点值得强调：SQLite 默认关闭外键，关掉后 `DELETE` 依然成功返回影响行数，
只是子记录全变成孤儿。若测试只断言「删除操作没抛异常」，这个故障可以一路潜伏到线上。

### 2. 单元测试覆盖每张表的增删改查，全部通过　✅

`test/data/crud_test.dart`，14 项。八张表逐一走 增 → 查 → 改 → 删，
改与删都回查落库后的实际值，不只看返回的影响行数。

补充覆盖的边界：

- 更新时未传的字段保持原值（`Value.absent()` 语义正确）
- `orderNo` 唯一约束触发冲突
- 标签重复绑定同一客户靠联合主键去重，不抛错也不产生第二行
- 附件归属不明确（两个外键都空或都有值）时 DAO 拒绝写入
- 附件传绝对路径时 DAO 拒绝写入

另有 `test/data/query_test.dart` 24 项覆盖业务查询语义，这部分单纯的增删改查测不到：
`lastFollowAt` 冗余字段维护、`listStale` 三种口径、订单金额统计、计划状态流转、
`listByUrgency` 的四档排序。

### 3. 级联删除：删除客户后其联系人、跟进记录、跟进计划、订单、附件一并删除　✅

`test/data/cascade_test.dart`，6 项。每项都**先断言子记录确实写进去了**，
再删除，再断言记录数为 0 —— 否则「归零」可能只是因为一开始就没写进去。

覆盖的场景：

| 场景 | 断言 |
|---|---|
| 删客户 | 联系人/跟进/计划/订单/附件全部归零，两级级联到底 |
| 删跟进记录 | 只删其附件，订单附件不受影响 |
| 删订单 | 只删其附件，跟进附件不受影响 |
| 删标签 | 客户关联清除，客户本身保留 |
| 插孤儿记录 | 外键拒绝 |
| 多客户共存 | 删一个不影响另一个 |

附件的两级级联是重点：附件挂在跟进记录与订单上，删客户时要经过
客户 → 跟进/订单 → 附件两跳才能删净。

### 4. 500 客户 + 5000 跟进记录，按紧急度排序查询低于 200ms　✅

`test/data/performance_test.dart`（内存库）与 `test/data/file_db_test.dart`（落盘库）
各测一遍。数据量实测确认为 500 客户 / 5000 跟进 / 400 计划。

方法：预热一次后连测三轮取中位数。预热是必要的，首次查询要编译 SQL、填页缓存，
算进去不代表稳态表现。

| 查询 | 内存库中位数 | 落盘库中位数 | 预算 |
|---|---|---|---|
| `listByUrgency` | 3.6ms | 4.8ms | 200ms |
| `listStale` | 0.8ms | — | 200ms |
| `search` | < 1ms | — | 200ms |
| `countByStage` | < 1ms | — | 200ms |

**关于内存库偏乐观的风险，实测结论是它不成立**：计划文档提醒过内存库比文件库快、
若实测接近阈值就要警惕。所以我补了 `file_db_test.dart` 用真实文件库复测，
两者相差仅 1.2ms（3.6 vs 4.8），并非数量级差异，库文件 577KB。
余量约 40 倍，真机 CPU 更弱也不构成风险。

排序正确性单独断言，不只测耗时：逾期项占据列表开头的连续区间且逾期越久越靠前，
无计划客户连续排在末尾，四档顺序为 逾期 > 今日 > 未来 > 无计划，
无计划客户内部按 A > B > C。

### 5. 数据库版本号与迁移函数就位，能从 v1 空库正常初始化　✅

`test/data/migration_test.dart`，8 项。

- `schemaVersion` 为 1，`PRAGMA user_version` 实测写入 1
- 八张表与 9 个业务索引全部建成，索引名逐一断言
- 附件表的 CHECK 约束随建表落地（查 `sqlite_master` 的建表 SQL 确认）
- 空库各表计数为 0 且可立即写入
- 建索引语句幂等：重复执行同名 `CREATE INDEX IF NOT EXISTS` 不报错，
  索引数仍为 9。迁移里重跑建索引是常见操作，不幂等的话升级会中途失败

落盘库另验了持久化：写入后关连接、换新连接重开同一文件，数据仍在，
`user_version` 仍为 1 而不会重跑 `onCreate`。

`onUpgrade` 本期为空但结构留好，后续加表加字段在此按 `from`/`to` 分支处理。

### 6. 附件表仅存相对路径，路径拼接在应用目录变化后仍能正确解析　✅

`test/data/attachment_path_test.dart`，11 项。

`AttachmentPath` 全部是纯函数，不读文件系统、不调 `getApplicationDocumentsDirectory`。
这是本项验收能成立的前提：函数不依赖当前进程的目录，才能对任意 `appDir` 解析。

关键测试传入两个不同的应用目录：

```
/data/user/0/com.example.customer/app_flutter
/data/user/10/com.example.customer/app_flutter
```

同一条数据库记录在两个目录下都解析出正确的绝对路径。落库的值经断言确认
不以 `/` 开头、不含任何包名或设备相关前缀。

另覆盖：年月分目录与月份补零、扩展名带点、`appDir` 末尾带斜杠不产生双斜杠、
传绝对路径抛 `ArgumentError`、`resolveDir` 返回所在目录、全表扫描确认
没有绝对路径混入。

## 自查项

### 7. `flutter analyze` 无问题，`build_runner` 生成无警告　✅

```
Analyzing customer... No issues found! (ran in 4.0s)
Built with build_runner/aot in 3s; wrote 46 outputs.
```

过程中修掉一处真实错误：`CustomerDao.listStale()` 原先用 Dart 三元运算符拼
where 条件，但 drift 的 `where` 接的是 `Expression<bool>` 而非 Dart `bool`，
原代码靠一个 `as Expression<bool>` 强转勉强编译，analyze 报
`non_bool_condition`。改用 `coalesce([lastFollowAt, createdAt])` 交给 SQL 计算，
语义不变且去掉了强转。

### 8. 金额整数分、时间 UTC 毫秒、枚举字符串　✅

- 金额字段名为 `amountCents`，`IntColumn`。字段名带单位是刻意的，
  写 `amount` 迟早有人塞进去一个以元为单位的 double，浮点误差在金额上不可接受
- 全部时间字段为 `IntColumn`，存 UTC 毫秒。测试断言写入值等于
  `toUtc().millisecondsSinceEpoch`，确认没有本地时区偏移混入
- 五个枚举均存字符串。`enum_test.dart` 8 项验证往返一致、`dbValue` 全小写无重复、
  非法值一律抛 `InvalidEnumValueException` 而不静默降级

枚举不做静默降级是有意的：降级到默认值会让脏数据一路流到界面，
等用户发现「客户阶段莫名变了」时已经查不出源头。

### 9. 所有数据库访问经 DAO，无裸 SQL 字符串拼接　✅

六个 DAO 覆盖全部数据访问。唯一一处 `customSelect` 是
`CustomerDao.listByUrgency()` 的紧急度排序，用 `?1` `?2` `?3` 占位符配合
`Variable.withInt()` 绑定，无字符串插值。

`limit` 是唯一进入 SQL 文本的动态部分（`LIMIT ?3` 整段的有无），
它只由是否传 `limit` 决定，值本身仍走参数绑定。

## 与计划文档的偏离

### 订单号「删除后重用」的行为已明确并记录

我最初写了一条测试，要求删掉当天最后一条订单后新号不重用该编号。这条测试失败了。

复核后判定**是测试写错，不是实现有缺陷**：计划文档第 98 行只要求 `orderNo`
非空唯一，并未要求号码永不重用。要做到永不重用得单独加一张号码水位表记住已发到哪一号,
而八张表结构是本期定稿的，加第九张表会同时打破迁移测试的表清单断言，超出本期范围。

当前行为：`nextOrderNo()` 按当天已有的最大序号推进，删掉最后一条后会重用那个号。
唯一约束仍然成立（旧记录已不存在），对单人本地使用够用。已在
`order_dao.dart` 的文档注释中写明这一行为与将来的改法。

保留了一条更有价值的测试：删掉**中间**一条订单后，新号按最大号推进而不是按条数，
所以不会撞上仍然存在的编号，并实际插入验证没有触发唯一约束。

### 新增计划外的测试文件

计划文档 3.4 节列了 6 个测试文件，实际写了 8 个：

| 文件 | 计划内 | 说明 |
|---|---|---|
| `crud_test.dart` | ✓ | |
| `cascade_test.dart` | ✓ | |
| `migration_test.dart` | ✓ | |
| `attachment_path_test.dart` | ✓ | |
| `performance_test.dart` | ✓ | |
| `enum_test.dart` | ✓ | |
| `query_test.dart` | 新增 | 业务查询语义，增删改查覆盖不到 |
| `file_db_test.dart` | 新增 | 落盘库复测，用于排除内存库偏乐观的风险 |

另有 `helpers.dart` 提供建库辅助，它在建库后立即断言 `PRAGMA foreign_keys` 生效，
外键没开就直接卡住测试，避免整组级联测试静默假通过。

### DAO 方法比计划略多

计划文档 3.3 节点名要求的方法全部就位。实现时另加了几个后续阶段确定会用到的：

- `OrderDao.sumAmountGroupedByCustomer()`　客户列表一次取全部成交额，避免每行一次查询
- `OrderDao.nextOrderNo()`　订单号自动生成
- `AttachmentDao.totalSizeBytes()`　设置页展示存储占用
- `AttachmentDao.listAll()`　阶段 5 备份打包遍历用
- `PlanDao.listUpcoming()`　设备重启后重建闹钟，阶段 2 必需

## 遗留事项

- **`markOverdue` 的调用时机未定**。逾期是派生状态，由该方法在应用启动与每日首次
  打开时批量刷新，而不是查询时实时计算。调用点属于阶段 3 的应用层职责，本期只提供方法
- **`notifiedAt` 字段已就位但无人写入**。阶段 2 的提醒回调负责调 `markNotified()`，
  该字段与 `planAt` 的偏差是判断 ColorOS 有没有掐掉闹钟的依据
- **附件的实际文件读写未实现**，本期只做路径解析与表记录，文件操作在阶段 4。
  `file_picker` 已移除，文档选择需自己写 `ACTION_OPEN_DOCUMENT` platform channel
- **一加 13 真机仍未接入**，`flutter devices` 只有模拟器。阶段 2 的提醒可靠性验证
  必须用真机，需提前用数据线连接

## 阶段 2 的硬门槛提醒

阶段 2 是整个项目风险最高的一环。验收要求在一加 13 真机上连续验证 3 天、
每天至少 2 个提醒、触发率 100%，且通过强杀应用 / 飞行模式 / 重启手机 /
整夜息屏充电四种场景。这个验证周期无法压缩，建议阶段 2 一开始就把测试提醒排上,
让 3 天的观察窗口与开发并行。

## v2 数据库迁移补充验收（2026-08-05）

数据库结构已从 v1 升级到 v2，新增 `opportunities` 项目表，并在跟进、计划、订单
增加项目外键。升级过程不删除或重建旧业务表，避免破坏附件对跟进和订单的既有外键。

迁移测试使用手工创建的真实 v1 SQLite 文件，覆盖五种旧客户阶段和跟进、计划、订单、
附件数据。首次由 v2 数据库打开后，验证结果如下：

- 每个旧客户生成且仅生成一个“历史项目”。
- 旧阶段按 `potential/contacted/intent/deal/lost` 映射为
  `new_lead/contact_established/needs_confirmed/won/lost`。
- 旧跟进、计划和订单全部回填至所属客户的历史项目。
- 客户、业务记录和附件数量保持不变。
- `PRAGMA foreign_key_check` 返回空结果。
- 数据库 `user_version` 升级为 2，新库共 9 张表、16 个业务索引。

现有 v1 页面继续可用：通过服务层新建客户时自动创建“待确认项目”，新建跟进、计划和
订单时自动关联该项目。后续项目选择器上线前，不会继续产生新的无项目业务记录。

本次验证命令：

- `flutter analyze`：No issues found。
- `flutter test`：169 项全部通过。
- `flutter build apk --debug`：成功生成 `app-debug.apk`。

报价、样品、注册、招标、自动业务规则和项目 UI 不属于本次数据库迁移交付，继续按
SPRD 阶段 C–F 实施。
