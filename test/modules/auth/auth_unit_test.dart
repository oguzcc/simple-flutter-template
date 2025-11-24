// AuthService Testi
//
// Bu test dosyası AuthService sınıfını test etmek için hazırlanmıştır.
// AuthService, bir AuthRepo ile çalışarak kimlik doğrulama işlemlerini yönetir.
//
// Test dosyasının amacı:
// - AuthService'in `signIn` ve `signUp` metotlarının doğru
//çalıştığını doğrulamak.
// - Başarılı ve hatalı senaryoları test etmek.
// - Mocklama kullanarak birim testler yazmak.
//
// Kullanılan araçlar:
// - `mocktail`: Mocklama için kullanılmıştır.
// - `flutter_test`: Flutter test altyapısı.

import 'package:daisy/core/types/data_exception.dart';
import 'package:daisy/data/dto/auth/req_sign_in_dto.dart';
import 'package:daisy/data/dto/auth/req_sign_up_dto.dart';
import 'package:daisy/data/model/auth_model.dart';
import 'package:daisy/data/repo/auth_repo.dart';
import 'package:daisy/data/service/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock Repo
//
// AuthRepo'nun bir mock versiyonunu oluşturuyoruz.
// Bu sınıf, AuthRepo'nun davranışlarını taklit etmek için kullanılır ve
// AuthService'in bağımlılıklarının izole edilmesini sağlar.
class MockAuthRepo extends Mock implements IAuthRepo {}

void main() {
  // Test Değişkenleri
  late MockAuthRepo mockAuthRepo; // Mocklanan AuthRepo
  late AuthService authService; // Test edilen AuthService

  // Sabit Test Verileri
  //
  // Bu veriler, test sırasında kullanılan örnek DTO'lar ve mock
  // response'lardır.
  const testSignInDto = ReqSignInDto(
    email: 'test@test.com',
    password: '123456',
  );

  const testSignUpDto = ReqSignUpDto(
    email: 'test@test.com',
    password: '123456',
    name: 'Test User',
  );

  final testResponseData = {
    'token': 'test_token',
    'user': {
      'id': '1',
      'email': 'test@test.com',
      'name': 'Test User',
    },
  };

  final testResponse = Response(
    data: testResponseData,
    statusCode: 200,
    requestOptions: RequestOptions(path: '/auth/login'),
  );

  // Test Kurulumu
  //
  // Her testten önce mock repo ve AuthService örnekleri oluşturulur.
  // Ayrıca, mocktail için fallback değerler kaydedilir.
  setUp(() {
    mockAuthRepo = MockAuthRepo();
    authService = AuthService(mockAuthRepo);

    // Mocktail için fallback değerler
    registerFallbackValue(testSignInDto);
    registerFallbackValue(testSignUpDto);
  });

  // Test Grupları
  //
  // Testler, ilgili metotlar için gruplar halinde düzenlenmiştir.
  group('AuthModule Unit Test', () {
    // signIn Metodu Testleri
    group('signIn', () {
      test('başarılı olduğunda Right(AuthModel) döner', () async {
        // Arrange (Hazırlık)
        // Mock repo, başarılı bir yanıt dönecek şekilde ayarlanır.
        when(() => mockAuthRepo.signIn(any()))
            .thenAnswer((_) async => testResponse);

        // Act (İcra)
        // AuthService'in signIn metodu çağrılır.
        final result = await authService.signIn(testSignInDto);

        // Assert (Doğrulama)
        // Sonuç doğrulanır.
        expect(result.isRight(), true);
        result.fold(
          (l) => fail(
            'Should not return left',
          ), // Sol taraf dönerse test hata verir.
          (r) {
            // Sağ tarafın AuthModel olduğu ve beklenen değerleri içerdiği
            // doğrulanır.
            expect(r, isA<AuthModel>());
            expect(r.token, equals('test_token'));
            expect(r.user!.email, equals('test@test.com'));
            expect(r.user!.name, equals('Test User'));
          },
        );

        // Mock repo'nun signIn metodu 1 kez çağrılmış olmalı.
        verify(() => mockAuthRepo.signIn(testSignInDto)).called(1);
      });

      test('hata durumunda Left(Err) döner', () async {
        // Arrange (Hazırlık)
        // Mock repo, bir hata fırlatacak şekilde ayarlanır.
        when(() => mockAuthRepo.signIn(any()))
            .thenThrow(Exception('Auth error'));

        // Act (İcra)
        // AuthService'in signIn metodu çağrılır.
        final result = await authService.signIn(testSignInDto);

        // Assert (Doğrulama)
        // Sonuç doğrulanır.
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<Err>()), // Sol tarafın Err olduğu doğrulanır.
          (r) => fail(
            'Should not return right',
          ), // Sağ taraf dönerse test hata verir.
        );

        // Mock repo'nun signIn metodu 1 kez çağrılmış olmalı.
        verify(() => mockAuthRepo.signIn(testSignInDto)).called(1);
      });
    });

    // signUp Metodu Testleri
    group('signUp', () {
      test('başarılı olduğunda Right(AuthModel) döner', () async {
        // Arrange (Hazırlık)
        // Mock repo, başarılı bir yanıt dönecek şekilde ayarlanır.
        when(() => mockAuthRepo.signUp(any()))
            .thenAnswer((_) async => testResponse);

        // Act (İcra)
        // AuthService'in signUp metodu çağrılır.
        final result = await authService.signUp(testSignUpDto);

        // Assert (Doğrulama)
        // Sonuç doğrulanır.
        expect(result.isRight(), true);
        result.fold(
          (l) => fail(
            'Should not return left',
          ), // Sol taraf dönerse test hata verir.
          (r) {
            // Sağ tarafın AuthModel olduğu ve beklenen değerleri içerdiği
            // doğrulanır.
            expect(r, isA<AuthModel>());
            expect(r.token, equals('test_token'));
            expect(r.user!.email, equals('test@test.com'));
            expect(r.user!.name, equals('Test User'));
          },
        );

        // Mock repo'nun signUp metodu 1 kez çağrılmış olmalı.
        verify(() => mockAuthRepo.signUp(testSignUpDto)).called(1);
      });

      test('hata durumunda Left(Err) döner', () async {
        // Arrange (Hazırlık)
        // Mock repo, bir hata fırlatacak şekilde ayarlanır.
        when(() => mockAuthRepo.signUp(any()))
            .thenThrow(Exception('Auth error'));

        // Act (İcra)
        // AuthService'in signUp metodu çağrılır.
        final result = await authService.signUp(testSignUpDto);

        // Assert (Doğrulama)
        // Sonuç doğrulanır.
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<Err>()), // Sol tarafın Err olduğu doğrulanır.
          (r) => fail(
            'Should not return right',
          ), // Sağ taraf dönerse test hata verir.
        );

        // Mock repo'nun signUp metodu 1 kez çağrılmış olmalı.
        verify(() => mockAuthRepo.signUp(testSignUpDto)).called(1);
      });
    });
  });
}
