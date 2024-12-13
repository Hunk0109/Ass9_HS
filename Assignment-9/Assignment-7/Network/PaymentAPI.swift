import Foundation

func addPaymentData(_ payment: Payment)async throws -> Payment {
    guard let url = URL(string: "https://675c965dfe09df667f644778.mockapi.io/Payment") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField:"Content-Type")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let requestBody = """
    {
        "policyId": \(payment.policy_id),
        "payment_amount": \(payment.payment_amount),
        "payment_date": "\(dateFormatter.string(from: payment.payment_date))",
        "payment_method": "\(payment.payment_method)",
        "status": "\(payment.status)"
    }
"""
    guard let bodyData = requestBody.data(using: .utf8) else {
        throw URLError(.cannotParseResponse)
    }
    request.httpBody = bodyData
    
    let(data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
        if let httpResponse = response as? HTTPURLResponse
        {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: errorResponse.message)
            } else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: "Server error")
            }
        } else {
            throw NetworkError.invalidResponse
        }
    }
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    let payment = try decoder.decode(Payment.self, from: data)
    return payment
}
func updatePaymentData(_ payment: Payment)async throws -> Payment {
    guard let url = URL(string: "https://675c965dfe09df667f644778.mockapi.io/Payment/\(payment.id)") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField:"Content-Type")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let requestBody = """
    {
        "id": \(payment.id),
        "policyId": \(payment.policy_id),
        "payment_amount": \(payment.payment_amount),
        "payment_date": "\(dateFormatter.string(from: payment.payment_date))",
        "payment_method": "\(payment.payment_method)",
        "status": "\(payment.status)"
    }
"""
    guard let bodyData = requestBody.data(using: .utf8) else {
        throw URLError(.cannotParseResponse)
    }
    request.httpBody = bodyData
    
    let(data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
        if let httpResponse = response as? HTTPURLResponse
        {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: errorResponse.message)
            } else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: "Server error")
            }
        } else {
            throw NetworkError.invalidResponse
        }
    }
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    let payment = try decoder.decode(Payment.self, from: data)
    return payment
}

func deletePaymentData(_ id: Int) async throws -> Bool {
    guard let url = URL(string: "https://675c965dfe09df667f644778.mockapi.io/Payment/\(id)") else {
        throw URLError(.badURL)
    }
    print(url.absoluteString)
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
            
        }
        
        switch httpResponse.statusCode {
        case 200...299, 204:
            return true
        default:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: errorResponse.message)
            } else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: "Server error")
            }
        }
        
    } catch let error as URLError {
        print("URL Error:", error)
        throw error
    } catch {
        print("Other Error:", error)
        throw error
    }
}
