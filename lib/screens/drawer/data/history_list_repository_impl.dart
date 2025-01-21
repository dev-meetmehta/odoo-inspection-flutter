import 'package:dartz/dartz.dart';
import '../../../../../core/network_info/network_info_repository.dart';
import '../../../../../core/utils/errors/failures.dart';
import '../../../domain/entities/History_list/History_list.dart';
import '../../../domain/repositories/History_list/History_list_repository.dart';
import '../../datasources/History_list/history_list_data_source_repository.dart';

class HistoryListRepositoryImpl implements HistoryListRepository {
  HistoryListRepositoryImpl();

  @override
  Future<Failure> getHistoryListData() async {
    try {
      final inspection =
          await HistoryListDataSourceRepository.getHistoryListData();
      return Right(inspection);
    }
  }
}
