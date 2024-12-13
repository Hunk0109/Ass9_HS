import Foundation


func addClaimData(_ newClaim: Claim)async throws -> Claim {
    guard let url = URL(string: "https://675c965dfe09df667f644778.mockapi.io/Claims") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField:"Content-Type")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let requestBody = """
    {
        "policyId": \(newClaim.policy_id),
        "claim_amount": \(newClaim.claim_amount),
        "date_of_claim": "\(dateFormatter.string(from: newClaim.date_of_claim))",
        "status": "\(newClaim.status)"
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
    
    let nClaim = try decoder.decode(Claim.self, from: data)
    return nClaim
}

func updateClaimData(_ updatedClaim: Claim)async throws -> Claim {
    guard let url = URL(string: "https://675c965dfe09df667f644778.mockapi.io/Claims/\(updatedClaim.id)") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField:"Content-Type")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let requestBody = """
    {
        "id": \(updatedClaim.id),
        "policyId": \(updatedClaim.policy_id),
        "claim_amount": \(updatedClaim.claim_amount),
        "date_of_claim": "\(dateFormatter.string(from: updatedClaim.date_of_claim))",
        "status": "\(updatedClaim.status)"
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
    
    let nClaim = try decoder.decode(Claim.self, from: data)
    return nClaim

}

func deleteClaimData(_ claimId: Int)async throws -> Bool {
    guard let url = URL(string: "https://675c965dfe09df667f644778.mockapi.io/Claims/\(claimId)") else {
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
