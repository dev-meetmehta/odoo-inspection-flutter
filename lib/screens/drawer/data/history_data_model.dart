import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/History_list/History_list.dart';
part 'history_data_model.g.dart';

@JsonSerializable()
@immutable
class HistoryDataModel extends HistoryData {
  int? odoo_History_id;
  String? name;


  HistoryDataModel({this.odoo_History_id, this.name});

  Map<String, dynamic> toJson() => _$HistoryDataModelToJson(this);

  factory HistoryDataModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryDataModelFromJson(json);
}