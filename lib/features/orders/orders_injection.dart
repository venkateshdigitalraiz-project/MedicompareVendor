import '../../core/utils/core_injection.dart';
import 'data/datasources/orders_remote_data_source.dart';
import 'data/repositories/orders_repository_impl.dart';
import 'domain/repositories/orders_repository.dart';
import 'domain/usecases/get_orders_usecase.dart';
import 'domain/usecases/get_order_details_usecase.dart';
import 'domain/usecases/update_order_status_usecase.dart';
import 'presentation/bloc/orders_bloc.dart';
import 'presentation/bloc/order_details_bloc.dart';
import 'domain/repositories/rental_booking_repository.dart';
import 'domain/usecases/get_rental_bookings_usecase.dart';
import 'data/repositories/rental_booking_repository_impl.dart';
import 'data/datasources/rental_booking_remote_data_source.dart';
import 'presentation/bloc/rental_booking_bloc.dart';

class OrdersInjection {
  static OrdersBloc provideOrdersBloc() {
    return OrdersBloc(
      getOrdersUseCase: provideGetOrdersUseCase(),
    );
  }

  static OrderDetailsBloc provideOrderDetailsBloc() {
    return OrderDetailsBloc(
      getOrderDetailsUseCase: provideGetOrderDetailsUseCase(),
      updateOrderStatusUseCase: provideUpdateOrderStatusUseCase(),
    );
  }

  static GetOrdersUseCase provideGetOrdersUseCase() {
    return GetOrdersUseCase(provideOrdersRepository());
  }

  static GetOrderDetailsUseCase provideGetOrderDetailsUseCase() {
    return GetOrderDetailsUseCase(provideOrdersRepository());
  }

  static UpdateOrderStatusUseCase provideUpdateOrderStatusUseCase() {
    return UpdateOrderStatusUseCase(provideOrdersRepository());
  }

  static OrdersRepository provideOrdersRepository() {
    return OrdersRepositoryImpl(
      remoteDataSource: provideOrdersRemoteDataSource(),
    );
  }

  static OrdersRemoteDataSource provideOrdersRemoteDataSource() {
    return OrdersRemoteDataSourceImpl(
      apiService: CoreInjection.provideApiService(),
    );
  }

  static RentalBookingBloc provideRentalBookingBloc() {
    return RentalBookingBloc(
      getRentalBookingsUseCase: provideGetRentalBookingsUseCase(),
    );
  }

  static GetRentalBookingsUseCase provideGetRentalBookingsUseCase() {
    return GetRentalBookingsUseCase(provideRentalBookingRepository());
  }

  static RentalBookingRepository provideRentalBookingRepository() {
    return RentalBookingRepositoryImpl(
      remoteDataSource: provideRentalBookingRemoteDataSource(),
    );
  }

  static RentalBookingRemoteDataSource provideRentalBookingRemoteDataSource() {
    return RentalBookingRemoteDataSourceImpl(
      apiService: CoreInjection.provideApiService(),
    );
  }
}
