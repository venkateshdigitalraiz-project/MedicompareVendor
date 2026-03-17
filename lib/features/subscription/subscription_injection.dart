import '../../core/utils/core_injection.dart';
import 'data/data_sources/subscription_service.dart';
import 'data/repositories/subscription_repository_impl.dart';
import 'domain/repositories/subscription_repository.dart';
import 'presentation/bloc/subscription_bloc.dart';

class SubscriptionInjection {
  static SubscriptionService provideService() {
    return SubscriptionService(apiService: CoreInjection.provideApiService());
  }

  static SubscriptionRepository provideRepository() {
    return SubscriptionRepositoryImpl(service: provideService());
  }

  static SubscriptionBloc provideBloc() {
    return SubscriptionBloc(repository: provideRepository());
  }
}
