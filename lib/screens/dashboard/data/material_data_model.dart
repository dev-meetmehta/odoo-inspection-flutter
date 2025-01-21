import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/material_list/material_list.dart';
part 'material_data_model.g.dart';

@JsonSerializable()
@immutable
class MaterialDataModel extends MaterialData {
  int? odoo_material_id;
  String? name;


  MaterialDataModel({this.odoo_material_id, this.name});

  Map<String, dynamic> toJson() => _$MaterialDataModelToJson(this);

  factory MaterialDataModel.fromJson(Map<String, dynamic> json) =>
      _$MaterialDataModelFromJson(json);
}