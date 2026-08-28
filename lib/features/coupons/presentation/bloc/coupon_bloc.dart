import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/coupon_entity.dart';
import '../../domain/usecases/add_coupon_usecase.dart';
import '../../domain/usecases/get_coupons_usecase.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/update_coupon_usecase.dart';
import '../../domain/usecases/delete_coupon_usecase.dart';
import 'coupon_event.dart';
import 'coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final AddCouponUseCase addCouponUseCase;
  final GetCouponsUseCase getCouponsUseCase;
  final UpdateCouponUseCase updateCouponUseCase;
  final GetCustomersUseCase getCustomersUseCase;
  final DeleteCouponUseCase deleteCouponUseCase;

  CouponBloc({
    required this.addCouponUseCase,
    required this.getCouponsUseCase,
    required this.updateCouponUseCase,
    required this.getCustomersUseCase,
    required this.deleteCouponUseCase,
  }) : super(CouponInitial()) {
    on<SubmitAddCouponEvent>(_onSubmitAddCouponEvent);
    on<GetCouponsEvent>(_onGetCouponsEvent);
    on<SubmitUpdateCouponEvent>(_onSubmitUpdateCouponEvent);
    on<FetchCustomersEvent>(_onFetchCustomersEvent);
    on<DeleteCouponEvent>(_onDeleteCouponEvent);
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
    if (!event.isLoadMore) {
      emit(CouponListLoading());
    } else if (state is CouponListLoaded) {
      final currentState = state as CouponListLoaded;
      emit(CouponListLoaded(
        coupons: currentState.coupons,
        hasReachedMax: currentState.hasReachedMax,
        isFetchingMore: true,
        currentPage: currentState.currentPage,
      ));
    }

    try {
      final list = await getCouponsUseCase.call(
        page: event.page,
        limit: event.limit,
        search: event.search,
        status: event.status,
      );

      final bool hasReachedMax = list.length < event.limit;

      if (event.isLoadMore && state is CouponListLoaded) {
        final currentState = state as CouponListLoaded;
        if (list.isEmpty) {
          emit(CouponListLoaded(
            coupons: currentState.coupons,
            hasReachedMax: true,
            isFetchingMore: false,
            currentPage: currentState.currentPage,
          ));
          return;
        }

        final existingIds = currentState.coupons.map((c) => c.id).toSet();
        final newItems = list.where((c) => !existingIds.contains(c.id)).toList();
        final updatedList = List<Coupon>.from(currentState.coupons)..addAll(newItems);

        emit(CouponListLoaded(
          coupons: updatedList,
          hasReachedMax: hasReachedMax,
          isFetchingMore: false,
          currentPage: event.page,
        ));
      } else {
        emit(CouponListLoaded(
          coupons: list,
          hasReachedMax: hasReachedMax,
          isFetchingMore: false,
          currentPage: event.page,
        ));
      }
    } catch (e) {
      if (state is CouponListLoaded) {
        final currentState = state as CouponListLoaded;
        emit(CouponListLoaded(
          coupons: currentState.coupons,
          hasReachedMax: currentState.hasReachedMax,
          isFetchingMore: false,
          currentPage: currentState.currentPage,
        ));
      } else {
        emit(CouponListError(message: e.toString()));
      }
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

  Future<void> _onDeleteCouponEvent(
    DeleteCouponEvent event,
    Emitter<CouponState> emit,
  ) async {
    final currentState = state;
    emit(CouponDeleteLoading(id: event.id));
    try {
      await deleteCouponUseCase.call(event.id);
      emit(CouponDeleteSuccess(id: event.id));
      if (currentState is CouponListLoaded) {
        final updatedCoupons = currentState.coupons.where((c) => c.id != event.id).toList();
        emit(CouponListLoaded(
          coupons: updatedCoupons,
          hasReachedMax: currentState.hasReachedMax,
          isFetchingMore: currentState.isFetchingMore,
          currentPage: currentState.currentPage,
        ));
      }
    } catch (e) {
      emit(CouponDeleteFailure(
        id: event.id,
        message: e.toString().replaceAll('Exception: ', ''),
      ));
      if (currentState is CouponListLoaded) {
        emit(currentState);
      }
    }
  }
}
