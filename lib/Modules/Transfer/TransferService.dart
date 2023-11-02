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
            "Date": Moment.fromDate(dateTime$.value).format("yyyy-MM-dd"),
            "Time": Moment.fromDate(dateTime$.value).format("HH:mm"),
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

      await showWarningDialog("Success".tr(), "Transaction Inserted Successfully.".tr());

      fixedAssetItem$.value?.locId = to$.value?.id;

      if (fixedAssetItem$.value?.barcode != null) fixedAssetItem$.value?.barkodeList?[fixedAssetItem$.value?.barcode]?.locationId = to$.value?.id;

      if (fixedAssetItem$.value?.id != null) fixAssets$.value[fixedAssetItem$.value!.id!] = fixedAssetItem$.value!;

      return UpdateResponse(success: true);
    } on Exception catch (e) {
      await showErrorDialog(e.toString());
      return UpdateResponse(success: false);
    }
  }

  Future fastTransfer(FixAsset asset, int from, int to) async {
    try {
      var response = await api.execute({
        "Action": "Execute",
        "Object": "SP_ACCOUNTING_FIXASSET_TRANSACTION_INSERT",
        "Parameters": {
          "HOTELID": loginResponse.tenancy?.hotelid,
          "JSONDATA": json.encode({
            "Date": Moment.now().format("yyyy-MM-dd"),
            "Time": Moment.now().format("HH:mm"),
            "MasterAssetID": asset.id,
            "BarcodeID": asset.barkodeList?[asset.barcode]?.id,
            "TransferTypeID": 12,
            "LocationFromID": from,
            "LocationToID": to,
            "QTY": 1,
          })
        }
      }).first;

      await showWarningDialog("Success".tr(), "Transaction Inserted Successfully.".tr());
    } on Exception catch (e) {
      await showErrorDialog(e.toString());
    }
  }
}
