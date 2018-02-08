import 'package:http/http.dart' as http;
import 'dart:core';
import 'query.dart';
import 'dart:convert';
import 'dart:async';

class GQLResponse {
  Map<String, dynamic> data;
  List<Map<String, dynamic>> errors;

  GQLResponse({this.data, this.errors});

  get existErrors => this.errors.length>0;

}


class GQLClient {
  String uri;
  String jwtToken;
  http.Client client;

  // final _filterQuery = new RegExp(r"^(query)\ (\w+)\((.+)\)");
  // final _varsFilter = new RegExp(r"\$(\w+:\ *(\w+)!*)");

  GQLClient(String uri, {String jwtAuthToken}) {
    this.client = new http.Client();
    
    this.uri = uri;
    if (jwtAuthToken != null) {
      this.jwtToken = jwtAuthToken;
    }
  }

  set setJwtToken(token) => this.jwtToken = token;

  Future<GQLResponse> run(GQLQuery query, {bool auth}) async {
    var _headers = {
      "Content-Type": "application/json",
      "Authorization": auth!=null && auth?"Bearer " + this.jwtToken:"",
    };


    // var match = _filterQuery.firstMatch(query.queryString);
    // String queryDeclaration = match.toString();
    
    // assert(queryDeclaration != "", "Query not found");

    // var varsDeclarations = _varsFilter.allMatches(queryDeclaration);
    // for (var v in varsDeclarations) {

    // }

    var jsonQ = new Map<String, dynamic>();

    jsonQ.addAll({"query": query.queryString});
    jsonQ.addAll({"variables": query.vars});

    var _finalBody = JSON.encode(jsonQ);

    var response = await this.client.post(this.uri,
      headers: _headers,
      body: _finalBody
    );

    var bodyRaw = JSON.decode(response.body);
    return new GQLResponse(data: bodyRaw["data"], errors: bodyRaw["errors"]);

  }


}