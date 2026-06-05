import 'package:lost_n_found/features/batch/domain/entities/batch_entity.dart';

class BatchApiModel {
  final String? id;
  final String batchName;
  final String? status;

  BatchApiModel({this.id, required this.batchName, this.status});

  // From JSON
  factory BatchApiModel.fromJson(Map<String, dynamic> json) {
    return BatchApiModel(
      id: json['_id'] as String?,
      batchName: json['batchName'] as String,
      status: json['status'] as String,
    );
  }

  //  TO JSON
  Map<String, dynamic> toJson() {
    return {'batchName': batchName};
  }

  // To entity
  BatchEntity toEntity() {
    return BatchEntity(batchId: id, batchName: batchName, status: status);
  }

  // From Entity
  factory BatchApiModel.fromEntity(BatchEntity entity) {
    return BatchApiModel(
      id: entity.batchId,
      batchName: entity.batchName,
      status: entity.status,
    );
  }

  // List Conversion
  static List<BatchEntity> toEntityList(List<BatchApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
