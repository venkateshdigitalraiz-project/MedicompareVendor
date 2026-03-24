import 'package:MediCompare/core/utils/core_injection.dart';
import 'presentation/bloc/notifications_bloc.dart';

class NotificationsInjection {
  static NotificationsBloc provideNotificationsBloc() {
    return NotificationsBloc(CoreInjection.provideApiService());
  }
}
