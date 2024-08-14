import 'package:flutter/services.dart';

import '../../Globals/index.dart';
import 'package:flutter/material.dart';

class Counting_LocationDetails extends StatefulWidget {
  @override
  _Counting_LocationDetailsState createState() => _Counting_LocationDetailsState();
}

class _Counting_LocationDetailsState extends State<Counting_LocationDetails> {
  final service = GetIt.I<Counting_LocationService>();

  late StreamSubscription barcodeListener;
  bool firstRun = true;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle( SystemUiOverlayStyle(
      statusBarColor: kWhite,
    ));

    service.currentList$.value = {};

    if (fixAssets_byLocation$.value[service.selectedLocation$.value?.id] != null) {
      fixAssets_byLocation$.value[service.selectedLocation$.value?.id]!.forEach((e) {
        if (e.barcodeID != null) {
          if (e.isScannedInApp == true) {
            service.currentList$.value[e.barcodeID!] = true;
          } else {
            service.currentList$.value[e.barcodeID!] = false;
          }
        }
      });
    }

    service.currentList$.add(service.currentList$.value);

    barcodeListener = lastBarcode$.listen((barcode) async {
      print('SECOND LISTENER WORKINGG');
      if (scannerBusy.value == false) {
        scannerBusy.add(true);
        if (firstRun) {
          firstRun = false;
          print("First Time.");
        } else {
          if (fixAssets_byBarcode$.value[barcode] != null) {
            var approved = true;
            if (fixAssets_byBarcode$.value[barcode]!.barkodeList?[barcode]?.locationId != service.selectedLocation$.value?.id) {
              approved = false;
              approved = await makeFastTransfer(
                barcode,
                fixAssetsLocations$.value[fixAssets_byBarcode$.value[barcode]?.barkodeList?[barcode]?.locationId],
                service.selectedLocation$.value,
                fixAssets_byBarcode$.value[barcode],
              );

              print(approved.toString());
              if (approved) {
                if (fixAssetsLocations$.value[fixAssets_byBarcode$.value[barcode]!.barkodeList?[barcode]?.locationId]?.id != null && service.selectedLocation$.value?.id != null) {
                  await showLoadingDialog(GetIt.I<TransferService>().fastTransfer(
                    fixAssets_byBarcode$.value[barcode]!,
                    fixAssetsLocations$.value[fixAssets_byBarcode$.value[barcode]!.barkodeList![barcode]!.locationId]!.id!,
                    service.selectedLocation$.value!.id!,
                  )).then((value) {
                    if (value.success!) {
                      fixAssets_byLocation$.value[fixAssets_byBarcode$.value[barcode]!.barkodeList![barcode]!.locationId]!.removeWhere((e) => e.barcode == barcode);
                      fixAssets_byLocation$.value[service.selectedLocation$.value!.id]!.add(fixAssets_byBarcode$.value[barcode]!);
                      fixAssets$.value[fixAssets_byBarcode$.value[barcode]!.id]!.barkodeList![barcode]!.locationId = service.selectedLocation$.value!.id;
                      fixAssets_byBarcode$.value[barcode]!.barkodeList![barcode]!.locationId = service.selectedLocation$.value!.id;
                      approved = true;

                      var oldList = service.currentList$.value;
                      service.currentList$.value = {};

                      fixAssets_byLocation$.value[service.selectedLocation$.value!.id]!.forEach((e) {
                        if (service.currentList$.value[e.barcodeID] == null && e.barcodeID != null) service.currentList$.value[e.barcodeID!] = oldList[e.barcodeID!] ?? false;
                      });
                      kShowBanner(BannerType.SUCCESS, "Success".tr(), "Transaction inserted successfully".tr(), context);
                    } else {
                      kShowBanner(BannerType.ERROR, "Error".tr(), value.message ?? "An error occurred while inserting the transaction".tr(), context);
                    }
                  });
                }
              }
            }
            if (approved) {
              service.currentList$.add(service.currentList$.value);
              if (service.currentList$.value.containsKey(fixAssets_byBarcode$.value[barcode]?.barcodeID)) {
                service.currentList$.value[fixAssets_byBarcode$.value[barcode]!.barcodeID!] = true;
                service.currentList$.add(service.currentList$.value);
              } else {
                kShowBanner(BannerType.ERROR, "Error".tr(),"This Item doesn't exist in this location".tr(), context);
              }
            }
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
    fixAssets_byLocation$.value.removeWhere((key, value) => value.isEmpty);
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
                FocusScope.of(context).unfocus();
            await showDialog(
              context: context,
              builder: (context) {
                isOffline$.value
                    ? db
                    .sendLocationCountingDataOffline(
                  currentList: service.currentList$.value,
                  selectedLocation: service.selectedLocation$.value,
                  note: service.note$.value,
                )
                    .then((v) {
                        Navigator.pop(context);
                      if(v == true){
                        Future.delayed(Duration.zero).then((value) async {
                          kShowBanner(BannerType.SUCCESS, "Success".tr(), "The offline count has been successfully saved to the offline count screen.".tr(), context);
                        });
                      }else{
                        kShowBanner(BannerType.ERROR, "Error".tr(), "An error occurred while saving the offline count".tr(), context);
                      }
                })
                    : db
                    .sendLocationCountingDataOnline(
                  currentList: service.currentList$.value,
                  selectedLocation: service.selectedLocation$.value,
                  note: service.note$.value,
                )
                    .then((v) {
                  Navigator.pop(context);
                      if(v.success == true){
                        kShowBanner(BannerType.SUCCESS, "Success".tr(), "Fixed Assets Inserted Successfully".tr(), context);
                      }else{
                        kShowBanner(BannerType.ERROR, "Error".tr(), v.message ?? "An error occurred while inserting the transaction".tr(), context);
                      }
                });
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          }, icon: SvgPicture.asset("assets/images/save.svg"))
        ],
        bottom: PreferredSize(
          preferredSize: Size(w, 80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Location Counting".tr(),
                    style: k16w400Black(color: kGrey600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.selectedLocation$.value?.name ?? "",
                    style: k20w600Black(color: kGrey900),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            CTextFormField(
              hintText: "Enter counting note here".tr(),
              textInputAction: TextInputAction.done,
              onChange: (value) {
                service.note$.value = value;
              },
              hasIcon: true,
              iconPath: "assets/images/note.svg",
            ),
            SingleChildScrollView(
              child: StreamBuilder(
                  stream: Rx.combineLatest3(service.currentList$.stream, fixAssets_byBarcodeID$.stream, fixAssets_byBarcode$.stream, (a, b, c) => null),
                  builder: (context, snapshot) {
                    return ListView.separated(
                      padding: EdgeInsets.only(top: 16, bottom: h * 0.2),
                      itemCount: service.currentList$.value.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fixAssets_byBarcodeID$.value[service.currentList$.value.keys.toList()[index]]?.name ?? '-',
                                  style: k14w500Black(color: kGrey900),
                                ),
                                fixAssets_byBarcodeID$.value[service.currentList$.value.keys.toList()[index]]?.barcode != null
                                    ? Row(
                                        children: [
                                          Text(
                                            "${"Barcode".tr()}:",
                                            style: k14w400Black(color: kGrey700),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            "${fixAssets_byBarcodeID$.value[service.currentList$.value.keys.toList()[index]]!.barcode}",
                                            style: k14w500Black(color: kGrey700),
                                          )
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Text(
                                            "${"Barcode ID".tr()}:",
                                            style: k14w400Black(color: kGrey700),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            "${fixAssets_byBarcodeID$.value[service.currentList$.value.keys.toList()[index]]!.barcodeID}",
                                            style: k14w500Black(color: kGrey700),
                                          )
                                        ],
                                      ),
                                (fixAssets_byBarcodeID$.value[service.currentList$.value.keys.toList()[index]]?.readingDate != null && (!service.currentList$.value.values.toList()[index]))
                                    ? Row(
                                        children: [
                                          Text(
                                            "${"Last Scanned Date".tr()}:",
                                            style: k14w400Black(color: kGrey700),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            DateFormat("yyyy/MM/dd HH:mm").format(fixAssets_byBarcodeID$.value[service.currentList$.value.keys.toList()[index]]!.readingDate!),
                                            style: k14w400Black(color: kGrey700),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        "${"Last Scanned Date".tr()}:",
                                        style: k14w400Black(color: Colors.transparent),
                                      ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                service.currentList$.value[service.currentList$.value.keys.toList()[index]] = !service.currentList$.value.values.toList()[index];
                                service.currentList$.add(service.currentList$.value);
                              },
                              child: service.currentList$.value.values.toList()[index]
                                  ? SvgPicture.asset("assets/images/scanned_now.svg")
                                  : fixAssets_byBarcodeID$.value[service.currentList$.value.keys.toList()[index]]?.readingDate != null
                                      ? SvgPicture.asset("assets/images/scanned_before.svg")
                                      : SvgPicture.asset("assets/images/not_scanned.svg"),
                            )
                          ],
                        ),
                      ),
                      separatorBuilder: (context, index) => const Divider(color: kBorderColor2),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
