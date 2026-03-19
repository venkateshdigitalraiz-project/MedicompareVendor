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
  static const String leadsSubscriptionHistory = '/vendor/leads-subscription/history';
  static const String leadsSubscriptionList = '/vendor/leads-subscription/list';
  static const String leadsSubscriptionCreateOrder = '/vendor/leads-subscription/payment/create-order';
  static const String leadsSubscriptionPurchase = '/vendor/leads-subscription/purchase';
  static const String medicineCategories = '/common/allcategory/medicine';
  static const String medicineList = '/vendor/product/medicine/list';
  static const String medicineDropdownSearch = '/common/tablets';
  static const String createMedicine = '/vendor/product/medicine/create';
  static String vendorMedicineDetails(String id) => '/vendor/product/medicine/details/$id';
  static String updateMedicine(String id) => '/vendor/product/medicine/update/$id';
  static String deleteMedicine(String id) => '/vendor/product/medicine/delete/$id';

  // Surgeries
  static const String surgeryCategories = '/common/allcategory/surgeries';
  static const String surgeryList = '/vendor/product/surgeries/list';
  static String surgeryDetails(String id) => '/vendor/product/surgery/details/$id';
  static const String commonSurgeries = '/common/tablets?type=surgeries';
  static String commonSurgeryDetails(String id) => '/common/tablets/$id';
  static const String createSurgery = '/vendor/product/surgery/create';
  static String updateSurgery(String id) => '/vendor/product/surgery/update/$id';
  static String deleteSurgery(String id) => '/vendor/product/surgery/delete/$id';
}
