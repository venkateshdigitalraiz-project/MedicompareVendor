class ApiEndpoints {
  static const String _releaseBaseUrl = 'https://api.medicompares.com/api/v1';

  static String get baseUrl => _releaseBaseUrl;

  // Auth
  static const String register = '/vendor/auth/register';
  static const String login = '/vendor/auth/login';
  static const String forgotPassword = '/vendor/auth/forgot-password';
  static const String stepOneUpdate = '/vendor/profile/step_one_update';
  static const String stepTwoUpdate = '/vendor/profile/step_two';
  static const String dashboard = '/vendor/dashboard';

  // Profile
  static const String vendorProfile = '/vendor/profile';
  static const String updateProfilePicture = '/vendor/profile/update/profile';
  static const String changePassword = '/vendor/profile/change-password';
  
  // Notifications
  static const String notificationList = '/vendor/notifications/list';
  static const String markAllNotificationsRead = '/vendor/notifications/mark-all-read';
  
  // Slot Timings
  static const String slotTimings = '/vendor/vendor-timings/list';
  static String updateSlotTimings(String id) => '/vendor/vendor-timings/update/$id';
  
  // Coupons
  static const String couponList = '/vendor/coupon/list';
  static const String couponCreate = '/vendor/coupon/create';
  static String updateCoupon(String id) => '/vendor/coupon/update/$id';
  static const String customersList = '/vendor/notifications/customers-list';
  
  // Pincodes
  static const String pincodeList = '/vendor/pincode/list';
  static const String pincodeCreate = '/vendor/pincode/create';
  static String pincodeUpdate(String id) => '/vendor/pincode/update/$id';
  static String pincodeDelete(String id) => '/vendor/pincode/delete/$id';

  // Orders
  static const String orderList = '/vendor/order/list';
  static const String rentalOrderList = '/vendor/order/rental/list';
  static const String appointmentOrderList = '/vendor/order/appointment/list';
  static const String orderDetails = '/vendor/order/details';
  static const String rentalOrderDetails = '/vendor/order/rental/details';
  static const String appointmentOrderDetails = '/vendor/order/appointment/details';
  static String updateOrderStatus(String id) => '/vendor/order/update-status/$id';

  // Leads
  static const String leadsList = '/vendor/leads/list';
  static String leadDetails(String id) => '/vendor/leads/details/$id';
  static String updateLeadApprovalStatus(String id) => '/vendor/leads/updateApprovalStatus/$id';
  
  // Support Tickets
  static const String createTicket = '/vendor/support/tickets/create';
  static const String listTickets = '/vendor/support/tickets/list';
  static const String sendMessage = '/vendor/support/tickets/message';

  // Leads Subscription
  static const String leadsSubscriptionHistory = '/vendor/leads-subscription/history';
  static const String leadsSubscriptionList = '/vendor/leads-subscription/list';
  static const String leadsSubscriptionCreateOrder = '/vendor/leads-subscription/payment/create-order';
  static const String leadsSubscriptionPurchase = '/vendor/leads-subscription/purchase';

  // Medicines
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
  static String surgeryDetails(String id) => '/vendor/product/surgeries/details/$id';
  static const String commonSurgeries = '/common/tablets';
  static String commonSurgeryDetails(String id) => '/common/tablets/$id';
  static const String createSurgery = '/vendor/product/surgeries/create';
  static String updateSurgery(String id) => '/vendor/product/surgeries/update/$id';
  static String deleteSurgery(String id) => '/vendor/product/surgeries/delete/$id';

  // Lab Tests
  static const String labTestsCategories = "/common/allcategory/labtests";
  static const String labTestsList = "/vendor/product/labtests/list";
  static String labTestDetails(String id) => "/vendor/product/labtests/details/$id";
  static const String labTestsSearchTablets = "/common/tablets"; // Use ?search=&type=labtests
  static const String createLabTest = "/vendor/product/labtests/create";
  static String updateLabTest(String id) => "/vendor/product/labtests/update/$id";
  static String deleteLabTest(String id) => "/vendor/product/labtests/delete/$id";
  static String getTabletDetails(String id) => "/common/tablets/$id";

  // Lab Test Packages
  static const String packageList = "/vendor/package/list";
  static const String createPackage = "/vendor/package/create";
  static String updatePackage(String id) => "/vendor/package/update/$id";
  static String deletePackage(String id) => "/vendor/package/delete/$id";
  static const String adminPackageList = "/vendor/admin/package/list";

  // Diagnostics
  static const String diagnosticCategories = '/common/allcategory/diagnostics';
  static const String diagnosticList = '/vendor/product/diagnostics/list';
  static String diagnosticDetails(String id) => '/vendor/product/diagnostics/details/$id';
  static const String commonTablets = '/common/tablets';
  static const String createDiagnostic = '/vendor/product/diagnostics/create';
  static String updateDiagnostic(String id) => '/vendor/product/diagnostics/update/$id';
  static String deleteDiagnostic(String id) => '/vendor/product/diagnostics/delete/$id';

  // Home Care Services
  static const String homeCareCategories = '/common/allcategory/homecare';
  static const String homeCareList = '/vendor/product/homecare/list';
  static String homeCareDetails(String id) => '/vendor/product/homecare/details/$id';
  static const String createHomeCare = '/vendor/product/healthcareservice/create';
  static String updateHomeCare(String id) => '/vendor/product/healthcareservice/update/$id';
  static String deleteHomeCare(String id) => '/vendor/product/homecare/delete/$id';

  // Nursing Care (Care Taker Services)
  static const String nursingCareCategories = '/common/allcategory/nursingcare';
  static const String nursingCareList = '/vendor/product/nursingcare/list';
  static String nursingCareDetails(String id) => '/vendor/product/nursingcare/details/$id';
  static const String createNursingCare = '/vendor/product/nursingcare/create';
  static String updateNursingCare(String id) => '/vendor/product/nursingcare/update/$id';
  static String deleteNursingCare(String id) => '/vendor/product/nursingcare/delete/$id';

  // Odontogram (Dental) Services
  static const String dentalServiceCategories = '/common/allcategory/dentalservice';
  static const String dentalServiceList = '/vendor/product/dentalservice/list';
  static String dentalServiceDetails(String id) => '/vendor/product/dentalservice/details/$id';
  static const String createDentalService = '/vendor/product/dentalservice/create';
  static String updateDentalService(String id) => '/vendor/product/dentalservice/update/$id';
  static String deleteDentalService(String id) => '/vendor/product/dentalservice/delete/$id';

  // Medical Treatment Services
  static const String medicalTreatmentCategories = '/common/allcategory/medicaltreatment';
  static const String medicalTreatmentList = '/vendor/product/medicaltreatment/list';
  static String medicalTreatmentDetails(String id) => '/vendor/product/medicaltreatment/details/$id';
  static const String createMedicalTreatment = '/vendor/product/medicaltreatment/create';
  static String updateMedicalTreatment(String id) => '/vendor/product/medicaltreatment/update/$id';
  static String deleteMedicalTreatment(String id) => '/vendor/product/medicaltreatment/delete/$id';

  // Medical Equipment Services
  static const String medicalEquipmentCategories = '/common/allcategory/medicalequipment';
  static const String medicalEquipmentList = '/vendor/product/medicalequipment/list';
  static String medicalEquipmentDetails(String id) => '/vendor/product/medicalequipment/details/$id';
  static const String createMedicalEquipment = '/vendor/product/medicalequipment/create';
  static String updateMedicalEquipment(String id) => '/vendor/product/medicalequipment/update/$id';
  static String deleteMedicalEquipment(String id) => '/vendor/product/medicalequipment/delete/$id';

  // Ambulance Services
  static const String ambulanceCategories = '/common/allcategory/ambulanceservice';
  static const String ambulanceList = '/vendor/product/ambulanceservice/list';
  static String ambulanceDetails(String id) => '/vendor/product/ambulanceservice/details/$id';
  static const String createAmbulance = '/vendor/product/ambulanceservice/create';
  static String updateAmbulance(String id) => '/vendor/product/ambulanceservice/update/$id';
  static String deleteAmbulance(String id) => '/vendor/product/ambulanceservice/delete/$id';
  static const String ambulanceNames = '/common/tablets';
  static const String facilitiesList = '/vendor/facilities/list';

  // Ambulance Orders (Bookings)
  static const String ambulanceBookingList = '/vendor/ambulance-booking/list';
  static String ambulanceBookingSingle(String id) => '/vendor/ambulance-booking/single/$id';
  static const String branchList = '/vendor/branch/list';
  static String branchDetails(String id) => '/vendor/branch/details/$id';
  static String updateBranch(String id) => '/vendor/branch/update/$id';

  // Service Charge (Service Fee)
  static const String serviceChargeList = '/vendor/service-charge/list';
}
