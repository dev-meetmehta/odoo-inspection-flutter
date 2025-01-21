import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/material_list/home_list.dart';
part 'home_data_model.g.dart';

@JsonSerializable()
@immutable
class HomeDataModel extends MaterialData {
  int? odoo_home_id;
  String? name;


  HomeDataModel({this.odoo_home_id, this.name});

  Map<String, dynamic> toJson() => _$HomeDataModelToJson(this);

  factory HomeDataModel.fromJson(Map<String, dynamic> json) =>
      _$HomeDataModelFromJson(json);
}