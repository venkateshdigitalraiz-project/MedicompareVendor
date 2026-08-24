import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_coupon_usecase.dart';
import '../../domain/usecases/get_coupons_usecase.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/update_coupon_usecase.dart';
import 'coupon_event.dart';
import 'coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final AddCouponUseCase addCouponUseCase;
  final GetCouponsUseCase getCouponsUseCase;
  final UpdateCouponUseCase updateCouponUseCase;
  final GetCustomersUseCase getCustomersUseCase;

  CouponBloc({
    required this.addCouponUseCase,
    required this.getCouponsUseCase,
    required this.updateCouponUseCase,
    required this.getCustomersUseCase,
  }) : super(CouponInitial()) {
    on<SubmitAddCouponEvent>(_onSubmitAddCouponEvent);
    on<GetCouponsEvent>(_onGetCouponsEvent);
    on<SubmitUpdateCouponEvent>(_onSubmitUpdateCouponEvent);
    on<FetchCustomersEvent>(_onFetchCustomersEvent);
  }

  Future<void> _onSubmitAddCouponEvent(
    SubmitAddCouponEvent event,
    Emitter<CouponState> emit,
  ) async {
    emit(CouponLoading());
    try {
      await addCouponUseCase.call(event.coupon);
      emit(CouponSuccess());
    } catch (e) {
      emit(CouponFailure(message: e.toString()));
    }
  }

  Future<void> _onGetCouponsEvent(
    GetCouponsEvent event,
    Emitter<CouponState> emit,
  ) async {
    emit(CouponListLoading());
    try {
      final list = await getCouponsUseCase.call(
        page: event.page,
        limit: event.limit,
        search: event.search,
        status: event.status,
      );
      emit(CouponListLoaded(coupons: list));
    } catch (e) {
      emit(CouponListError(message: e.toString()));
    }
  }

  Future<void> _onSubmitUpdateCouponEvent(
    SubmitUpdateCouponEvent event,
    Emitter<CouponState> emit,
  ) async {
    emit(CouponUpdateLoading());
    try {
      await updateCouponUseCase.call(event.id, event.coupon);
      emit(CouponUpdateSuccess());
    } catch (e) {
      emit(CouponUpdateFailure(message: e.toString()));
    }
  }

  Future<void> _onFetchCustomersEvent(
    FetchCustomersEvent event,
    Emitter<CouponState> emit,
  ) async {
    emit(CustomersLoading());
    try {
      final list = await getCustomersUseCase.call(search: event.search);
      emit(CustomersLoaded(customers: list));
    } catch (e) {
      emit(CustomersError(message: e.toString()));
    }
  }
}
