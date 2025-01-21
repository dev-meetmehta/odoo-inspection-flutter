import 'package:dartz/dartz.dart';
import '../../../../../core/network_info/network_info_repository.dart';
import '../../../../../core/utils/errors/failures.dart';
import '../../../domain/entities/Home_list/history_list.dart';
import '../../../domain/repositories/Home_list/home_list_repository.dart';
import '../../datasources/Home_list/history_list_data_source_repository.dart';

class HomeListRepositoryImpl implements HomeListRepository {
  HomeListRepositoryImpl();

  @override
  Future<Either> getHomeListData() async {
    try {
      final inspection =
          await HomeListDataSourceRepository.getHomeListData();
      return Right(inspection);
    }
  }
}
