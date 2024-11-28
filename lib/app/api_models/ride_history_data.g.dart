// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_history_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RideHistoryData _$RideHistoryDataFromJson(Map<String, dynamic> json) =>
    RideHistoryData(
      status: json['status'] as bool?,
      msg: json['msg'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RideHistoryDataToJson(RideHistoryData instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };
