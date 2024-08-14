import 'package:flutter/material.dart';
import '../Globals/index.dart';
import 'package:http/http.dart' as http;

class Api {
  String url = "https://api.eptera.com/";

  Future<void> login(
      String? tenant,
      String? usercode,
      String? password, {
        endPoint,
        authcode,
        required BuildContext context,
      }) async {
    try {
      var obj = {
        "Action": "Login",
        "Usercode": usercode,
        "Password": password,
        "Tenant": tenant,
      };
      if (authcode != null) obj["AuthCode"] = authcode;

      final http.Response response = await http.post(
        Uri.parse(endPoint ?? "$url/Login"),
        headers: ({"Content-Type": "application/json; charset=UTF-8"}),
        body: jsonEncode(obj),
      );
      print("");
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body["Success"] == true) {
          if (endPoint != null) url = endPoint;
          print("Login Success");
          loginResponse = LoginResponse.fromJson(json.decode(response.body));
        } else {
          throw Exception(json.decode(response.body).toString());
        }
      } else {
        throw Exception(json.decode(response.body).toString());
      }
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());
    }
  }



  Stream<ExecuteResponse> execute(dynamic requestObject, [BehaviorSubject<bool>? cancelSubject, Function? requestTransformer]) async* {
    do {
      try {
        if (cancelSubject?.value != null && cancelSubject?.value == true) {
          break;
        }
        if (requestTransformer != null) {
          var newRequestObject = requestTransformer(requestObject);
          if (newRequestObject != null) {
            requestObject = newRequestObject;
          }
        }
        print(loginResponse.loginToken);
        requestObject["LoginToken"] = loginResponse.loginToken;

        final http.Response response = await http.post(
          Uri.parse(url),
          headers: ({"Content-Type": "application/json"}),
          body: jsonEncode(requestObject),
        );
        if (response.statusCode == 200) {
          print("Execute Success");
          String body = utf8.decode(response.bodyBytes);
          yield ExecuteResponse.fromJson(json.decode(body));
        } else {
          String body = utf8.decode(response.bodyBytes);
          throw Exception(body);
        }
      } catch (e) {
        print(e.toString());
        throw Exception(e.toString());
      }
    } while (requestObject["WaitMode"] == 4 || requestObject["WaitMode"] == 3);
  }

  Future<UpdateResponse> update(dynamic requestObject) async {
    try {
      requestObject["LoginToken"] = loginResponse.loginToken;

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: ({"Content-Type": "application/json"}),
        body: jsonEncode(requestObject),
      );
      if (response.statusCode == 200) {
        print("Update Success");
        String body = utf8.decode(response.bodyBytes);
        return UpdateResponse.fromJson(json.decode(body));
      } else {
        String body = utf8.decode(response.bodyBytes);
        throw Exception(body);
      }
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<SequenceResponse> seq(dynamic requestObject) async {
    try {
      requestObject["LoginToken"] = loginResponse.loginToken;

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: ({"Content-Type": "application/json"}),
        body: jsonEncode(requestObject),
      );
      if (response.statusCode == 200) {
        print("Seq Success");
        String body = utf8.decode(response.bodyBytes);
        return SequenceResponse.fromJson(json.decode(body));
      } else {
        String body = utf8.decode(response.bodyBytes);
        throw Exception(body);
      }
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());
    }
  }

  Stream<SelectResponse<T>> select<T>(dynamic requestObject, T elementConverter(Map<String, dynamic> element)) async* {
    try {
      requestObject["LoginToken"] = loginResponse.loginToken;

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: ({"Content-Type": "application/json"}),
        body: jsonEncode(requestObject),
      );
      if (response.statusCode == 200) {
        print("success");
        String body = utf8.decode(response.bodyBytes);
        // return SelectResponse<T>.fromJson(json.decode(body), elementConverter);

        yield SelectResponse<T>.fromJson(json.decode(body), elementConverter);
      } else {
        throw Exception(json.decode(response.body));
      }
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<String> forgotPassword({tenant, usercode}) async {
    var body = jsonEncode({
      "Action": "Execute",
      "Object": "SP_EASYPMS_FORGOTPASSWORD",
      "Parameters": {"TENANTID": tenant, "USERCODE": usercode}
    });
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: ({"Content-Type": "application/json", "Referer": "app.eptera.com"}),
      body: body,
    );
    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      return json.decode(body)[0][0]["EMAIL"];
    } else {
      String body = utf8.decode(response.bodyBytes);
      return body;
    }
  }
}
