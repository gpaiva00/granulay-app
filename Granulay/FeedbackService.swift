import Foundation

enum FeedbackServiceError: LocalizedError {
    case invalidURL
    case missingApiKey
    case invalidResponse(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid feedback endpoint URL"
        case .missingApiKey:
            return "Missing Resend API key"
        case .invalidResponse(let statusCode):
            return "Invalid response status code: \(statusCode)"
        }
    }
}

enum FeedbackService {
    static func sendFeedback(message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://api.resend.com/emails") else {
            completion(.failure(FeedbackServiceError.invalidURL))
            return
        }

        let apiKey = Bundle.main.infoDictionary?["ResendApiKey"] as? String ?? ""
        guard !apiKey.isEmpty else {
            completion(.failure(FeedbackServiceError.missingApiKey))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        let emailBody = """
        <p><strong>Feedback do Granulay:</strong></p>
        <p>\(message)</p>
        <hr>
        <p><small>Versão do App: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")<br>Sistema: \(osVersion)</small></p>
        """

        let emailData: [String: Any] = [
            "from": "Granulay <support@granulay.com.br>",
            "to": ["support@granulay.com.br"],
            "subject": "Feedback do Granulay",
            "html": emailBody,
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: emailData)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(FeedbackServiceError.invalidResponse(statusCode: -1)))
                return
            }

            guard (200...299).contains(response.statusCode) else {
                completion(.failure(FeedbackServiceError.invalidResponse(statusCode: response.statusCode)))
                return
            }

            completion(.success(()))
        }.resume()
    }
}
