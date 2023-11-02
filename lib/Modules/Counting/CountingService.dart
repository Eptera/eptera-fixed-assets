import 'package:flutter/material.dart';

import '../../Globals/index.dart';

class CountingService {
  BehaviorSubject<FixAssetCount?> selectedCounting$ = BehaviorSubject.seeded(null);
  BehaviorSubject<FixAssetLocation?> selectedLocation$ = BehaviorSubject.seeded(null);
  BehaviorSubject<Map<int, FixAssetCountDetail>> newScanned$ = BehaviorSubject.seeded({});

  Future<double?> showFixedAssetCountDialog(FixAsset value, BehaviorSubject quantityStreamValue$) async {
    return await showDialog(
      barrierDismissible: false,
      context: currentContext,
      builder: (context) {
        var qty = TextEditingController(text: '');
        return StreamBuilder(
            stream: quantityStreamValue$.stream,
            builder: (context, snapshot) {
              return AlertDialog(
                title: Text(value.name ?? ''),
                content: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Row(children: [
                      Expanded(flex: 3, child: Text("Location").tr()),
                      Expanded(flex: 1, child: Text(":")),
                      Expanded(flex: 5, child: Text(selectedLocation$.value?.name ?? '', style: TextStyle(fontSize: 16))),
                    ]),
                    Row(children: [
                      Expanded(flex: 3, child: Text("Quantity").tr()),
                      Expanded(flex: 1, child: Text(":")),
                      Expanded(
                        flex: 5,
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: qty,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(0),
                          ),
                          onChanged: (value) {
                            quantityStreamValue$.value = value;
                          },
                        ),
                      ),
                    ]),
                  ],
                ),
                actions: [
                  IconButton(
                    iconSize: MediaQuery.of(context).size.width / 10,
                    icon: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.greenAccent,
                    ),
                    onPressed: () {
                      Navigator.pop(context, quantityStreamValue$.value == null || quantityStreamValue$.value == "" ? 1.0 : double.parse(quantityStreamValue$.value));
                    },
                  ),
                ],
              );
            });
      },
    );
  }
}
