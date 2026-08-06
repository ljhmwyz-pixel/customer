import '../../models/enums.dart';

const supplierProblemOptions = <String>[
  '价格高',
  '质量问题',
  '交期不稳定',
  '型号不完整',
  '注册文件不足',
  '服务慢',
  'MOQ高',
  '暂无明显问题',
  '尚未确认',
];

const changeWillingnessOptions = <String>['高', '中', '低', '未确认'];
const substitutionDifficultyOptions = <String>['容易', '中等', '困难'];
const entryPointOptions = <String>[
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
];
const investmentAdviceOptions = <String>[
  '继续投入',
  '限制样品投入',
  '先确认订单',
  '暂不承担注册费用',
  '暂停跟进',
];

List<String> optionsWithLegacyValue(
  List<String> options,
  String? currentValue,
) {
  final value = currentValue?.trim();
  if (value == null || value.isEmpty || options.contains(value)) {
    return List.unmodifiable(options);
  }
  return List.unmodifiable([...options, value]);
}

class SupplierSubstitutionInput {
  const SupplierSubstitutionInput({
    this.equipmentBrand,
    this.equipmentModel,
    this.currentSupplier,
    this.currentPurchaseBrand,
    this.supplierStability,
    this.supplierProblem,
    this.changeWillingness,
    this.substitutionDifficulty,
    this.estimatedAnnualVolume,
    this.expectedCloseAt,
    this.stage = OpportunityStage.newLead,
  });

  final String? equipmentBrand;
  final String? equipmentModel;
  final String? currentSupplier;
  final String? currentPurchaseBrand;
  final String? supplierStability;
  final String? supplierProblem;
  final String? changeWillingness;
  final String? substitutionDifficulty;
  final int? estimatedAnnualVolume;
  final DateTime? expectedCloseAt;
  final OpportunityStage stage;
}

class SupplierSubstitutionRecommendation {
  const SupplierSubstitutionRecommendation({
    required this.entryPoint,
    required this.investmentAdvice,
    required this.summary,
    required this.reasons,
  });

  final String entryPoint;
  final String investmentAdvice;
  final String summary;
  final List<String> reasons;
}

SupplierSubstitutionRecommendation recommendSupplierSubstitution(
  SupplierSubstitutionInput input,
) {
  final problem = input.supplierProblem?.trim();
  final willingness = input.changeWillingness?.trim();
  final difficulty = input.substitutionDifficulty?.trim();
  final brandText = [
    input.currentSupplier,
    input.currentPurchaseBrand,
  ].whereType<String>().join(' ').toLowerCase();
  final equipmentBrand = input.equipmentBrand?.trim().toLowerCase() ?? '';
  final constrained = willingness == '低' || difficulty == '困难';

  SupplierSubstitutionRecommendation result(
    String entryPoint,
    String investmentAdvice,
    String summary,
    List<String> reasons,
  ) => SupplierSubstitutionRecommendation(
    entryPoint: entryPoint,
    investmentAdvice: investmentAdvice,
    summary: summary,
    reasons: List.unmodifiable(reasons),
  );

  if (problem == null || problem.isEmpty || problem == '尚未确认') {
    final missing = <String>[
      if (input.equipmentModel?.trim().isEmpty ?? true) '设备型号',
      if (input.estimatedAnnualVolume == null) '年用量',
      if (input.expectedCloseAt == null) '采购时间',
      if (input.currentSupplier?.trim().isEmpty ?? true) '现有供应商',
    ];
    return result('暂不推进', '先确认订单', '供应商问题尚未确认，先完成替代决策所需的信息采集。', [
      '需要先确认现供应商的不满点和更换意愿',
      if (missing.isNotEmpty) '仍需补齐：${missing.join('、')}',
    ]);
  }

  if (brandText.contains('antmed')) {
    return result('样品测试', '限制样品投入', '现有供应链包含 Antmed，先用小范围样品验证明确切换条件。', [
      '已有明确供应商问题：$problem',
      '样品投入应绑定测试负责人、时间和反馈结果',
    ]);
  }

  if (equipmentBrand.contains('medtron')) {
    final lowWillingness = willingness == '低';
    return result(
      lowWillingness ? '非核心型号切入' : '连接管切入',
      constrained ? '限制样品投入' : '继续投入',
      lowWillingness
          ? '客户更换意愿低，从非核心型号开始，避免正面替换设备品牌。'
          : '设备品牌为 Medtronic 系列，优先从连接管等兼容耗材切入。',
      ['设备品牌匹配 Medtron/Medtronic', if (lowWillingness) '当前更换意愿低'],
    );
  }

  if (problem == '型号不完整') {
    return result(
      '补充缺失型号',
      constrained ? '限制样品投入' : '继续投入',
      '以补齐现有供应商缺失型号切入，避免要求客户整体替换。',
      ['客户已确认现供应商型号覆盖不完整'],
    );
  }

  if (problem == '暂无明显问题') {
    return result('第二供应商', '限制样品投入', '现有供应稳定时保留第二供应商位置，不推动高成本替换。', [
      '客户未确认现供应商存在明显问题',
      '第二来源可用于供应风险备份',
    ]);
  }

  if (problem == '价格高') {
    final hasOrderEvidence =
        input.estimatedAnnualVolume != null || input.expectedCloseAt != null;
    return result(
      '价格替代',
      hasOrderEvidence ? '继续投入' : '先确认订单',
      hasOrderEvidence
          ? '客户已提供数量或采购时间，可围绕明确采购条件推进价格替代。'
          : '价格支持必须绑定数量或订单承诺，先确认采购依据。',
      ['客户明确反馈现供应商价格高', hasOrderEvidence ? '已有年用量或采购时间证据' : '尚无数量或订单承诺'],
    );
  }

  final entryPoint = switch (problem) {
    '质量问题' => '样品测试',
    '交期不稳定' => '第二供应商',
    '注册文件不足' => '注册合作',
    '服务慢' => '第二供应商',
    'MOQ高' => 'OEM',
    _ => '样品测试',
  };
  final investmentAdvice = problem == '注册文件不足'
      ? '暂不承担注册费用'
      : constrained
      ? '限制样品投入'
      : '继续投入';
  return result(entryPoint, investmentAdvice, '根据已确认的供应商问题选择低风险切入方式，并保留人工决策。', [
    '客户已确认供应商问题：$problem',
    if (constrained) '更换意愿或替代难度要求控制投入',
  ]);
}
