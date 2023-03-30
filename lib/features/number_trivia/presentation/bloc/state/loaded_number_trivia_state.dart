import '../../../domain/entities/number_trivia.dart';
import '../number_trivia_bloc.dart';

class LoadedNumberTriviaState extends NumberTriviaState {
  const LoadedNumberTriviaState({required this.numberTrivia});

  final NumberTrivia numberTrivia;

  @override
  List<Object> get props => [numberTrivia];
}