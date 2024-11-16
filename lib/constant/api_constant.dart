const String baseURL = "http://172.93.54.177:3002";
const String sendOtpEndpoint = "/users/signin"; //POST
const String veriftOtpEndpoint = "/users/confirmation"; //POST
const String resendOtpEndpoint = "/users/resendotp"; //POST
const String complpeteSignUpEndpoint = "/users/complete"; //POST
const String logOutEndpoint = "/users/logout"; //POST
const String getUserPofileEndpoint = "/users/profile/preview"; //GET
const String updatePofileEndpoint = "/users/profile/update"; //PUT
const String updloadProfileImageEndpoint = "/users/profile/upload"; //PUT
const String currentLocationEndpoint = "/users/current_location"; //PUT
const String driverListEndpoint = "/driver/driver/list"; //GET
const String userRideRequest = "/users/ride/request"; //GET

const String userRideSubmit = "/users/ride/submit_ride"; //GET
const String realtimeRequest = "/users/ride/request/realtime";

const String getDriverDetails = "/users/get_driver_detail";

String token = "";
