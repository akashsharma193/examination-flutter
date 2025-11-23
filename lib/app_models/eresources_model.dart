class EResourceModel {
  final String id;
  final String? name;
  final String? description;
  final String? orgCode;
  final String? batch;
  final String? topic;
  final String? url;
  final bool? isActive;
  final String? fileName;
  final String? fileType;
  final String? gridFsId;
  final int? fileSize;
  final String? created;
  final String? updated;
  final int? version;

  EResourceModel({
    required this.id,
    this.name,
    this.description,
    this.orgCode,
    this.batch,
    this.topic,
    this.url,
    this.isActive,
    this.fileName,
    this.fileType,
    this.gridFsId,
    this.fileSize,
    this.created,
    this.updated,
    this.version,
  });

  factory EResourceModel.fromJson(Map<String, dynamic> json) {
    return EResourceModel(
      id: json['id'] ?? '',
      name: json['name'],
      description: json['description'],
      orgCode: json['orgCode'],
      batch: json['batch'],
      topic: json['topic'],
      url: json['url'],
      isActive: json['isActive'],
      fileName: json['fileName'],
      fileType: json['fileType'],
      gridFsId: json['gridFsId'],
      fileSize: json['fileSize'],
      created: json['created'],
      updated: json['updated'],
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'orgCode': orgCode,
      'batch': batch,
      'topic': topic,
      'url': url,
      'isActive': isActive,
      'fileName': fileName,
      'fileType': fileType,
      'gridFsId': gridFsId,
      'fileSize': fileSize,
      'created': created,
      'updated': updated,
      'version': version,
    };
  }
}
