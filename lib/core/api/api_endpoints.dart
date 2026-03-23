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
  static String updateSlotTimings(String id) =>
      '/vendor/vendor-timings/update/$id';
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
  static const String leadsSubscriptionHistory =
      '/vendor/leads-subscription/history';
  static const String leadsSubscriptionList = '/vendor/leads-subscription/list';
  static const String leadsSubscriptionCreateOrder =
      '/vendor/leads-subscription/payment/create-order';
  static const String leadsSubscriptionPurchase =
      '/vendor/leads-subscription/purchase';
  static const String medicineCategories = '/common/allcategory/medicine';
  static const String medicineList = '/vendor/product/medicine/list';
  static const String medicineDropdownSearch = '/common/tablets';
  static const String createMedicine = '/vendor/product/medicine/create';
  static String vendorMedicineDetails(String id) =>
      '/vendor/product/medicine/details/$id';
  static String updateMedicine(String id) =>
      '/vendor/product/medicine/update/$id';
  static String deleteMedicine(String id) =>
      '/vendor/product/medicine/delete/$id';

  // Surgeries
  static const String surgeryCategories = '/common/allcategory/surgeries';
  static const String surgeryList = '/vendor/product/surgeries/list';
  static String surgeryDetails(String id) =>
      '/vendor/product/surgery/details/$id';
  static const String commonSurgeries = '/common/tablets?type=surgeries';
  static String commonSurgeryDetails(String id) => '/common/tablets/$id';
  static const String createSurgery = '/vendor/product/surgery/create';
  static String updateSurgery(String id) =>
      '/vendor/product/surgery/update/$id';
  static String deleteSurgery(String id) =>
      '/vendor/product/surgery/delete/$id';

  // Lab Tests
  static const String labTestsCategories = "/common/allcategory/labtests";
  static const String labTestsList = "/vendor/product/labtests/list";
  static String labTestDetails(String id) =>
      "/vendor/product/labtests/details/$id";
  static const String labTestsSearchTablets =
      "/common/tablets"; // Use ?search=&type=labtests
  static const String createLabTest = "/vendor/product/labtests/create";
  static String updateLabTest(String id) =>
      "/vendor/product/labtests/update/$id";
  static String deleteLabTest(String id) =>
      "/vendor/product/labtests/delete/$id";
  static String getTabletDetails(String id) => "/common/tablets/$id";

  // Lab Test Packages
  static const String packageList = "/vendor/package/list";
  static const String createPackage = "/vendor/package/create";
  static String updatePackage(String id) => "/vendor/package/update/$id";
  static String deletePackage(String id) => "/vendor/package/delete/$id";

  // Diagnostics
  static const String diagnosticCategories = '/common/allcategory/diagnostics';
  static const String diagnosticList = '/vendor/product/diagnostics/list';
  static String diagnosticDetails(String id) =>
      '/vendor/product/diagnostic/details/$id';
  static const String commonTablets = '/common/tablets';
  static const String createDiagnostic = '/vendor/product/diagnostic/create';
  static String updateDiagnostic(String id) =>
      '/vendor/product/diagnostic/update/$id';
  static String deleteDiagnostic(String id) =>
      '/vendor/product/diagnostic/delete/$id';

  // Home Care Services
  static const String homeCareCategories = '/common/allcategory/homecare';
  static const String homeCareList = '/vendor/product/homecare/list';
  static String homeCareDetails(String id) =>
      '/vendor/product/homecare/details/$id';
  static const String createHomeCare =
      '/vendor/product/healthcareservice/create';
  static String updateHomeCare(String id) =>
      '/vendor/product/healthcareservice/update/$id';
  static String deleteHomeCare(String id) =>
      '/vendor/product/homecare/delete/$id';

  // Nursing Care (Care Taker Services)
  static const String nursingCareCategories = '/common/allcategory/nursingcare';
  static const String nursingCareList = '/vendor/product/nursingcare/list';
  static String nursingCareDetails(String id) =>
      '/vendor/product/nursingcare/details/$id';
  static const String createNursingCare = '/vendor/product/nursingcare/create';
  static String updateNursingCare(String id) =>
      '/vendor/product/nursingcare/update/$id';
  static String deleteNursingCare(String id) =>
      '/vendor/product/nursingcare/delete/$id';

  // Odontogram (Dental) Services
  static const String dentalServiceCategories =
      '/common/allcategory/dentalservice';
  static const String dentalServiceList = '/vendor/product/dentalservice/list';
  static String dentalServiceDetails(String id) =>
      '/vendor/product/dentalservice/details/$id';
  static const String createDentalService =
      '/vendor/product/dentalservice/create';
  static String updateDentalService(String id) =>
      '/vendor/product/dentalservice/update/$id';
  static String deleteDentalService(String id) =>
      '/vendor/product/dentalservice/delete/$id';

  // Medical Treatment Services
  static const String medicalTreatmentCategories =
      '/common/allcategory/medicaltreatment';
  static const String medicalTreatmentList =
      '/vendor/product/medicaltreatment/list';
  static String medicalTreatmentDetails(String id) =>
      '/vendor/product/medicaltreatment/details/$id';
  static const String createMedicalTreatment =
      '/vendor/product/medicaltreatment/create';
  static String updateMedicalTreatment(String id) =>
      '/vendor/product/medicaltreatment/update/$id';
  static String deleteMedicalTreatment(String id) =>
      '/vendor/product/medicaltreatment/delete/$id';
}
