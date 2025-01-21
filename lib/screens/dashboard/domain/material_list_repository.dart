import 'package:dartz/dartz.dart';

import '../../../../../core/utils/errors/failures.dart';
import '../../entities/material_list/material_list.dart';

abstract class MaterialListRepository {
  Future<Either> getMaterialListData();
}
