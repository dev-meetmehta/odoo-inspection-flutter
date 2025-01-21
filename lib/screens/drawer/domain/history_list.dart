import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class HistoryData extends Equatable {
  const HistoryData({this.name, this.odoo_History_id});

  final String? name;
  final int? odoo_History_id;

  @override
  List<Object?> get props => [odoo_History_id, name];

  HistoryData copyWith({String? name, int? odoo_History_id}) => HistoryData(
      name: name ?? this.name,
      odoo_History_id: odoo_History_id ?? this.odoo_History_id);
}
