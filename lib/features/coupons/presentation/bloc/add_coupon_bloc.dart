import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_coupon_usecase.dart';
import 'add_coupon_event.dart';
import 'add_coupon_state.dart';

class AddCouponBloc extends Bloc<AddCouponEvent, AddCouponState> {
  final AddCouponUseCase addCouponUseCase;

  AddCouponBloc({required this.addCouponUseCase}) : super(AddCouponInitial()) {
    on<SubmitAddCouponEvent>(_onSubmitAddCouponEvent);
  }

  Future<void> _onSubmitAddCouponEvent(
    SubmitAddCouponEvent event,
    Emitter<AddCouponState> emit,
  ) async {
    emit(AddCouponLoading());
    try {
      await addCouponUseCase.call(event.coupon);
      emit(AddCouponSuccess());
    } catch (e) {
      emit(AddCouponFailure(message: e.toString()));
    }
  }
}
