import 'package:eptera_fixed_asset/Globals/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OfflineSummary extends StatefulWidget {
  const OfflineSummary({super.key});

  @override
  State<StatefulWidget> createState() => _OfflineSummary();
}

class _OfflineSummary extends State<OfflineSummary> with SingleTickerProviderStateMixin {
  BehaviorSubject<List<FixAssetCountDetail>> fixAssetCountDetails$ = BehaviorSubject.seeded([]);
  BehaviorSubject<List<OfflineLocationCountingItem>> offlineLocationCountingItemsList$ = BehaviorSubject.seeded([]);

  BehaviorSubject<bool> countingUploading$ = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> locationCountingUploading$ = BehaviorSubject.seeded(false);

  BehaviorSubject<int> countingCount$ = BehaviorSubject.seeded(0);
  BehaviorSubject<int> locationCountingCount$ = BehaviorSubject.seeded(0);

  BehaviorSubject<bool> uploading$ = BehaviorSubject.seeded(false);
  BehaviorSubject<int> count$ = BehaviorSubject.seeded(0);

  int countingTotalCount = 0;
  int locationCountingTotalCount = 0;

  late TabController tabController;

  bool countingUploadingError = false;
  bool locationCountingUploadingError = false;

  String? tenantFromStorage;
  String? userCodeFromStorage;
  String? passwordFromStorage;
  String? endPointFromStorage;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: kWhite,
    ));

    tabController = TabController(vsync: this, length: 2, initialIndex: 0);

    loadData();

    initStorageVariables();
  }

  initStorageVariables() async {
    tenantFromStorage = await Hive.box('userOperations').get('tenant');
    userCodeFromStorage = await Hive.box('userOperations').get('userCode');
    passwordFromStorage = await Hive.box('userOperations').get('password');
    endPointFromStorage = await Hive.box('userOperations').get('endPoint');
  }

  loadData() async {
    var fixAssetCountDetailsNewList = (fixAssetCountDetailsFromHive.get('FixAssetCountDetailsFromHive') ?? []).cast<FixAssetCountDetail>();

    fixAssetCountDetailsNewList.forEach((element) {
      fixAssetCountDetails$.value.add(element);
    });

    fixAssetCountDetails$.add(fixAssetCountDetails$.value);

    var offlineLocationCountingItemsNewList = (offlineLocationCountingItemsFromHive.get('OfflineLocationCountingItems') ?? []).cast<OfflineLocationCountingItem>();

    offlineLocationCountingItemsNewList.forEach((element) {
      offlineLocationCountingItemsList$.value.add(element);
    });
    offlineLocationCountingItemsList$.add(offlineLocationCountingItemsList$.value);

    countingTotalCount = fixAssetCountDetails$.value.length;
    locationCountingTotalCount = offlineLocationCountingItemsList$.value.length;
  }

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;

    return StreamBuilder(
        stream: Rx.combineLatest2(fixAssetCountDetails$, offlineLocationCountingItemsList$, (a, b) => null),
        builder: (context, snapshot) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: SvgPicture.asset("assets/images/appbarLogo.svg"),
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: kGrey700,
                    )),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(44 + 32 + 12),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Offline Data".tr(),
                              style: k20w600Black(color: kGrey900),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                      TabBar(
                        isScrollable: false,
                        indicator: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: kPrimaryColor,
                              width: 2.0,
                            ),
                          ),
                        ),
                        dividerColor: kBorderColor2,
                        unselectedLabelStyle: k14w600Black(color: kGrey500),
                        labelStyle: k14w600Black(color: kPrimaryColor),
                        controller: tabController,
                        tabs: [
                          Tab(text: "${"Counting".tr()} (${fixAssetCountDetails$.value.length})"),
                          Tab(text: "${"Location Counting".tr()} (${offlineLocationCountingItemsList$.value.length})"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              body: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 20, right: 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: TabBarView(
                            controller: tabController,
                            children: [
                              StreamBuilder<bool>(
                                  stream: countingUploading$.stream,
                                  builder: (context, snapshot) {
                                    if (snapshot.data ?? false) {
                                      return Center(
                                        child: SizedBox(
                                          height: w / 2,
                                          child: Column(
                                            children: [
                                              const CircularProgressIndicator(
                                                color: Colors.black87,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                tr("DONE_COUNTING_TEXT").replaceAll('[]', '${countingCount$.value}').replaceAll('{}', '$countingTotalCount'),
                                                style: const TextStyle(color: Colors.black87),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return SizedBox(
                                      height: h * 0.8,
                                      child: ListView.separated(
                                        padding: EdgeInsets.only(
                                          bottom: h * 0.2,
                                        ),
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: fixAssetCountDetails$.value.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(right: 8.0),
                                                          child: Text(
                                                            fixAssets$.value[fixAssetCountDetails$.value[index].masterassetid]?.name ?? "-",
                                                            style: k14w500Black(color: kGrey900),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 2,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Text("${"Barcode".tr()}:",style: k14w400Black(color: kGrey500),),
                                                        SizedBox(width: 6,),
                                                        Text(
                                                          fixAssetCountDetails$.value[index].barcode ?? "-",
                                                          style: k14w500Black(color: kGrey500),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 2,
                                                    ),
                                                    Text(
                                                      fixAssetsLocations$.value[fixAssetCountDetails$.value[index].locationid]?.name ?? "",
                                                      style: k14w400Black(color: kSecondaryColor),
                                                    ),
                                                    SizedBox(
                                                      height: 2,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      fixAssetCountDetails$.value[index].qty.toString(),
                                                      style: k16w600Black(color: kPrimaryColor),
                                                    ),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    InkWell(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: SvgPicture.asset(
                                                          "assets/images/delete.svg",
                                                          color: Color(0xFFF97066),
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        var result = await showConfirmDialog("Delete".tr(), "Are you sure you want to delete this stock?".tr(),
                                                            imagePath: "assets/images/error.svg", buttonColor: kPrimaryColor, actionText: "Delete".tr());
                                                        if (result == true) {
                                                          fixAssetCountDetails$.value.removeAt(index);
                                                          fixAssetCountDetailsFromHive.clear();
                                                          fixAssetCountDetailsFromHive.put('FixAssetCountDetailsFromHive', fixAssetCountDetails$.value);
                                                          fixAssetCountDetails$.add(fixAssetCountDetails$.value);
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) => const Divider(color: kBorderColor2),
                                      ),
                                    );
                                  }),
                              StreamBuilder<bool>(
                                  stream: locationCountingUploading$.stream,
                                  builder: (context, snapshot) {
                                    if (snapshot.data ?? false) {
                                      return Center(
                                        child: SizedBox(
                                          height: w / 2,
                                          child: Column(
                                            children: [
                                              const CircularProgressIndicator(),
                                              const SizedBox(height: 10),
                                              Text(
                                                tr("DONE_COUNTING_TEXT").replaceAll('[]', '${locationCountingCount$.value}').replaceAll('{}', '$locationCountingTotalCount'),
                                                style: const TextStyle(color: Colors.black87),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    return SizedBox(
                                      height: h * 0.8,
                                      child: ListView.separated(
                                        padding: EdgeInsets.only(
                                          bottom: h * 0.2,
                                        ),
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: offlineLocationCountingItemsList$.value.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                           child: Row(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               Expanded(
                                                 child: Column(
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: [
                                                     Text(
                                                       offlineLocationCountingItemsList$.value[index].selectedLocation?.name ?? "",
                                                       style: k16w600Black(color: kSecondaryColor),
                                                     ),
                                                     const SizedBox(height: 4),
                                                     for (var i = 0; i < offlineLocationCountingItemsList$.value[index].currentList.keys.toList().length; i++)
                                                       Text(fixAssets_byBarcodeID$.value[offlineLocationCountingItemsList$.value[index].currentList.keys.toList()[i]]?.name ?? ""),
                                                     if (offlineLocationCountingItemsList$.value[index].note != null && offlineLocationCountingItemsList$.value[index].note != '')
                                                       Padding(
                                                         padding: const EdgeInsets.only(top: 4),
                                                         child: Container(
                                                           padding: EdgeInsets.all(6),
                                                           decoration: BoxDecoration(
                                                             border: Border.all(color: kGrey50),
                                                             borderRadius: BorderRadius.circular(8),

                                                           ),
                                                           child: Row(
                                                             mainAxisAlignment: MainAxisAlignment.start,
                                                             children: [
                                                               SvgPicture.asset("assets/images/note.svg",color: Color(0xFF98A2B3),),
                                                               const SizedBox(width: 8,),
                                                               SizedBox(
                                                                 width: w - (48 + 36 + 8 +100),
                                                                 child: Text(
                                                                   offlineLocationCountingItemsList$.value[index].note!,
                                                                   style: k14w400Black(color: kGrey600),
                                                                   overflow: TextOverflow.ellipsis,
                                                                   maxLines: 2,
                                                                   // style: k14w600ColoTextStyle(color: Colors.black.withOpacity(0.75), fontSize: 16, fontWeight: FontWeight.w400),
                                                                 ),
                                                               ),
                                                             ],
                                                           ),
                                                         ),
                                                       ),
                                                   ],
                                                 ),
                                               ),
                                               const SizedBox(width: 8,),
                                               InkWell(
                                                 child:  Padding(
                                                   padding: const EdgeInsets.all(8.0),
                                                   child: SvgPicture.asset("assets/images/delete.svg"
                                                   ),
                                                 ),
                                                 onTap: () async {
                                                   var result = await showConfirmDialog("Delete".tr(), "Are you sure you want to delete this stock?".tr(),
                                                       imagePath: "assets/images/error.svg", buttonColor: kPrimaryColor, actionText: "Delete".tr());

                                                   if (result == true) {
                                                     offlineLocationCountingItemsList$.value.removeAt(index);
                                                     offlineLocationCountingItemsFromHive.clear();
                                                     await offlineLocationCountingItemsFromHive.put('OfflineLocationCountingItems', offlineLocationCountingItemsList$.value);
                                                     offlineLocationCountingItemsList$.add(offlineLocationCountingItemsList$.value);
                                                   }
                                                 },
                                               ),
                                             ],
                                           ),
                                          );
                                        },
                                        separatorBuilder: (context, index) => const Divider(color: Colors.red),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Divider(
                          color: kBorderColor2,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: padding.bottom > 0 ? padding.bottom + 16 : 32),
                          child: ElevatedButton(
                            child: Text(
                              "Upload".tr(),
                              style: k16w600Black(color: kWhite),
                            ),
                            onPressed: () async {

                              if (countingUploading$.value || locationCountingUploading$.value) {
                                return;
                              }
                              if (await checkConnection()) {
                                if (tabController.index == 0) {
                                  countingUploading$.add(true);
                                  await api.login(
                                    tenantFromStorage,
                                    userCodeFromStorage,
                                    passwordFromStorage,
                                    endPoint: endPointFromStorage == "" ? null : endPointFromStorage,
                                    context: context,
                                  );
                                  bool? isCountStockOfflineMasterItemActive;
                                  await db.setDataFromOnline([false, false, false, true, false]).then((value) async {
                                    if (value == "") {
                                      isCountStockOfflineMasterItemActive = fixAssetsCount$.value.containsKey(fixAssetOfflineCountItem$.value?.id);
                                    } else {
                                      print("-----------------Error_----------------------");
                                      kShowBanner(BannerType.ERROR, "Error".tr(), value, context);
                                      
                                    }
                                  });

                                  if (isCountStockOfflineMasterItemActive == false) {
                                    kShowBanner(BannerType.ERROR, "Error".tr(), "Counting is no longer active".tr(), context);
                                    countingUploading$.add(false);
                                    return;
                                  }

                                  if (loginResponse.loginToken != "") {
                                    List<FixAssetCountDetail> copyFixAssetCountDetails = List.from(fixAssetCountDetails$.value);
                                    int endRangeValue = 0;
                                    for (var i = 0; i < copyFixAssetCountDetails.length; i = i + 100) {
                                      if (i + 100 > copyFixAssetCountDetails.length) {
                                        endRangeValue = copyFixAssetCountDetails.length;
                                      } else {
                                        endRangeValue = i + 100;
                                      }
                                      await db
                                          .sendCountingDataOnline(
                                        newScannedItems: copyFixAssetCountDetails.getRange(i, endRangeValue),
                                        selectedCounting: fixAssetOfflineCountItem$.value,
                                        showDialog: endRangeValue == copyFixAssetCountDetails.length,
                                      )
                                          .then((value) {
                                        if (value.success == true) {
                                          fixAssetCountDetails$.value.removeRange(0, endRangeValue - i);
                                          fixAssetCountDetails$.add(fixAssetCountDetails$.value);
                                          countingCount$.value = i;
                                          countingCount$.add(countingCount$.value);
                                          if (endRangeValue == copyFixAssetCountDetails.length) {
                                            i = copyFixAssetCountDetails.length;
                                            fixAssetCountDetails$.value = [];
                                            fixAssetCountDetailsFromHive.clear();
                                            fixAssetCountDetails$.add(fixAssetCountDetails$.value);
                                          }
                                          kShowBanner(BannerType.SUCCESS, "Success".tr(), "Transaction inserted successfully".tr(), context);
                                        } else if ((value.success == false) || (endRangeValue == copyFixAssetCountDetails.length)) {
                                          i = copyFixAssetCountDetails.length;
                                        }
                                      });
                                    }

                                    countingUploading$.add(false);
                                    countingCount$.add(0);
                                    countingUploadingError = false;
                                  }
                                } else {
                                  locationCountingUploading$.add(true);

                                  // ignore: use_build_context_synchronously
                                  await api.login(
                                    tenantFromStorage,
                                    userCodeFromStorage,
                                    passwordFromStorage,
                                    endPoint: endPointFromStorage == "" ? null : endPointFromStorage,
                                    context: context,
                                  );
                                  if (loginResponse.loginToken != "") {
                                    List<OfflineLocationCountingItem> copyOfflineLocationCountingList = List.from(offlineLocationCountingItemsList$.value);

                                    for (final item in copyOfflineLocationCountingList) {
                                      await db
                                          .sendLocationCountingDataOnline(
                                        currentList: item.currentList,
                                        selectedLocation: item.selectedLocation,
                                        note: item.note,
                                        showDialog: (locationCountingCount$.value == copyOfflineLocationCountingList.length - 1) ? true : false,
                                      )
                                          .then((value) {
                                        if (!value.success!) {
                                          kShowBanner(BannerType.ERROR, "Warning".tr(), value.message != null ? value.message!.tr() : "An error occurred while inserting the transaction", context);
                                          locationCountingUploadingError = true;
                                        } else {
                                          offlineLocationCountingItemsList$.value.removeWhere((e) => e == item);
                                          locationCountingCount$.value = locationCountingCount$.value + 1;
                                          locationCountingCount$.add(locationCountingCount$.value);
                                        }
                                      });

                                      if (locationCountingUploadingError == true) break;
                                    }

                                    offlineLocationCountingItemsFromHive.clear();
                                    await offlineLocationCountingItemsFromHive.put('OfflineLocationCountingItems', offlineLocationCountingItemsList$.value);
                                    offlineLocationCountingItemsList$.add(offlineLocationCountingItemsList$.value);
                                    locationCountingUploading$.add(false);
                                    locationCountingCount$.add(0);
                                    locationCountingUploadingError = false;
                                  }
                                }
                              } else {
                                // ignore: use_build_context_synchronously
                                kShowBanner(BannerType.ERROR, "Error".tr(), "No Internet Found please fix you're connection and try again".tr(), context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
