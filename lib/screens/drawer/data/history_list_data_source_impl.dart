import '../../../../../core/api/api_repository.dart';
import '../../../../../core/enums/response_type_enum.dart';
import '../../../../../core/utils/errors/exceptions.dart';
import '../../model/material_list/material_list_model.dart';
import 'history_list_data_source_repository.dart';

class HistoryListDataSourceImpl
    implements HistoryListDataSourceRepository {
  HistoryListDataSourceImpl(
      {required this.api,
      required this.token,
      required this.user_id});

  final String token;
  final int user_id;

  @override
  Future<void> getHistoryListData() async {
    final jsonResponse =
        await api.post(route: '/history-data', dataType: tDataType, body: {
          "jsonrpc":"2.0",
        });
    try {

      return HistoryListDataModel.fromJson(['result']);
    } catch (e, stacktrace) {
      throw stacktrace;
    }
  }
}
