import 'package:hive_flutter/hive_flutter.dart';

import '../../Globals/index.dart';
import 'package:flutter/material.dart';

class CountingDetails extends StatefulWidget {
  @override
  _CountingDetailsState createState() => _CountingDetailsState();
}

class _CountingDetailsState extends State<CountingDetails> {
  final service = GetIt.I<CountingService>();

  late StreamSubscription barcodeListener;
  bool firstRun = true;
  BehaviorSubject<String> quantityStreamValue$ = BehaviorSubject.seeded("1");

  @override
  void initState() {
    super.initState();

    if (isOffline$.value && fixAssetOfflineCountItem$.value != null) {
      service.selectedCounting$.value = fixAssetOfflineCountItem$.value;
      service.selectedCounting$.add(service.selectedCounting$.value);
    }

    if (fixAssetsLocations$.value.values.toList().isNotEmpty) {
      service.selectedLocation$.add(fixAssetsLocations$.value.values.toList().first);
    }

    barcodeListener = lastBarcode$.listen((barcode) async {
      print(barcode);
      if (scannerBusy.value == false) {
        scannerBusy.add(true);
        if (firstRun) {
          firstRun = false;
          print("First Time.");
        } else {
          try {
            if (!service.newScanned$.value.keys.toList().contains(fixAssets_byBarcode$.value[barcode]?.id)) {
              double qty = 1.0;
              var approved = true;
              if ((fixAssets_byBarcode$.value[barcode]?.renewable ?? true) != true) {
                if (fixAssets_byBarcode$.value[barcode]?.barkodeList?[barcode]?.locationId != service.selectedLocation$.value?.id) {
                  approved = false;
                  approved = await makeFastTransfer(
                    barcode,
                    fixAssetsLocations$.value[fixAssets_byBarcode$.value[barcode]?.barkodeList?[barcode]?.locationId],
                    service.selectedLocation$.value,
                    fixAssets_byBarcode$.value[barcode],
                  );
                  print(approved.toString());
                  if (approved) {
                    if (fixAssets_byBarcode$.value[barcode] != null &&
                        fixAssetsLocations$.value[fixAssets_byBarcode$.value[barcode]?.barkodeList?[barcode]?.locationId]?.id != null &&
                        service.selectedLocation$.value?.id != null) {
                      await GetIt.I<TransferService>().fastTransfer(
                        fixAssets_byBarcode$.value[barcode]!,
                        fixAssetsLocations$.value[fixAssets_byBarcode$.value[barcode]!.barkodeList![barcode]!.locationId]!.id!,
                        service.selectedLocation$.value!.id!,
                      );
                    }

                    approved = true;
                    if (service.selectedLocation$.value?.id != null && fixAssets_byLocation$.value[service.selectedLocation$.value?.id] == null) {
                      fixAssets_byLocation$.value[service.selectedLocation$.value!.id!] = [];
                    }

                    fixAssets$.value[fixAssets_byBarcode$.value[barcode]?.id]?.barkodeList?[barcode]?.locationId = service.selectedLocation$.value?.id;
                    fixAssets_byBarcode$.value[barcode]?.barkodeList?[barcode]?.locationId = service.selectedLocation$.value?.id;
                  }
                }
              } else {
                if (fixAssets_byBarcode$.value[barcode] == null) {
                  return;
                }
                var result = await service.showFixedAssetCountDialog(fixAssets_byBarcode$.value[barcode]!, quantityStreamValue$);
                if (result != null) {
                  qty = result;
                }
              }
              if (approved) {
                if (fixAssets_byBarcode$.value[barcode]!.id == null) {
                  return;
                }
                service.newScanned$.value[fixAssets_byBarcode$.value[barcode]!.id!] = FixAssetCountDetail(
                  countingid: service.selectedCounting$.value?.id,
                  avgUnitprice: fixAssets_byBarcode$.value[barcode]!.boughtprice,
                  qty: qty,
                  locationid: (fixAssets_byBarcode$.value[barcode]!.renewable ?? true) == true
                      ? service.selectedLocation$.value?.id
                      : fixAssets_byBarcode$.value[barcode]!.barkodeList?[barcode]?.locationId,
                  masterassetid: fixAssets_byBarcode$.value[barcode]!.id,
                  barcodeID: fixAssets_byBarcode$.value[barcode]!.barkodeList?[barcode]?.id,
                  barcode: barcode,
                );

                service.newScanned$.add(service.newScanned$.value);
              }
            } else {
              if (fixAssets_byBarcode$.value[barcode] != null) {
                if (fixAssets_byBarcode$.value[barcode]!.renewable == true) {
                  var result = await service.showFixedAssetCountDialog(fixAssets_byBarcode$.value[barcode]!, quantityStreamValue$);
                  if (result != null) {
                    service.newScanned$.value[fixAssets_byBarcode$.value[barcode]!.id]!.qty = service.newScanned$.value[fixAssets_byBarcode$.value[barcode]!.id]!.qty ?? 1 + result;
                  }
                  service.newScanned$.add(service.newScanned$.value);
                }
              }
            }
          } catch (e) {
            scannerBusy.add(false);
          }
        }
        scannerBusy.add(false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    barcodeListener.cancel();
  }

  Future<void> setLocalDataFunction() async {
    for (var i = 0; i < service.newScanned$.value.values.toList().length; i++) {
      if (service.newScanned$.value.values.toList()[i].barcode != null && fixAssets_byBarcode$.value[service.newScanned$.value.values.toList()[i].barcode] != null) {
        fixAssets_byLocation$
            .value[fixAssets_byBarcode$.value[service.newScanned$.value.values.toList()[i].barcode]?.barkodeList?[service.newScanned$.value.values.toList()[i].barcode]?.locationId]
            ?.forEach((element) {
          if (element.barcode == service.newScanned$.value.values.toList()[i].barcode) {
            element.isScannedInApp = true;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${branches$.value[service.selectedCounting$.value?.branchid]!.name == null ? " " : (branches$.value[service.selectedCounting$.value?.branchid]!.name!)}\n${service.selectedCounting$.value?.periodstart == null ? " " : DateFormat("yyyy/MM/dd").format(service.selectedCounting$.value!.periodstart!)} - ${service.selectedCounting$.value!.periodend != null ? DateFormat("yyyy/MM/dd").format(service.selectedCounting$.value!.periodend!) : ""}",
          textAlign: TextAlign.center,
        ),
        actions: [
          if (cameraModeIsActive$.value == true)
            IconButton(
              icon: const Icon(Icons.camera_alt_rounded),
              onPressed: () async {
                var barcode = await scanner.scanBarcodeNormal();
                lastBarcode$.add(barcode);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: StreamBuilder(
            stream: Rx.combineLatest2(service.newScanned$, service.selectedLocation$, (a, b) => null),
            builder: (context, snapshot) {
              return Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                              boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, 0), spreadRadius: 5, blurRadius: 3)],
                              border: Border.all(color: Colors.black38, width: 1, style: BorderStyle.solid),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          child: InkWell(
                            onTap: () async {
                              var item = await showSearchWidget_FixedAssetsLocationName();
                              if (item != null) service.selectedLocation$.add(item);
                            },
                            child: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                        child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(padding: const EdgeInsets.all(5), child: Text(service.selectedLocation$.value?.name ?? '')),
                                ))),
                                SizedBox(width: 10),
                                Container(child: Padding(padding: EdgeInsets.only(left: 10.0, right: 10.0), child: Icon(Icons.list))),
                              ],
                            ),
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: service.newScanned$.value.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: w - 25,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                        boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, 0), spreadRadius: 3, blurRadius: 2)]),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 30, top: 5, right: 5, bottom: 5),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("${fixAssets$.value[service.newScanned$.value.values.toList()[index].masterassetid]?.name ?? ''}"),
                                                  if (service.newScanned$.value.values.toList()[index].barcode != null)
                                                    Text(
                                                      "${service.newScanned$.value.values.toList()[index].barcode ?? ''}",
                                                      style: TextStyle(color: Colors.grey),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Wrap(
                                            direction: Axis.horizontal,
                                            spacing: 5,
                                            runSpacing: 5,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: Text(
                                                  "${service.newScanned$.value.values.toList()[index].qty}",
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              InkWell(
                                                child: Icon(
                                                  Icons.clear,
                                                  color: Colors.red,
                                                ),
                                                onTap: () async {
                                                  var result = await showDeleteConfirmDialog();
                                                  if (result == true) {
                                                    service.newScanned$.value.remove(service.newScanned$.value.values.toList()[index].masterassetid);
                                                    service.newScanned$.add(service.newScanned$.value);
                                                  }
                                                },
                                              ),
                                            ],
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
                                      boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, 0), spreadRadius: 3, blurRadius: 2)]),
                                  child: Center(
                                    child: Text(
                                      (index + 1).toString(),
                                      style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) => Divider(height: 1),
                        )
                      ],
                    ),
                    SizedBox(
                      height: h * 0.14,
                    ),
                  ],
                ),
              );
            }),
      ),
      floatingActionButton: UnicornDialer(
        finalButtonIcon: Icon(Icons.clear),
        parentButton: Icon(Icons.menu),
        parentButtonBackground: Colors.blueGrey,
        hasBackground: true,
        backgroundColor: Colors.black12,
        orientation: 1,
        childPadding: 20,
        childButtons: [
          UnicornButton(
            null,
            null,
            null,
            hasLabel: true,
            labelText: "Add By Barcode".tr(),
            currentButton: FloatingActionButton(
              heroTag: "bybarcode",
              mini: true,
              child: Icon(Icons.add),
              onPressed: () async {
                var barcode = await showGetBarcodeDialog();

                if (fixAssets_byBarcode$.value[barcode] != null) {
                  lastBarcode$.add(barcode!);
                } else {
                  if (barcode != null) {
                    await showErrorDialog("No Fix Asset found for this barcode".tr());
                  }
                }
              },
            ),
          ),
          UnicornButton(
            null,
            null,
            null,
            hasLabel: true,
            labelText: "Add By Stock Name".tr(),
            currentButton: FloatingActionButton(
              heroTag: "byname",
              mini: true,
              child: Icon(Icons.add),
              onPressed: () async {
                var qty = 1.0;

                var result = await showSearchWidget_FixedAssetName();
                if (result?.id != null && result?.barkodeList != null) {
                  if (!(result!.renewable == true)) {
                    var barcodeItem = await showSearchWidget_FixedAssetBarcodes(result.barkodeList!.values.toList());
                    if (barcodeItem != null) {
                      result.barcode = barcodeItem.barcode;
                    }
                  }

                  var qtyResult = await service.showFixedAssetCountDialog(
                    result,
                    quantityStreamValue$,
                  );
                  qty = qtyResult ?? 1;

                  service.newScanned$.value[result.id!] = FixAssetCountDetail(
                    countingid: service.selectedCounting$.value?.id,
                    avgUnitprice: result.boughtprice,
                    qty: qty,
                    locationid: service.selectedLocation$.value?.id,
                    masterassetid: result.id,
                    barcodeID: result.renewable == true ? null : result.barkodeList?[result.barcode]?.id,
                    barcode: result.renewable == true ? null : result.barcode,
                  );
                  service.newScanned$.add(service.newScanned$.value);
                }
              },
            ),
          ),
          UnicornButton(
            null,
            null,
            null,
            hasLabel: true,
            labelText: "${"Save Counting".tr()}${isOffline$.value ? " Offline" : ""}",
            currentButton: FloatingActionButton(
              heroTag: "upload2",
              mini: true,
              child: Icon(Icons.upload_rounded),
              onPressed: () {
                service.newScanned$.value.forEach((key, value) {});
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    isOffline$.value
                        ? db
                            .sendCountingDataOffline(
                            newScannedItems: service.newScanned$.value.values.toList(),
                          )
                            .then((value) async {
                            if (value == true) {
                              await setLocalDataFunction();
                              service.newScanned$.add({});
                            }
                            Navigator.pop(context);
                          })
                        : db.sendCountingDataOnline(newScannedItems: service.newScanned$.value.values, selectedCounting: service.selectedCounting$.value).then((value) async {
                            if (value.success == true) {
                              await setLocalDataFunction();
                              service.newScanned$.add({});
                            }
                            Navigator.pop(context);
                          });
                    return Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
