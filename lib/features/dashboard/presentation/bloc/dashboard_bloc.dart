import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_erp/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:mini_erp/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:mini_erp/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;

  DashboardBloc(this.getDashboardStatsUseCase) : super(DashboardInitial()) {
    on<LoadDashboardEvent>((event, emit) async {
      emit(DashboardLoading());
      try {
        final stats = await getDashboardStatsUseCase();
        emit(DashboardLoaded(stats));
      } catch (e) {
        emit(DashboardError(e.toString()));
      }
    });
  }
}
