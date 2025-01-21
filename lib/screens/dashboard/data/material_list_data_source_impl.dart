import '../../../../../core/api/api_repository.dart';
import '../../../../../core/enums/response_type_enum.dart';
import '../../../../../core/utils/errors/exceptions.dart';
import '../../model/material_list/material_list_model.dart';
import 'material_list_data_source_repository.dart';

class MaterialListDataSourceImpl
    implements MaterialListDataSourceRepository {
  MaterialListDataSourceImpl(
      {required this.api,
      required this.token,
      required this.user_id});

  final String token;
  final int user_id;

  @override
  Future<void> getMaterialListData() async {
    final jsonResponse =
        await api.post(route: '/data-material', dataType: tDataType, body: {
          "jsonrpc":"2.0",
        });
    try {

      return MaterialListDataModel.fromJson(['data']);
    } catch (e, stacktrace) {
      throw stacktrace;
    }
  }
}
