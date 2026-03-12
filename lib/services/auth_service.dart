import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Escopos necessários para a Google Calendar API
  static const List<String> _scopes = [
    'email',
    'profile',
    'https://www.googleapis.com/auth/calendar.readonly',
  ];

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: const String.fromEnvironment(
      'GOOGLE_CLIENT_ID',
      defaultValue: 'SEU_CLIENT_ID.apps.googleusercontent.com',
    ),
    scopes: _scopes,
  );

  GoogleSignInAccount? _currentUser;
  String? _accessToken;
  bool _isLoading = false;

  GoogleSignInAccount? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _currentUser != null && _accessToken != null;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Tenta fazer sign-in silencioso (usuário já logado antes)
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        _currentUser = account;
        await _refreshToken();
      }
    } catch (e) {
      debugPrint('Silent sign-in failed: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn() async {
    _isLoading = true;
    notifyListeners();

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = account;
      await _refreshToken();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Sign-in error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _accessToken = null;
    notifyListeners();
  }

  Future<void> _refreshToken() async {
    try {
      final auth = await _currentUser?.authentication;
      _accessToken = auth?.accessToken;
    } catch (e) {
      debugPrint('Token refresh error: $e');
    }
  }

  /// Garante que o token é válido, renovando se necessário
  Future<String?> getValidToken() async {
    try {
      await _refreshToken();
      return _accessToken;
    } catch (e) {
      debugPrint('Could not get valid token: $e');
      return null;
    }
  }

  String get userDisplayName => _currentUser?.displayName ?? 'Usuário';
  String get userEmail => _currentUser?.email ?? '';
  String? get userPhotoUrl => _currentUser?.photoUrl;
}
