import 'package:dartz/dartz.dart';
import 'package:flutter_clean_architecture/core/error/failures.dart';
import 'package:flutter_clean_architecture/core/use_cases/use_case.dart';
import 'package:flutter_clean_architecture/core/utils/input_converter.dart';
import 'package:flutter_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_clean_architecture/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';
import 'package:flutter_clean_architecture/features/number_trivia/domain/use_cases/get_random_number_trivia.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presentation/bloc/state/initial_number_trivia_state.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presentation/bloc/state/loaded_number_trivia_state.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presentation/bloc/state/loading_number_trivia_state.dart';
import 'package:flutter_clean_architecture/features/number_trivia/presentation/bloc/state/number_trivia_retrieval_error_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  const tNumberString = '1';
  const tNumberParsed = 1;
  const tNumberTrivia = NumberTrivia(text: 'test text', number: 1);

  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;
  late NumberTriviaBloc bloc;

  setUpAll(() {
    registerFallbackValue(const Params(number: tNumberParsed));
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  void setUpMockInputConverterSuccess() {
    when(() => mockInputConverter.stringToUnsignedInteger(any()))
        .thenReturn(const Right(tNumberParsed));
  }

  void setUpMockGetConcreteNumberTriviaSuccess() {
    when(() => mockGetConcreteNumberTrivia(any()))
        .thenAnswer((_) async => const Right(tNumberTrivia));
  }

  void setUpMockGetRandomNumberTriviaSuccess() {
    when(() => mockGetRandomNumberTrivia(any()))
        .thenAnswer((_) async => const Right(tNumberTrivia));
  }

  test('bloc initial state should be InitialNumberTriviaState', () {
    // assert
    expect(bloc.state, equals(InitialNumberTriviaState()));
  });

  group('GetTriviaForConcreteNumber', () {
    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();

        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(
            () => mockInputConverter.stringToUnsignedInteger(any()));

        // assert
        verify(() => mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    test(
      'should emit [NumberTriviaRetrievalErrorState] when the input is invalid',
      () async {
        // arrange
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(left(InvalidInputFailure()));

        // assert later
        expectLater(
            bloc.stream,
            emitsInOrder([
              const NumberTriviaRetrievalErrorState(
                  message: invalidInputFailureMessage)
            ]));

        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      'should get data from the concrete use case',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();

        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(
            () => mockInputConverter.stringToUnsignedInteger(any()));

        // assert
        verify(() =>
            mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
      },
    );

    test(
      'should emit [LoadingNumberTriviaState, LoadedNumberTriviaState] states when data is gotten successfully',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();

        // assert later
        final expected = [
          LoadingNumberTriviaState(),
          const LoadedNumberTriviaState(numberTrivia: tNumberTrivia),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      'should emit [LoadingNumberTriviaState, NumberTriviaRetrievalErrorState] states when data is gotten successfully',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Left(ServerFailure()));

        // assert later
        final expected = [
          LoadingNumberTriviaState(),
          const NumberTriviaRetrievalErrorState(message: serverFailureMessage),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      'should emit [LoadingNumberTriviaState, NumberTriviaRetrievalErrorState] with a proper message for the error when getting data fails',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Left(CacheFailure()));

        // assert later
        final expected = [
          LoadingNumberTriviaState(),
          const NumberTriviaRetrievalErrorState(message: cacheFailureMessage),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );
  });

  group('GetTriviaForRandomNumber', () {
    test(
      'should get data from the random use case',
      () async {
        // arrange
        setUpMockGetRandomNumberTriviaSuccess();

        // act
        bloc.add(const GetTriviaForRandomNumber());
        await untilCalled(() => mockGetRandomNumberTrivia(NoParams()));

        // assert
        verify(() => mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test(
      'should emit [LoadingNumberTriviaState, LoadedNumberTriviaState] states when data is gotten successfully',
      () async {
        // arrange
        setUpMockGetRandomNumberTriviaSuccess();

        // assert later
        final expected = [
          LoadingNumberTriviaState(),
          const LoadedNumberTriviaState(numberTrivia: tNumberTrivia),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [LoadingNumberTriviaState, NumberTriviaRetrievalErrorState] states when data is gotten successfully',
      () async {
        // arrange
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Left(ServerFailure()));

        // assert later
        final expected = [
          LoadingNumberTriviaState(),
          const NumberTriviaRetrievalErrorState(message: serverFailureMessage),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [LoadingNumberTriviaState, NumberTriviaRetrievalErrorState] with a proper message for the error when getting data fails',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Left(CacheFailure()));

        // assert later
        final expected = [
          LoadingNumberTriviaState(),
          const NumberTriviaRetrievalErrorState(message: cacheFailureMessage),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const GetTriviaForRandomNumber());
      },
    );
  });
}
