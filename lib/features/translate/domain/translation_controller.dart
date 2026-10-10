import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../../providers/providers.dart';
import 'translation_result.dart';

class TranslationState {
  const TranslationState({this.busy = false, this.error, this.result});

  final bool busy;
  final String? error;
  final TranslationResult? result;
}

class TranslationController extends Notifier<TranslationState> {
  @override
  TranslationState build() => const TranslationState();

  /// Falls back to English when the requested target equals the source
  /// (e.g. Tagalog -> Tagalog for the Philippines).
  TranslateLanguage effectiveTarget(
          TranslateLanguage source, TranslateLanguage requested) =>
      requested == source ? TranslateLanguage.english : requested;

  Future<List<TranslateLanguage>> missingModels(
    TranslateLanguage source,
    TranslateLanguage requestedTarget,
  ) {
    final needed = <TranslateLanguage>{
      source,
      TranslateLanguage.english,
      effectiveTarget(source, requestedTarget),
    };
    return ref.read(languageModelServiceProvider).missing(needed);
  }

  Future<void> downloadModels(List<TranslateLanguage> languages) async {
    final models = ref.read(languageModelServiceProvider);
    for (final l in languages) {
      await models.download(l);
    }
  }

  Future<void> fromImage(
    String path,
    TranslateLanguage source,
    TranslateLanguage requestedTarget,
  ) async {
    state = const TranslationState(busy: true);
    try {
      final text = await ref.read(ocrServiceProvider).recognize(path);
      if (text.isEmpty) {
        state = const TranslationState(
          error: 'No readable text was detected in that image. '
              'Try taking a clearer, well-lit photo or type the text manually.',
        );
        return;
      }
      await _translate(text, source, requestedTarget, imagePath: path);
    } catch (e) {
      state = TranslationState(
        error: 'Unable to scan image ($e). You can enter the text directly below.',
      );
    }
  }

  Future<void> fromText(
    String text,
    TranslateLanguage source,
    TranslateLanguage requestedTarget,
  ) async {
    state = const TranslationState(busy: true);
    try {
      await _translate(text, source, requestedTarget);
    } catch (e) {
      state = TranslationState(error: 'Translation failed: $e');
    }
  }

  Future<void> retranslate(TranslateLanguage requestedTarget) async {
    final current = state.result;
    if (current == null) return;
    state = TranslationState(busy: true, result: current);
    try {
      await _translate(
        current.recognized,
        current.source,
        requestedTarget,
        imagePath: current.imagePath,
      );
    } catch (e) {
      state = TranslationState(result: current, error: 'Translation failed: $e');
    }
  }

  /// Update recognized text manually (e.g. user corrected a character) and retranslate
  Future<void> updateTextAndRetranslate(String newText) async {
    final current = state.result;
    if (current == null) return;
    state = TranslationState(busy: true, result: current);
    try {
      await _translate(
        newText,
        current.source,
        current.target,
        imagePath: current.imagePath,
      );
    } catch (e) {
      state = TranslationState(result: current, error: 'Translation failed: $e');
    }
  }

  /// Swap source and target languages (vice-versa)
  Future<void> swapLanguages() async {
    final current = state.result;
    if (current == null) return;
    state = TranslationState(busy: true, result: current);
    try {
      await _translate(
        current.translated, // Use previous translation as the new source
        current.target,     // Swap source
        current.source,     // Swap target
        imagePath: current.imagePath,
      );
    } catch (e) {
      state = TranslationState(result: current, error: 'Translation swap failed: $e');
    }
  }

  Future<void> _translate(
    String text,
    TranslateLanguage source,
    TranslateLanguage requestedTarget, {
    String? imagePath,
  }) async {
    final target = effectiveTarget(source, requestedTarget);
    final translated = await ref
        .read(translationServiceProvider)
        .translate(text, from: source, to: target);
    state = TranslationState(
      result: TranslationResult(
        imagePath: imagePath,
        recognized: text,
        translated: translated,
        source: source,
        target: target,
      ),
    );
  }
}

final translationControllerProvider =
    NotifierProvider<TranslationController, TranslationState>(
        TranslationController.new);