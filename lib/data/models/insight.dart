enum InsightSeverity { info, opportunity, warning, critical }

class Insight {
  const Insight({
    required this.id,
    required this.title,
    required this.summary,
    required this.severity,
    required this.createdAt,
    this.recommendation = '',
    this.estimatedImpact = '',
    this.relatedEntity = '',
    this.action = '',
  });

  final String id;
  final String title;
  final String summary;
  final InsightSeverity severity;
  final DateTime createdAt;
  final String recommendation;
  final String estimatedImpact;
  final String relatedEntity;
  final String action;
}
