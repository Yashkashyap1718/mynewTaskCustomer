import 'package:flutter/material.dart';

class BookingStatus {
  static const String bookingAccepted = "booking_accepted";
  static const String bookingPlaced = "booking_placed";
  static const String bookingRequested = "requested";
  static const String bookingOngoing = "booking_ongoing";
  static const String bookingCancelled = "booking_cancelled";
  static const String bookingCompleted = "booking_completed";
  static const String bookingRejected = "booking_rejected";

  static String getBookingStatusTitle(String status) {
    String bookingStatus = '';
    if (status == "requested") {
      bookingStatus = 'Placed';
    } else if (status == "accepted") {
      bookingStatus = 'Accepted';
    } else if (status == "in_progress") {
      bookingStatus = 'Ongoing';
    } else if (status == "canceled") {
      bookingStatus = 'Cancelled';
    } else if (status == "completed") {
      bookingStatus = 'Completed';
    }else if (status == "rejected") {
      bookingStatus = 'Rejected';
    }
    return bookingStatus;
  }

  static Color getBookingStatusTitleColor(String status) {
    Color color = const Color(0xff9d9d9d);
    if (status == "requested") {
      color = const Color(0xff9d9d9d);
    } else if (status == "accepted") {
      color = const Color(0xff1EADFF);
    } else if (status == "in_progress") {
      color = const Color(0xffD19D00);
    } else if (status == "canceled") {
      color = const Color(0xffFE7235);
    } else if (status == "completed") {
      color = const Color(0xff27C041);
    }else if (status == "rejected") {
      color = const Color(0xffFE7235);
    }
    return color;
  }
}
