import 'package:customer/features/opportunities/supplier_substitution.dart';
import 'package:customer/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('固定选项', () {
    test('与 SPRD 选项一致且没有重复项', () {
      expect(supplierProblemOptions, [
        '价格高',
        '质量问题',
        '交期不稳定',
        '型号不完整',
        '注册文件不足',
        '服务慢',
        'MOQ高',
        '暂无明显问题',
        '尚未确认',
      ]);
      expect(changeWillingnessOptions, ['高', '中', '低', '未确认']);
      expect(substitutionDifficultyOptions, ['容易', '中等', '困难']);
      expect(entryPointOptions, [
        '价格替代',
        '第二供应商',
        '连接管切入',
        '非核心型号切入',
        '样品测试',
        'OEM',
        '注册合作',
        '新招标',
        '补充缺失型号',
        '暂不推进',
      ]);
      expect(investmentAdviceOptions, [
        '继续投入',
        '限制样品投入',
        '先确认订单',
        '暂不承担注册费用',
        '暂停跟进',
      ]);
      for (final options in [
        supplierProblemOptions,
        changeWillingnessOptions,
        substitutionDifficultyOptions,
        entryPointOptions,
        investmentAdviceOptions,
      ]) {
        expect(options.toSet(), hasLength(options.length));
      }
    });

    test('历史值只在非标准且非空时追加', () {
      expect(optionsWithLegacyValue(['高', '中'], null), ['高', '中']);
      expect(optionsWithLegacyValue(['高', '中'], ' 高 '), ['高', '中']);
      expect(optionsWithLegacyValue(['高', '中'], '旧判断'), ['高', '中', '旧判断']);
    });
  });

  group('供应商替代建议', () {
    SupplierSubstitutionRecommendation recommend({
      String? equipmentBrand,
      String? equipmentModel = 'OptiVantage',
      String? currentSupplier = '现供应商',
      String? currentPurchaseBrand,
      String? supplierStability,
      String? supplierProblem = '质量问题',
      String? changeWillingness = '中',
      String? substitutionDifficulty = '中等',
      int? estimatedAnnualVolume = 1000,
      DateTime? expectedCloseAt,
    }) => recommendSupplierSubstitution(
      SupplierSubstitutionInput(
        equipmentBrand: equipmentBrand,
        equipmentModel: equipmentModel,
        currentSupplier: currentSupplier,
        currentPurchaseBrand: currentPurchaseBrand,
        supplierStability: supplierStability,
        supplierProblem: supplierProblem,
        changeWillingness: changeWillingness,
        substitutionDifficulty: substitutionDifficulty,
        estimatedAnnualVolume: estimatedAnnualVolume,
        expectedCloseAt: expectedCloseAt,
        stage: OpportunityStage.needsConfirmed,
      ),
    );

    test('问题未确认时先补齐决策信息', () {
      final result = recommend(
        equipmentModel: null,
        currentSupplier: null,
        supplierProblem: '尚未确认',
        estimatedAnnualVolume: null,
      );

      expect(result.entryPoint, '暂不推进');
      expect(result.investmentAdvice, '先确认订单');
      expect(result.reasons.join(), contains('设备型号'));
      expect(result.reasons.join(), contains('现有供应商'));
      expect(result.reasons, isNotEmpty);
    });

    test('Antmed 已有明确问题时建议小范围样品验证', () {
      final result = recommend(
        currentPurchaseBrand: 'ANTMED consumables',
        supplierProblem: '交期不稳定',
      );

      expect(result.entryPoint, '样品测试');
      expect(result.investmentAdvice, '限制样品投入');
      expect(result.summary, contains('Antmed'));
    });

    test('Medtronic 设备优先连接管，低意愿转为非核心型号', () {
      expect(recommend(equipmentBrand: 'Medtronic').entryPoint, '连接管切入');
      expect(
        recommend(equipmentBrand: 'medtron', changeWillingness: '低').entryPoint,
        '非核心型号切入',
      );
    });

    test('稳定且无明显问题时保留第二供应商位置', () {
      final result = recommend(
        supplierStability: '稳定',
        supplierProblem: '暂无明显问题',
      );

      expect(result.entryPoint, '第二供应商');
      expect(result.investmentAdvice, '限制样品投入');
    });

    test('型号不完整时补充缺失型号', () {
      expect(recommend(supplierProblem: '型号不完整').entryPoint, '补充缺失型号');
    });

    test('价格替代必须绑定数量或采购时间证据', () {
      final withoutEvidence = recommend(
        supplierProblem: '价格高',
        estimatedAnnualVolume: null,
      );
      final withVolume = recommend(supplierProblem: '价格高');
      final withDate = recommend(
        supplierProblem: '价格高',
        estimatedAnnualVolume: null,
        expectedCloseAt: DateTime(2026, 10, 1),
      );

      expect(withoutEvidence.entryPoint, '价格替代');
      expect(withoutEvidence.investmentAdvice, '先确认订单');
      expect(withoutEvidence.reasons.join(), contains('数量或订单承诺'));
      expect(withVolume.investmentAdvice, '继续投入');
      expect(withDate.investmentAdvice, '继续投入');
    });

    test('注册问题不自动承诺注册费用，困难替代限制投入', () {
      expect(recommend(supplierProblem: '注册文件不足').investmentAdvice, '暂不承担注册费用');
      expect(
        recommend(
          supplierProblem: '质量问题',
          substitutionDifficulty: '困难',
        ).investmentAdvice,
        '限制样品投入',
      );
    });
  });
}
