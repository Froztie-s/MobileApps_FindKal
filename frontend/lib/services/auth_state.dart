class AuthState {
  static Map<String, dynamic>? currentUser;

  static bool get isWargaLokal => currentUser?['is_warga_lokal'] == true;

  static int get attemptsUsed => (currentUser?['attempts_used'] as int?) ?? 0;

  static String? get lockedUntil => currentUser?['locked_until'] as String?;

  static bool get isLockedOut {
    final lu = lockedUntil;
    if (lu == null) return false;
    return DateTime.tryParse(lu)?.isAfter(DateTime.now()) ?? false;
  }
}