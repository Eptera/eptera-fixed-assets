class LoginResponse {
  LoginResponse({
    this.success,
    this.loginToken,
    this.code,
    this.usercode,
    this.roleName,
    this.adminLevel,
    this.tenantColumn,
    this.tenantTable,
    this.tenancy,
  });

  bool? success;
  String? loginToken;
  String? code;
  String? usercode;
  String? roleName;
  int? adminLevel;
  String? tenantColumn;
  String? tenantTable;
  Tenancy? tenancy;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        success: json["Success"],
        loginToken: json["LoginToken"],
        code: json["Code"],
        usercode: json["Usercode"],
        roleName: json["RoleName"],
        adminLevel: json["AdminLevel"],
        tenantColumn: json["TenantColumn"],
        tenantTable: json["TenantTable"],
        tenancy: Tenancy.fromJson(json["Tenancy"]),
      );

  Map<String, dynamic> toJson() {
    return {
      'Success': success,
      'LoginToken': loginToken,
      'Code': code,
      'Usercode': usercode,
      'RoleName': roleName,
      'AdminLevel': adminLevel,
      'TenantColumn': tenantColumn,
      'TenantTable': tenantTable,
      'Tenancy': tenancy?.toJson(),
    };
  }
}

class Tenancy {
  Tenancy({
    this.hotelid,
    this.elektraFixedassetsLicanceExpire,
  });

  int? hotelid;
  DateTime? elektraFixedassetsLicanceExpire;

  factory Tenancy.fromJson(Map<String, dynamic> json) => Tenancy(
        hotelid: json["HOTELID"],
        elektraFixedassetsLicanceExpire: json["ELEKTRA_FIXEDASSETS_LICANCE_EXPIRE"] == null ? null : DateTime.parse(json["ELEKTRA_FIXEDASSETS_LICANCE_EXPIRE"]),
      );

  Map<String, dynamic> toJson() {
    return {
      'HOTELID': hotelid,
      'ELEKTRA_FIXEDASSETS_LICANCE_EXPIRE': elektraFixedassetsLicanceExpire?.toIso8601String(),
    };
  }
}

class ExecuteResponse {
  ExecuteResponse({this.dataSets});

  List<dynamic>? dataSets;

  factory ExecuteResponse.fromJson(List<dynamic> responseDataSets) {
    return ExecuteResponse(
      dataSets: responseDataSets,
    );
  }
}

class SelectResponse<T> {
  SelectResponse({
    this.totalCount,
    this.data,
    this.sql,
  });

  int? totalCount;
  List<T>? data;
  String? sql;

  factory SelectResponse.fromJson(Map<String, dynamic> list, T elementConverter(Map<String, dynamic> element)) {
    List<Map<String, dynamic>> rawList = List.from(list["ResultSets"][0]);
    List<T> convertedList = [];
    rawList.forEach((e) {
      convertedList.add(elementConverter(e));
    });
    return SelectResponse(
      totalCount: list["TotalCount"],
      data: convertedList,
      sql: list["SQL"],
    );
  }
}

class UpdateResponse {
  UpdateResponse({
    this.success,
    this.primaryKey,
    this.message,
    this.rowsAffected,
  });

  bool? success;
  int? primaryKey;
  int? rowId;
  String? message;
  int? rowsAffected;

  factory UpdateResponse.fromJson(Map<String, dynamic> json) => UpdateResponse(
        success: json["Success"],
        primaryKey: json["PrimaryKey"],
        message: json["Message"],
        rowsAffected: json["RowsAffected"],
      );
}

class SequenceResponse {
  SequenceResponse({
    this.warning,
    this.stepIndex,
    this.stepStarted,
    this.spResult,
    this.success,
    this.message,
  });

  String? warning;
  int? success;
  String? message;
  int? stepIndex;
  DateTime? stepStarted;
  SpResult? spResult;

  factory SequenceResponse.fromJson(Map<String, dynamic> json) => SequenceResponse(
        warning: json["Warning"],
        success: json["SUCCESS"],
        message: json["MESSAGE"],
        stepIndex: json["StepIndex"],
        stepStarted: json["StepStarted"] == null ? null : DateTime.parse(json["StepStarted"]),
        spResult: json["SPResult"] == null ? null : SpResult.fromJson(json["SPResult"]),
      );
}

class SpResult {
  SpResult({
    this.body,
    this.headers,
    this.pHeaders,
  });

  String? body;
  String? headers;
  String? pHeaders;

  factory SpResult.fromJson(Map<String, dynamic> json) => SpResult(
        body: json["BODY"],
        headers: json["HEADERS"],
        pHeaders: json["P_HEADERS"],
      );
}

class ScreenArguments<T> {
  final T item;

  ScreenArguments(this.item);
}

class DeliveryInfo {
  DeliveryInfo({
    this.id,
    this.hotelid,
    this.linetypeid,
    this.addressid,
    this.plateno,
    this.personname,
    this.personsurname,
    this.personidentity,
    this.invoiceid,
    this.linetypeidName,
    this.addressidAddressinfo,
  });

  int? id;
  int? hotelid;
  int? linetypeid;
  int? addressid;
  String? plateno;
  String? personname;
  String? personsurname;
  String? personidentity;
  int? invoiceid;
  String? linetypeidName;
  String? addressidAddressinfo;

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) => DeliveryInfo(
        id: json["ID"],
        hotelid: json["HOTELID"],
        linetypeid: json["LINETYPEID"],
        addressid: json["ADDRESSID"],
        plateno: json["PLATENO"],
        personname: json["PERSONNAME"],
        personsurname: json["PERSONSURNAME"],
        personidentity: json["PERSONIDENTITY"],
        invoiceid: json["INVOICEID"],
        linetypeidName: json["LINETYPEID_NAME"],
        addressidAddressinfo: json["ADDRESSID_ADDRESSINFO"],
      );
}
