import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class HomeData extends Equatable {
  const HomeData({this.name, this.odoo_Home_id});

  final String? name;
  final int? odoo_Home_id;

  @override
  List<Object?> get props => [odoo_Home_id, name];

  HomeData copyWith({String? name, int? odoo_Home_id}) => HomeData(
      name: name ?? this.name,
      odoo_Home_id: odoo_Home_id ?? this.odoo_Home_id);
}
