part of 'get_income_bloc.dart';

sealed class GetIncomeEvent extends Equatable {
  const GetIncomeEvent();

  @override
  List<Object> get props => [];
}

class GetIncome extends GetIncomeEvent {}