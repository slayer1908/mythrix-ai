/// IF-THIS-THEN-THAT engine for ad campaigns. Matches Revealbot's mental model.

enum RuleTrigger {
  roasBelow, roasAbove,
  ctrBelow, ctrAbove,
  cpaAbove, cpaBelow,
  spendAbove, spendBelow,
  conversionsBelow, conversionsAbove,
  budgetPacing, // e.g. 110% of pace
  timeOfDay,
  audienceFatigue, // frequency > X
}

extension RuleTriggerX on RuleTrigger {
  String get label {
    switch (this) {
      case RuleTrigger.roasBelow: return 'ROAS drops below';
      case RuleTrigger.roasAbove: return 'ROAS climbs above';
      case RuleTrigger.ctrBelow: return 'CTR drops below';
      case RuleTrigger.ctrAbove: return 'CTR climbs above';
      case RuleTrigger.cpaAbove: return 'CPA exceeds';
      case RuleTrigger.cpaBelow: return 'CPA falls under';
      case RuleTrigger.spendAbove: return 'Daily spend exceeds';
      case RuleTrigger.spendBelow: return 'Daily spend below';
      case RuleTrigger.conversionsBelow: return 'Conversions drop below';
      case RuleTrigger.conversionsAbove: return 'Conversions exceed';
      case RuleTrigger.budgetPacing: return 'Budget pacing exceeds';
      case RuleTrigger.timeOfDay: return 'At a specific time';
      case RuleTrigger.audienceFatigue: return 'Frequency exceeds';
    }
  }

  String get unit {
    switch (this) {
      case RuleTrigger.roasBelow:
      case RuleTrigger.roasAbove:
        return '×';
      case RuleTrigger.ctrBelow:
      case RuleTrigger.ctrAbove:
      case RuleTrigger.budgetPacing:
        return '%';
      case RuleTrigger.cpaAbove:
      case RuleTrigger.cpaBelow:
      case RuleTrigger.spendAbove:
      case RuleTrigger.spendBelow:
        return '\$';
      case RuleTrigger.conversionsBelow:
      case RuleTrigger.conversionsAbove:
        return '';
      case RuleTrigger.timeOfDay:
        return ':00';
      case RuleTrigger.audienceFatigue:
        return 'imp/user';
    }
  }
}

enum RuleAction {
  pause, resume,
  increaseBudgetPct, decreaseBudgetPct,
  changeBidStrategy,
  notifyMythrix,
  notifySlack,
  notifyEmail,
  duplicateCampaign,
  rotateCreative,
  shiftBudgetTo,
}

extension RuleActionX on RuleAction {
  String get label {
    switch (this) {
      case RuleAction.pause: return 'Pause the ad set';
      case RuleAction.resume: return 'Resume the ad set';
      case RuleAction.increaseBudgetPct: return 'Increase budget by';
      case RuleAction.decreaseBudgetPct: return 'Decrease budget by';
      case RuleAction.changeBidStrategy: return 'Switch bid strategy';
      case RuleAction.notifyMythrix: return 'Send Mythrix notification';
      case RuleAction.notifySlack: return 'Send Slack alert';
      case RuleAction.notifyEmail: return 'Send email alert';
      case RuleAction.duplicateCampaign: return 'Duplicate campaign';
      case RuleAction.rotateCreative: return 'Rotate to next creative';
      case RuleAction.shiftBudgetTo: return 'Shift budget to winning ad set';
    }
  }
}

enum RuleScope { allCampaigns, specificCampaign, specificAdSet, specificAdNetwork }

class AutomationRule {
  AutomationRule({
    required this.id,
    required this.name,
    required this.trigger,
    required this.triggerValue,
    required this.action,
    this.actionValue,
    this.scope = RuleScope.allCampaigns,
    this.scopeTarget,
    this.enabled = true,
    DateTime? createdAt,
    this.timesFired = 0,
    this.lastFiredAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  String name;
  RuleTrigger trigger;
  double triggerValue;
  RuleAction action;
  double? actionValue;
  RuleScope scope;
  String? scopeTarget;
  bool enabled;
  final DateTime createdAt;
  int timesFired;
  DateTime? lastFiredAt;

  String get summary {
    final triggerPart = '${trigger.label} ${triggerValue.toStringAsFixed(triggerValue % 1 == 0 ? 0 : 2)}${trigger.unit}';
    final actionPart = actionValue != null
        ? '${action.label} ${actionValue!.toStringAsFixed(0)}%'
        : action.label;
    return 'WHEN $triggerPart → $actionPart';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'trigger': trigger.name,
        'triggerValue': triggerValue,
        'action': action.name,
        'actionValue': actionValue,
        'scope': scope.name,
        'scopeTarget': scopeTarget,
        'enabled': enabled,
        'createdAt': createdAt.toIso8601String(),
        'timesFired': timesFired,
        'lastFiredAt': lastFiredAt?.toIso8601String(),
      };

  static AutomationRule fromMap(Map<dynamic, dynamic> m) => AutomationRule(
        id: m['id'] as String,
        name: m['name'] as String? ?? 'Untitled rule',
        trigger: RuleTrigger.values.firstWhere(
          (t) => t.name == m['trigger'],
          orElse: () => RuleTrigger.roasBelow,
        ),
        triggerValue: (m['triggerValue'] as num?)?.toDouble() ?? 0,
        action: RuleAction.values.firstWhere(
          (a) => a.name == m['action'],
          orElse: () => RuleAction.notifyMythrix,
        ),
        actionValue: (m['actionValue'] as num?)?.toDouble(),
        scope: RuleScope.values.firstWhere(
          (s) => s.name == m['scope'],
          orElse: () => RuleScope.allCampaigns,
        ),
        scopeTarget: m['scopeTarget'] as String?,
        enabled: m['enabled'] as bool? ?? true,
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
        timesFired: (m['timesFired'] as num?)?.toInt() ?? 0,
        lastFiredAt: m['lastFiredAt'] != null
            ? DateTime.tryParse(m['lastFiredAt'] as String)
            : null,
      );
}

/// Pre-built templates the user can one-click adopt.
const kRuleTemplates = <Map<String, dynamic>>[
  {
    'name': 'Pause when ROAS drops below 1.3×',
    'trigger': RuleTrigger.roasBelow,
    'triggerValue': 1.3,
    'action': RuleAction.pause,
    'actionValue': null,
  },
  {
    'name': 'Scale winners — increase budget 20% when ROAS > 3×',
    'trigger': RuleTrigger.roasAbove,
    'triggerValue': 3.0,
    'action': RuleAction.increaseBudgetPct,
    'actionValue': 20.0,
  },
  {
    'name': 'Kill fatigue — pause when frequency > 4 impressions/user',
    'trigger': RuleTrigger.audienceFatigue,
    'triggerValue': 4.0,
    'action': RuleAction.pause,
    'actionValue': null,
  },
  {
    'name': 'Slow down overspend — pause when daily spend > \$500',
    'trigger': RuleTrigger.spendAbove,
    'triggerValue': 500.0,
    'action': RuleAction.pause,
    'actionValue': null,
  },
  {
    'name': 'Wake me up — Slack alert when CPA > \$80',
    'trigger': RuleTrigger.cpaAbove,
    'triggerValue': 80.0,
    'action': RuleAction.notifySlack,
    'actionValue': null,
  },
  {
    'name': 'Refresh creative — rotate when CTR drops below 1.2%',
    'trigger': RuleTrigger.ctrBelow,
    'triggerValue': 1.2,
    'action': RuleAction.rotateCreative,
    'actionValue': null,
  },
  {
    'name': 'Throttle pacing — reduce budget 15% when pacing > 110%',
    'trigger': RuleTrigger.budgetPacing,
    'triggerValue': 110.0,
    'action': RuleAction.decreaseBudgetPct,
    'actionValue': 15.0,
  },
];
