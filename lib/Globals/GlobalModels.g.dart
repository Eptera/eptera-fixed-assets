// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GlobalModels.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BranchAdapter extends TypeAdapter<Branch> {
  @override
  final int typeId = 1;

  @override
  Branch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Branch(
      id: fields[0] == null ? 0 : fields[0] as int?,
      name: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Branch obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FixAssetLocationAdapter extends TypeAdapter<FixAssetLocation> {
  @override
  final int typeId = 2;

  @override
  FixAssetLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FixAssetLocation(
      id: fields[0] == null ? 0 : fields[0] as int?,
      name: fields[1] as String?,
      parentId: fields[2] as String?,
      barcode: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FixAssetLocation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.parentId)
      ..writeByte(3)
      ..write(obj.barcode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixAssetLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FixAssetAdapter extends TypeAdapter<FixAsset> {
  @override
  final int typeId = 0;

  @override
  FixAsset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FixAsset(
      id: fields[0] == null ? 0 : fields[0] as int?,
      name: fields[1] as String?,
      boughtprice: fields[2] as double?,
      barkodeList: (fields[4] as Map?)?.cast<String?, BarcodeItem>(),
      renewable: fields[3] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, FixAsset obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.boughtprice)
      ..writeByte(3)
      ..write(obj.renewable)
      ..writeByte(4)
      ..write(obj.barkodeList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixAssetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BarcodeItemAdapter extends TypeAdapter<BarcodeItem> {
  @override
  final int typeId = 6;

  @override
  BarcodeItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BarcodeItem(
      id: fields[0] == null ? 0 : fields[0] as int?,
      barcode: fields[1] as String?,
      serialNo: fields[2] as String?,
      locationId: fields[3] as int?,
      readingDate: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BarcodeItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.barcode)
      ..writeByte(2)
      ..write(obj.serialNo)
      ..writeByte(3)
      ..write(obj.locationId)
      ..writeByte(4)
      ..write(obj.readingDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarcodeItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FixAssetCountAdapter extends TypeAdapter<FixAssetCount> {
  @override
  final int typeId = 3;

  @override
  FixAssetCount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FixAssetCount(
      id: fields[0] == null ? 0 : fields[0] as int?,
      branchid: fields[1] as int?,
      periodstart: fields[2] as DateTime?,
      periodend: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FixAssetCount obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.branchid)
      ..writeByte(2)
      ..write(obj.periodstart)
      ..writeByte(3)
      ..write(obj.periodend);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixAssetCountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FixAssetCountDetailAdapter extends TypeAdapter<FixAssetCountDetail> {
  @override
  final int typeId = 4;

  @override
  FixAssetCountDetail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FixAssetCountDetail(
      id: fields[0] == null ? 0 : fields[0] as int?,
      masterassetid: fields[1] as int?,
      locationid: fields[2] as int?,
      qty: fields[3] as double?,
      avgUnitprice: fields[4] as double?,
      countingid: fields[5] as int?,
      barcodeID: fields[6] as int?,
      barcode: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FixAssetCountDetail obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.masterassetid)
      ..writeByte(2)
      ..write(obj.locationid)
      ..writeByte(3)
      ..write(obj.qty)
      ..writeByte(4)
      ..write(obj.avgUnitprice)
      ..writeByte(5)
      ..write(obj.countingid)
      ..writeByte(6)
      ..write(obj.barcodeID)
      ..writeByte(7)
      ..write(obj.barcode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixAssetCountDetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OfflineLocationCountingItemAdapter
    extends TypeAdapter<OfflineLocationCountingItem> {
  @override
  final int typeId = 5;

  @override
  OfflineLocationCountingItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineLocationCountingItem(
      id: fields[0] == null ? 0 : fields[0] as int?,
      currentList: (fields[1] as Map).cast<int, bool>(),
      selectedLocation: fields[2] as FixAssetLocation?,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineLocationCountingItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.currentList)
      ..writeByte(2)
      ..write(obj.selectedLocation)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineLocationCountingItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
