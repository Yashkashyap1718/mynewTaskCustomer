import 'package:customer/app/models/user_model.dart';

const String imageBaseURL = "https://travelteachergroup.com:8081/uploads/";

const String baseURL = "https://travelteachergroup.com:8081";
const String imageBaseUrl = "https://travelteachergroup.com:8081/uploads/";
const String sendOtpEndpoint = "/users/signin"; //POST
const String sendOtpOnEmail = "/users/send/email"; //POST
const String veriftOtpEndpoint = "/users/confirmation"; //POST
const String veriftOtpEmail = "/users/verify/email"; //POST
const String complpeteSignUpEndpoint = "/users/complete"; //POST
const String logOutEndpoint = "/users/logout"; //POST
const String getUserPofileEndpoint = "/users/profile/preview"; //GET
const String updatePofileEndpoint = "/users/profile/update"; //PUT
const String updloadProfileImageEndpoint = "/users/profile/upload"; //PUT
const String currentLocationEndpoint = "/users/current_location"; //PUT
const String userRideRequest = "/users/ride/request"; //GET
const String userRideSubmit = "/users/ride/submit_ride"; //GET
const String userRideCanceled = "/users/ride/canceled";
const String realtimeRequest = "/users/ride/request/realtime";
const String completedRide = "/users/ride/completed/list";
const String canceledRide = "/users/ride/canceled/list";
const String acceptedRide = "/users/ride/accepted/list";
const String getDriverDetails = "/users/get_driver_detail";
const String sendEmailOtp = "/users/send/email"; //POST
const String updatedCurrentLocation = "/users/current_location"; //PUT
const String createChat = "/users/ride/chat/create"; //PUT
const String findDriverChat = "/users/ride/chat/finddriverchat"; //PUT
const String sendMessageAPIHttp = "/users/ride/chat/send_message"; //PUT
const String ongoingRidesEndpoint = "/users/ride/inprogress/list"; //POST
const String completedRidesEndpoint = "/users/ride/completed/list"; //POST
const String rejectedRidesEndpoint = "/users/ride/canceled/list"; //POST
const String bannerEndPoint = "/users/banner_list"; //Get
const String myRidesEndPoint = "/users/booking_list"; //Get
const String serviceListEndPoint = "/users/service/list"; //Get
const String servicePreviewEndPoint = "/users/service/preview"; //Get
const String rideNotesEndPoint = "/users/ride/reason_list"; //Get
const String getTicketList = "/driver/support/ticket/list";
const String createSupportTicket = "/driver/support/ticket/create";
const String createOwnerSupportTicket =
    "/driver/owner/support/ticket/create"; //POST
String token = "";

UserData userDataModel = UserData();

//Not use
const String driverListEndpoint = "/driver/driver/list"; //GET
const String resendOtpEndpoint = "/users/resendotp"; //POST
const String imagePath = "$baseURL/uploads/"; //POST