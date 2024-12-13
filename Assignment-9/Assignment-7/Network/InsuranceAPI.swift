import Foundation

func fetchInsuranceData() async throws -> [Insurance] {
    guard let url = URL(string: "https://675c726bfe09df667f63ed91.mockapi.io/api/v1/Insurance") else {
        throw URLError(.badURL)
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else
    {
        if let httpResponse = response as? HTTPURLResponse {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        } else {
            throw NetworkError.invalidResponse
        }
    }
    
    let insuranceData = try decoder.decode([Insurance].self, from: data)
    return insuranceData
}

func addInsuranceData(insurance: Insurance) async throws -> Insurance {
    guard let url = URL(string: "https://675c726bfe09df667f63ed91.mockapi.io/api/v1/Insurance") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField:"Content-Type")
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .formatted(dateFormatter)
    
    
    let requestBody = """
        {
            "customer_id": \(insurance.customer_id),
            "policy_type": "\(insurance.policy_type)",
            "premium_amount": \(insurance.premium_amount),
            "start_date": "\(dateFormatter.string(from: insurance.start_date))",
            "end_date": "\(dateFormatter.string(from: insurance.end_date))"
        }
        """
    guard let bodyData = requestBody.data(using: .utf8) else {
        throw URLError(.cannotParseResponse)
    }
    request.httpBody = bodyData
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
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
    let newInsurance = try decoder.decode(Insurance.self, from: data)
    return newInsurance
}
func updateInsuranceData(_ insurance: Insurance) async throws -> Insurance {
    guard let url = URL(string: "https://675c726bfe09df667f63ed91.mockapi.io/api/v1/Insurance/\(insurance.id)") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField:"Content-Type")
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    
    let requestBody = """
        {
            "id": "\(insurance.id)",
            "customer_id": \(insurance.customer_id),
            "policy_type": "\(insurance.policy_type)",
            "premium_amount": \(insurance.premium_amount),
            "start_date": "\(dateFormatter.string(from: insurance.start_date))",
            "end_date": "\(dateFormatter.string(from: insurance.end_date))"
        }
        """
    print(requestBody)
    guard let bodyData = requestBody.data(using: .utf8) else {
        throw URLError(.cannotParseResponse)
    }
    request.httpBody = bodyData
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
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
    let newInsurance = try decoder.decode(Insurance.self, from: data)
    return newInsurance
}

func deleteInsuranceData(_ id: Int) async throws -> Bool {
    
    guard let url = URL(string: "https://675c726bfe09df667f63ed91.mockapi.io/api/v1/Insurance/\(id)") else {
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
        print("URL Error:", error) // Or use a more robust logging mechanism
        throw error
    } catch {
        print("Other Error:", error) // Or use a more robust logging mechanism
        throw error
    }
}

struct ErrorResponse: Decodable {
    let message: String
}

enum NetworkError: Error {
    case httpError(statusCode: Int, message: String? = nil)
    case invalidResponse
}
