import 'package:json_annotation/json_annotation.dart';

part 'base_request.g.dart';

@JsonSerializable(explicitToJson: true)
class BaseRequest {
  int? page;
  int? perPage;
  int? size;

  BaseRequest({this.page = 1, this.perPage = 12, this.size = 12});

  factory BaseRequest.fromJson(Map<String, dynamic> json) =>
      _$BaseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BaseRequestToJson(this);
}
