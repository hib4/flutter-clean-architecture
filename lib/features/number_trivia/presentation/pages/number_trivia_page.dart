import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presentation/bloc/state/initial_number_trivia_state.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presentation/bloc/state/loaded_number_trivia_state.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presentation/bloc/state/loading_number_trivia_state.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presentation/bloc/state/number_trivia_retrieval_error_state.dart';
import 'package:flutter_clean_architecture/injection_container.dart';

import '../widgets/loading_widget.dart';
import '../widgets/message_display.dart';
import '../widgets/trivia_controls.dart';
import '../widgets/trivia_display.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator.get<NumberTriviaBloc>(),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 8),
            BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
              builder: (context, state) {
                late final Widget widget;

                if (state is InitialNumberTriviaState) {
                  widget = const MessageDisplay(message: 'Start Searching!');
                } else if (state is LoadingNumberTriviaState) {
                  widget = const LoadingWidget();
                } else if (state is LoadedNumberTriviaState) {
                  widget = TriviaDisplay(numberTrivia: state.numberTrivia);
                } else if (state is NumberTriviaRetrievalErrorState) {
                  widget = MessageDisplay(message: state.message);
                }

                return widget;
              },
            ),
            const SizedBox(height: 20),
            const TriviaControls(),
          ],
        ),
      ),
    );
  }
}
