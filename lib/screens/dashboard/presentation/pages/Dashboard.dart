import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:lookover/lookover.dart';
import '../../../commons/pages/drawer.dart';
import '../providers/home_provider.dart';

class DashBoardScreen extends ConsumerStatefulWidget {
  const DashBoardScreen({super.key});

  @override
  DashBoardScreenState createState() => DashBoardScreenState();
}

class DashBoardScreenState extends ConsumerState<DashBoardScreen> {
  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   final providerDispose = ref.watch(dashboardProvider);
  //   providerDispose.statusDropdownController.dispose();
  //   providerDispose.typeDropdownController.dispose();
  //   providerDispose.AssignToDropdownController.dispose();
  //   providerDispose.buyerDropdownController.dispose();
  //   providerDispose.VendorToDropdownController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(dashboardProvider);
    return WillPopScope(
      onWillPop: () => onWillPop(context),
      child: IgnorePointer(
        ignoring: provider.isFloatingButton,
        child: Scaffold(
          drawer: EndDrawer(),
          floatingActionButton:
              (provider.isTab == false && provider.inspectionsList2.length > 0)
                  ? CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                          onPressed: () {
                            provider.setIsSearchedFilter(null);
                            provider.setIsTabVisible(true);
                          },
                          icon: Icon(
                            Icons.filter_alt_outlined,
                            color: Colors.white,
                          )))
                  : null,
          appBar: AppBar(
              title: CTextWhite(StringConstant().dashboard),
              backgroundColor: AppColors.primary,
              actions: [
                IconButton(
                    onPressed: () {
                      //context.pushNamed(AppRoutes.search.routePath);
                     context.push(AppRoutes.search.routePath);
                    },
                    icon: Icon(CupertinoIcons.search)),
                IconButton(
                    onPressed: () async {

                      // var result = await PhotoManager.requestPermissionExtend();
                      // if(result.hasAccess){
                      //   List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true);
                      //   List<AssetEntity> media = await albums[0].getAssetListPaged(page: 0, size: 1000);
                      //   print(media.length);
                      // } else {
                      //   await PhotoManager.requestPermissionExtend();
                      // }

                      // await Gal.open();
                      //context.push(AppRoutes.commonImage.routePath);
                    },
                    icon: Icon(Icons.notifications_active_outlined))
              ]), FullScreenLoader(
                  widgetId: LoaderWidgetId.homeScreen,
                  child: Stack(
                    children: [
                      Column(
                        children: [

                            CText(
                                provider.isSearched
                                    ? StringConstant().notFoundInspection
                                    : StringConstant().welcomeHomeScreen,
                                mBold: true,
                                mSize: NumberConstant().regular),
                            if (provider.isSearched == false) ...{
                              CCommonWidget().doubleHeightBox(),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .5,
                                child: CustomActionButton(
                                  buttonTitle: 'Saved Inspection',
                                  onTap: () async {
                                    context.push(
                                        AppRoutes.savedinspection.routePath);
                                  },
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                ),
                              )
                            },
                            Spacer(
                              flex: 2,
                            )
                          },
                        ],
                      ),
                      if (provider.isTab == true &&
                          provider.inspectionsList2.length > 0) ...{
                        Positioned(
                            height: 70,
                            width: MediaQuery.of(context).size.width * .8,
                            bottom: provider.tabBarValue,
                            right: MediaQuery.of(context).size.width * .1,
                            child: CCommonWidget().borderBox(
                                background: AppColors.white,
                                // isPadded: true,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          provider.setResetInspectionList();
                                          provider.setIsSearchedFilter(null);
                                          provider.setIsTabVisible(false);
                                        },
                                        icon: Icon(
                                          AppIcons.close,
                                          color: AppColors.primary,
                                        )),
                                    if (provider.selectedCheckboxList.length >
                                        0) ...{
                                      CText(
                                        "${provider.selectedCheckboxList.length} Selected",
                                        textColor: AppColors.primary,
                                      ),
                                      CCommonWidget().CommonDropdown(
                                          hint: StringConstant().assignTo,
                                          controller:
                                              provider.AssignToDropdownController,
                                          dropdownList: provider.employeeList,
                                          onChange: (v) {
                                            provider.setAssignTo(v);
                                            if (provider
                                                .AssignToDropdownController.isOpen) {
                                              provider.AssignToDropdownController.close();
                                            }
                                          }),
                                      CircleAvatar(
                                          backgroundColor: AppColors.primary,
                                          child: IconButton(
                                              onPressed: () async {
                                                if(provider.assign_to != null){
                                                  ref
                                                      .read(isLoadingStateProvider(LoaderWidgetId.homeScreen).notifier)
                                                      .state = true; //userCredential.uid!
                                                  await provider.api.assignToInspectionDataApi(inspection_list: provider.selectedCheckboxList,assignto: provider.assign_to!);
                                                  provider.setCheckBoxSelectionListEmpty();
                                                  await provider.inspectionsListDataApi();
                                                  ref
                                                      .read(isLoadingStateProvider(LoaderWidgetId.homeScreen).notifier)
                                                      .state = false;
                                                }
                                              },
                                              icon: Icon(
                                                Icons
                                                    .keyboard_arrow_right_outlined,
                                                color: Colors.white,
                                              )))
                                    },
                                    if (provider.selectedCheckboxList.length ==
                                        0) ...{
                                      CCommonWidget().widthBox(),
                                      SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  .2,
                                          child: CCommonWidget().CommonDropdown(
                                              hint: StringConstant().selectBuyer,
                                              controller: provider
                                                  .buyerDropdownController,
                                              dropdownList: provider.buyerType,
                                              onChange: (v) {
                                                if (provider.isSearchedFilter ==
                                                    null) {
                                                  provider.setIsSearchedFilter(
                                                      'buyer');
                                                }
                                                provider.filterWithBuyer(v);
                                                if (provider
                                                    .buyerDropdownController
                                                    .isOpen) {
                                                  provider.buyerDropdownController
                                                      .close();
                                                }
                                              })),
                                      CCommonWidget().widthBox(),
                                      Expanded(
                                          child: AppTextFormField(
                                        controller: provider.editingController,
                                        onChanged: (s) {
                                          provider.searchBuyerPO(s);
                                        },
                                        suffix: IconButton(
                                            onPressed: () {
                                              provider.editingController.clear();
                                              provider.searchBuyerPO('');
                                            },
                                            icon: Icon(Icons.close)),
                                        hintValue: 'Buyer PO No.',
                                        textFieldType: TextFieldType.other,
                                        fixBorder: true,
                                      )),
                                    }
                                  ],
                                )))
                      }
                    ],
                  ),
                ),
        ),
      ),
    );
  }

}
