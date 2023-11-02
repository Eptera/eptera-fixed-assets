import 'package:fixed_assets_v3/Globals/index.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class OfflineSummery extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OfflineSummery();
}

class _OfflineSummery extends State<OfflineSummery> with SingleTickerProviderStateMixin {
  BehaviorSubject<List<FixAssetCountDetail>> fixAssetCountDetails$ = BehaviorSubject.seeded([]);
  BehaviorSubject<List<OfflineLocationCountingItem>> offlineLocationCountingItemsList$ = BehaviorSubject.seeded([]);

  BehaviorSubject<bool> countingUploading$ = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> locationCountingUploading$ = BehaviorSubject.seeded(false);

  BehaviorSubject<int> countingCount$ = BehaviorSubject.seeded(0);
  BehaviorSubject<int> locationCountingCount$ = BehaviorSubject.seeded(0);

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

// //TEST
//     for (var i = 0; i < 467; i++)
//       fixAssetCountDetails$.value.add(FixAssetCountDetail(
//         avgUnitprice: 5000.0,
//         barcode: "0511",
//         barcodeID: 78,
//         countingid: 134,
//         id: 0,
//         locationid: 100,
//         masterassetid: 14263,
//         qty: 3,
//       ));

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

    return StreamBuilder(
        stream: Rx.combineLatest2(fixAssetCountDetails$, offlineLocationCountingItemsList$, (a, b) => null),
        builder: (context, snapshot) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text("Offline Data".tr()),
                bottom: TabBar(
                  controller: tabController,
                  tabs: [
                    Tab(text: "Counting".tr() + " (${fixAssetCountDetails$.value.length})"),
                    Tab(text: "Lokasyon Sayım" + " (${offlineLocationCountingItemsList$.value.length})"),
                  ],
                ),
              ),
              body: TabBarView(
                controller: tabController,
                children: [
                  StreamBuilder<bool>(
                      stream: countingUploading$.stream,
                      builder: (context, snapshot) {
                        if (snapshot.data ?? false) {
                          return StreamBuilder(
                              stream: countingCount$.stream,
                              builder: (context, snapshot) {
                                return Center(
                                  child: Container(
                                    height: w / 2,
                                    child: Column(
                                      children: [
                                        const CircularProgressIndicator(
                                          color: Colors.black87,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "${countingCount$.value} of ${countingTotalCount} Done",
                                          style: const TextStyle(color: Colors.black87),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              });
                        }
                        return Container(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: fixAssetCountDetails$.value.length,
                            padding: EdgeInsets.only(bottom: h * 0.14),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(10),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Container(
                                        // height: 80,
                                        width: w - 25,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: Colors.white,
                                            boxShadow: [const BoxShadow(color: Colors.black12, offset: Offset(0, 0), spreadRadius: 3, blurRadius: 2)]),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 30, top: 5, right: 5, bottom: 5),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(fixAssetsLocations$.value[fixAssetCountDetails$.value[index].locationid]?.name ?? "",
                                                        style: TextStyle(color: Colors.blue[900], fontSize: 16, fontWeight: FontWeight.w400)),
                                                    SizedBox(height: 10),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(fixAssets$.value[fixAssetCountDetails$.value[index].masterassetid]?.name ?? ""),
                                                        Text(fixAssetCountDetails$.value[index].qty.toString()),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.clear,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () async {
                                                  var result = await showDeleteConfirmDialog();

                                                  // if (result == true) {
                                                  //   stockItems_ByBarcode$.value.removeWhere((key, value) => key == barcodeList$.value[index].barcode);
                                                  //   stockItems_ByID$.value.removeWhere((key, value) => key == barcodeList$.value[index].stockId);
                                                  //   barcodeList$.value.removeAt(index);
                                                  //   barcodeList$.add(barcodeList$.value);
                                                  //   barcodesFromHive.clear();
                                                  //   barcodesFromHive.put('stock_barcode_new', barcodeList$.value);
                                                  // }

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
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Colors.white,
                                          boxShadow: [const BoxShadow(color: Colors.black12, offset: Offset(0, 0), spreadRadius: 3, blurRadius: 2)]),
                                      child: Center(
                                        child: Text(
                                          (index + 1).toString(),
                                          style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }),
                  StreamBuilder<bool>(
                      stream: locationCountingUploading$.stream,
                      builder: (context, snapshot) {
                        if (snapshot.data ?? false) {
                          return StreamBuilder(
                              stream: locationCountingCount$.stream,
                              builder: (context, snapshot) {
                                return Center(
                                  child: Container(
                                    height: w / 2,
                                    child: Column(
                                      children: [
                                        const CircularProgressIndicator(
                                          color: Colors.black87,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "${locationCountingCount$.value} of ${locationCountingTotalCount} Done",
                                          style: const TextStyle(color: Colors.black87),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              });
                        }
                        return Container(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: offlineLocationCountingItemsList$.value.length,
                            padding: EdgeInsets.only(bottom: h * 0.14),
                            itemBuilder: (context, index) {
                              print(offlineLocationCountingItemsList$.value[index].note);
                              return Padding(
                                padding: const EdgeInsets.all(10),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Container(
                                        // height: 80,
                                        width: w - 25,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: Colors.white,
                                            boxShadow: [const BoxShadow(color: Colors.black12, offset: Offset(0, 0), spreadRadius: 3, blurRadius: 2)]),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 30, top: 5, right: 5, bottom: 5),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      offlineLocationCountingItemsList$.value[index].selectedLocation?.name ?? "",
                                                      style: TextStyle(color: Colors.blue[900], fontSize: 16, fontWeight: FontWeight.w400),
                                                    ),
                                                    SizedBox(height: 10),
                                                    for (var i = 0; i < offlineLocationCountingItemsList$.value[index].currentList.keys.toList().length; i++)
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                                        child: Text(
                                                            "- ${fixAssets_byBarcodeID$.value[offlineLocationCountingItemsList$.value[index].currentList.keys.toList()[i]]?.name ?? ""}"),
                                                      ),
                                                    if (offlineLocationCountingItemsList$.value[index].note != null && offlineLocationCountingItemsList$.value[index].note != '')
                                                      Column(
                                                        children: [
                                                          SizedBox(height: 10),
                                                          Text(
                                                            offlineLocationCountingItemsList$.value[index].note!,
                                                            style: TextStyle(color: Colors.black.withOpacity(0.75), fontSize: 16, fontWeight: FontWeight.w400),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.clear,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () async {
                                                  var result = await showDeleteConfirmDialog();

                                                  if (result == true) {
                                                    offlineLocationCountingItemsList$.value.removeAt(index);
                                                    offlineLocationCountingItemsFromHive.clear();
                                                    await offlineLocationCountingItemsFromHive.put('OfflineLocationCountingItems', offlineLocationCountingItemsList$.value);
                                                    offlineLocationCountingItemsList$.add(offlineLocationCountingItemsList$.value);
                                                  }
                                                  // var result = await showDeleteConfirmDialog();
                                                  // if (result == true) {
                                                  //   countDetailsList$.value.removeAt(index);
                                                  //   countDetailsList$.add(countDetailsList$.value);
                                                  //   countStockDetailsFromHive.clear();
                                                  //   countStockDetailsFromHive.put('CountStockMasterItems', countDetailsList$.value);
                                                  // }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Colors.white,
                                          boxShadow: [const BoxShadow(color: Colors.black12, offset: Offset(0, 0), spreadRadius: 3, blurRadius: 2)]),
                                      child: Center(
                                        child: Text(
                                          (index + 1).toString(),
                                          style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                // mini: true,
                child: const Icon(Icons.upload_rounded),
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
                      );
                      bool? isCountStockOfflineMasterItemActive;
                      await db.setDataFromOnline([false, false, false, true, false]).then((value) async {
                        if (value == "") {
                          isCountStockOfflineMasterItemActive = fixAssetsCount$.value.containsKey(fixAssetOfflineCountItem$.value?.id);
                        } else {
                          print("-----------------Error_----------------------");
                          await showErrorDialog(value);
                        }
                      });

                      if (isCountStockOfflineMasterItemActive == false) {
                        showErrorDialog("Counting is no longer active".tr());
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
                              showErrorDialog("${item.selectedLocation}\n\n${value.message}");

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
                    showErrorDialog("No Internet Found please fix you're connection and try again.".tr());
                  }
                },
              ),
            ),
          );
        });
  }
}
