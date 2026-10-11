//
//  TranslationService.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 1/2/26.
//

import Foundation

protocol TranslationService {
    func translate(text: String, targetLang: String, sourceLang: String? ) async throws -> String
}
final class DeepLTranslationService: TranslationService {
    enum DeepLError: Error { case badURL, badResponse(Int), empty }

    private let apiKey: String
    private let baseURL: String
    private let urlSession: URLSession

    init(apiKey: String, isFreePlan: Bool = true, urlSession: URLSession = .shared) {
        self.apiKey = apiKey
        self.baseURL = isFreePlan ? "https://api-free.deepl.com" : "https://api.deepl.com"
        self.urlSession = urlSession
    }

    func translate(text: String, targetLang: String, sourceLang: String? = nil) async throws -> String {
        guard let url = URL(string: "\(baseURL)/v2/translate") else { throw DeepLError.badURL }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.setValue("DeepL-Auth-Key \(apiKey)", forHTTPHeaderField: "Authorization")

        var comps: [URLQueryItem] = [
            .init(name: "text", value: text),
            .init(name: "target_lang", value: targetLang.uppercased())
        ]

        if let sourceLang {
            comps.append(.init(name: "source_lang", value: sourceLang.uppercased()))
        }

        var body = URLComponents()
        body.queryItems = comps
        req.httpBody = body.query?.data(using: .utf8)

        let (data, resp) = try await urlSession.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw DeepLError.empty }
        guard (200...299).contains(http.statusCode) else { throw DeepLError.badResponse(http.statusCode) }

        struct Response: Decodable {
            struct Translation: Decodable { let text: String }
            let translations: [Translation]
        }

        let decoded = try JSONDecoder().decode(Response.self, from: data)
        return decoded.translations.first?.text ?? ""
    }
}
