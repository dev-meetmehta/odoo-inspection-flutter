import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class MaterialData extends Equatable {
  const MaterialData({this.name, this.odoo_material_id});

  final String? name;
  final int? odoo_material_id;

  @override
  List<Object?> get props => [odoo_material_id, name];

  MaterialData copyWith({String? name, int? odoo_material_id}) => MaterialData(
      name: name ?? this.name,
      odoo_material_id: odoo_material_id ?? this.odoo_material_id);
}
