import 'dart:io';
import 'package:flutter/material.dart';
import 'index.dart';

Future<bool?> showConfirmDialog(BuildContext context, String title, String content) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: Text("Ok".tr()),
            onPressed: () => Navigator.pop(context, true),
          ),
          TextButton(
            child: Text("Cancel".tr()),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      );
    },
  );
}

Future<bool?> showDeleteConfirmDialog() async {
  return await showDialog<bool>(
    context: currentContext,
    builder: (context) {
      return AlertDialog(
        title: Text("Warning".tr()),
        content: Text("Are you sure you want to Delete this Item?".tr()),
        actions: [
          TextButton(
            child: Text("Ok".tr()),
            onPressed: () => Navigator.pop(context, true),
          ),
          TextButton(
            child: Text("Cancel".tr()),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      );
    },
  );
}

Future<bool> checkConnection() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
    return false;
  } on SocketException catch (_) {
    return false;
  }
}

Future showWarningDialog(String title, String content) async {
  await showDialog(
      context: currentContext,
      builder: (context) {
        return Container(
          child: AlertDialog(
            title: Text(title),
            contentPadding: const EdgeInsets.all(16.0),
            content: SingleChildScrollView(child: Text(content)),
            actions: <Widget>[
              TextButton(
                  child: Text("OK").tr(),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        );
      });
}

Future showErrorDialog(String? error) async {
  await showDialog(
      context: currentContext,
      builder: (context) {
        return Container(
          child: AlertDialog(
            title: Text("Error".tr()),
            contentPadding: const EdgeInsets.all(16.0),
            content: Text(error ?? ""),
            actions: <Widget>[
              TextButton(
                  child: Text("OK").tr(),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        );
      });
}

Future<String?> showGetBarcodeDialog() {
  return showDialog(
    context: currentContext,
    builder: (context) {
      TextEditingController barcode = TextEditingController();
      return AlertDialog(
        title: Text("Enter Barcode").tr(),
        content: TextField(
          controller: barcode,
          autofocus: true,
          keyboardType: TextInputType.multiline,
        ),
        actions: [
          TextButton(
            child: Text("No".tr(), style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, ""),
          ),
          TextButton(
            child: Text("Yes".tr(), style: TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.pop(context, barcode.text),
          ),
        ],
      );
    },
  );
}

Future<bool> makeFastTransfer(String barcode, FixAssetLocation? fromLocation, FixAssetLocation? toLocation, FixAsset? fixedAsset) async {
  return await showDialog(
    context: currentContext,
    builder: (context) {
      return AlertDialog(
        title: Text("Fast Transfer".tr()),
        content: Wrap(
          children: [
            Row(children: [Expanded(flex: 3, child: Text("DateTime".tr() + " : ")), Expanded(flex: 5, child: Text("${Moment.now().format("dd/MM/yyyy HH:mm")}"))]),
            Divider(height: 5, indent: 5, endIndent: 5),
            Row(children: [Expanded(flex: 3, child: Text("Name".tr() + " : ")), Expanded(flex: 5, child: Text("${fixedAsset?.name}"))]),
            Divider(height: 5, indent: 5, endIndent: 5),
            Row(children: [Expanded(flex: 3, child: Text("From Loaction".tr() + " : ")), Expanded(flex: 5, child: Text("${fromLocation?.name ?? "-"}"))]),
            Divider(height: 5, indent: 5, endIndent: 5),
            Row(children: [Expanded(flex: 3, child: Text("To Loaction".tr() + " : ")), Expanded(flex: 5, child: Text("${toLocation?.name ?? "-"}"))]),
            Divider(height: 5, indent: 5, endIndent: 5),
            Row(children: [Expanded(flex: 3, child: Text("Quantity".tr() + " : ")), Expanded(flex: 5, child: Text("1"))]),
          ],
        ),
        actions: [
          TextButton(child: Text("Cancel".tr(), style: TextStyle(color: Colors.redAccent)), onPressed: () => Navigator.pop(context, false)),
          TextButton(child: Text("Approve Transfer".tr(), style: TextStyle(color: Colors.greenAccent)), onPressed: () => Navigator.pop(context, true)),
        ],
      );
    },
  );
}

List<FixAssetLocation> searchFixedAssetsLoaction(String pattern) {
  // ignore: missing_return
  var value = fixAssetsLocations$.value.values.toList().where((item) {
    if (item.name != null) {
      return item.name!.toLowerCase().contains(pattern.toLowerCase());
    } else {
      return false;
    }
  });
  return value.isEmpty ? [] : value.toList();
}

Future<FixAssetLocation?> showSearchWidget_FixedAssetsLocationName() async {
  return await showDialog<FixAssetLocation>(
    barrierDismissible: false,
    context: currentContext,
    builder: (context) {
      var search = TextEditingController(text: "");
      BehaviorSubject<List<FixAssetLocation>> newList = BehaviorSubject.seeded(fixAssetsLocations$.value.values.toList());

      return AlertDialog(
        title: TextField(
          controller: search,
          decoration: InputDecoration(labelText: "Locations".tr()),
          onChanged: (value) => newList.add(searchFixedAssetsLoaction(value)),
        ),
        content: StreamBuilder<List<FixAssetLocation>>(
          stream: newList,
          builder: (context, snapshot) => Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ListView.separated(
              itemCount: newList.value.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(newList.value[index].name ?? ''),
                onTap: () async => Navigator.pop(context, newList.value[index]),
              ),
              separatorBuilder: (context, index) => Divider(),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Close".tr(),
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  ).then((value) => value);
}

List<FixAsset> searchFixedAsset(String pattern) {
  var value = fixAssets$.value.values.toList().where((item) =>
      (item.name ?? " ").toLowerCase().contains(pattern.toLowerCase()) ||
      (item.barkodeList != null && item.barkodeList!.isNotEmpty
          ? item.barkodeList!.keys.any((element) => element != null ? element.toLowerCase().contains(pattern.toLowerCase()) : false)
          : false));
  return value.isEmpty ? [] : value.toList();
}

//(item.barcode ?? " ").toLowerCase().contains(pattern.toLowerCase())
Future<FixAsset?> showSearchWidget_FixedAssetName() async {
  return await showDialog<FixAsset>(
    barrierDismissible: false,
    context: currentContext,
    builder: (context) {
      var search = TextEditingController(text: "");
      BehaviorSubject<List<FixAsset>> newList = BehaviorSubject.seeded(fixAssets$.value.values.toList());

      return AlertDialog(
        title: TextField(
          controller: search,
          decoration: InputDecoration(labelText: "Fixed Assets".tr()),
          onChanged: (value) => newList.add(searchFixedAsset(value)),
        ),
        content: StreamBuilder<List<FixAsset>>(
          stream: newList,
          builder: (context, snapshot) => Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ListView.separated(
              itemCount: newList.value.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(newList.value[index].name ?? "-"),
                  onTap: () async => Navigator.pop(context, newList.value[index]),
                );
              },
              separatorBuilder: (context, index) => Divider(),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Close".tr(),
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  ).then((value) => value);
}

Future<BarcodeItem?> showSearchWidget_FixedAssetBarcodes(List<BarcodeItem> newList) async {
  return await showDialog<BarcodeItem>(
    barrierDismissible: false,
    context: currentContext,
    builder: (context) {
      return AlertDialog(
        title: Text(fixAssets_byBarcode$.value[newList.first.barcode]?.name ?? "-"),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: ListView.separated(
            itemCount: newList.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(newList[index].serialNo ?? " - "),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Location".tr() +
                      " : " +
                      (fixAssetsLocations$.value[newList[index].locationId]?.name != null ? fixAssetsLocations$.value[newList[index].locationId]!.name! : "-")),
                  Text("Barcode" + " : " + (newList[index].barcode ?? " - ")),
                ],
              ),
              onTap: () async => Navigator.pop(context, newList[index]),
            ),
            separatorBuilder: (context, index) => Divider(),
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Close".tr(),
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  ).then((value) => value);
}

List<ResponsibleStaff> searchResponsibleStaff(String pattern) {
  var value = fixAssetsResponsibleStaff$.value.values.toList().where((item) => (item.name ?? "").toLowerCase().contains(pattern.toLowerCase()));
  return value.isEmpty ? [] : value.toList();
}

Future<ResponsibleStaff?> showSearchWidget_ResponsibleStaffName() async {
  return await showDialog<ResponsibleStaff>(
    barrierDismissible: false,
    context: currentContext,
    builder: (context) {
      var search = TextEditingController(text: "");
      BehaviorSubject<List<ResponsibleStaff>> newList = BehaviorSubject.seeded(fixAssetsResponsibleStaff$.value.values.toList());

      return AlertDialog(
        title: TextField(
          controller: search,
          decoration: InputDecoration(labelText: "Responsible Staff".tr()),
          onChanged: (value) => newList.add(searchResponsibleStaff(value)),
        ),
        content: StreamBuilder<List<ResponsibleStaff>>(
          stream: newList,
          builder: (context, snapshot) => Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ListView.separated(
              itemCount: newList.value.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(newList.value[index].name ?? "-"),
                onTap: () async => Navigator.pop(context, newList.value[index]),
              ),
              separatorBuilder: (context, index) => Divider(),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Close".tr(),
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  ).then((value) => value);
}

Future<FixAssetCount?> showWidget_CountingMasterbyName(BuildContext context, String title, List<FixAssetCount> list) async {
  return await showDialog<FixAssetCount>(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: ListView.separated(
            itemCount: list.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(branches$.value[list[index].branchid]?.name == null ? '' : branches$.value[list[index].branchid]!.name!),
                subtitle: Row(
                  children: [
                    if (list[index].periodstart != null) Expanded(child: Center(child: Text(Moment.fromDate(list[index].periodstart!).format("yyyy/MM/dd")))),
                    if (list[index].periodstart != null) const Icon(Icons.arrow_forward_rounded),
                    if (list[index].periodend != null) Expanded(child: Center(child: Text(Moment.fromDate(list[index].periodend!).format("yyyy/MM/dd")))),
                  ],
                ),
                onTap: () async {
                  Navigator.pop(context, list[index]);
                },
              );
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Close".tr(),
              style: const TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  ).then((value) {
    print(value);
    return value;
  });
}
