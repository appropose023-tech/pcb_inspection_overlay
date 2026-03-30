class PCBDefect {
  final int x, y, w, h;
  PCBDefect({required this.x, required this.y, required this.w, required this.h});

  factory PCBDefect.fromJson(Map<String, dynamic> json) {
    return PCBDefect(
      x: json['x'],
      y: json['y'],
      w: json['w'],
      h: json['h'],
    );
  }
}

class InspectionResult {
  final int defectCount;
  final List<PCBDefect> defects;

  InspectionResult({required this.defectCount, required this.defects});

  factory InspectionResult.fromJson(Map<String, dynamic> json) {
    List defects = json['defects'] ?? [];
    return InspectionResult(
      defectCount: json['defect_count'] ?? 0,
      defects: defects.map((e) => PCBDefect.fromJson(e)).toList(),
    );
  }
}
