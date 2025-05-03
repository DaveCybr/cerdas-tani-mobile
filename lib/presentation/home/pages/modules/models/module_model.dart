import 'dart:convert';

class ModuleModel {
  final List<Module> data;

  ModuleModel({required this.data});

  factory ModuleModel.fromJson(String str) =>
      ModuleModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ModuleModel.fromMap(Map<String, dynamic> json) {
    return ModuleModel(
      data: json["data"] != null
          ? List<Module>.from(json["data"].map((x) => Module.fromMap(x)))
          : [], // Jika data kosong, return List kosong
    );
  }

  Map<String, dynamic> toMap() => {
        "data": data.map((x) => x.toMap()).toList(),
      };
}

class Module {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String attachment;

  Module({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.attachment,
  });

  factory Module.fromJson(String str) => Module.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Module.fromMap(Map<String, dynamic> json) {
    return Module(
      id: json["id"],
      name: json["name"] ?? "Tanpa Judul",
      slug: json["slug"] ?? "Tanpa Slug",
      description: json["description"] ?? "Tanpa Deskripsi",
      attachment: json["attachment"] ?? "Tanpa Lampiran",
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "slug": slug,
        "description": description,
        "attachment": attachment,
      };
}
