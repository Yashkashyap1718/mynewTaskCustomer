import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant_widgets/custom_dialog_box.dart';
import 'package:customer/constant_widgets/pick_drop_point_view.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:customer/models/ride_booking.dart';
import 'package:provider/provider.dart';

class NewRideView extends StatelessWidget {
  final RideBooking bookingModel;

  const NewRideView({super.key, required this.bookingModel});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DarkThemeProvider>(context);

    return GestureDetector(
      onTap: () {
        // Navigate to ride details view (if implemented)
        // Navigator.push(context, MaterialPageRoute(builder: (_) => RideDetailsView(bookingModel: bookingModel)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.isDarkTheme() ? Colors.grey : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.isDarkTheme() ? Colors.grey : Colors.grey,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.isDarkTheme()
                  ? Colors.transparent
                  : Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bookingModel.status == "requested"
                ? Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: LinearProgressIndicator(
                      color: Colors.blue,
                      backgroundColor: Colors.grey,
                    ),
                  )
                : Container(),
            PickDropPointView(
              pickUpAddress: bookingModel.pickupAddress,
              dropAddress: bookingModel.dropoffAddress,
            ),
            const SizedBox(height: 12),
            if (bookingModel.status == BookingStatus.bookingRequested)
              _buildCancelRideButton(context, theme),
            if (bookingModel.status == BookingStatus.bookingAccepted)
              _buildActionButtons(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelRideButton(BuildContext context, DarkThemeProvider theme) {
    return RoundShapeButton(
      title: "Cancel Ride",
      buttonColor: Colors.red,
      buttonTextColor: Colors.white,
      onTap: () => _showCancelDialog(context, theme),
      size: const Size(double.infinity, 48),
    );
  }

  Widget _buildActionButtons(BuildContext context, DarkThemeProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: RoundShapeButton(
            title: "Cancel Ride",
            buttonColor: theme.isDarkTheme() ? Colors.grey : Colors.grey,
            buttonTextColor: theme.isDarkTheme() ? Colors.white : Colors.black,
            onTap: () => _showCancelDialog(context, theme),
            size: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context, DarkThemeProvider theme) {
    showDialog(
      context: context,
      builder: (_) => CustomDialogBox(
        title: "Cancel Ride",
        descriptions: "Are you sure you want to cancel this ride?",
        positiveString: "Yes",
        negativeString: "No",
        positiveButtonColor: Colors.red,
        positiveButtonTextColor: Colors.white,
        negativeButtonColor: theme.isDarkTheme() ? Colors.grey : Colors.grey,
        negativeButtonTextColor:
            theme.isDarkTheme() ? Colors.white : Colors.black,
        positiveClick: () {
          // Handle cancellation logic
          Navigator.pop(context);
        },
        negativeClick: () => Navigator.pop(context),
        img: Image.asset(
          "assets/icon/ic_green_right.png",
          height: 58,
          width: 58,
        ),
        themeChange: theme,
      ),
    );
  }
}
