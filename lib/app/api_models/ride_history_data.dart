import 'package:customer/app/models/booking_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ride_history_data.g.dart';

@JsonSerializable()
class RideHistoryData {
  final bool? status;
  final String? msg;
  final List<BookingModel>? data;

  const RideHistoryData({
    this.status,
    this.msg,
    this.data,
  });

  factory RideHistoryData.fromJson(Map<String, dynamic> json) =>
      _$RideHistoryDataFromJson(json);

  Map<String, dynamic> toJson() => _$RideHistoryDataToJson(this);
}
