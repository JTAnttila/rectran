import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rectran/core/config/ai_model.dart';

/// Service for securely storing sensitive data like API keys.
///
/// Uses platform-specific secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences
/// - Web: Encrypted storage with Web Crypto API
///
/// Supports multiple AI providers with separate API keys
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Storage key prefixes
  static const String _apiKeyPrefix = 'api_key_';
  static const String _selectedModelKey = 'selected_ai_model';
  static const String _selectedProviderKey = 'selected_ai_provider';

  /// Get storage key for a specific provider
  String _getProviderKey(AIProvider provider) {
    return '$_apiKeyPrefix${provider.name}';
  }

  /// Save API key for a specific provider
  Future<void> saveApiKey(AIProvider provider, String apiKey) async {
    await _storage.write(key: _getProviderKey(provider), value: apiKey);
  }

  /// Retrieve API key for a specific provider
  Future<String?> getApiKey(AIProvider provider) async {
    return await _storage.read(key: _getProviderKey(provider));
  }

  /// Delete API key for a specific provider
  Future<void> deleteApiKey(AIProvider provider) async {
    await _storage.delete(key: _getProviderKey(provider));
  }

  /// Check if API key exists for a specific provider
  Future<bool> hasApiKey(AIProvider provider) async {
    final key = await getApiKey(provider);
    return key != null && key.isNotEmpty;
  }

  /// Get all providers that have API keys configured
  Future<List<AIProvider>> getConfiguredProviders() async {
    final List<AIProvider> configured = [];
    for (final provider in AIProvider.values) {
      if (await hasApiKey(provider)) {
        configured.add(provider);
      }
    }
    return configured;
  }

  /// Save selected AI model
  Future<void> saveSelectedModel(String modelId) async {
    await _storage.write(key: _selectedModelKey, value: modelId);
  }

  /// Retrieve selected AI model
  Future<String?> getSelectedModel() async {
    return await _storage.read(key: _selectedModelKey);
  }

  /// Save selected AI provider
  Future<void> saveSelectedProvider(String providerName) async {
    await _storage.write(key: _selectedProviderKey, value: providerName);
  }

  /// Retrieve selected AI provider
  Future<String?> getSelectedProvider() async {
    return await _storage.read(key: _selectedProviderKey);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}