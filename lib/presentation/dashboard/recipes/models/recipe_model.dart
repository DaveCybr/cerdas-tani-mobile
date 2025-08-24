// ========================================
// 1. HYDROBUDDY-STYLE MODEL - recipe_model.dart
// ========================================

class RecipeModel {
  final int? id;
  final String name;
  final String type; // 'VEGETATIVE', 'GENERATIVE', 'BLOOM', etc.

  // Primary Nutrients (as ions - HydroBuddy style)
  final double nitrateNitrogen; // N_NO3 (ppm)
  final double ammoniumNitrogen; // N_NH4 (ppm)
  final double calcium; // Ca (ppm)
  final double sulfur; // S (ppm)
  final double potassium; // K (ppm)
  final double phosphorus; // P (ppm)
  final double magnesium; // Mg (ppm)

  // Micronutrients (ppm)
  final double iron; // Fe
  final double manganese; // Mn
  final double zinc; // Zn
  final double boron; // B
  final double copper; // Cu
  final double molybdenum; // Mo

  // Optional fields
  final DateTime createdAt;
  final DateTime updatedAt;

  RecipeModel({
    this.id,
    required this.name,
    required this.type,
    required this.nitrateNitrogen,
    required this.ammoniumNitrogen,
    required this.calcium,
    required this.sulfur,
    required this.potassium,
    required this.phosphorus,
    required this.magnesium,
    required this.iron,
    required this.manganese,
    required this.zinc,
    required this.boron,
    required this.copper,
    required this.molybdenum,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Calculate total nitrogen (N_NO3 + N_NH4)
  double get totalNitrogen => nitrateNitrogen + ammoniumNitrogen;

  // Calculate N ratio (useful for plant growth phases)
  double get nitrateRatio =>
      totalNitrogen > 0 ? (nitrateNitrogen / totalNitrogen) * 100 : 0;
  double get ammoniumRatio =>
      totalNitrogen > 0 ? (ammoniumNitrogen / totalNitrogen) * 100 : 0;

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'nitrate_nitrogen': nitrateNitrogen,
      'ammonium_nitrogen': ammoniumNitrogen,
      'calcium': calcium,
      'sulfur': sulfur,
      'potassium': potassium,
      'phosphorus': phosphorus,
      'magnesium': magnesium,
      'iron': iron,
      'manganese': manganese,
      'zinc': zinc,
      'boron': boron,
      'copper': copper,
      'molybdenum': molybdenum,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Map
  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      nitrateNitrogen: map['nitrate_nitrogen']?.toDouble() ?? 0.0,
      ammoniumNitrogen: map['ammonium_nitrogen']?.toDouble() ?? 0.0,
      calcium: map['calcium']?.toDouble() ?? 0.0,
      sulfur: map['sulfur']?.toDouble() ?? 0.0,
      potassium: map['potassium']?.toDouble() ?? 0.0,
      phosphorus: map['phosphorus']?.toDouble() ?? 0.0,
      magnesium: map['magnesium']?.toDouble() ?? 0.0,
      iron: map['iron']?.toDouble() ?? 0.0,
      manganese: map['manganese']?.toDouble() ?? 0.0,
      zinc: map['zinc']?.toDouble() ?? 0.0,
      boron: map['boron']?.toDouble() ?? 0.0,
      copper: map['copper']?.toDouble() ?? 0.0,
      molybdenum: map['molybdenum']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Copy with method for updates
  RecipeModel copyWith({
    int? id,
    String? name,
    String? type,
    double? nitrateNitrogen,
    double? ammoniumNitrogen,
    double? calcium,
    double? sulfur,
    double? potassium,
    double? phosphorus,
    double? magnesium,
    double? iron,
    double? manganese,
    double? zinc,
    double? boron,
    double? copper,
    double? molybdenum,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      nitrateNitrogen: nitrateNitrogen ?? this.nitrateNitrogen,
      ammoniumNitrogen: ammoniumNitrogen ?? this.ammoniumNitrogen,
      calcium: calcium ?? this.calcium,
      sulfur: sulfur ?? this.sulfur,
      potassium: potassium ?? this.potassium,
      phosphorus: phosphorus ?? this.phosphorus,
      magnesium: magnesium ?? this.magnesium,
      iron: iron ?? this.iron,
      manganese: manganese ?? this.manganese,
      zinc: zinc ?? this.zinc,
      boron: boron ?? this.boron,
      copper: copper ?? this.copper,
      molybdenum: molybdenum ?? this.molybdenum,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, double> get targets => {
    'NO3': nitrateNitrogen,
    'NH4': ammoniumNitrogen,
    'P': phosphorus,
    'K': potassium,
    'Ca': calcium,
    'Mg': magnesium,
    'S': sulfur,
    'Fe': iron,
    'Mn': manganese,
    'Zn': zinc,
    'B': boron,
    'Cu': copper,
    'Mo': molybdenum,
  };

  // Factory for creating common hydroponic recipes (HydroBuddy style)

  // Lettuce/Leafy Greens Recipe
  factory RecipeModel.lettuce({
    String name = 'Lettuce (Leafy Greens)',
    String? description,
    String? brand,
    double? price,
  }) {
    return RecipeModel(
      name: name,
      type: 'VEGETATIVE',
      nitrateNitrogen: 190,
      ammoniumNitrogen: 10,
      calcium: 170,
      sulfur: 30,
      potassium: 210,
      phosphorus: 40,
      magnesium: 40,
      iron: 3.0,
      manganese: 0.8,
      zinc: 0.3,
      boron: 0.5,
      copper: 0.1,
      molybdenum: 0.05,
    );
  }

  @override
  String toString() {
    return 'RecipeModel(id: $id, name: $name, type: $type, Total N: ${totalNitrogen.toStringAsFixed(1)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
