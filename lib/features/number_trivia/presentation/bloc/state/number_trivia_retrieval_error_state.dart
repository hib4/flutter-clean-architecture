import 'package:flutter_clean_architecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class NumberTriviaRetrievalErrorState extends NumberTriviaState {
  const NumberTriviaRetrievalErrorState({required String message})
      : _message = message;

  final String _message;

  String get message => _message;

  @override
  // TODO: implement props
  List<Object?> get props => [_message];
}
