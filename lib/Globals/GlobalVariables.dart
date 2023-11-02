import 'dart:math';
import 'package:fixed_assets_v3/Services/Database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:soundpool/soundpool.dart';
import 'index.dart';
import 'package:package_info_plus/package_info_plus.dart';

late PackageInfo packageInfo;
late BuildContext currentContext;
late LoginResponse loginResponse;

//Hive
late Box<Map?> fixAssetsFromHive;
late Box<Map?> branchesFromHive;
late Box<Map?> fixAssetsLocationsFromHive;
late Box<Map?> fixAssetsCountFromHive;
late Box<List?> fixAssetCountDetailsFromHive;
late Box<List?> offlineLocationCountingItemsFromHive;

late Box<Object?> fixAssetOfflineCountItemFromHive;

Scanner scanner = GetIt.I<Scanner>();
Database db = GetIt.I<Database>();

Api api = GetIt.I<Api>();
Random random = Random();
Soundpool pool = Soundpool.fromOptions();

BehaviorSubject<FixAssetCount?> fixAssetOfflineCountItem$ = BehaviorSubject.seeded(null);

BehaviorSubject<String> lastBarcode$ = BehaviorSubject.seeded("");
BehaviorSubject<bool> scannerBusy = BehaviorSubject.seeded(false);

BehaviorSubject<bool> isOffline$ = BehaviorSubject.seeded(false);
BehaviorSubject<bool?> cameraModeIsActive$ = BehaviorSubject.seeded(false);

BehaviorSubject<Map<int, FixAsset>> fixAssets$ = BehaviorSubject.seeded({});
BehaviorSubject<Map<int, FixAsset>> fixAssets_byBarcodeID$ = BehaviorSubject.seeded({});
BehaviorSubject<Map<String, FixAsset>> fixAssets_byBarcode$ = BehaviorSubject.seeded({});
BehaviorSubject<Map<int, List<FixAsset>>> fixAssets_byLocation$ = BehaviorSubject.seeded({});

BehaviorSubject<Map<int, Branch>> branches$ = BehaviorSubject.seeded({});
BehaviorSubject<Map<int, FixAssetLocation>> fixAssetsLocations$ = BehaviorSubject.seeded({});
BehaviorSubject<Map<int, FixAssetCount>> fixAssetsCount$ = BehaviorSubject.seeded({});

//??????
BehaviorSubject<Map<int, FixAssetGroup>> fixAssetsGroup$ = BehaviorSubject.seeded({});
BehaviorSubject<Map<int, Account>> accounts$ = BehaviorSubject.seeded({});
BehaviorSubject<Map<int, FixAssetCountDetail>> fixAssetsCountDetails$ = BehaviorSubject.seeded({});

//Transfer
BehaviorSubject<Map<int, ResponsibleStaff>> fixAssetsResponsibleStaff$ = BehaviorSubject.seeded({});

//Shxpr_Bluetooth_Printer_Convert_Turkish_to_English
List<String> turkishChars = ['ı', 'ğ', 'İ', 'Ğ', 'ç', 'Ç', 'ş', 'Ş', 'ö', 'Ö', 'ü', 'Ü'];
List<String> englishChars = ['i', 'g', 'I', 'G', 'c', 'C', 's', 'S', 'o', 'O', 'u', 'U'];

var colors = [
  Color(0xffda627d),
  Color(0xff4c3549),
  Color(0xffedddd4),
  Color(0xff70877f),
  Color(0xff80ffe8),
  Color(0xff7c90db),
  Color(0xffa44200),
  Color(0xff1b9aaa),
  Color(0xff6e7897),
  Color(0xff7f9172)
];
