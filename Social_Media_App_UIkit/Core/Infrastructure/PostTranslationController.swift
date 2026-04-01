//
//  PostTranslationController.swift
//  Social_Media_App_UIkit
//
//  Created by Codex on 3/31/26.
//

import Foundation
import Combine

protocol PostTranslationControlling: AnyObject {
    var translationsPublisher: AnyPublisher<[UUID: TranslationState], Never> { get }
    var onError: ((String) -> Void)? { get set }
    func toggle(postId: UUID, text: String)
}

final class PostTranslationController: ObservableObject, PostTranslationControlling {
    @Published private(set) var translations: [UUID: TranslationState] = [:]

    var onError: ((String) -> Void)?

    private let service: any TranslationService
    private let targetLanguage: String

    var translationsPublisher: AnyPublisher<[UUID: TranslationState], Never> {
        $translations.eraseToAnyPublisher()
    }

    init(service: any TranslationService, targetLanguage: String = "EN") {
        self.service = service
        self.targetLanguage = targetLanguage
    }

    @MainActor
    func toggle(postId: UUID, text: String) {
        var state = translations[postId] ?? TranslationState()

        if state.isShowingTranslation {
            state.isShowingTranslation = false
            translations[postId] = state
            return
        }

        if state.translatedText != nil {
            state.isShowingTranslation = true
            translations[postId] = state
            return
        }

        state.isLoading = true
        translations[postId] = state

        Task { [weak self] in
            guard let self else { return }

            do {
                let translatedText = try await self.service.translate(
                    text: text,
                    targetLang: self.targetLanguage,
                    sourceLang: nil
                )

                await MainActor.run {
                    var updated = self.translations[postId] ?? TranslationState()
                    updated.translatedText = translatedText
                    updated.isShowingTranslation = true
                    updated.isLoading = false
                    self.translations[postId] = updated
                }
            } catch {
                await MainActor.run {
                    self.translations[postId] = nil
                    self.onError?("Error translating post. Please try again later.")
                }
            }
        }
    }
}
