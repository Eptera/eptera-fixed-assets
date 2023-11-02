import 'dart:convert';

import 'package:fixed_assets_v3/Globals/GlobalFunctions.dart';
import 'package:fixed_assets_v3/Globals/GlobalModels.dart';
import 'package:fixed_assets_v3/Globals/GlobalVariables.dart';
import 'package:fixed_assets_v3/Globals/index.dart';
import 'package:fixed_assets_v3/Services/ApiModels.dart';

class Database {
  Future<String?> setDataFromOnline(List activeSelection) async {
    try {
      var response = await api.execute({
        "Action": "Function",
        "Object": "FN_FIXASSET_GETMOBILEDATA",
        "Parameters": {
          "HOTELID": loginResponse.tenancy?.hotelid,
          "GETBRANCHES": activeSelection[0],
          "GETLOCATION": activeSelection[1],
          "GETFIXASSET": activeSelection[2],
          "GETCOUNTING": activeSelection[3],
          "GETRESPONSIBLESTAFF": activeSelection[4],
          "COUNTINGID": null,
          "BRANCHIDS": null
        },
      }).first;

      if (json.decode(response.dataSets?[0][0]["Return"])["Branches"] != null) {
        branches$.value = {};
        json.decode(response.dataSets![0][0]["Return"])["Branches"].forEach((e) {
          branches$.value[e["id"]] = Branch.fromJson(e);
        });
      }

      if (json.decode(response.dataSets?[0][0]["Return"])["FixAssetGroups"] != null) {
        fixAssetsGroup$.value = {};
        json.decode(response.dataSets![0][0]["Return"])["FixAssetGroups"].forEach((e) {
          fixAssetsGroup$.value[e["id"]] = FixAssetGroup.fromJson(e);
        });
      }

      if (json.decode(response.dataSets?[0][0]["Return"])["FixAssetLocations"] != null) {
        fixAssetsLocations$.value = {};
        json.decode(response.dataSets![0][0]["Return"])["FixAssetLocations"].forEach((e) {
          fixAssetsLocations$.value[e["id"]] = FixAssetLocation.fromJson(e);
        });
      }

      if (json.decode(response.dataSets?[0][0]["Return"])["FixAssets"] != null) {
        fixAssets$.value = {};
        fixAssets_byBarcodeID$.value = {};
        fixAssets_byBarcode$.value = {};
        fixAssets_byLocation$.value = {};
        json.decode(response.dataSets![0][0]["Return"])["FixAssets"].forEach((e) {
          fixAssets$.value[e["ID"]] = FixAsset.fromJson(e);
          if (fixAssets$.value[e["ID"]]?.barkodeList != null && (fixAssets$.value[e["ID"]]?.barkodeList?.length ?? -1) > 0) {
            fixAssets$.value[e["ID"]]!.barkodeList!.forEach((index, barcodeItem) {
              if (barcodeItem.id != null) {
                fixAssets_byBarcodeID$.value[barcodeItem.id!] = fixAssets$.value[e["ID"]]!.clone();
                fixAssets_byBarcodeID$.value[barcodeItem.id]!.barcode = barcodeItem.barcode;
                fixAssets_byBarcodeID$.value[barcodeItem.id]!.barcodeID = barcodeItem.id;
                fixAssets_byBarcodeID$.value[barcodeItem.id]!.readingDate = barcodeItem.readingDate;
              }

              if (barcodeItem.barcode != null) {
                fixAssets_byBarcode$.value[barcodeItem.barcode!] = fixAssets$.value[e["ID"]]!.clone();
                fixAssets_byBarcode$.value[barcodeItem.barcode]!.barcode = barcodeItem.barcode;
                fixAssets_byBarcode$.value[barcodeItem.barcode]!.barcodeID = barcodeItem.id;
                fixAssets_byBarcode$.value[barcodeItem.barcode]!.readingDate = barcodeItem.readingDate;
              }
              if (barcodeItem.locationId != null) {
                if (fixAssets_byLocation$.value[barcodeItem.locationId] == null) fixAssets_byLocation$.value[barcodeItem.locationId!] = [];
                fixAssets_byLocation$.value[barcodeItem.locationId]!.add(fixAssets$.value[e["ID"]]!.clone());
                fixAssets_byLocation$.value[barcodeItem.locationId]!.last.locId = barcodeItem.locationId;
                fixAssets_byLocation$.value[barcodeItem.locationId]!.last.barcode = barcodeItem.barcode;
                fixAssets_byLocation$.value[barcodeItem.locationId]!.last.barcodeID = barcodeItem.id;
                fixAssets_byLocation$.value[barcodeItem.locationId]!.last.readingDate = barcodeItem.readingDate;
              }
            });
          }
        });
      }

      if (json.decode(response.dataSets?[0][0]["Return"])["FixAssetCountDetail"] != null) {
        fixAssetsCountDetails$.value = {};
        json.decode(response.dataSets![0][0]["Return"])["FixAssetCountDetail"].forEach((e) {
          fixAssetsCountDetails$.value[e["ID"]] = FixAssetCountDetail.fromJson(e);
        });
      }
      if (json.decode(response.dataSets?[0][0]["Return"])["FixAssetCount"] != null) {
        fixAssetsCount$.value = {};
        json.decode(response.dataSets![0][0]["Return"])["FixAssetCount"].forEach((e) {
          fixAssetsCount$.value[e["ID"]] = FixAssetCount.fromJson(e);
        });
      }

      if (json.decode(response.dataSets?[0][0]["Return"])["FixAssetResponsibleStaff"] != null) {
        fixAssetsResponsibleStaff$.value = {};
        json.decode(response.dataSets![0][0]["Return"])["FixAssetResponsibleStaff"].forEach((e) {
          fixAssetsResponsibleStaff$.value[e["ID"]] = ResponsibleStaff.fromJson(e);
        });
      }

      if (isOffline$.value) {
        await _emptyTable(activeSelection);

        if (branches$.value.isNotEmpty && activeSelection[0]) {
          branchesFromHive.put('Branches', branches$.value);
        }
        if (fixAssetsLocations$.value.isNotEmpty && activeSelection[1]) {
          fixAssetsLocationsFromHive.put('FixAssetsLocations', fixAssetsLocations$.value);
        }

        if (fixAssets$.value.isNotEmpty && activeSelection[2]) {
          fixAssetsFromHive.put('FixAssets', fixAssets$.value);
        }
        if (fixAssetsCount$.value.isNotEmpty && activeSelection[3]) {
          fixAssetsCountFromHive.put('FixAssetsCount', fixAssetsCount$.value);
        }
      }

      return "";
    } on Exception catch (e) {
      await showErrorDialog(e.toString());
      return e.toString();
    }
  }

  Future setDataFromOffline() async {
    var fixAssets = fixAssetsFromHive.get('FixAssets')?.cast<int, FixAsset>();
    if (fixAssets != null) {
      fixAssets.forEach((key, value) {
        fixAssets$.value[key] = value;
        if (fixAssets[value.id]?.barkodeList != null && (fixAssets[value.id]?.barkodeList?.length ?? -1) > 0) {
          fixAssets[value.id]!.barkodeList!.forEach((index, barcodeItem) {
            if (barcodeItem.id != null) {
              fixAssets_byBarcodeID$.value[barcodeItem.id!] = fixAssets[value.id]!.clone();
              fixAssets_byBarcodeID$.value[barcodeItem.id]!.barcode = barcodeItem.barcode;
              fixAssets_byBarcodeID$.value[barcodeItem.id]!.barcodeID = barcodeItem.id;
              fixAssets_byBarcodeID$.value[barcodeItem.id]!.readingDate = barcodeItem.readingDate;
            }

            if (barcodeItem.barcode != null) {
              fixAssets_byBarcode$.value[barcodeItem.barcode!] = fixAssets[value.id]!.clone();
              fixAssets_byBarcode$.value[barcodeItem.barcode]!.barcode = barcodeItem.barcode;
              fixAssets_byBarcode$.value[barcodeItem.barcode]!.barcodeID = barcodeItem.id;
              fixAssets_byBarcode$.value[barcodeItem.barcode]!.readingDate = barcodeItem.readingDate;
            }
            if (barcodeItem.locationId != null) {
              if (fixAssets_byLocation$.value[barcodeItem.locationId] == null) fixAssets_byLocation$.value[barcodeItem.locationId!] = [];
              fixAssets_byLocation$.value[barcodeItem.locationId]!.add(fixAssets[value.id]!.clone());
              fixAssets_byLocation$.value[barcodeItem.locationId]!.last.locId = barcodeItem.locationId;
              fixAssets_byLocation$.value[barcodeItem.locationId]!.last.barcode = barcodeItem.barcode;
              fixAssets_byLocation$.value[barcodeItem.locationId]!.last.barcodeID = barcodeItem.id;
              fixAssets_byLocation$.value[barcodeItem.locationId]!.last.readingDate = barcodeItem.readingDate;
            }
          });
        }
      });
    }

    var branches = branchesFromHive.get('Branches')?.cast<int, Branch>();
    if (branches != null) {
      branches.forEach((key, value) {
        branches$.value[key] = value;
      });
    }

    var fixAssetsLocations = fixAssetsLocationsFromHive.get('FixAssetsLocations')?.cast<int, FixAssetLocation>();
    if (fixAssetsLocations != null) {
      fixAssetsLocations.forEach((key, value) {
        fixAssetsLocations$.value[key] = value;
      });
    }

    var fixAssetsCount = fixAssetsCountFromHive.get('FixAssetsCount')?.cast<int, FixAssetCount>();
    if (fixAssetsCount != null) {
      fixAssetsCount.forEach((key, value) {
        fixAssetsCount$.value[key] = value;
      });
    }

    // var offlineCountingItems = offlineCountingItemsFromHive.get('OfflineCountingItems')?.cast<>();
  }

  _emptyTable(List activeList) async {
    if (activeList[0]) branchesFromHive.clear();
    if (activeList[1]) fixAssetsLocationsFromHive.clear();
    if (activeList[2]) fixAssetsFromHive.clear();
    if (activeList[3]) fixAssetsCountFromHive.clear();
  }

  Future<UpdateResponse> sendCountingDataOnline({
    required Iterable<FixAssetCountDetail> newScannedItems,
    FixAssetCount? selectedCounting,
    bool showDialog = true,
  }) async {
    try {
      await api.execute({
        "Action": "Execute",
        "Object": "SP_ACCOUNTING_FIXASSET_COUNTING_INSERT",
        "Parameters": {
          "HOTELID": loginResponse.tenancy?.hotelid,
          "JSONDATA": json.encode({
            "LocationCounting": false,
            "Items": newScannedItems
                .map((e) => {
                      "DateTime": Moment.now().format("yyyy-MM-dd HH:mm"),
                      "LocationID": e.locationid,
                      "MasterAssetID": e.barcodeID != null ? null : e.masterassetid,
                      "BarcodeID": e.barcodeID,
                      "Barcode": e.barcode,
                      "QTY": e.qty,
                      "CountingID": selectedCounting?.id,
                      "BranchID": selectedCounting?.branchid,
                      "Price": e.avgUnitprice,
                    })
                .toList()
          })
        }
      }).first;

      if (showDialog) {
        await showWarningDialog("Success".tr(), "Fixed Assets Inserted Successfully.".tr());
      }
      return UpdateResponse(success: true);
    } on Exception catch (e) {
      await showErrorDialog(e.toString());
      return UpdateResponse(success: false);
    }
  }

  Future<UpdateResponse> sendLocationCountingDataOnline({
    required Map<int, bool> currentList,
    FixAssetLocation? selectedLocation,
    String? note,
    bool showDialog = true,
  }) async {
    try {
      var requestObj = [];

      currentList.forEach((key, value) {
        if (value) {
          requestObj.add({
            "DateTime": Moment.now().format("yyyy-MM-dd HH:mm"),
            "LocationID": selectedLocation?.id,
            "MasterAssetID": fixAssets_byBarcodeID$.value[key]?.id,
            "BarcodeID": key,
            "QTY": 1
          });
        }
      });

      if (requestObj.isEmpty) {
        return UpdateResponse(success: false);
      }

      await api.execute({
        "Action": "Execute",
        "Object": "SP_ACCOUNTING_FIXASSET_COUNTING_INSERT",
        "Parameters": {
          "HOTELID": loginResponse.tenancy?.hotelid,
          "JSONDATA": json.encode({
            "LocationCounting": true,
            "Note": note,
            "Items": requestObj,
          })
        }
      }).first;

      if (showDialog) {
        await showWarningDialog("Success".tr(), "Fixed Assets Inserted Successfully.".tr());
      }
      return UpdateResponse(success: true);
    } on Exception catch (e) {
      if (showDialog) {
        await showErrorDialog(e.toString());
      }
      return UpdateResponse(success: false, message: e.toString());
    }
  }

  Future<bool> sendCountingDataOffline({
    required List<FixAssetCountDetail> newScannedItems,
  }) async {
    try {
      var newFixAssetCountDetailsList = fixAssetCountDetailsFromHive.get('FixAssetCountDetailsFromHive')?.cast<FixAssetCountDetail>();
      newFixAssetCountDetailsList ??= [];

      newScannedItems.forEach((element) {
        newFixAssetCountDetailsList!.add(element);
      });

      fixAssetCountDetailsFromHive.put('FixAssetCountDetailsFromHive', newFixAssetCountDetailsList);

      Future.delayed(Duration.zero).then((value) async {
        // await showWarningDialog("Success".tr(), "Fixed Assets Inserted Successfully.".tr());
        await showWarningDialog("Success".tr(), "The offline count has been successfully saved to the offline count screen.".tr());
      });

      return true;
    } on Exception catch (e) {
      Future.delayed(Duration.zero).then((value) async {
        await showErrorDialog(e.toString());
      });
      return false;
    }
  }

  Future<bool> sendLocationCountingDataOffline({
    required Map<int, bool> currentList,
    FixAssetLocation? selectedLocation,
    String? note,
  }) async {
    try {
      List<OfflineLocationCountingItem> newOfflineLocationCountingItemList =
          offlineLocationCountingItemsFromHive.get('OfflineLocationCountingItems', defaultValue: <OfflineLocationCountingItem>[])!.cast<OfflineLocationCountingItem>();

      newOfflineLocationCountingItemList.add(OfflineLocationCountingItem(
        currentList: currentList,
        selectedLocation: selectedLocation,
        note: note,
      ));

      offlineLocationCountingItemsFromHive.put('OfflineLocationCountingItems', newOfflineLocationCountingItemList);

      Future.delayed(Duration.zero).then((value) async {
        // await showWarningDialog("Success".tr(), "Fixed Assets Inserted Successfully.".tr());

        await showWarningDialog("Success".tr(), "The offline count has been successfully saved to the offline count screen.".tr());
      });
      return true;
    } on Exception catch (e) {
      Future.delayed(Duration.zero).then((value) async {
        await showErrorDialog(e.toString());
      });
      return false;
    }
  }
}
