import '../../model/material_list/material_list_model.dart';

abstract class MaterialListDataSourceRepository {
  Future<MaterialListDataModel> getMaterialListData();
}
