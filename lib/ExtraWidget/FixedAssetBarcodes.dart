import 'package:eptera_fixed_asset/Globals/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Globals/GlobalModels.dart';
import '../Globals/GlobalVariables.dart';


class FixedAssetBarcodes extends StatefulWidget {
   FixedAssetBarcodes(this.newList,{super.key});
  List<BarcodeItem> newList;
  @override
  State<FixedAssetBarcodes> createState() => _FixedAssetBarcodesState();
}

class _FixedAssetBarcodesState extends State<FixedAssetBarcodes> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kWhite,
    ));
  }
  @override
  Widget build(BuildContext context) {
    currentContext = context;
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    EdgeInsets padding = MediaQuery.of(context).padding;

    return  Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16,top: padding.top > 0 ? padding.top : 24,right: 24,bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(fixAssets_byBarcode$.value[widget.newList.first.barcode]?.name ?? "-"),
                InkWell(
                  onTap: (){
                    Navigator.pop(context,null);
                  },
                  child: SvgPicture.asset("assets/images/close.svg"),
                )
              ],
            ),
          ),
          Divider(color: kBorderColor2,),
          SizedBox(
            height: h * 0.8,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.newList.length,
              padding: EdgeInsets.only(bottom: h * 0.2),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 12),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.newList[index].serialNo ?? " - ",style: k16w500Black(color: kGrey700),),
SvgPicture.asset("assets/images/arrow_right.svg"),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Location:".tr(),style: k14w400Black(color: kGrey700),),
                          const SizedBox(width: 6,),
                          Text(fixAssetsLocations$.value[widget.newList[index].locationId]?.name != null ? fixAssetsLocations$.value[widget.newList[index].locationId]!.name! : "-",style: k14w500Black(color: kGrey700),),
                        ],
                      ),
                      SizedBox(height: 2,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Barcode:".tr(),style: k14w400Black(color: kGrey700),),
                          const SizedBox(width: 6,),
                          Text(widget.newList[index].barcode ?? "-",style: k14w500Black(color: kGrey700),),
                        ],
                      ),
                    ],
                  ),
                  onTap: () async => Navigator.pop(context, widget.newList[index]),
                ),
              ),
              separatorBuilder: (context, index) => Divider(color: kBorderColor2,),
            ),
          )
        ],
      ),
    );
  }
}
