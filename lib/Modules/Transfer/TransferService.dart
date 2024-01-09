import '../../Globals/index.dart';

class TransferService {
  final api = GetIt.I<Api>();

  BehaviorSubject<FixAsset?> fixedAssetItem$ = BehaviorSubject.seeded(null);
  BehaviorSubject<int> transferType$ = BehaviorSubject.seeded(12);
  BehaviorSubject<DateTime> dateTime$ = BehaviorSubject.seeded(DateTime.now());
  BehaviorSubject<ResponsibleStaff?> selectedStaff$ = BehaviorSubject.seeded(null);
  BehaviorSubject<FixAssetLocation?> from$ = BehaviorSubject.seeded(null);
  BehaviorSubject<FixAssetLocation?> to$ = BehaviorSubject.seeded(null);
  BehaviorSubject<double> qty$ = BehaviorSubject.seeded(0.0);

  Future<UpdateResponse> addTransfer() async {
    try {
      print("hg");

      var response = await api.execute({
        "Action": "Execute",
        "Object": "SP_ACCOUNTING_FIXASSET_TRANSACTION_INSERT",
        "Parameters": {
          "HOTELID": loginResponse.tenancy?.hotelid,
          "JSONDATA": json.encode({
            "Date": DateFormat("yyyy-MM-dd").format(dateTime$.value),
            "Time": DateFormat("HH:mm").format(dateTime$.value),
            "MasterAssetID": fixedAssetItem$.value?.id,
            "BarcodeID": fixedAssetItem$.value?.renewable == true ? null : fixedAssetItem$.value!.barkodeList?[fixedAssetItem$.value?.barcode]?.id,
            "ResponsibleStaffID": transferType$.value == 12 ? selectedStaff$.value?.id : null,
            "TransferTypeID": transferType$.value,
            "LocationFromID": from$.value?.id,
            "LocationToID": transferType$.value == 12 ? to$.value?.id : null,
            "QTY": qty$.value,
          })
        }
      }).first;
      if(response.dataSets![0][0]["SUCCESS"] == 1){

        fixedAssetItem$.value?.locId = to$.value?.id;

        if (fixedAssetItem$.value?.barcode != null) fixedAssetItem$.value?.barkodeList?[fixedAssetItem$.value?.barcode]?.locationId = to$.value?.id;

        if (fixedAssetItem$.value?.id != null) fixAssets$.value[fixedAssetItem$.value!.id!] = fixedAssetItem$.value!;
        return UpdateResponse(success: true, message:response.dataSets![0][0]["MESSAGE"]);
      }else{
        return UpdateResponse(success: false, message: response.dataSets![0][0]["MESSAGE"]);
      }



    } on Exception catch (e) {
      return UpdateResponse(success: false);
    }
  }

  Future<UpdateResponse> fastTransfer(FixAsset asset, int from, int to) async {
    try {
      var response = await api.execute({
        "Action": "Execute",
        "Object": "SP_ACCOUNTING_FIXASSET_TRANSACTION_INSERT",
        "Parameters": {
          "HOTELID": loginResponse.tenancy?.hotelid,
          "JSONDATA": json.encode({
            "Date": DateFormat("yyyy-MM-dd").format(DateTime.now()),
            "Time": DateFormat("HH:mm").format(DateTime.now()),
            "MasterAssetID": asset.id,
            "BarcodeID": asset.barkodeList?[asset.barcode]?.id,
            "TransferTypeID": 12,
            "LocationFromID": from,
            "LocationToID": to,
            "QTY": 1,
          })
        }
      }).first;
      if(response.dataSets![0][0]["SUCCESS"] == 1){

        fixedAssetItem$.value?.locId = to$.value?.id;

        if (fixedAssetItem$.value?.barcode != null) fixedAssetItem$.value?.barkodeList?[fixedAssetItem$.value?.barcode]?.locationId = to$.value?.id;

        if (fixedAssetItem$.value?.id != null) fixAssets$.value[fixedAssetItem$.value!.id!] = fixedAssetItem$.value!;
        return UpdateResponse(success: true, message:response.dataSets![0][0]["MESSAGE"]);
      }else{
        return UpdateResponse(success: false, message: response.dataSets![0][0]["MESSAGE"]);
      }
    } on Exception catch (e) {
      return UpdateResponse(success: false);
    }
  }
}
