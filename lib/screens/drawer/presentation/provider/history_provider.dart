import '../../../commons/providers/api_provider.dart';
import '../widgets/History_exports.dart';

final HistoryProvider = ChangeNotifierProvider<HistoryNotifier>((ref) {
  final userData = ref.read(userCredentialProvider);
  final api = ref.read(apiDataProvider);
  return HistoryNotifier(
      ref: ref,
      api: api,
      failureState: ref.read(failureProvider.notifier),
      userCredential: userData,
      sql: ref.read(sqfliteStorageImplProvider));
});

class HistoryNotifier extends ChangeNotifier {
  final Ref ref;
  final UserCredential userCredential;
  final SqfliteStorageRepository sql;
  ApiDataRepo api;

  HistoryNotifier(
      {required this.ref,
      required this.failureState,
      required this.sql,
      required this.api,
      required this.userCredential})
      : super() {
    _initMethod();
  }

  //----------------------------init Method------------------------------------------------------------

  Future<void> _initMethod() async {
    statusDropdownController = DropdownController();
    typeDropdownController = DropdownController();
    AssignToDropdownController = DropdownController();
    buyerDropdownController = DropdownController();
    vendorToDropdownController = DropdownController();
    scrollController = ScrollController();
    scrollController = ScrollController()..addListener(_scrollListener);
    _dialogCalendarPickerValue = [
      DateTime(2023, 01, 01),
      DateTime.now().add(Duration(days: 15)),
    ];
    final jsonString =
        await ref.read(secureStorageImplProvider).getItem(keyInspectionType);
    final itemData = InspectionListTypeModel.fromJson(json.decode(jsonString!));
    _localInspectionList = await sql.getAllInspectionList(userCredential.uid!);
    if (itemData.inspection_type_list!.isNotEmpty &&
        itemData.inspection_type_list!.first.odoo_inspection_type_id != null) {
      _inspectionType = itemData.inspection_type_list!
          .map((e) => CoolDropdownItem<String>(
              label: e.name!, value: e.odoo_inspection_type_id!.toString()))
          .toList();
      int i = 0;
      setFromDate(
          "${_dialogCalendarPickerValue[i]?.year}-${(_dialogCalendarPickerValue[i]!.month < 10) ? "0" : ""}${_dialogCalendarPickerValue[i]?.month}-${(_dialogCalendarPickerValue[i]!.day < 10) ? "0" : ""}${_dialogCalendarPickerValue[i]?.day}");
      if (_dialogCalendarPickerValue.length > 1) {
        i = 1;
      }
      setToDate(
          "${_dialogCalendarPickerValue[i]?.year}-${(_dialogCalendarPickerValue[i]!.month < 10) ? "0" : ""}${_dialogCalendarPickerValue[i]?.month}-${(_dialogCalendarPickerValue[i]!.day < 10) ? "0" : ""}${_dialogCalendarPickerValue[i]?.day}");
    }
  }

  //----------------------------dropdown Controller------------------------------------------------------------

  late DropdownController statusDropdownController;
  late DropdownController typeDropdownController;
  late DropdownController AssignToDropdownController;
  late DropdownController buyerDropdownController;
  late DropdownController vendorToDropdownController;
  late ScrollController scrollController;

  StateController<Failure?> failureState;

  TextEditingController editingController = TextEditingController();

  //============================Saved Inspection List========================================================================

  List<InspectionList> _localInspectionList = [];

  List<InspectionList> get localInspectionList => _localInspectionList;

  bool checkInspectionLocally(InspectionsItem value) {
    bool isMatched = false;
    for (var data in _localInspectionList) {
      if (data.inspection_id.toString() == value.inspection_id.toString()) {
        isMatched = true;
        break;
      }
    }
    return isMatched;
  }

  //============================Saved Inspection Locally========================================================================

  savedInspectionLocally(InspectionsItem value) async {
    final _time = DateTime.now().toString();
    ref.read(isLoadingStateProvider(LoaderWidgetId.homeScreen).notifier).state =
        true;
    final data = InspectionList(
        inspection_id: value.inspection_id.toString(),
        vendor_product_code: value.vendor_product_code,
        vendor: value.vendor,
        sku_no: value.sku_no,
        product_name: value.product_name,
        buyer_product_code: value.buyer_product_code,
        is_submit: false,
        is_download_complete: false,
        is_inspection_desc_start: false,
        is_inspection_desc_complete: false,
        is_defect_desc_start: false,
        is_defect_desc_complete: false,
        is_download: true,
        is_defect_image_complete: false,
        is_defect_image_start: false,
        desc_id: '0',
        is_inspection_image_complete: false,
        is_inspection_image_start: false,
        is_assembly: false,
        is_bone: false,
        is_cane: false,
        is_complete_data: false,
        is_construction: false,
        is_finish: false,
        is_functionality: false,
        is_glass: false,
        is_handling: false,
        is_hardware: false,
        is_jute: false,
        is_leather: false,
        is_lighting: false,
        is_marble: false,
        is_metal: false,
        is_mirrors: false,
        is_outdoor: false,
        is_packaging: false,
        is_paper: false,
        is_plastic: false,
        is_quality: false,
        is_resin: false,
        is_submit_complete: false,
        is_testing: false,
        is_upholstery: false,
        is_wax: false,
        is_wood: false,
        int_value: "0",
        buyer: value.buyer,
        image: value.image,
        uid: userCredential.uid.toString(),
        buyer_order_no: value.buyer_order_no);

    _localInspectionList = await sql.insertInspectionList(data);
    try {


        _uomList = await api.uomListDataApi();
        _finishList = await api.finishListDataApi();
        _materialList = await api.materialListDataApi();

        if (_finishList != null) {
          if (_finishList!.isNotEmpty) {
            for (var _finishItem in _finishList!) {
              await sql.insertFinishList(InspectionFinishDB(
                  uid: userCredential.uid.toString(),
                  inspection_id: value.inspection_id.toString(),
                  name: _finishItem.name,
                  odoo_finish_id: _finishItem.odoo_finish_id.toString()));
            }
          }
        }

        _inspectionCompleteData = await api.inspectionCompleteDataApi(
            inpsectionID: value.inspection_id!);
        if (_inspectionCompleteData != null) {
          await sql.insertInspCompleteData(InspectionCompleteDataDB(
              uid: userCredential.uid.toString(),
              inspection_id: _inspectionCompleteData!.inspection_id.toString(),
              aql: _inspectionCompleteData!.aql,
              sku_no: _inspectionCompleteData!.sku_no,
              product_name: _inspectionCompleteData!.product_name,
              buyer: _inspectionCompleteData!.buyer,
              net_wt: _inspectionCompleteData!.net_wt,
              critical: _inspectionCompleteData!.critical,
              minor: _inspectionCompleteData!.minor,
              major: _inspectionCompleteData!.major,
              is_master_box2_finding: false,
              is_master_box3_finding: false,
              is_master_box_finding: false,
              is_wood_finding: false,
              is_upholstery_finding: false,
              is_metal_finding: false,
              is_glass_finding: false,
              is_marble_finding: false,
              is_construction_finding: false,
              is_finish_finding: false,
              is_assembly_finding: false,
              is_handling_finding: false,
              is_packaging_finding: false,
              is_hardware_finding: false,
              is_lighting_finding: false,
              is_functionality_finding: false,
              is_wax_finding: false,
              is_quality_finding: false,
              is_testing_finding: false,
              is_jute_finding: false,
              is_cane_finding: false,
              is_leather_finding: false,
              is_paper_finding: false,
              is_plastic_finding: false,
              is_resin_finding: false,
              is_bone_finding: false,
              is_outdoor_finding: false,
              is_mirrors_finding: false,
              vendor: _inspectionCompleteData!.vendor,
              inspection_state: _inspectionCompleteData!.inspection_state,
              vendor_product_code: _inspectionCompleteData!.vendor_product_code,
              buyer_product_code: _inspectionCompleteData!.buyer_product_code,
              buyer_order_no: _inspectionCompleteData!.buyer_order_no,
              image: _inspectionCompleteData!.image,
              plan_date: _inspectionCompleteData!.plan_date,
              inspection_type: _inspectionCompleteData!.inspection_type,
              achivement_date: _inspectionCompleteData!.achivement_date,
              ship_date: _inspectionCompleteData!.ship_date,
              vendor_date: _inspectionCompleteData!.vendor_date,
              factory_delivery: _inspectionCompleteData!.factory_delivery,
              team_id: _inspectionCompleteData!.team_id,
              assigned_to: _inspectionCompleteData!.assigned_to,
              sample_size: _inspectionCompleteData!.sample_size,
              aql_cr: _inspectionCompleteData!.aql_cr,
              aql_ma: _inspectionCompleteData!.aql_ma,
              aql_mi: _inspectionCompleteData!.aql_mi,
              total_cr: _inspectionCompleteData!.total_cr,
              total_ma: _inspectionCompleteData!.total_ma,
              total_mi: _inspectionCompleteData!.total_mi,
              terms_of_delivery: _inspectionCompleteData!.terms_of_delivery,
              product_spec_measure: _inspectionCompleteData!.product_spec_measure,
              product_spec_length:
              _inspectionCompleteData!.product_spec_length.toString(),
              product_spec_width:
              _inspectionCompleteData!.product_spec_width.toString(),
              product_spec_height:
              _inspectionCompleteData!.product_spec_height.toString(),
              product_spec_length_findings: _inspectionCompleteData!.product_spec_length_findings
                  .toString(),
              product_spec_width_findings:
              _inspectionCompleteData!.product_spec_width_findings.toString(),
              product_spec_height_findings: _inspectionCompleteData!
                  .product_spec_height_findings
                  .toString(),
              color: _inspectionCompleteData!.color,
              is_wood: _inspectionCompleteData!.is_wood,
              material: _inspectionCompleteData!.material,
              is_upholstery: _inspectionCompleteData!.is_upholstery,
              finish: _inspectionCompleteData!.finish,
              is_metal: _inspectionCompleteData!.is_metal,
              is_glass: _inspectionCompleteData!.is_glass,
              is_marble: _inspectionCompleteData!.is_marble,
              is_construction: _inspectionCompleteData!.is_construction,
              is_finish: _inspectionCompleteData!.is_finish,
              is_assembly: _inspectionCompleteData!.is_assembly,
              is_handling: _inspectionCompleteData!.is_handling,
              is_packaging: _inspectionCompleteData!.is_packaging,
              is_hardware: _inspectionCompleteData!.is_hardware,
              is_lighting: _inspectionCompleteData!.is_lighting,
              is_functionality: _inspectionCompleteData!.is_functionality,
              is_wax: _inspectionCompleteData!.is_wax,
              is_quality: _inspectionCompleteData!.is_quality,
              is_testing: _inspectionCompleteData!.is_testing,
              is_jute: _inspectionCompleteData!.is_jute,
              is_cane: _inspectionCompleteData!.is_cane,
              is_leather: _inspectionCompleteData!.is_leather,
              is_paper: _inspectionCompleteData!.is_paper,
              is_plastic: _inspectionCompleteData!.is_plastic,
              is_resin: _inspectionCompleteData!.is_resin,
              is_bone: _inspectionCompleteData!.is_bone,
              is_outdoor: _inspectionCompleteData!.is_outdoor,
              is_mirrors: _inspectionCompleteData!.is_mirrors,
              approved_sample: _inspectionCompleteData!.approved_sample,
              order_copy: _inspectionCompleteData!.order_copy,
              ordered_qty: _inspectionCompleteData!.ordered_qty.toString(),
              labelling: _inspectionCompleteData!.labelling,
              offered_qty: _inspectionCompleteData!.offered_qty.toString(),
              insp_qty: _inspectionCompleteData!.insp_qty.toString(),
              carton_packed: _inspectionCompleteData!.carton_packed.toString(),
              carton_inspected:
              _inspectionCompleteData!.carton_inspected.toString(),
              total_pass_qty: _inspectionCompleteData!.total_pass_qty.toString(),
              material_remark:
              _inspectionCompleteData!.material_remark.toString(),
              gross_wt: _inspectionCompleteData!.gross_wt.toString(),
              cbm: _inspectionCompleteData!.cbm.toString(),
              cft: _inspectionCompleteData!.cft.toString(),
              gross_wt_findings:
              _inspectionCompleteData!.gross_wt_findings.toString(),
              cbm_findings: _inspectionCompleteData!.cbm_findings.toString(),
              cft_findings: _inspectionCompleteData!.cft_findings.toString(),
              is_master_box: _inspectionCompleteData!.is_master_box,
              is_master_box2: _inspectionCompleteData!.is_master_box2,
              is_master_box3: _inspectionCompleteData!.is_master_box3,
              master_box_length:
              _inspectionCompleteData!.master_box_length.toString(),
              master_box_width:
              _inspectionCompleteData!.master_box_width.toString(),
              master_box_height:
              _inspectionCompleteData!.master_box_height.toString(),
              pieces_per_master:
              _inspectionCompleteData!.pieces_per_master.toString(),
              pieces_per_inner:
              _inspectionCompleteData!.pieces_per_inner.toString(),
              master_box_length_findings:
              _inspectionCompleteData!.master_box_length_findings.toString(),
              master_box_width_findings:
              _inspectionCompleteData!.master_box_width_findings.toString(),
              master_box_height_findings:
              _inspectionCompleteData!.master_box_height_findings.toString(),
              pieces_per_master_findings:
              _inspectionCompleteData!.pieces_per_master_findings.toString(),
              pieces_per_inner_findings: _inspectionCompleteData!.pieces_per_inner_findings.toString(),
              master_box_length2: _inspectionCompleteData!.master_box_length2.toString(),
              master_box_width2: _inspectionCompleteData!.master_box_width2.toString(),
              master_box_height2: _inspectionCompleteData!.master_box_height2.toString(),
              pieces_per_master2: _inspectionCompleteData!.pieces_per_master2.toString(),
              pieces_per_inner2: _inspectionCompleteData!.pieces_per_inner2.toString(),
              master_box_length2_findings: _inspectionCompleteData!.master_box_length2_findings.toString(),
              master_box_width2_findings: _inspectionCompleteData!.master_box_width2_findings.toString(),
              master_box_height2_findings: _inspectionCompleteData!.master_box_height2_findings.toString(),
              pieces_per_master2_findings: _inspectionCompleteData!.pieces_per_master2_findings.toString(),
              pieces_per_inner2_findings: _inspectionCompleteData!.pieces_per_inner2_findings.toString(),
              master_box_length3: _inspectionCompleteData!.master_box_length3.toString(),
              master_box_width3: _inspectionCompleteData!.master_box_width3.toString(),
              master_box_height3: _inspectionCompleteData!.master_box_height3.toString(),
              pieces_per_master3: _inspectionCompleteData!.pieces_per_master3.toString(),
              pieces_per_inner3: _inspectionCompleteData!.pieces_per_inner3.toString(),
              master_box_length3_findings: _inspectionCompleteData!.master_box_length3_findings.toString(),
              master_box_width3_findings: _inspectionCompleteData!.master_box_width3_findings.toString(),
              master_box_height3_findings: _inspectionCompleteData!.master_box_height3_findings.toString(),
              pieces_per_master3_findings: _inspectionCompleteData!.pieces_per_master3_findings.toString(),
              pieces_per_inner3_findings: _inspectionCompleteData!.pieces_per_inner3_findings.toString(),
              inspection_again: _inspectionCompleteData!.inspection_again,
              inspection_again_type: _inspectionCompleteData!.inspection_again_type,
              new_inspection: _inspectionCompleteData!.new_inspection,
              remark: _inspectionCompleteData!.remark,
              reason_pass_fail: _inspectionCompleteData!.reason_pass_fail));

          _inspectionCompleteDataDB = await sql.getInspCompleteData(
              _inspectionCompleteData!.inspection_id!.toString(), userCredential.uid!.toString());

        if (_materialList != null) {
          if (_materialList!.isNotEmpty) {
            for (var _materialItem in _materialList!) {
              await sql.insertMaterialList(InspectionMaterialDB(
                  uid: userCredential.uid.toString(),
                  inspection_id: value.inspection_id.toString(),
                  name: _materialItem.name,
                  odoo_material_id: _materialItem.odoo_material_id.toString()));
            }
          }
        }

        if (_uomList != null) {
          if (_uomList!.isNotEmpty) {
            for (var _uomItem in _uomList!) {
              await sql.insertUomList(InspectionUomDB(
                  uid: userCredential.uid.toString(),
                  inspection_id: value.inspection_id.toString(),
                  name: _uomItem.name,
                  odoo_uom_id: _uomItem.odoo_uom_id.toString()));
            }
          }
        }

        if (_inspectionCompleteData!.component_size_lines!.isNotEmpty) {
          for (var _component
              in _inspectionCompleteData!.component_size_lines!) {
            await sql.insertInspComponent(InspectionComponentDB(
                uid: userCredential.uid.toString(),
                inspection_id: _component.inspection_id.toString(),
                name: _component.name.toString(),
                uom_id: _component.uom_id.toString(),
                is_saved: false,
                material: _component.material.toString(),
                item_length: _component.item_length.toString(),
                item_width: _component.item_width.toString(),
                data_time: 'empty',
                item_height: _component.item_height.toString(),
                thickness_measurement:
                    _component.thickness_measurement.toString(),
                thickness: _component.thickness.toString(),
                dia: _component.dia.toString(),
                inner_dia: _component.inner_dia.toString(),
                outer_dia: _component.outer_dia.toString(),
                top_dia: _component.top_dia.toString(),
                bottom_dia: _component.bottom_dia.toString(),
                depth: _component.depth.toString(),
                circumference: _component.circumference.toString(),
                grammage: _component.grammage.toString(),
                finish_id: _component.finish_id.toString(),
                finish_ids: _component.finish_ids.toString(),
                barcode: _component.barcode.toString(),
                uom_id_findings: _component.uom_id_findings.toString(),
                material_findings: _component.material_findings.toString(),
                item_length_findings:
                    _component.item_length_findings.toString(),
                item_width_findings: _component.item_width_findings.toString(),
                item_height_findings:
                    _component.item_height_findings.toString(),
                thickness_measurement_findings:
                    _component.thickness_measurement_findings.toString(),
                thickness_findings: _component.thickness_findings.toString(),
                dia_findings: _component.dia_findings.toString(),
                inner_dia_findings: _component.inner_dia_findings.toString(),
                outer_dia_findings: _component.outer_dia_findings.toString(),
                top_dia_findings: _component.top_dia_findings.toString(),
                bottom_dia_findings: _component.bottom_dia_findings.toString(),
                depth_findings: _component.depth_findings.toString(),
                circumference_findings:
                    _component.circumference_findings.toString(),
                grammage_findings: _component.grammage_findings.toString(),
                finish_id_findings: _component.finish_id_findings.toString()));
          }
        }

        for (int i = 0; i < StringConstant().headNameList.length; i++) {
          print('[$i] ${StringConstant().headModelList[i]} string');
          List<HeadLineData>? data = await api.inspectionHeadLineDataApi(
              model: StringConstant().headModelList[i],
              method: StringConstant().headMethodList[i],
              inspection_id: value.inspection_id!);
          if (data!.isNotEmpty) {
            for (int j = 0; j < data.length; j++) {
              print('j = $j i = $i');
              final _data = await sql.insertHeadLineList(InspectionHeadsLinesDB(
                  inspection_id: value.inspection_id!.toString(),
                  uid: userCredential.uid.toString(),
                  head_id: StringConstant().headNameList[i],
                  data_time: _time,
                  head_name: data[j].head_name));
              await sql.insertHeadLineData(HeadsLinesDataDB(
                  uid: userCredential.uid.toString(),
                  inspection_id: value.inspection_id!.toString(),
                  head_name: data[j].head_name,
                  head_id: data[j].head_id.toString(),
                  image_url: "empty",
                  head_list_id: _data!.id.toString(),
                  data_time: _time,
                  findings: data[j].findings,
                  critical: data[j].critical,
                  minor: data[j].minor,
                  major: data[j].major,
                  remark: data[j].remark,
                  head: StringConstant().headNameList[i]));
            }
          }
        }

        ref.read(inspLocalCompleteDataProvider.notifier).state =
            _inspectionCompleteDataDB;

        ref
            .read(isLoadingStateProvider(LoaderWidgetId.homeScreen).notifier)
            .state = false;
        // ref.read(successProvider.notifier).state =
        //     'You have successfully Downloaded inspection';
        // ref.read(successProvider.notifier).state = null;
      }
    } catch (e) {
      ref
          .read(isLoadingStateProvider(LoaderWidgetId.homeScreen).notifier)
          .state = false;

      ref.read(warningProvider.notifier).state = e.toString();
      ref.read(warningProvider.notifier).state = null;
    }

    notifyListeners();
  }

  //----------------------------Tabbar position Value------------------------------------------------------------

  double _tabBarValue = 30;

  double get tabBarValue => _tabBarValue;

  setTabPosition(double value) {
    _tabBarValue = value;
    notifyListeners();
  }

  //---------------checkbox selected list for assign to------------------------------------------------------------

  int? _assign_to;

  int? get assign_to => _assign_to;

  List<int> _selectedCheckboxList = [];

  List<int> get selectedCheckboxList => _selectedCheckboxList;

  setCheckBoxSelectionList(int id) {
    if (_selectedCheckboxList.contains(id)) {
      _selectedCheckboxList.remove(id);
    } else {
      _selectedCheckboxList.add(id);
    }
    if (_selectedCheckboxList.isNotEmpty) {
      setIsTabVisible(true);
    } else {
      setIsTabVisible(false);
    }
  }

  setCheckBoxSelectionListEmpty() {
    _selectedCheckboxList.clear();
  }

  setAssignTo(String? value) {
    _assign_to = int.tryParse(value!);
  }

  //----------------------------inspection list------------------------------------------------------------

  List<InspectionsItem> _inspectionsList = [];

  List<InspectionsItem> get inspectionsList => _inspectionsList;

  List<InspectionsItem> _inspectionsList2 = [];

  List<InspectionsItem> get inspectionsList2 => _inspectionsList2;

  List<InspectionsItem> _inspectionsList3 = [];

  List<InspectionsItem> get inspectionsList3 => _inspectionsList3;

  String? _isSearchedFilter;

  String? get isSearchedFilter => _isSearchedFilter;

  //----------------------------isSearched First Time------------------------------------------------------------

  bool _isSearched = false;

  bool get isSearched => _isSearched;

  //----------------------------isTab VisibleOrNot------------------------------------------------------------

  bool _isTab = false;

  bool get isTab => _isTab;

  setIsTabVisible(bool isVisible) {
    _isTab = isVisible;
    notifyListeners();
  }

  //----------------------------isTab VisibleOrNot------------------------------------------------------------

  bool _isLoadingFirst = true;

  bool get isLoadingFirst => _isLoadingFirst;

  //----------------------------set To Date------------------------------------------------------------

  String? _toDate;

  String? get toDate => _toDate;

  setToDate(String date) {
    _toDate = date;
    _isLoadingFirst = false;
    notifyListeners();
  }

  //----------------------------set From Date------------------------------------------------------------

  String? _fromDate;

  String? get fromDate => _fromDate;

  setFromDate(String date) {
    _fromDate = date;
  }

  //----------------------------set inspection Type ID------------------------------------------------------------

  int? _inspectionTypeID;

  int? get inspectionTypeID => _inspectionTypeID;

  setInspectionTypeID(String value) {
    _inspectionTypeID = int.tryParse(value);
    notifyListeners();
  }

  //----------------------------set inspection State------------------------------------------------------------

  String? _inspectionState;

  String? get inspectionState => _inspectionState;

  setInspectionStateType(String value) {
    _inspectionState = value;
    notifyListeners();
  }

  //----------------------------Finish List------------------------------------------------------------

  List<FinishData>? _finishList = [];

  List<FinishData>? get finishList => _finishList;

  //----------------------------Material List------------------------------------------------------------

  List<MaterialData>? _materialList = [];

  List<MaterialData>? get materialList => _materialList;

  //---------------------------- UOM List------------------------------------------------------------

  List<UomData>? _uomList = [];

  List<UomData>? get uomList => _uomList;

  //=======================FLOATING BUTTON IGNORE==========================================================

  bool _isFloatingButton = false;

  bool get isFloatingButton => _isFloatingButton;

  setIsFloatingButton(bool value) {
    _isFloatingButton = value;
    notifyListeners();
  }

  viewLocallyInspection(InspectionsItem value) async {
    final _time = DateTime.now().toString();
    ref.read(isLoadingStateProvider(LoaderWidgetId.homeScreen).notifier).state =
    true;
    final data = InspectionList(
        inspection_id: value.inspection_id.toString(),
        vendor_product_code: value.vendor_product_code,
        vendor: value.vendor,
        sku_no: value.sku_no,
        product_name: value.product_name,
        buyer_product_code: value.buyer_product_code,
        is_submit: false,
        is_download_complete: false,
        is_inspection_desc_start: false,
        is_inspection_desc_complete: false,
        is_defect_desc_start: false,
        is_defect_desc_complete: false,
        is_download: true,
        is_defect_image_complete: false,
        is_defect_image_start: false,
        desc_id: '0',
        is_inspection_image_complete: false,
        is_inspection_image_start: false,
        is_assembly: false,
        is_bone: false,
        is_cane: false,
        is_complete_data: false,
        is_construction: false,
        is_finish: false,
        is_functionality: false,
        is_glass: false,
        is_handling: false,
        is_hardware: false,
        is_jute: false,
        is_leather: false,
        is_lighting: false,
        is_marble: false,
        is_metal: false,
        is_mirrors: false,
        is_outdoor: false,
        is_packaging: false,
        is_paper: false,
        is_plastic: false,
        is_quality: false,
        is_resin: false,
        is_submit_complete: false,
        is_testing: false,
        is_upholstery: false,
        is_wax: false,
        is_wood: false,
        int_value: "0",
        buyer: value.buyer,
        image: value.image,
        uid: userCredential.uid.toString(),
        buyer_order_no: value.buyer_order_no);

    _localInspectionList = await sql.insertInspectionList(data);
    try {
      _inspectionCompleteData = await api.inspectionCompleteDataApi(
          inpsectionID: value.inspection_id!);
      if (_inspectionCompleteData != null) {
        await sql.insertInspCompleteData(InspectionCompleteDataDB(
            uid: userCredential.uid.toString(),
            inspection_id: _inspectionCompleteData!.inspection_id.toString(),
            aql: _inspectionCompleteData!.aql,
            sku_no: _inspectionCompleteData!.sku_no,
            product_name: _inspectionCompleteData!.product_name,
            buyer: _inspectionCompleteData!.buyer,
            net_wt: _inspectionCompleteData!.net_wt,
            critical: _inspectionCompleteData!.critical,
            minor: _inspectionCompleteData!.minor,
            major: _inspectionCompleteData!.major,
            is_master_box2_finding: false,
            is_master_box3_finding: false,
            is_master_box_finding: false,
            is_wood_finding: false,
            is_upholstery_finding: false,
            is_metal_finding: false,
            is_glass_finding: false,
            is_marble_finding: false,
            is_construction_finding: false,
            is_finish_finding: false,
            is_assembly_finding: false,
            is_handling_finding: false,
            is_packaging_finding: false,
            is_hardware_finding: false,
            is_lighting_finding: false,
            is_functionality_finding: false,
            is_wax_finding: false,
            is_quality_finding: false,
            is_testing_finding: false,
            is_jute_finding: false,
            is_cane_finding: false,
            is_leather_finding: false,
            is_paper_finding: false,
            is_plastic_finding: false,
            is_resin_finding: false,
            is_bone_finding: false,
            is_outdoor_finding: false,
            is_mirrors_finding: false,
            vendor: _inspectionCompleteData!.vendor,
            inspection_state: _inspectionCompleteData!.inspection_state,
            vendor_product_code: _inspectionCompleteData!.vendor_product_code,
            buyer_product_code: _inspectionCompleteData!.buyer_product_code,
            buyer_order_no: _inspectionCompleteData!.buyer_order_no,
            image: _inspectionCompleteData!.image,
            plan_date: _inspectionCompleteData!.plan_date,
            inspection_type: _inspectionCompleteData!.inspection_type,
            achivement_date: _inspectionCompleteData!.achivement_date,
            ship_date: _inspectionCompleteData!.ship_date,
            vendor_date: _inspectionCompleteData!.vendor_date,
            factory_delivery: _inspectionCompleteData!.factory_delivery,
            team_id: _inspectionCompleteData!.team_id,
            assigned_to: _inspectionCompleteData!.assigned_to,
            sample_size: _inspectionCompleteData!.sample_size,
            aql_cr: _inspectionCompleteData!.aql_cr,
            aql_ma: _inspectionCompleteData!.aql_ma,
            aql_mi: _inspectionCompleteData!.aql_mi,
            total_cr: _inspectionCompleteData!.total_cr,
            total_ma: _inspectionCompleteData!.total_ma,
            total_mi: _inspectionCompleteData!.total_mi,
            terms_of_delivery: _inspectionCompleteData!.terms_of_delivery,
            product_spec_measure: _inspectionCompleteData!.product_spec_measure,
            product_spec_length:
            _inspectionCompleteData!.product_spec_length.toString(),
            product_spec_width:
            _inspectionCompleteData!.product_spec_width.toString(),
            product_spec_height:
            _inspectionCompleteData!.product_spec_height.toString(),
            product_spec_length_findings: _inspectionCompleteData!.product_spec_length_findings
                .toString(),
            product_spec_width_findings:
            _inspectionCompleteData!.product_spec_width_findings.toString(),
            product_spec_height_findings: _inspectionCompleteData!
                .product_spec_height_findings
                .toString(),
            color: _inspectionCompleteData!.color,
            is_wood: _inspectionCompleteData!.is_wood,
            material: _inspectionCompleteData!.material,
            is_upholstery: _inspectionCompleteData!.is_upholstery,
            finish: _inspectionCompleteData!.finish,
            is_metal: _inspectionCompleteData!.is_metal,
            is_glass: _inspectionCompleteData!.is_glass,
            is_marble: _inspectionCompleteData!.is_marble,
            is_construction: _inspectionCompleteData!.is_construction,
            is_finish: _inspectionCompleteData!.is_finish,
            is_assembly: _inspectionCompleteData!.is_assembly,
            is_handling: _inspectionCompleteData!.is_handling,
            is_packaging: _inspectionCompleteData!.is_packaging,
            is_hardware: _inspectionCompleteData!.is_hardware,
            is_lighting: _inspectionCompleteData!.is_lighting,
            is_functionality: _inspectionCompleteData!.is_functionality,
            is_wax: _inspectionCompleteData!.is_wax,
            is_quality: _inspectionCompleteData!.is_quality,
            is_testing: _inspectionCompleteData!.is_testing,
            is_jute: _inspectionCompleteData!.is_jute,
            is_cane: _inspectionCompleteData!.is_cane,
            is_leather: _inspectionCompleteData!.is_leather,
            is_paper: _inspectionCompleteData!.is_paper,
            is_plastic: _inspectionCompleteData!.is_plastic,
            is_resin: _inspectionCompleteData!.is_resin,
            is_bone: _inspectionCompleteData!.is_bone,
            is_outdoor: _inspectionCompleteData!.is_outdoor,
            is_mirrors: _inspectionCompleteData!.is_mirrors,
            approved_sample: _inspectionCompleteData!.approved_sample,
            order_copy: _inspectionCompleteData!.order_copy,
            ordered_qty: _inspectionCompleteData!.ordered_qty.toString(),
            labelling: _inspectionCompleteData!.labelling,
            offered_qty: _inspectionCompleteData!.offered_qty.toString(),
            insp_qty: _inspectionCompleteData!.insp_qty.toString(),
            carton_packed: _inspectionCompleteData!.carton_packed.toString(),
            carton_inspected:
            _inspectionCompleteData!.carton_inspected.toString(),
            total_pass_qty: _inspectionCompleteData!.total_pass_qty.toString(),
            material_remark:
            _inspectionCompleteData!.material_remark.toString(),
            gross_wt: _inspectionCompleteData!.gross_wt.toString(),
            cbm: _inspectionCompleteData!.cbm.toString(),
            cft: _inspectionCompleteData!.cft.toString(),
            gross_wt_findings:
            _inspectionCompleteData!.gross_wt_findings.toString(),
            cbm_findings: _inspectionCompleteData!.cbm_findings.toString(),
            cft_findings: _inspectionCompleteData!.cft_findings.toString(),
            is_master_box: _inspectionCompleteData!.is_master_box,
            is_master_box2: _inspectionCompleteData!.is_master_box2,
            is_master_box3: _inspectionCompleteData!.is_master_box3,
            master_box_length:
            _inspectionCompleteData!.master_box_length.toString(),
            master_box_width:
            _inspectionCompleteData!.master_box_width.toString(),
            master_box_height:
            _inspectionCompleteData!.master_box_height.toString(),
            pieces_per_master:
            _inspectionCompleteData!.pieces_per_master.toString(),
            pieces_per_inner:
            _inspectionCompleteData!.pieces_per_inner.toString(),
            master_box_length_findings:
            _inspectionCompleteData!.master_box_length_findings.toString(),
            master_box_width_findings:
            _inspectionCompleteData!.master_box_width_findings.toString(),
            master_box_height_findings:
            _inspectionCompleteData!.master_box_height_findings.toString(),
            pieces_per_master_findings:
            _inspectionCompleteData!.pieces_per_master_findings.toString(),
            pieces_per_inner_findings: _inspectionCompleteData!.pieces_per_inner_findings.toString(),
            master_box_length2: _inspectionCompleteData!.master_box_length2.toString(),
            master_box_width2: _inspectionCompleteData!.master_box_width2.toString(),
            master_box_height2: _inspectionCompleteData!.master_box_height2.toString(),
            pieces_per_master2: _inspectionCompleteData!.pieces_per_master2.toString(),
            pieces_per_inner2: _inspectionCompleteData!.pieces_per_inner2.toString(),
            master_box_length2_findings: _inspectionCompleteData!.master_box_length2_findings.toString(),
            master_box_width2_findings: _inspectionCompleteData!.master_box_width2_findings.toString(),
            master_box_height2_findings: _inspectionCompleteData!.master_box_height2_findings.toString(),
            pieces_per_master2_findings: _inspectionCompleteData!.pieces_per_master2_findings.toString(),
            pieces_per_inner2_findings: _inspectionCompleteData!.pieces_per_inner2_findings.toString(),
            master_box_length3: _inspectionCompleteData!.master_box_length3.toString(),
            master_box_width3: _inspectionCompleteData!.master_box_width3.toString(),
            master_box_height3: _inspectionCompleteData!.master_box_height3.toString(),
            pieces_per_master3: _inspectionCompleteData!.pieces_per_master3.toString(),
            pieces_per_inner3: _inspectionCompleteData!.pieces_per_inner3.toString(),
            master_box_length3_findings: _inspectionCompleteData!.master_box_length3_findings.toString(),
            master_box_width3_findings: _inspectionCompleteData!.master_box_width3_findings.toString(),
            master_box_height3_findings: _inspectionCompleteData!.master_box_height3_findings.toString(),
            pieces_per_master3_findings: _inspectionCompleteData!.pieces_per_master3_findings.toString(),
            pieces_per_inner3_findings: _inspectionCompleteData!.pieces_per_inner3_findings.toString(),
            inspection_again: _inspectionCompleteData!.inspection_again,
            inspection_again_type: _inspectionCompleteData!.inspection_again_type,
            new_inspection: _inspectionCompleteData!.new_inspection,
            remark: _inspectionCompleteData!.remark,
            reason_pass_fail: _inspectionCompleteData!.reason_pass_fail));

        _inspectionCompleteDataDB = await sql.getInspCompleteData(
            _inspectionCompleteData!.inspection_id!.toString(), userCredential.uid!.toString());

        _uomList = await api.uomListDataApi();
        _finishList = await api.finishListDataApi();
        _materialList = await api.materialListDataApi();

        if (_finishList != null) {
          if (_finishList!.isNotEmpty) {
            for (var _finishItem in _finishList!) {
              await sql.insertFinishList(InspectionFinishDB(
                  uid: userCredential.uid.toString(),
                  inspection_id: value.inspection_id.toString(),
                  name: _finishItem.name,
                  odoo_finish_id: _finishItem.odoo_finish_id.toString()));
            }
          }
        }

        if (_materialList != null) {
          if (_materialList!.isNotEmpty) {
            for (var _materialItem in _materialList!) {
              await sql.insertMaterialList(InspectionMaterialDB(
                  uid: userCredential.uid.toString(),
                  inspection_id: value.inspection_id.toString(),
                  name: _materialItem.name,
                  odoo_material_id: _materialItem.odoo_material_id.toString()));
            }
          }
        }

        if (_uomList != null) {
          if (_uomList!.isNotEmpty) {
            for (var _uomItem in _uomList!) {
              await sql.insertUomList(InspectionUomDB(
                  uid: userCredential.uid.toString(),
                  inspection_id: value.inspection_id.toString(),
                  name: _uomItem.name,
                  odoo_uom_id: _uomItem.odoo_uom_id.toString()));
            }
          }
        }

        if (_inspectionCompleteData!.component_size_lines!.isNotEmpty) {
          for (var _component
          in _inspectionCompleteData!.component_size_lines!) {
            await sql.insertInspComponent(InspectionComponentDB(
                uid: userCredential.uid.toString(),
                inspection_id: _component.inspection_id.toString(),
                name: _component.name.toString(),
                uom_id: _component.uom_id.toString(),
                is_saved: false,
                material: _component.material.toString(),
                item_length: _component.item_length.toString(),
                item_width: _component.item_width.toString(),
                data_time: 'empty',
                item_height: _component.item_height.toString(),
                thickness_measurement:
                _component.thickness_measurement.toString(),
                thickness: _component.thickness.toString(),
                dia: _component.dia.toString(),
                inner_dia: _component.inner_dia.toString(),
                outer_dia: _component.outer_dia.toString(),
                top_dia: _component.top_dia.toString(),
                bottom_dia: _component.bottom_dia.toString(),
                depth: _component.depth.toString(),
                circumference: _component.circumference.toString(),
                grammage: _component.grammage.toString(),
                finish_id: _component.finish_id.toString(),
                finish_ids: _component.finish_ids.toString(),
                barcode: _component.barcode.toString(),
                uom_id_findings: _component.uom_id_findings.toString(),
                material_findings: _component.material_findings.toString(),
                item_length_findings:
                _component.item_length_findings.toString(),
                item_width_findings: _component.item_width_findings.toString(),
                item_height_findings:
                _component.item_height_findings.toString(),
                thickness_measurement_findings:
                _component.thickness_measurement_findings.toString(),
                thickness_findings: _component.thickness_findings.toString(),
                dia_findings: _component.dia_findings.toString(),
                inner_dia_findings: _component.inner_dia_findings.toString(),
                outer_dia_findings: _component.outer_dia_findings.toString(),
                top_dia_findings: _component.top_dia_findings.toString(),
                bottom_dia_findings: _component.bottom_dia_findings.toString(),
                depth_findings: _component.depth_findings.toString(),
                circumference_findings:
                _component.circumference_findings.toString(),
                grammage_findings: _component.grammage_findings.toString(),
                finish_id_findings: _component.finish_id_findings.toString()));
          }
        }

        for (int i = 0; i < StringConstant().headNameList.length; i++) {
          print('[$i] ${StringConstant().headModelList[i]} string');
          List<HeadLineData>? data = await api.inspectionHeadLineDataApi(
              model: StringConstant().headModelList[i],
              method: StringConstant().headMethodList[i],
              inspection_id: value.inspection_id!);
          if (data!.isNotEmpty) {
            for (int j = 0; j < data.length; j++) {
              print('j = $j i = $i');
              final _data = await sql.insertHeadLineList(InspectionHeadsLinesDB(
                  inspection_id: value.inspection_id!.toString(),
                  uid: userCredential.uid.toString(),
                  head_id: StringConstant().headNameList[i],
                  data_time: _time,
                  head_name: data[j].head_name));
              await sql.insertHeadLineData(HeadsLinesDataDB(
                  uid: userCredential.uid.toString(),
                  inspection_id: value.inspection_id!.toString(),
                  head_name: data[j].head_name,
                  head_id: data[j].head_id.toString(),
                  image_url: "empty",
                  head_list_id: _data!.id.toString(),
                  data_time: _time,
                  findings: data[j].findings,
                  critical: data[j].critical,
                  minor: data[j].minor,
                  major: data[j].major,
                  remark: data[j].remark,
                  head: StringConstant().headNameList[i]));
            }
          }
        }

        ref.read(inspLocalCompleteDataProvider.notifier).state =
            _inspectionCompleteDataDB;

        ref
            .read(isLoadingStateProvider(LoaderWidgetId.homeScreen).notifier)
            .state = false;
        // ref.read(successProvider.notifier).state =
        //     'You have successfully Downloaded inspection';
        // ref.read(successProvider.notifier).state = null;
      }
    } catch (e) {
      ref
          .read(isLoadingStateProvider(LoaderWidgetId.homeScreen).notifier)
          .state = false;

      ref.read(warningProvider.notifier).state = e.toString();
      ref.read(warningProvider.notifier).state = null;
    }

    notifyListeners();
    savedInspectionLocally(InspectionsItem value) async {
      final _time = DateTime.now().toString();
      ref.read(isLoadingStateProvider(LoaderWidgetId.homeScreen).notifier).state =
      true;
      final data = InspectionList(
          inspection_id: value.inspection_id.toString(),
          vendor_product_code: value.vendor_product_code,
          vendor: value.vendor,
          sku_no: value.sku_no,
          product_name: value.product_name,
          buyer_product_code: value.buyer_product_code,
          is_submit: false,
          is_download_complete: false,
          is_inspection_desc_start: false,
          is_inspection_desc_complete: false,
          is_defect_desc_start: false,
          is_defect_desc_complete: false,
          is_download: true,
          is_defect_image_complete: false,
          is_defect_image_start: false,
          desc_id: '0',
          is_inspection_image_complete: false,
          is_inspection_image_start: false,
          is_assembly: false,
          is_bone: false,
          is_cane: false,
          is_complete_data: false,
          is_construction: false,
          is_finish: false,
          is_functionality: false,
          is_glass: false,
          is_handling: false,
          is_hardware: false,
          is_jute: false,
          is_leather: false,
          is_lighting: false,
          is_marble: false,
          is_metal: false,
          is_mirrors: false,
          is_outdoor: false,
          is_packaging: false,
          is_paper: false,
          is_plastic: false,
          is_quality: false,
          is_resin: false,
          is_submit_complete: false,
          is_testing: false,
          is_upholstery: false,
          is_wax: false,
          is_wood: false,
          int_value: "0",
          buyer: value.buyer,
          image: value.image,
          uid: userCredential.uid.toString(),
          buyer_order_no: value.buyer_order_no);

      _localInspectionList = await sql.insertInspectionList(data);
      try {
        _inspectionCompleteData = await api.inspectionCompleteDataApi(
            inpsectionID: value.inspection_id!);
        if (_inspectionCompleteData != null) {
          await sql.insertInspCompleteData(InspectionCompleteDataDB(
              uid: userCredential.uid.toString(),
              inspection_id: _inspectionCompleteData!.inspection_id.toString(),
              aql: _inspectionCompleteData!.aql,
              sku_no: _inspectionCompleteData!.sku_no,
              product_name: _inspectionCompleteData!.product_name,
              buyer: _inspectionCompleteData!.buyer,
              net_wt: _inspectionCompleteData!.net_wt,
              critical: _inspectionCompleteData!.critical,
              minor: _inspectionCompleteData!.minor,
              major: _inspectionCompleteData!.major,
              is_master_box2_finding: false,
              is_master_box3_finding: false,
              is_master_box_finding: false,
              is_wood_finding: false,
              is_upholstery_finding: false,
              is_metal_finding: false,
              is_glass_finding: false,
              is_marble_finding: false,
              is_construction_finding: false,
              is_finish_finding: false,
              is_assembly_finding: false,
              is_handling_finding: false,
              is_packaging_finding: false,
              is_hardware_finding: false,
              is_lighting_finding: false,
              is_functionality_finding: false,
              is_wax_finding: false,
              is_quality_finding: false,
              is_testing_finding: false,
              is_jute_finding: false,
              is_cane_finding: false,
              is_leather_finding: false,
              is_paper_finding: false,
              is_plastic_finding: false,
              is_resin_finding: false,
              is_bone_finding: false,
              is_outdoor_finding: false,
              is_mirrors_finding: false,
              vendor: _inspectionCompleteData!.vendor,
              inspection_state: _inspectionCompleteData!.inspection_state,
              vendor_product_code: _inspectionCompleteData!.vendor_product_code,
              buyer_product_code: _inspectionCompleteData!.buyer_product_code,
              buyer_order_no: _inspectionCompleteData!.buyer_order_no,
              image: _inspectionCompleteData!.image,
              plan_date: _inspectionCompleteData!.plan_date,
              inspection_type: _inspectionCompleteData!.inspection_type,
              achivement_date: _inspectionCompleteData!.achivement_date,
              ship_date: _inspectionCompleteData!.ship_date,
              vendor_date: _inspectionCompleteData!.vendor_date,
              factory_delivery: _inspectionCompleteData!.factory_delivery,
              team_id: _inspectionCompleteData!.team_id,
              assigned_to: _inspectionCompleteData!.assigned_to,
              sample_size: _inspectionCompleteData!.sample_size,
              aql_cr: _inspectionCompleteData!.aql_cr,
              aql_ma: _inspectionCompleteData!.aql_ma,
              aql_mi: _inspectionCompleteData!.aql_mi,
              total_cr: _inspectionCompleteData!.total_cr,
              total_ma: _inspectionCompleteData!.total_ma,
              total_mi: _inspectionCompleteData!.total_mi,
              terms_of_delivery: _inspectionCompleteData!.terms_of_delivery,
              product_spec_measure: _inspectionCompleteData!.product_spec_measure,
              product_spec_length:
              _inspectionCompleteData!.product_spec_length.toString(),
              product_spec_width:
              _inspectionCompleteData!.product_spec_width.toString(),
              product_spec_height:
              _inspectionCompleteData!.product_spec_height.toString(),
              product_spec_length_findings: _inspectionCompleteData!.product_spec_length_findings
                  .toString(),
              product_spec_width_findings:
              _inspectionCompleteData!.product_spec_width_findings.toString(),
              product_spec_height_findings: _inspectionCompleteData!
                  .product_spec_height_findings
                  .toString(),
              color: _inspectionCompleteData!.color,
              is_wood: _inspectionCompleteData!.is_wood,
              material: _inspectionCompleteData!.material,
              is_upholstery: _inspectionCompleteData!.is_upholstery,
              finish: _inspectionCompleteData!.finish,
              is_metal: _inspectionCompleteData!.is_metal,
              is_glass: _inspectionCompleteData!.is_glass,
              is_marble: _inspectionCompleteData!.is_marble,
              is_construction: _inspectionCompleteData!.is_construction,
              is_finish: _inspectionCompleteData!.is_finish,
              is_assembly: _inspectionCompleteData!.is_assembly,
              is_handling: _inspectionCompleteData!.is_handling,
              is_packaging: _inspectionCompleteData!.is_packaging,
              is_hardware: _inspectionCompleteData!.is_hardware,
              is_lighting: _inspectionCompleteData!.is_lighting,
              is_functionality: _inspectionCompleteData!.is_functionality,
              is_wax: _inspectionCompleteData!.is_wax,
              is_quality: _inspectionCompleteData!.is_quality,
              is_testing: _inspectionCompleteData!.is_testing,
              is_jute: _inspectionCompleteData!.is_jute,
              is_cane: _inspectionCompleteData!.is_cane,
              is_leather: _inspectionCompleteData!.is_leather,
              is_paper: _inspectionCompleteData!.is_paper,
              is_plastic: _inspectionCompleteData!.is_plastic,
              is_resin: _inspectionCompleteData!.is_resin,
              is_bone: _inspectionCompleteData!.is_bone,
              is_outdoor: _inspectionCompleteData!.is_outdoor,
              is_mirrors: _inspectionCompleteData!.is_mirrors,
              approved_sample: _inspectionCompleteData!.approved_sample,
              order_copy: _inspectionCompleteData!.order_copy,
              ordered_qty: _inspectionCompleteData!.ordered_qty.toString(),
              labelling: _inspectionCompleteData!.labelling,
              offered_qty: _inspectionCompleteData!.offered_qty.toString(),
              insp_qty: _inspectionCompleteData!.insp_qty.toString(),
              carton_packed: _inspectionCompleteData!.carton_packed.toString(),
              carton_inspected:
              _inspectionCompleteData!.carton_inspected.toString(),
              total_pass_qty: _inspectionCompleteData!.total_pass_qty.toString(),
              material_remark:
              _inspectionCompleteData!.material_remark.toString(),
              gross_wt: _inspectionCompleteData!.gross_wt.toString(),
              cbm: _inspectionCompleteData!.cbm.toString(),
              cft: _inspectionCompleteData!.cft.toString(),
              gross_wt_findings:
              _inspectionCompleteData!.gross_wt_findings.toString(),
              cbm_findings: _inspectionCompleteData!.cbm_findings.toString(),
              cft_findings: _inspectionCompleteData!.cft_findings.toString(),
              is_master_box: _inspectionCompleteData!.is_master_box,
              is_master_box2: _inspectionCompleteData!.is_master_box2,
              is_master_box3: _inspectionCompleteData!.is_master_box3,
              master_box_length:
              _inspectionCompleteData!.master_box_length.toString(),
              master_box_width:
              _inspectionCompleteData!.master_box_width.toString(),
              master_box_height:
              _inspectionCompleteData!.master_box_height.toString(),
              pieces_per_master:
              _inspectionCompleteData!.pieces_per_master.toString(),
              pieces_per_inner:
              _inspectionCompleteData!.pieces_per_inner.toString(),
              master_box_length_findings:
              _inspectionCompleteData!.master_box_length_findings.toString(),
              master_box_width_findings:
              _inspectionCompleteData!.master_box_width_findings.toString(),
              master_box_height_findings:
              _inspectionCompleteData!.master_box_height_findings.toString(),
              pieces_per_master_findings:
              _inspectionCompleteData!.pieces_per_master_findings.toString(),
              pieces_per_inner_findings: _inspectionCompleteData!.pieces_per_inner_findings.toString(),
              master_box_length2: _inspectionCompleteData!.master_box_length2.toString(),
              master_box_width2: _inspectionCompleteData!.master_box_width2.toString(),
              master_box_height2: _inspectionCompleteData!.master_box_height2.toString(),
              pieces_per_master2: _inspectionCompleteData!.pieces_per_master2.toString(),
              pieces_per_inner2: _inspectionCompleteData!.pieces_per_inner2.toString(),
              master_box_length2_findings: _inspectionCompleteData!.master_box_length2_findings.toString(),
              master_box_width2_findings: _inspectionCompleteData!.master_box_width2_findings.toString(),
              master_box_height2_findings: _inspectionCompleteData!.master_box_height2_findings.toString(),
              pieces_per_master2_findings: _inspectionCompleteData!.pieces_per_master2_findings.toString(),
              pieces_per_inner2_findings: _inspectionCompleteData!.pieces_per_inner2_findings.toString(),
              master_box_length3: _inspectionCompleteData!.master_box_length3.toString(),
              master_box_width3: _inspectionCompleteData!.master_box_width3.toString(),
              master_box_height3: _inspectionCompleteData!.master_box_height3.toString(),
              pieces_per_master3: _inspectionCompleteData!.pieces_per_master3.toString(),
              pieces_per_inner3: _inspectionCompleteData!.pieces_per_inner3.toString(),
              master_box_length3_findings: _inspectionCompleteData!.master_box_length3_findings.toString(),
              master_box_width3_findings: _inspectionCompleteData!.master_box_width3_findings.toString(),
              master_box_height3_findings: _inspectionCompleteData!.master_box_height3_findings.toString(),
              pieces_per_master3_findings: _inspectionCompleteData!.pieces_per_master3_findings.toString(),
              pieces_per_inner3_findings: _inspectionCompleteData!.pieces_per_inner3_findings.toString(),
              inspection_again: _inspectionCompleteData!.inspection_again,
              inspection_again_type: _inspectionCompleteData!.inspection_again_type,
              new_inspection: _inspectionCompleteData!.new_inspection,
              remark: _inspectionCompleteData!.remark,
              reason_pass_fail: _inspectionCompleteData!.reason_pass_fail));

          _inspectionCompleteDataDB = await sql.getInspCompleteData(
              _inspectionCompleteData!.inspection_id!.toString(), userCredential.uid!.toString());

          _uomList = await api.uomListDataApi();
          _finishList = await api.finishListDataApi();
          _materialList = await api.materialListDataApi();

          if (_finishList != null) {
            if (_finishList!.isNotEmpty) {
              for (var _finishItem in _finishList!) {
                await sql.insertFinishList(InspectionFinishDB(
                    uid: userCredential.uid.toString(),
                    inspection_id: value.inspection_id.toString(),
                    name: _finishItem.name,
                    odoo_finish_id: _finishItem.odoo_finish_id.toString()));
              }
            }
          }

          if (_materialList != null) {
            if (_materialList!.isNotEmpty) {
              for (var _materialItem in _materialList!) {
                await sql.insertMaterialList(InspectionMaterialDB(
                    uid: userCredential.uid.toString(),
                    inspection_id: value.inspection_id.toString(),
                    name: _materialItem.name,
                    odoo_material_id: _materialItem.odoo_material_id.toString()));
              }
            }
          }

          if (_uomList != null) {
            if (_uomList!.isNotEmpty) {
              for (var _uomItem in _uomList!) {
                await sql.insertUomList(InspectionUomDB(
                    uid: userCredential.uid.toString(),
                    inspection_id: value.inspection_id.toString(),
                    name: _uomItem.name,
                    odoo_uom_id: _uomItem.odoo_uom_id.toString()));
              }
            }
          }

          if (_inspectionCompleteData!.component_size_lines!.isNotEmpty) {
            for (var _component
            in _inspectionCompleteData!.component_size_lines!) {
              await sql.insertInspComponent(InspectionComponentDB(
                  uid: userCredential.uid.toString(),
                  inspection_id: _component.inspection_id.toString(),
                  name: _component.name.toString(),
                  uom_id: _component.uom_id.toString(),
                  is_saved: false,
                  material: _component.material.toString(),
                  item_length: _component.item_length.toString(),
                  item_width: _component.item_width.toString(),
                  data_time: 'empty',
                  item_height: _component.item_height.toString(),
                  thickness_measurement:
                  _component.thickness_measurement.toString(),
                  thickness: _component.thickness.toString(),
                  dia: _component.dia.toString(),
                  inner_dia: _component.inner_dia.toString(),
                  outer_dia: _component.outer_dia.toString(),
                  top_dia: _component.top_dia.toString(),
                  bottom_dia: _component.bottom_dia.toString(),
                  depth: _component.depth.toString(),
                  circumference: _component.circumference.toString(),
                  grammage: _component.grammage.toString(),
                  finish_id: _component.finish_id.toString(),
                  finish_ids: _component.finish_ids.toString(),
                  barcode: _component.barcode.toString(),
                  uom_id_findings: _component.uom_id_findings.toString(),
                  material_findings: _component.material_findings.toString(),
                  item_length_findings:
                  _component.item_length_findings.toString(),
                  item_width_findings: _component.item_width_findings.toString(),
                  item_height_findings:
                  _component.item_height_findings.toString(),
                  thickness_measurement_findings:
                  _component.thickness_measurement_findings.toString(),
                  thickness_findings: _component.thickness_findings.toString(),
                  dia_findings: _component.dia_findings.toString(),
                  inner_dia_findings: _component.inner_dia_findings.toString(),
                  outer_dia_findings: _component.outer_dia_findings.toString(),
                  top_dia_findings: _component.top_dia_findings.toString(),
                  bottom_dia_findings: _component.bottom_dia_findings.toString(),
                  depth_findings: _component.depth_findings.toString(),
                  circumference_findings:
                  _component.circumference_findings.toString(),
                  grammage_findings: _component.grammage_findings.toString(),
                  finish_id_findings: _component.finish_id_findings.toString()));
            }
          }

          for (int i = 0; i < StringConstant().headNameList.length; i++) {
            print('[$i] ${StringConstant().headModelList[i]} string');
            List<HeadLineData>? data = await api.inspectionHeadLineDataApi(
                model: StringConstant().headModelList[i],
                method: StringConstant().headMethodList[i],
                inspection_id: value.inspection_id!);
            if (data!.isNotEmpty) {
              for (int j = 0; j < data.length; j++) {
                print('j = $j i = $i');
                final _data = await sql.insertHeadLineList(InspectionHeadsLinesDB(
                    inspection_id: value.inspection_id!.toString(),
                    uid: userCredential.uid.toString(),
                    head_id: StringConstant().headNameList[i],
                    data_time: _time,
                    head_name: data[j].head_name));
                await sql.insertHeadLineData(HeadsLinesDataDB(
                    uid: userCredential.uid.toString(),
                    inspection_id: value.inspection_id!.toString(),
                    head_name: data[j].head_name,
                    head_id: data[j].head_id.toString(),
                    image_url: "empty",
                    head_list_id: _data!.id.toString(),
                    data_time: _time,
                    findings: data[j].findings,
                    critical: data[j].critical,
                    minor: data[j].minor,
                    major: data[j].major,
                    remark: data[j].remark,
                    head: StringConstant().headNameList[i]));
              }
            }
          }

          ref.read(inspLocalCompleteDataProvider.notifier).state =
              _inspectionCompleteDataDB;

          ref
              .read(isLoadingStateProvider(LoaderWidgetId.homeScreen).notifier)
              .state = false;
          // ref.read(successProvider.notifier).state =
          //     'You have successfully Downloaded inspection';
          // ref.read(successProvider.notifier).state = null;
        }
      } catch (e) {
        ref
            .read(isLoadingStateProvider(LoaderWidgetId.homeScreen).notifier)
            .state = false;

        ref.read(warningProvider.notifier).state = e.toString();
        ref.read(warningProvider.notifier).state = null;
      }

      notifyListeners();
}
