// presentation/dashboard/modules/models/module_model.dart
class Module {
  final int id;
  final String name;
  final String slug;
  final String? attachment;
  final String? description;
  final int status;
  final int createdBy;
  final int updatedBy;
  final int? deletedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Module({
    required this.id,
    required this.name,
    required this.slug,
    this.attachment,
    this.description,
    required this.status,
    required this.createdBy,
    required this.updatedBy,
    this.deletedBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      attachment: json['attachment'],
      description: json['description'],
      status: json['status'] ?? 1,
      createdBy: json['created_by'] ?? 0,
      updatedBy: json['updated_by'] ?? 0,
      deletedBy: json['deleted_by'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'attachment': attachment,
      'description': description,
      'status': status,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'deleted_by': deletedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // Helper method untuk mendapatkan URL attachment lengkap
  String? get fullAttachmentUrl {
    if (attachment == null) return null;
    return 'http://sirangga.satelliteorbit.cloud/$attachment';
  }

  // Helper method untuk mendapatkan ekstensi file
  String? get attachmentExtension {
    if (attachment == null) return null;
    return attachment!.split('.').last.toLowerCase();
  }

  // Helper method untuk mengecek apakah file adalah PDF
  bool get isPdfFile {
    return attachmentExtension == 'pdf';
  }

  // Helper method untuk mengecek apakah modul aktif
  bool get isActive {
    return status == 1;
  }
}

// Response wrapper untuk pagination
class ModuleResponse {
  final int currentPage;
  final List<Module> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  ModuleResponse({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory ModuleResponse.fromJson(Map<String, dynamic> json) {
    return ModuleResponse(
      currentPage: json['current_page'] ?? 1,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => Module.fromJson(item))
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      links:
          (json['links'] as List<dynamic>?)
              ?.map((item) => PaginationLink.fromJson(item))
              .toList() ??
          [],
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPrevPage => prevPageUrl != null;
  bool get hasData => data.isNotEmpty;
}

class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  PaginationLink({this.url, required this.label, required this.active});

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}
