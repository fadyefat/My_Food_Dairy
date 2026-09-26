import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_food_diary/features/auth/data/models/user_model.dart';
import 'package:my_food_diary/features/auth/data/repos/auth_repo.dart';
import 'package:my_food_diary/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:my_food_diary/features/auth/presentation/cubit/auth_state.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockAuthRepo mockAuthRepo;
  late AuthCubit authCubit;

  final sampleUser = UserModel(
    uid: 'user_123',
    email: 'test@example.com',
    displayName: 'Test User',
    createdAt: '2026-09-26T10:00:00Z',
  );

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    when(() => mockAuthRepo.getCurrentUser()).thenReturn(null);
    authCubit = AuthCubit(mockAuthRepo);
  });

  tearDown(() {
    authCubit.close();
  });

  test('initial state is Unauthenticated when no stored session', () {
    expect(authCubit.state, isA<Unauthenticated>());
  });

  blocTest<AuthCubit, AuthState>(
    'signIn emits [AuthLoading, Authenticated] on success',
    build: () {
      when(() => mockAuthRepo.signInWithEmail(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => sampleUser);
      return authCubit;
    },
    act: (cubit) => cubit.signIn(
      email: 'test@example.com',
      password: 'password123',
    ),
    expect: () => [
      isA<AuthLoading>(),
      isA<Authenticated>().having((s) => s.user.email, 'email', 'test@example.com'),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'signIn emits [AuthLoading, AuthError] on failure',
    build: () {
      when(() => mockAuthRepo.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(ArgumentError('Invalid credentials'));
      return authCubit;
    },
    act: (cubit) => cubit.signIn(
      email: 'bad@example.com',
      password: '123',
    ),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthError>(),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'signUp emits [AuthLoading, Authenticated] on success',
    build: () {
      when(() => mockAuthRepo.signUpWithEmail(
            name: 'New User',
            email: 'new@example.com',
            password: 'password123',
          )).thenAnswer((_) async => sampleUser);
      return authCubit;
    },
    act: (cubit) => cubit.signUp(
      name: 'New User',
      email: 'new@example.com',
      password: 'password123',
    ),
    expect: () => [
      isA<AuthLoading>(),
      isA<Authenticated>(),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'signInAsGuest emits [AuthLoading, Authenticated]',
    build: () {
      when(() => mockAuthRepo.signInAsGuest()).thenAnswer(
        (_) async => sampleUser.copyWith(isGuest: true),
      );
      return authCubit;
    },
    act: (cubit) => cubit.signInAsGuest(),
    expect: () => [
      isA<AuthLoading>(),
      isA<Authenticated>().having((s) => s.user.isGuest, 'isGuest', true),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'signOut emits [AuthLoading, Unauthenticated]',
    build: () {
      when(() => mockAuthRepo.signOut()).thenAnswer((_) async {});
      return authCubit;
    },
    act: (cubit) => cubit.signOut(),
    expect: () => [
      isA<AuthLoading>(),
      isA<Unauthenticated>(),
    ],
  );
}
