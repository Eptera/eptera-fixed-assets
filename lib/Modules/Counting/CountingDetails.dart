import 'package:flutter/services.dart';
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

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kWhite,
    ));

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
                      await showLoadingDialog(GetIt.I<TransferService>().fastTransfer(
                        fixAssets_byBarcode$.value[barcode]!,
                        fixAssetsLocations$.value[fixAssets_byBarcode$.value[barcode]!.barkodeList![barcode]!.locationId]!.id!,
                        service.selectedLocation$.value!.id!,
                      )).then((value) {
                        if (value.success!) {
                          approved = true;
                          if (service.selectedLocation$.value?.id != null && fixAssets_byLocation$.value[service.selectedLocation$.value?.id] == null) {
                            fixAssets_byLocation$.value[service.selectedLocation$.value!.id!] = [];
                          }

                          fixAssets$.value[fixAssets_byBarcode$.value[barcode]?.id]?.barkodeList?[barcode]?.locationId = service.selectedLocation$.value?.id;
                          fixAssets_byBarcode$.value[barcode]?.barkodeList?[barcode]?.locationId = service.selectedLocation$.value?.id;
                          kShowBanner(BannerType.SUCCESS, "Success".tr(), "Transaction inserted successfully".tr(), context);
                        } else {
                          kShowBanner(BannerType.ERROR, "Error".tr(), value.message ?? "An error occurred while inserting the transaction".tr(), context);
                        }
                      });
                    }
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
                  locationid:
                      (fixAssets_byBarcode$.value[barcode]!.renewable ?? true) == true ? service.selectedLocation$.value?.id : fixAssets_byBarcode$.value[barcode]!.barkodeList?[barcode]?.locationId,
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
        fixAssets_byLocation$.value[fixAssets_byBarcode$.value[service.newScanned$.value.values.toList()[i].barcode]?.barkodeList?[service.newScanned$.value.values.toList()[i].barcode]?.locationId]
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: kGrey700,
            )),
        actions: [
          if (cameraModeIsActive$.value == true)
            IconButton(
              icon: SvgPicture.asset("assets/images/camera.svg"),
              onPressed: () async {
                var barcode = await scanner.scanBarcodeNormal();
                lastBarcode$.add(barcode);
              },
            ),
          IconButton(
              onPressed: () async {
                showModalBottomSheet(
                    isDismissible: false,
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                    builder: (BuildContext bottomSheetContext) {
                      return DraggableScrollableSheet(
                          expand: false,
                          maxChildSize: 0.4,
                          minChildSize: 0.3,
                          initialChildSize: 0.3,
                          builder: (draggableContext, controller) {
                            return Container(
                              decoration: const BoxDecoration(color: kWhite, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                              child: Stack(children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(35),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
                                        child: Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.start,
                                          runSpacing: 16,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                Navigator.pop(bottomSheetContext);
                                                await showDialog(
                                                  context: currentContext,
                                                  builder: (context) {
                                                    TextEditingController barcode = TextEditingController();
                                                    return Column(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        AlertDialog(
                                                          titlePadding: EdgeInsets.only(left: 16, top: 20, right: 16),
                                                          contentPadding: EdgeInsets.only(left: 16, top: 24, bottom: 24, right: 16),
                                                          actionsPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                                          insetPadding: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 32),
                                                          title: Text(
                                                            "Search Barcode".tr(),
                                                            style: k18w600Black(color: kGrey900),
                                                          ),
                                                          content: SizedBox(
                                                            width: w - 32,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  "Barcode No".tr(),
                                                                  style: k14w500Black(color: kGrey700),
                                                                ),
                                                                SizedBox(
                                                                  height: 6,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      width: w - 114,
                                                                      child: CTextFormField(
                                                                          textInputType: TextInputType.number,
                                                                          hasIcon: false,
                                                                          controller: barcode,
                                                                          hintText: "Enter barcode number".tr(),
                                                                          textInputAction: TextInputAction.done,
                                                                          onChange: (value) {}),
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () async {
                                                                        currentContext = context;
                                                                        await scanner.scanBarcodeNormal();
                                                                      },
                                                                      child: Container(
                                                                        padding: EdgeInsets.all(10),
                                                                        decoration:
                                                                        BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(8), border: Border.all(color: kBorderColor2)),
                                                                        child: SvgPicture.asset("assets/images/barcode.svg"),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          actions: [
                                                            Column(
                                                              children: [
                                                                StreamBuilder(
                                                                    stream: lastBarcode$.stream,
                                                                    builder: (context, snapshot) {
                                                                      return ElevatedButton(
                                                                        onPressed: () async {
                                                                          Navigator.pop(context);
                                                                          lastBarcode$.add(barcode.text);
                                                                        },
                                                                        child: Text(
                                                                          "Search".tr(),
                                                                          style: k16w600Black(color: kWhite),
                                                                        ),
                                                                      );
                                                                    }),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed: () => Navigator.pop(context),
                                                                  child: Text(
                                                                    "Cancel".tr(),
                                                                    style: k16w600Black(color: kGrey700),
                                                                  ),
                                                                  style: ElevatedButton.styleFrom(
                                                                    primary: kWhite,
                                                                    side: BorderSide(color: kBorderColor),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(8),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset("assets/images/search_barcode_20.svg"),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Text(
                                                    "Add By Barcode".tr(),
                                                    style: k14w500Black(color: kGrey900),
                                                  )
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                Navigator.pop(bottomSheetContext);
                                                var qty = 1.0;

                                                var result = await showSearchWidget_FixedAssetName();
                                                if (result?.id != null && result?.barkodeList != null) {
                                                  if (!(result!.renewable == true)) {
                                                    if (result.barkodeList!.values.toList().isNotEmpty) {
                                                      var value = await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => FixedAssetBarcodes(result.barkodeList!.values.toList()),
                                                        ),
                                                      );

                                                      if (value != null) {
                                                        currentContext = context;
                                                        result.barcode = value.barcode;


                                                      }else{
                                                        currentContext = context;
                                                      }
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
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset("assets/images/add_by_stock.svg"),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Text("Add By Fixed Asset Name".tr(), style: k14w500Black(color: kGrey900))
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(bottomSheetContext);
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
                                                        Navigator.pop(context);
                                                      kShowBanner(BannerType.SUCCESS,"Success".tr(), "The offline count has been successfully saved to the offline count screen.".tr(),context);
                                                      }else{
                                                        Navigator.pop(context);
                                                      }
                                                    })
                                                        : db
                                                        .sendCountingDataOnline(newScannedItems: service.newScanned$.value.values, selectedCounting: service.selectedCounting$.value)
                                                        .then((value) async {
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
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset("assets/images/save_20.svg"),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Text("Save".tr(), style: k14w500Black(color: kGrey900))
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 32,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(primary: kWhite, side: BorderSide(color: kBorderColor)),
                                        child: Text(
                                          "Cancel".tr(),
                                          style: k16w600Black(color: kGrey700),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            );
                          });
                    });
              },
              icon: SvgPicture.asset("assets/images/menu.svg"))
        ],
        bottom: PreferredSize(
          preferredSize: Size(w, 80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branches$.value[service.selectedCounting$.value?.branchid]!.name ?? "-",
                  style: k16w600Black(color: kGrey900),
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: (w - 64) / 2,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFECDC9))),
                      child: Text(
                        service.selectedCounting$.value?.periodstart == null ? " " : DateFormat("yyyy/MM/dd").format(service.selectedCounting$.value!.periodstart!),
                        style: k14w500Black(
                          color: const Color(0xFFB32218),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF17B26A),
                      size: 16,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      width: (w - 64) / 2,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFAAEFC6))),
                      child: Text(
                        service.selectedCounting$.value!.periodend != null ? DateFormat("yyyy/MM/dd").format(service.selectedCounting$.value!.periodend!) : "",
                        style: k14w500Black(
                          color: const Color(0xFF067647),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            Wrap(
              children: [
                StreamBuilder(
                    stream: service.selectedLocation$.stream,
                    builder: (context, snapshot) {
                      return ElevatedButton(
                        onPressed: () async {
                          var item = await showSearchWidget_FixedAssetsLocationName();
                          if (item != null) service.selectedLocation$.add(item);
                        },
                        style: ElevatedButton.styleFrom(minimumSize: Size(w - 64, 44), primary: kWhite, side: BorderSide(color: kBorderColor)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              service.selectedLocation$.value?.name ?? "Select Location".tr(),
                              style: k14w500Black(color: kGrey700),
                            ),
                            SvgPicture.asset("assets/images/arrow_down.svg")
                          ],
                        ),
                      );
                    }
                ),
                StreamBuilder(
                    stream: service.newScanned$.stream,
                    builder: (context, snapshot) {
                      if(service.newScanned$.value.isEmpty){
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset("assets/images/asset_not_found.svg"),
                              const SizedBox(height: 16,),
                              Text("You can add fixed assets from the menu icon, by scanning the barcode or by selecting the asset from the list".tr(),style: k14w400Black(color: kGrey600),textAlign: TextAlign.center,),
                            ],
                          ),
                        );
                      }else{
                        return ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: h * 0.2, top: 20),
                          itemCount: service.newScanned$.value.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fixAssets$.value[service.newScanned$.value.values.toList()[index].masterassetid]?.name ?? '',
                                        style: k14w500Black(color: kGrey900),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text("${"Barcode".tr()}:",style: k14w400Black(color: kGrey500),),
                                          SizedBox(width: 6,),
                                          Text(service.newScanned$.value.values.toList()[index].barcode ?? '-', style: k14w500Black(color: kGrey500)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        service.newScanned$.value.values.toList()[index].qty != null ? service.newScanned$.value.values.toList()[index].qty!.toString() : "",
                                        style: k16w600Black(color: kPrimaryColor),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          var result = await showConfirmDialog("Delete".tr(), "Are you sure you want to delete this fixed asset?".tr(),
                                              imagePath: "assets/images/error.svg", actionText: "Delete".tr());
                                          if (result == true) {
                                            service.newScanned$.value.remove(service.newScanned$.value.values.toList()[index].masterassetid);
                                            service.newScanned$.add(service.newScanned$.value);
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SvgPicture.asset("assets/images/delete.svg"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            color: kBorderColor2,
                          ),
                        );
                      }
                    }
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
