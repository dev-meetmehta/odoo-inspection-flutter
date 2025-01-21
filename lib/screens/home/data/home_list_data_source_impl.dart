import '../../../../../core/api/api_repository.dart';
import '../../../../../core/enums/response_type_enum.dart';
import '../../../../../core/utils/errors/exceptions.dart';
import '../../model/material_list/material_list_model.dart';
import 'home_list_data_source_repository.dart';

class HomeListDataSourceImpl
    implements HomeListDataSourceRepository {
  HomeListDataSourceImpl(
      {required this.api,
      required this.token,
      required this.user_id});

  final String token;
  final int user_id;

  @override
  Future<void> getHomeListData() async {
    final jsonResponse =
        await api.post(route: '/data-home', dataType: tDataType, body: {
          "jsonrpc":"2.0",
        });
    try {

      return HomeListDataModel.fromJson(data!['home']);
    } catch (e, stacktrace) {
      throw " ";
    }
  }
}
