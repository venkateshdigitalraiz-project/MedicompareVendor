import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_delivery_analytics_usecase.dart';
import 'delivery_analytics_event.dart';
import 'delivery_analytics_state.dart';

class DeliveryAnalyticsBloc
    extends Bloc<DeliveryAnalyticsEvent, DeliveryAnalyticsState> {
  final GetDeliveryAnalyticsUseCase getDeliveryAnalyticsUseCase;
  String _currentRange = '7days';

  DeliveryAnalyticsBloc({required this.getDeliveryAnalyticsUseCase})
      : super(const DeliveryAnalyticsInitial()) {
    on<LoadDeliveryAnalyticsEvent>(_onLoadAnalytics);
    on<ChangeDeliveryAnalyticsRangeEvent>(_onChangeRange);
  }

  Future<void> _onLoadAnalytics(
    LoadDeliveryAnalyticsEvent event,
    Emitter<DeliveryAnalyticsState> emit,
  ) async {
    _currentRange = event.range;
    if (!event.isRefresh) {
      emit(DeliveryAnalyticsLoading(selectedRange: _currentRange));
    }

    try {
      final analytics =
          await getDeliveryAnalyticsUseCase(range: _currentRange);
      emit(DeliveryAnalyticsLoaded(
        analytics: analytics,
        selectedRange: _currentRange,
      ));
    } catch (e) {
      emit(DeliveryAnalyticsError(
        message: e.toString().replaceAll('Exception: ', ''),
        selectedRange: _currentRange,
      ));
    }
  }

  Future<void> _onChangeRange(
    ChangeDeliveryAnalyticsRangeEvent event,
    Emitter<DeliveryAnalyticsState> emit,
  ) async {
    _currentRange = event.range;
    add(LoadDeliveryAnalyticsEvent(range: _currentRange));
  }
}
