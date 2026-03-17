class ApiEndpoints {
  static const String _releaseBaseUrl = 'https://api.medicompares.com/api/v1';
  
  static String get baseUrl => _releaseBaseUrl;

  // Paths
  static const String register = '/vendor/auth/register';
  static const String login = '/vendor/auth/login';
  static const String stepOneUpdate = '/vendor/profile/step_one_update';
  static const String stepTwoUpdate = '/vendor/profile/step_two';
  static const String dashboard = '/vendor/dashboard';
  static const String slotTimings = '/vendor/vendor-timings/list';
  static String updateSlotTimings(String id) => '/vendor/vendor-timings/update/$id';
  static const String pincodeList = '/vendor/pincode/list';
  static const String pincodeCreate = '/vendor/pincode/create';
  static String pincodeUpdate(String id) => '/vendor/pincode/update/$id';
  static String pincodeDelete(String id) => '/vendor/pincode/delete/$id';
  static const String orderList = '/vendor/order/list';
  static const String orderDetails = '/vendor/order/details';
  static const String leadsList = '/vendor/leads/list';
  static const String createTicket = '/vendor/support/tickets/create';
  static const String listTickets = '/vendor/support/tickets/list';
  static const String sendMessage = '/vendor/support/tickets/message';
}
