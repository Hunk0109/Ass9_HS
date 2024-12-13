import Foundation

func fetchCustomerData() async throws -> [Customer] {
    
    guard let url = URL(string: "https://675c726bfe09df667f63ed91.mockapi.io/api/v1/Customer") else {
        throw URLError(.badURL)
    }
    
    let(data, response) = try await URLSession.shared.data(from: url)
    print(response)
    let decoder = JSONDecoder()
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else
    {
        if let httpResponse = response as? HTTPURLResponse {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        } else {
            throw NetworkError.invalidResponse
        }
    }
    
    
        let customerData = try decoder.decode([Customer].self, from: data)
        print("Decoded Customer Data: \(customerData)")
        return customerData

}

func createCustomerData(_ customer: Customer) async throws -> Customer? {
    guard let url = URL(string: "https://675c726bfe09df667f63ed91.mockapi.io/api/v1/Customer") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let profileImageLocaction = customer.profileImage ?? ""
    
    let requestBody = """
    {
        "name": "\(customer.name)",
        "age": \(customer.age),
        "email": "\(customer.email)",
        "profileImage": "\(profileImageLocaction)"
    }
    """
    guard let bodyData = requestBody.data(using: .utf8) else {
        throw URLError(.cannotParseResponse)
    }
    request.httpBody = bodyData
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.invalidResponse
    }
    
    switch httpResponse.statusCode {
    case 200...299: // Success
        if data.isEmpty {
            print("No response body. Assuming success.")
            return nil // No data to decode
        }
        let decoder = JSONDecoder()
        let createdCustomer = try decoder.decode(Customer.self, from: data)
        return createdCustomer
    default:
        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: errorResponse.message)
        } else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: "Server error")
        }
    }
}


func updateCustomerData(_ customer: Customer) async throws -> Customer {
    guard let url = URL(string: "https://675c726bfe09df667f63ed91.mockapi.io/api/v1/Customer/\(customer.id)") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField:"Content-Type")
    let profileImageLocaction = customer.profileImage ?? ""
    print(profileImageLocaction)
    let requestBody = """
    {
        "id": \(customer.id),
        "name": "\(customer.name)",
        "age": \(customer.age),
        "email": "\(customer.email)",
        "pastPolicies": \(customer.pastPolicies),
        "profileImage": "\(profileImageLocaction)"
    }
"""
    print(requestBody)
    guard let bodyData = requestBody.data(using: .utf8) else {
        throw URLError(.cannotParseResponse)
    }
    request.httpBody = bodyData
    
    let(data, response) = try await URLSession.shared.data(for: request)
    
    let decoder = JSONDecoder()
    
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else
    {
        if let httpResponse = response as? HTTPURLResponse {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        } else {
            throw NetworkError.invalidResponse
        }
    }
    
    let customerData = try decoder.decode(Customer.self, from: data)
    return customerData
    
}

func deleteCustomerData(_ id:Int) async throws -> Bool {
    guard let url = URL(string: "https://675c726bfe09df667f63ed91.mockapi.io/api/v1/Customer/\(id)") else {
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
