import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:leet_tutur/models/requests/book_request.dart';
import 'package:leet_tutur/models/requests/booking_list_request.dart';
import 'package:leet_tutur/models/responses/book_response.dart';
import 'package:leet_tutur/models/responses/booking_list_response.dart';
import 'package:leet_tutur/models/responses/schedule_response.dart';
import 'package:logger/logger.dart';

class ScheduleService {
  final _dio = GetIt.instance.get<Dio>();
  final _logger = GetIt.instance.get<Logger>();
  FirebaseAnalytics? _firebaseAnalytics;

  ScheduleService() {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      _firebaseAnalytics = GetIt.instance.get<FirebaseAnalytics>();
    }
  }

  Future<ScheduleResponse> getScheduleByTutorIdAsync({String id = ""}) async {
    var res = await _dio.post("/schedule", data: {
      "tutorId": id,
    });

    // This operation is very heavy
    var scheduleResponse = await compute((Response dioResponse) {
      var scheduleResponse = ScheduleResponse.fromJson(dioResponse.data);

      var schedules = scheduleResponse.data
          ?.where((element) =>
              element.startTimestamp! >= DateTime.now().millisecondsSinceEpoch)
          .toList();

      schedules?.sort(
          (a, b) => a.startTimestamp?.compareTo(b.startTimestamp ?? 0) ?? 0);

      scheduleResponse.data = schedules;

      return scheduleResponse;
    }, res);

    _logger.i("Get schedule, found: ${scheduleResponse.data?.length} items");

    return scheduleResponse;
  }

  Future<BookingListResponse> getBookingsListAsync(
      {BookingListRequest? request}) async {
    var dioRes = await _dio.get("/booking/list/student", queryParameters: {
      "page": request?.page ?? 1,
      "perPage": request?.perPage ?? 12,
      "dateTimeGte":
          request?.dateTimeGte ?? DateTime.now().millisecondsSinceEpoch,
      "orderBy": request?.orderBy ?? "meeting",
      "sortBy": request?.sortBy ?? "asc",
    });

    var bookingListResponse = BookingListResponse.fromJson(dioRes.data);

    _logger.i(
        "Get booking list. Found: ${bookingListResponse.data?.rows?.length} items");

    return bookingListResponse;
  }

  Future<Duration> getTotalLearnedHoursAsync() async {
    var dioRes = await _dio.get("/call/total");
    var totalMinute = dioRes.data["total"] as int;

    _logger.i("Get total hours: ${totalMinute / 60}");

    return Duration(minutes: totalMinute);
  }

  Future<BookingListResponse> getLearnHistoryAsync(
      {BookingListRequest? request}) async {
    var dioRes = await _dio.get("/booking/list/student", queryParameters: {
      "page": request?.page ?? 1,
      "perPage": request?.perPage ?? 12,
      "dateTimeLte":
          request?.dateTimeLte ?? DateTime.now().millisecondsSinceEpoch,
      "orderBy": request?.orderBy ?? "meeting",
      "sortBy": request?.sortBy ?? "desc",
    });

    var bookingListResponse = BookingListResponse.fromJson(dioRes.data);

    _logger.i(
        "Get history list. Found: ${bookingListResponse.data?.rows?.length} items");

    return bookingListResponse;
  }

  Future<BookResponse> bookAsync({BookRequest? request}) async {
    var dioRes = await _dio.post("/booking", data: request);
    var response = BookResponse.fromJson(dioRes.data);

    _logger.i(response.message);
    _firebaseAnalytics?.logPurchase(
      transactionId: response.data?.first.id,
      items: response.data
          ?.map(
            (e) => AnalyticsEventItem(
              itemId: e.scheduleDetailId,
              itemName: "Booked Class",
              currency: "USD",
              price: 1,
            ),
          )
          .toList(),
    );

    return response;
  }

  Future cancelClassAsync({List<String>? scheduleDetailIds}) async {
    var dioRes = await _dio.delete(
      "/booking",
      data: {
        "scheduleDetailIds": scheduleDetailIds,
      },
    );

    _logger.i(dioRes.data["message"]);
    scheduleDetailIds?.forEach((element) {
      _firebaseAnalytics?.logRefund(
        transactionId: element,
      );
    });
  }
}
