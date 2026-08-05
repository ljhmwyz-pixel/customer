import 'package:customer/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// 枚举往返转换与非法值处理。
///
/// 重点是 fromDb 遇到未知值必须抛异常。静默降级到默认值会让脏数据一路流到界面，
/// 等到用户发现「客户阶段莫名变了」时已经查不出源头。
void main() {
  test('CustomerStage 往返一致', () {
    for (final v in CustomerStage.values) {
      expect(CustomerStage.fromDb(v.dbValue), v);
      expect(v.label, isNotEmpty);
    }
    expect(CustomerStage.deal.isClosed, isTrue);
    expect(CustomerStage.lost.isClosed, isTrue);
    expect(CustomerStage.potential.isClosed, isFalse);
  });

  test('CustomerGrade 往返一致且权重递减', () {
    for (final v in CustomerGrade.values) {
      expect(CustomerGrade.fromDb(v.dbValue), v);
    }
    expect(CustomerGrade.a.weight, greaterThan(CustomerGrade.b.weight));
    expect(CustomerGrade.b.weight, greaterThan(CustomerGrade.c.weight));
  });

  test('FollowMethod 往返一致', () {
    for (final v in FollowMethod.values) {
      expect(FollowMethod.fromDb(v.dbValue), v);
    }
  });

  test('PlanStatus 往返一致，isOpen 覆盖未完成状态', () {
    for (final v in PlanStatus.values) {
      expect(PlanStatus.fromDb(v.dbValue), v);
    }
    expect(PlanStatus.pending.isOpen, isTrue);
    expect(PlanStatus.notified.isOpen, isTrue);
    expect(PlanStatus.overdue.isOpen, isTrue);
    expect(PlanStatus.completed.isOpen, isFalse);
  });

  test('OrderStatus 往返一致，仅已完成计入成交额', () {
    for (final v in OrderStatus.values) {
      expect(OrderStatus.fromDb(v.dbValue), v);
    }
    expect(OrderStatus.completed.countsTowardRevenue, isTrue);
    for (final v in OrderStatus.values.where(
      (e) => e != OrderStatus.completed,
    )) {
      expect(v.countsTowardRevenue, isFalse);
    }
  });

  test('OrderStatus 仅允许顺序推进，前三态可取消', () {
    expect(OrderStatus.pending.nextStatus, OrderStatus.shipped);
    expect(OrderStatus.shipped.nextStatus, OrderStatus.paid);
    expect(OrderStatus.paid.nextStatus, OrderStatus.completed);
    expect(OrderStatus.completed.nextStatus, isNull);
    expect(OrderStatus.cancelled.nextStatus, isNull);

    expect(OrderStatus.pending.canTransitionTo(OrderStatus.shipped), isTrue);
    expect(OrderStatus.shipped.canTransitionTo(OrderStatus.paid), isTrue);
    expect(OrderStatus.paid.canTransitionTo(OrderStatus.completed), isTrue);
    for (final status in [
      OrderStatus.pending,
      OrderStatus.shipped,
      OrderStatus.paid,
    ]) {
      expect(status.canTransitionTo(OrderStatus.cancelled), isTrue);
    }

    expect(OrderStatus.pending.canTransitionTo(OrderStatus.paid), isFalse);
    expect(OrderStatus.shipped.canTransitionTo(OrderStatus.completed), isFalse);
    expect(
      OrderStatus.completed.canTransitionTo(OrderStatus.cancelled),
      isFalse,
    );
    expect(OrderStatus.cancelled.canTransitionTo(OrderStatus.pending), isFalse);
  });

  test('非法值一律抛 InvalidEnumValueException', () {
    expect(
      () => CustomerStage.fromDb('unknown'),
      throwsA(isA<InvalidEnumValueException>()),
    );
    expect(
      () => CustomerGrade.fromDb('d'),
      throwsA(isA<InvalidEnumValueException>()),
    );
    expect(
      () => FollowMethod.fromDb(''),
      throwsA(isA<InvalidEnumValueException>()),
    );
    expect(
      () => PlanStatus.fromDb('PENDING'),
      throwsA(isA<InvalidEnumValueException>()),
    );
    expect(
      () => OrderStatus.fromDb('refunded'),
      throwsA(isA<InvalidEnumValueException>()),
    );
  });

  test('异常信息带上枚举名与非法值，便于定位脏数据', () {
    final e = InvalidEnumValueException('CustomerStage', 'weird');
    expect(e.toString(), contains('CustomerStage'));
    expect(e.toString(), contains('weird'));
  });

  test('dbValue 全小写且无重复，避免大小写歧义', () {
    void checkUnique(String name, List<String> values) {
      expect(values.toSet().length, values.length, reason: '$name dbValue 重复');
      for (final v in values) {
        expect(v, v.toLowerCase(), reason: '$name dbValue 应全小写');
      }
    }

    checkUnique(
      'CustomerStage',
      CustomerStage.values.map((e) => e.dbValue).toList(),
    );
    checkUnique(
      'CustomerGrade',
      CustomerGrade.values.map((e) => e.dbValue).toList(),
    );
    checkUnique(
      'FollowMethod',
      FollowMethod.values.map((e) => e.dbValue).toList(),
    );
    checkUnique('PlanStatus', PlanStatus.values.map((e) => e.dbValue).toList());
    checkUnique(
      'OrderStatus',
      OrderStatus.values.map((e) => e.dbValue).toList(),
    );
  });
}
