/// Supported AI providers
enum AIProvider {
  gemini('Google Gemini', 'https://aistudio.google.com/app/apikey'),
  openai('OpenAI (ChatGPT)', 'https://platform.openai.com/api-keys'),
  anthropic('Anthropic (Claude)', 'https://console.anthropic.com/settings/keys');

  const AIProvider(this.displayName, this.apiKeyUrl);

  final String displayName;
  final String apiKeyUrl;
}

/// AI models with their provider information
enum AIModel {
  // Google Gemini models
  gemini25Flash('Gemini 2.5 Flash', 'gemini-2.5-flash', AIProvider.gemini, 'Fast and efficient, best for quick transcriptions'),
  gemini15Flash('Gemini 1.5 Flash', 'gemini-1.5-flash', AIProvider.gemini, 'Balanced speed and quality'),
  gemini15Pro('Gemini 1.5 Pro', 'gemini-1.5-pro', AIProvider.gemini, 'Most capable Gemini model'),

  // OpenAI models
  whisperLarge('Whisper Large V3', 'whisper-1', AIProvider.openai, 'OpenAI\'s speech-to-text model'),
  gpt4oAudio('GPT-4o Audio', 'gpt-4o-audio-preview', AIProvider.openai, 'GPT-4o with native audio understanding'),

  // Anthropic Claude models (via API - transcription through text)
  claudeOpus('Claude 3.5 Opus', 'claude-3-5-opus', AIProvider.anthropic, 'Most capable Claude model'),
  claudeSonnet('Claude 3.5 Sonnet', 'claude-3-5-sonnet-latest', AIProvider.anthropic, 'Fast and intelligent');

  const AIModel(this.displayName, this.modelId, this.provider, this.description);

  final String displayName;
  final String modelId;
  final AIProvider provider;
  final String description;

  /// Get all models for a specific provider
  static List<AIModel> getModelsForProvider(AIProvider provider) {
    return AIModel.values.where((model) => model.provider == provider).toList();
  }
}