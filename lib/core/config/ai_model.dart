enum AIModel {
  gemini25Flash('Gemini 2.5 Flash', 'gemini-2.5-flash'),
  gemini15Flash('Gemini 1.5 Flash', 'gemini-1.5-flash'),
  gemini15Pro('Gemini 1.5 Pro', 'gemini-1.5-pro');

  const AIModel(this.displayName, this.modelId);

  final String displayName;
  final String modelId;
}