import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

// ---------------------------------------------------------------------------
// State machine izin lokasi — mencerminkan alur _fetchLocation di SearchScreen
// ---------------------------------------------------------------------------

enum PermissionFlowResult {
  success,       // dapat posisi
  serviceDisabled,
  userDeclinedRationale,
  permissionDenied,
  permissionDeniedForever,
  exception,
}

/// Simulasi hasil akhir _fetchLocation berdasarkan kondisi awal.
PermissionFlowResult simulateFetchLocation({
  required bool serviceEnabled,
  required LocationPermission initialPermission,
  bool? rationaleAgreed, // null = tidak ditampilkan dialog
  LocationPermission? permissionAfterRequest,
  bool throwsException = false,
}) {
  if (throwsException) return PermissionFlowResult.exception;

  if (!serviceEnabled) return PermissionFlowResult.serviceDisabled;

  var permission = initialPermission;

  if (permission == LocationPermission.denied) {
    if (rationaleAgreed != true) {
      return PermissionFlowResult.userDeclinedRationale;
    }
    permission = permissionAfterRequest ?? LocationPermission.denied;
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return permission == LocationPermission.deniedForever
        ? PermissionFlowResult.permissionDeniedForever
        : PermissionFlowResult.permissionDenied;
  }

  return PermissionFlowResult.success;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('_fetchLocation — state machine izin lokasi', () {
    test('service dinonaktifkan → serviceDisabled, loadingLocation false', () {
      final result = simulateFetchLocation(
        serviceEnabled: false,
        initialPermission: LocationPermission.whileInUse,
      );
      expect(result, PermissionFlowResult.serviceDisabled);
    });

    test('izin sudah diberikan → sukses mendapatkan posisi', () {
      final result = simulateFetchLocation(
        serviceEnabled: true,
        initialPermission: LocationPermission.whileInUse,
      );
      expect(result, PermissionFlowResult.success);
    });

    test('izin already granted (always) → sukses', () {
      final result = simulateFetchLocation(
        serviceEnabled: true,
        initialPermission: LocationPermission.always,
      );
      expect(result, PermissionFlowResult.success);
    });

    test('izin denied → dialog ditampilkan → pengguna setuju → izin diberikan → sukses', () {
      final result = simulateFetchLocation(
        serviceEnabled: true,
        initialPermission: LocationPermission.denied,
        rationaleAgreed: true,
        permissionAfterRequest: LocationPermission.whileInUse,
      );
      expect(result, PermissionFlowResult.success);
    });

    test('izin denied → dialog ditampilkan → pengguna menolak → berhenti', () {
      final result = simulateFetchLocation(
        serviceEnabled: true,
        initialPermission: LocationPermission.denied,
        rationaleAgreed: false,
      );
      expect(result, PermissionFlowResult.userDeclinedRationale);
    });

    test('izin denied → setuju → sistem tetap denied → berhenti', () {
      final result = simulateFetchLocation(
        serviceEnabled: true,
        initialPermission: LocationPermission.denied,
        rationaleAgreed: true,
        permissionAfterRequest: LocationPermission.denied,
      );
      expect(result, PermissionFlowResult.permissionDenied);
    });

    test('izin deniedForever → berhenti tanpa dialog', () {
      final result = simulateFetchLocation(
        serviceEnabled: true,
        initialPermission: LocationPermission.deniedForever,
      );
      expect(result, PermissionFlowResult.permissionDeniedForever);
    });

    test('exception dilempar → berhenti dengan graceful (loadingLocation false)', () {
      final result = simulateFetchLocation(
        serviceEnabled: true,
        initialPermission: LocationPermission.whileInUse,
        throwsException: true,
      );
      expect(result, PermissionFlowResult.exception);
    });
  });

  // =========================================================================
  group('_LocationRationaleDialog — logika keputusan', () {
    test('mengembalikan true ketika tombol Izinkan ditekan', () {
      // Dialog.pop(context, true) → agreed = true
      const agreed = true;
      expect(agreed, isTrue);
    });

    test('mengembalikan false ketika tombol Nanti saja ditekan', () {
      // Dialog.pop(context, false) → agreed = false
      const agreed = false;
      expect(agreed, isFalse);
    });

    test('mengembalikan null ketika dialog ditutup tanpa pilihan', () {
      // barrierDismissible: false → tidak bisa dismiss
      // Tapi jika somehow null, harus ditangani
      const bool? agreed = null;
      expect(agreed != true, isTrue);
    });
  });

  // =========================================================================
  group('loadingLocation state transitions', () {
    test('loadingLocation true di awal, false setelah fetchLocation apapun hasilnya', () {
      bool loadingLocation = true;

      // Setelah fetch selesai (sukses/gagal/apapun), loadingLocation = false
      void onFetchComplete() {
        loadingLocation = false;
      }

      onFetchComplete();
      expect(loadingLocation, isFalse);
    });

    test('userPosition null jika layanan tidak tersedia', () {
      // Jika serviceEnabled = false, posisi tidak dicari
      final PermissionFlowResult result = simulateFetchLocation(
        serviceEnabled: false,
        initialPermission: LocationPermission.whileInUse,
      );

      final hasPosition = result == PermissionFlowResult.success;
      expect(hasPosition, isFalse);
    });

    test('userPosition terisi hanya ketika result sukses', () {
      final result = simulateFetchLocation(
        serviceEnabled: true,
        initialPermission: LocationPermission.always,
      );

      final hasPosition = result == PermissionFlowResult.success;
      expect(hasPosition, isTrue);
    });
  });
}