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
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AlertDialog(
                    title: Text("Add By Fixed Asset Name".tr(),style: k18w600Black(color: kGrey900),),
                    titlePadding: EdgeInsets.only(left: 16, top: 20, right: 16),
                    contentPadding: EdgeInsets.only(left: 16, top: 20, bottom: 24, right: 16),
                    actionsPadding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    insetPadding: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 32),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(value.name ?? '-',style: k18w600Black(color: kGrey900),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,),
                        Row(
                            children: [
                          Text("${"Location".tr()}:",style: k14w400Black(color: kGrey600),),
                          const SizedBox(width: 6,),
                          Text(selectedLocation$.value?.name ?? '-', style: k14w500Black(color: kGrey600),),
                        ]),
                        const SizedBox(height: 16,),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text("Quantity".tr(),style: k14w400Black(color: kGrey600),),
                          const SizedBox(height: 6,),
                          CTextFormField(
                            hasIcon: false,
                            controller: qty,
                            autoFocus: true,
                            textInputType: TextInputType.number,
                            textInputAction: TextInputAction.done, onChange: (value) {
                            quantityStreamValue$.value = value;
                          },),
                        ]),
                      ],
                    ),
                    actions: [
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () =>   Navigator.pop(context, quantityStreamValue$.value == null || quantityStreamValue$.value == "" ? 1.0 : double.parse(quantityStreamValue$.value)),
                            child: Text("Add".tr(),
                              style: k16w600Black(color: kWhite),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, null),
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
                      )
                    ],
                  ),
                ],
              );
            });
      },
    );
  }
}
