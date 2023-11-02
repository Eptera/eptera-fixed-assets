import 'package:fixed_assets_v3/Globals/index.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/io_client.dart';
part 'GlobalModels.g.dart';

class ResponsibleStaff {
  ResponsibleStaff({
    this.id,
    this.name,
  });

  int? id;
  String? name;

  factory ResponsibleStaff.fromJson(Map<String, dynamic> json) => ResponsibleStaff(
        id: json["ID"],
        name: json["FULLNAME"],
      );
}

class Account {
  Account({
    this.id,
    this.name,
    this.address,
  });

  int? id;
  String? name;
  List<Address>? address;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json["ID"],
        name: json["NAME"],
        address: json["ADDRESS"] == null ? null : List<Address>.from(json["ADDRESS"].map((x) => Address.fromJson(x))),
      );
}

class Address {
  Address({
    this.id,
    this.name,
  });

  int? id;
  String? name;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json["ID"],
        name: json["NAME"],
      );
}

@HiveType(typeId: 1)
class Branch extends HiveObject {
  Branch({
    this.id,
    this.name,
  });

  @HiveField(0, defaultValue: 0)
  int? id;
  @HiveField(1)
  String? name;

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json["id"],
        name: json["name"],
      );
}

class FixAssetGroup {
  FixAssetGroup({
    this.id,
    this.name,
  });

  int? id;
  String? name;

  factory FixAssetGroup.fromJson(Map<String, dynamic> json) => FixAssetGroup(
        id: json["id"],
        name: json["name"],
      );
}

@HiveType(typeId: 2)
class FixAssetLocation extends HiveObject {
  FixAssetLocation({
    this.id,
    this.name,
    this.parentId,
    this.barcode,
  });
  @HiveField(0, defaultValue: 0)
  int? id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? parentId;
  @HiveField(3)
  String? barcode;

  factory FixAssetLocation.fromJson(Map<String, dynamic> json) => FixAssetLocation(
        id: json["id"],
        name: json["name"],
        parentId: json["PARENTID"],
        barcode: json["BARCODE"],
      );
}

@HiveType(typeId: 0)
class FixAsset extends HiveObject {
  FixAsset({
    this.id,
    this.name,
    this.boughtprice,
    this.barkodeList,
    this.renewable,
  });

  @HiveField(0, defaultValue: 0)
  int? id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  double? boughtprice;
  @HiveField(3)
  bool? renewable;
  @HiveField(4)
  Map<String?, BarcodeItem>? barkodeList;

  String? barcode;
  int? barcodeID;
  int? locId;
  DateTime? readingDate;
  bool? isScannedInApp;

  factory FixAsset.fromJson(Map<String, dynamic> jsonData) {
    Map<String?, BarcodeItem> barcodes = {};
    if (jsonData["BarkodeList"] != null) {
      json.decode(jsonData["BarkodeList"]).forEach((x) {
        barcodes[x["BARCODE"]] = BarcodeItem.fromJson(x);
      });
    }

    return FixAsset(
      id: jsonData["ID"],
      name: jsonData["NAME"],
      boughtprice: jsonData["BOUGHTPRICE"] == null ? null : jsonData["BOUGHTPRICE"].toDouble(),
      barkodeList: barcodes,
      renewable: jsonData["ISCOUNTABLE"] == 1 ? true : false,
    );
  }

  FixAsset clone() => FixAsset(id: id, name: name, boughtprice: boughtprice, barkodeList: barkodeList, renewable: renewable);
}

@HiveType(typeId: 6)
class BarcodeItem extends HiveObject {
  BarcodeItem({
    this.id,
    this.barcode,
    this.serialNo,
    this.locationId,
    this.readingDate,
  });
  @HiveField(0, defaultValue: 0)
  int? id;
  @HiveField(1)
  String? barcode;
  @HiveField(2)
  String? serialNo;
  @HiveField(3)
  int? locationId;
  @HiveField(4)
  DateTime? readingDate;

  factory BarcodeItem.fromJson(Map<String, dynamic> json) => BarcodeItem(
      id: json["ID"],
      barcode: json["BARCODE"] == null || json["BARCODE"] == "" ? null : json["BARCODE"],
      locationId: json["LOCATIONID"],
      serialNo: json["SERIALNO"],
      readingDate: json["READING_DATE"] == null ? null : DateTime.parse(json["READING_DATE"]));
}

@HiveType(typeId: 3)
class FixAssetCount extends HiveObject {
  FixAssetCount({
    this.id,
    this.branchid,
    this.periodstart,
    this.periodend,
  });

  @HiveField(0, defaultValue: 0)
  int? id;
  @HiveField(1)
  int? branchid;
  @HiveField(2)
  DateTime? periodstart;
  @HiveField(3)
  DateTime? periodend;

  factory FixAssetCount.fromJson(Map<String, dynamic> json) => FixAssetCount(
        id: json["ID"],
        branchid: json["BRANCHID"],
        periodstart: json["PERIODSTART"] == null ? null : DateTime.parse(json["PERIODSTART"]),
        periodend: json["PERIODEND"] == null ? null : DateTime.parse(json["PERIODEND"]),
      );
}

@HiveType(typeId: 4)
class FixAssetCountDetail extends HiveObject {
  FixAssetCountDetail({this.id, this.masterassetid, this.locationid, this.qty, this.avgUnitprice, this.countingid, this.barcodeID, this.barcode});
  @HiveField(0, defaultValue: 0)
  int? id;
  @HiveField(1)
  int? masterassetid;
  @HiveField(2)
  int? locationid;
  @HiveField(3)
  double? qty;
  @HiveField(4)
  double? avgUnitprice;
  @HiveField(5)
  int? countingid;

  @HiveField(6)
  int? barcodeID;
  @HiveField(7)
  String? barcode;

  factory FixAssetCountDetail.fromJson(Map<String, dynamic> json) => FixAssetCountDetail(
        id: json["ID"],
        masterassetid: json["MASTERASSETID"],
        locationid: json["LOCATIONID"],
        qty: json["QTY"] == null ? null : json["QTY"].toDouble(),
        avgUnitprice: json["AVG_UNITPRICE"] == null ? null : json["AVG_UNITPRICE"].toDouble(),
        countingid: json["COUNTINGID"],
      );
}

@HiveType(typeId: 5)
class OfflineLocationCountingItem extends HiveObject {
  @HiveField(0, defaultValue: 0)
  int? id;
  @HiveField(1)
  Map<int, bool> currentList;
  @HiveField(2)
  FixAssetLocation? selectedLocation;
  @HiveField(3)
  String? note;

  OfflineLocationCountingItem({this.id, required this.currentList, this.selectedLocation, this.note});
}
