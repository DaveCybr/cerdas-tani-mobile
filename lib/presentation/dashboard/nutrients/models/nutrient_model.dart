// ========================================
// FIXED NUTRIENT MODEL - nutrient_model.dart
// ========================================

class NutrientModel {
  final int? id;
  final String name;
  final String formula;
  final String type; // 'A' or 'B'
  final double pricePerKg;

  // Macronutrients (%)
  final double nh4; // Ammonium nitrogen (%)
  final double no3; // Nitrate nitrogen (%)
  final double p; // Phosphorus (%)
  final double k; // Potassium (%)
  final double ca; // Calcium (%)
  final double mg; // Magnesium (%)
  final double s; // Sulfur (%)

  // Micronutrients (ppm)
  final double fe; // Iron
  final double mn; // Manganese
  final double zn; // Zinc
  final double b; // Boron
  final double cu; // Copper
  final double mo; // Molybdenum

  final DateTime createdAt;
  final DateTime updatedAt;

  NutrientModel({
    this.id,
    required this.name,
    required this.formula,
    required this.type,
    required this.pricePerKg,
    this.nh4 = 0.0,
    this.no3 = 0.0,
    this.p = 0.0,
    this.k = 0.0,
    this.ca = 0.0,
    this.mg = 0.0,
    this.s = 0.0,
    this.fe = 0.0,
    this.mn = 0.0,
    this.zn = 0.0,
    this.b = 0.0,
    this.cu = 0.0,
    this.mo = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Helper getters with null safety
  double get totalNitrogen => (nh4) + (no3);

  String get nutrientProfile {
    List<String> nutrients = [];
    if (totalNitrogen > 0) nutrients.add('N');
    if (p > 0) nutrients.add('P');
    if (k > 0) nutrients.add('K');
    if (ca > 0) nutrients.add('Ca');
    if (mg > 0) nutrients.add('Mg');
    if (s > 0) nutrients.add('S');
    return nutrients.join('-');
  }

  // Safe conversion helper
  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  static String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'formula': formula,
      'type': type,
      'price_per_kg': pricePerKg,
      'nh4': nh4,
      'no3': no3,
      'p': p,
      'k': k,
      'ca': ca,
      'mg': mg,
      's': s,
      'fe': fe,
      'mn': mn,
      'zn': zn,
      'b': b,
      'cu': cu,
      'mo': mo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Map with safe parsing
  factory NutrientModel.fromMap(Map<String, dynamic> map) {
    try {
      // Safe parsing for DateTime
      DateTime parseDateTime(dynamic value) {
        if (value == null) return DateTime.now();
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (e) {
            return DateTime.now();
          }
        }
        return DateTime.now();
      }

      return NutrientModel(
        id: map['id'] != null ? _safeInt(map['id']) : null,
        name: _safeString(map['name']),
        formula: _safeString(map['formula']),
        type: _safeString(map['type']).isEmpty ? 'A' : _safeString(map['type']),
        pricePerKg: _safeDouble(map['price_per_kg']),
        nh4: _safeDouble(map['nh4']),
        no3: _safeDouble(map['no3']),
        p: _safeDouble(map['p']),
        k: _safeDouble(map['k']),
        ca: _safeDouble(map['ca']),
        mg: _safeDouble(map['mg']),
        s: _safeDouble(map['s']),
        fe: _safeDouble(map['fe']),
        mn: _safeDouble(map['mn']),
        zn: _safeDouble(map['zn']),
        b: _safeDouble(map['b']),
        cu: _safeDouble(map['cu']),
        mo: _safeDouble(map['mo']),
        createdAt: parseDateTime(map['created_at']),
        updatedAt: parseDateTime(map['updated_at']),
      );
    } catch (e) {
      // Return a default model if parsing fails completely
      print('Error parsing NutrientModel: $e');
      return NutrientModel(
        name: 'Unknown',
        formula: 'Unknown',
        type: 'A',
        pricePerKg: 0.0,
      );
    }
  }

  // Copy with method
  NutrientModel copyWith({
    int? id,
    String? name,
    String? formula,
    String? type,
    double? pricePerKg,
    double? nh4,
    double? no3,
    double? p,
    double? k,
    double? ca,
    double? mg,
    double? s,
    double? fe,
    double? mn,
    double? zn,
    double? b,
    double? cu,
    double? mo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NutrientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      formula: formula ?? this.formula,
      type: type ?? this.type,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      nh4: nh4 ?? this.nh4,
      no3: no3 ?? this.no3,
      p: p ?? this.p,
      k: k ?? this.k,
      ca: ca ?? this.ca,
      mg: mg ?? this.mg,
      s: s ?? this.s,
      fe: fe ?? this.fe,
      mn: mn ?? this.mn,
      zn: zn ?? this.zn,
      b: b ?? this.b,
      cu: cu ?? this.cu,
      mo: mo ?? this.mo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'NutrientModel(name: $name, formula: $formula, type: $type, nutrients: $nutrientProfile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NutrientModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
