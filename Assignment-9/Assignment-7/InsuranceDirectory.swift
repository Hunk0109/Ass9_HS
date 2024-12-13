import Foundation
class InsuranceDirectory{
    private var insurance: [Insurance]
    private var customer: [Customer]
    private var claims: [Claim]
    static let insuranceTypes: [String] = ["Auto", "Home", "Life", "Health", "Travel"]
    static let claimStatus: [String] = ["Pending","Approved","Denied"]
    static let paymentMethod:[String] = ["Cash","Credit","Bank Transfer"]
    static let paymentStatus:[String] = ["Pending","Processed","Failed"]
    
    static let profileImage:String = "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"
    private var dbHelper: DatabaseHelper
    
    private init (){
        self.dbHelper = DatabaseHelper()
        self.customer = dbHelper.readCustomers()
        self.insurance = dbHelper.readInsurances()
        self.claims = dbHelper.getCliams()
        Task{
            do {
                let insurance = try await fetchInsuranceData()
                let customers = try await fetchCustomerData()
                
                self.insurance = insurance
                self.customer = customers
                print("Data fetched successfully....")
            } catch {
                print("Error fetching insurance data: \(error)")
            }
        }
        populateClaims()
        populatePayments()
    }
    static let shared = InsuranceDirectory()
    
    func addInsurance(i: Insurance) async->Bool{
        let c = customer.first(where: { $0.id == i.customer_id })!
        
        do {
            let policy = try await addInsuranceData(insurance: i)
            print("Insurance added successfully, type:", policy.policy_type)
            self.insurance.append(policy)
            c.pastPolicies = true
            if await updateCustomer(update:c){
                return true
            } else {
                return false
            }
        } catch NetworkError.invalidResponse{
            print("Invalid response")
        } catch NetworkError.httpError(let statusCode, let message){
            print("Message \(String(describing: message)), Status Code \(statusCode)")
        } catch{
            print("Error")
        }
        return false
        
    }
    
    func addCustomer(customer: Customer) async -> Bool{
        do{
            let c = try await createCustomerData(customer)
            self.customer.append(c!)
            return true
        } catch NetworkError.invalidResponse{
            print("Invalid response")
        } catch NetworkError.httpError(statusCode: let statusCode, message: let message){
            print("Message \(String(describing: message)), Status Code \(statusCode)")
        } catch{
            print("Error")
        }
        return false
    }
    func getInsurance(id: Int) -> Insurance?{
        return insurance.first(where: { $0.id == id })
    }
    func getCustomer(id: Int) -> Customer?{
        return customer.first(where: { $0.id == id })
    }
    func getInsurances() -> [Insurance]{
        return insurance
    }
    func deleteInsurance(id: Int)async ->Bool{
        do{
            let _ = try await deleteInsuranceData(id)
            insurance.removeAll(where: { $0.id == id })
            NotificationCenter.default.post(name: Notification.Name("InsuranceDataUpdated"), object: nil)
            return true
        } catch NetworkError.invalidResponse{
            print("Invalid response")
        } catch NetworkError.httpError(statusCode: let statusCode, message: let message){
            print("Message \(String(describing: message)), Status Code \(statusCode)")
        } catch{
            print("Error")
        }
        
        return false
    }
    func updateInsurance(update: Insurance) async->Bool{
        
        do {
            let policy = try await updateInsuranceData(update)
            let a = insurance.first(where: { $0.id == update.id })!
            a.policy_type = update.policy_type
            a.premium_amount = update.premium_amount
            a.end_date = update.end_date
            
            NotificationCenter.default.post(name: Notification.Name("InsuranceDataUpdated"), object: nil)
            print("Insurance updated successfully, type:", policy.policy_type)
            return true
        } catch NetworkError.invalidResponse{
            print("Invalid response")
        } catch NetworkError.httpError(let statusCode, let message){
            print("Message \(String(describing: message)), Status Code \(statusCode)")
        } catch{
            print("Error")
        }
        return false
        
    }
    func getCustomers() -> [Customer]{
        return customer
    }
    func updateCustomer(update: Customer)async ->Bool{
        do {
            let _ = try await updateCustomerData(update)
            let a = customer.first(where: { $0.id == update.id })!
            a.name = update.name
            a.age = update.age
            NotificationCenter.default.post(name: Notification.Name("CustomerDataUpdated"), object: nil)
            return true
            
        }catch NetworkError.invalidResponse{
            print("Invalid response")
        } catch NetworkError.httpError(let statusCode, let message){
            print("Message \(String(describing: message)), Status Code \(statusCode)")
        } catch{
            print("Error")
        }
        return false
    }
    func deleteCustomer(id: Int) async->Bool{
        do{
            let _ = try await deleteCustomerData(id)
            customer.removeAll(where: { $0.id == id })
            NotificationCenter.default.post(name: Notification.Name("CustomerDataUpdated"), object: nil)
            return true
        }catch NetworkError.invalidResponse{
            print("Invalid response")
        } catch NetworkError.httpError(let statusCode, let message){
            print("Message \(String(describing: message)), Status Code \(statusCode)")
        } catch{
            print("Error")
        }
        return false
    }
    
    func addClaim(claim: Claim)async throws ->Bool {
        let i = getInsurance(id: claim.policy_id)
        guard let i = i else {
            return false
        }
        do{
            let c = try await addClaimData(claim)
            i.claims.append(c)
            return true
        }catch NetworkError.invalidResponse{
            print("Invalid response")
        } catch NetworkError.httpError(let statusCode, let message){
            print("Message \(String(describing: message)), Status Code \(statusCode)")
        } catch{
            print("Error")
        }
        return false
        
    }
    
    func getClaims(clm:customClaim) -> Claim{
        let i = getInsurance(id: clm.policy_id)
        let c = i?.claims.first(where: { $0.id == clm.claim_id })
        return c!
    }
    func getClaims() -> [Claim]{
        return claims
    }
    func deleteClaim(clm:customClaim)async throws->Bool{
        let i = getInsurance(id: clm.policy_id)
        do{
            let result = try await deleteClaimData(clm.claim_id)
            if result{ 
                i?.claims.removeAll(where: { $0.id == clm.claim_id })
                self.claims.removeAll(where: { $0.id == clm.claim_id })
                return true
            }
            return false
        }catch NetworkError.invalidResponse{
            print("Invalid response")
        } catch NetworkError.httpError(let statusCode, let message){
            print("Message \(String(describing: message)), Status Code \(statusCode)")
        } catch{
            print("Error")
        }
        return false
    }
    
    func addPayment(payment: Payment)async throws ->Bool {
        let i = getInsurance(id: payment.policy_id)
        guard let i = i else {
            return false
        }
        do{
            let p = try await addPaymentData(payment)
            i.payments.append(p)
            return true
        }catch NetworkError.invalidResponse{
            print("Invalid response")
        } catch NetworkError.httpError(let statusCode, let message){
            print("Message \(String(describing: message)), Status Code \(statusCode)")
        } catch{
            print("Error")
        }
        return false
    }
    
    func getPayments(pay:customPayment) -> Payment{
        let i = getInsurance(id: pay.policy_id)
        let p = i?.payments.first(where: { $0.id == pay.payment_id })
        return p!
    }
    
    func deletePayment(pay:customPayment)async throws->Bool{
        let i = getInsurance(id: pay.policy_id)
        do{
            let result = try await deletePaymentData(pay.payment_id)
            i?.payments.removeAll(where: { $0.id == pay.payment_id })
            return true
        }catch NetworkError.invalidResponse{
            print("Invalid response")
        } catch NetworkError.httpError(let statusCode, let message){
            print("Message \(String(describing: message)), Status Code \(statusCode)")
        } catch{
            print("Error")
        }
        return false
    }
    
    func updateClaim(claim: Claim)async->Bool{
        do{
            let _ = try await updateClaimData(claim)
            guard let i = getInsurance(id: claim.policy_id) else {
                return false
            }
            let cl = i.claims.first(where: { $0.id == claim.id })!
            cl.status = claim.status
            cl.claim_amount = claim.claim_amount
            return true
        }catch NetworkError.invalidResponse{
            print("Invalid response")
        } catch NetworkError.httpError(let statusCode, let message){
            print("Message \(String(describing: message)), Status Code \(statusCode)")
        } catch{
            print("Error")
        }
        return false
    }
    func updatePayment(payment: Payment)async throws->Bool{
        do{
            let result = try await updatePaymentData(payment)
            guard let i = getInsurance(id: payment.policy_id) else {
                return false
            }
            let p = i.payments.first(where: { $0.id == payment.id })!
            p.payment_amount = result.payment_amount
            p.payment_method = result.payment_method
            p.status = result.status
            return true
        }catch NetworkError.invalidResponse{
            print("Invalid response")
        } catch NetworkError.httpError(let statusCode, let message){
            print("Message \(String(describing: message)), Status Code \(statusCode)")
        } catch{
            print("Error")
        }
        return false
        
    }
    func populateClaims(){
        print("Populating Claims")
        for c in self.claims{
            guard let i = getInsurance(id: c.policy_id) else{
                continue
            }
            i.claims.append(c)
        }
    }
    func populatePayments(){
        let payments = dbHelper.getPayments()
        print("Populating Payments")
        for p in payments{
            guard let i = getInsurance(id: p.policy_id) else{
                continue
            }
            i.payments.append(p)
        }
    }
}
class Insurance: Codable {
    var id: Int
    var customer_id: Int
    var policy_type: String
    var premium_amount: Double
    var start_date: Date
    var end_date: Date
    var claims: [Claim]
    var payments: [Payment]
    
    enum CodingKeys: String, CodingKey {
        case id, customer_id, policy_type, premium_amount, start_date, end_date, claims, payments
    }
    
    init(id: Int, customer_id: Int, policy_type: String, premium_amount: Double, start_date: Date, end_date: Date, claims: [Claim] = [], payments: [Payment] = []) {
        self.id = id
        self.customer_id = customer_id
        self.policy_type = policy_type
        self.premium_amount = premium_amount
        self.start_date = start_date
        self.end_date = end_date
        self.claims = claims
        self.payments = payments
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let idString = try container.decode(String.self, forKey: .id)
        guard let id = Int(idString) else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "ID is not a valid integer")
        }
        self.id = id
        self.customer_id = try container.decode(Int.self, forKey: .customer_id)
        self.policy_type = try container.decode(String.self, forKey: .policy_type)
        self.premium_amount = try container.decode(Double.self, forKey: .premium_amount)
        self.start_date = try container.decode(Date.self, forKey: .start_date)
        self.end_date = try container.decode(Date.self, forKey: .end_date)
        
        // Handle potential decoding errors or mismatched types
        self.claims = (try? container.decode([Claim].self, forKey: .claims)) ?? []
        self.payments = (try? container.decode([Payment].self, forKey: .payments)) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(id), forKey: .id)
        try container.encode(customer_id, forKey: .customer_id)
        try container.encode(policy_type, forKey: .policy_type)
        try container.encode(premium_amount, forKey: .premium_amount)
        try container.encode(start_date, forKey: .start_date)
        try container.encode(end_date, forKey: .end_date)
        try container.encode(claims, forKey: .claims)
        try container.encode(payments, forKey: .payments)
    }
}

class Customer: Codable {
    var id: Int
    var name: String
    var age: Int
    var email: String
    var pastPolicies: Bool
    var profileImage: String?

    init(id: Int, name: String, age: Int, email: String, pastPolicies: Bool = false, profileImage: String? = nil) {
        self.id = id
        self.name = name
        self.age = age
        self.email = email
        self.pastPolicies = pastPolicies
        self.profileImage = profileImage
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, age, email, pastPolicies, profileImage
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Convert `id` from String to Int
        let idString = try container.decode(String.self, forKey: .id)
        guard let id = Int(idString) else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "ID is not a valid integer")
        }
        self.id = id
        self.name = try container.decode(String.self, forKey: .name)
        self.age = try container.decode(Int.self, forKey: .age)
        self.email = try container.decode(String.self, forKey: .email)
        self.pastPolicies = try container.decode(Bool.self, forKey: .pastPolicies)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Convert `id` from Int to String
        try container.encode(String(id), forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(age, forKey: .age)
        try container.encode(email, forKey: .email)
        try container.encode(pastPolicies, forKey: .pastPolicies)
        try container.encode(profileImage, forKey: .profileImage)
    }
}


class Claim: Codable {
    var id: Int
    var policy_id: Int
    var claim_amount: Double
    var date_of_claim: Date
    var status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case policy_id = "policyId"  // Map `policyId` to `policy_id`
        case claim_amount
        case date_of_claim
        case status
    }
    
    init(id: Int, policy_id: Int, claim_amount: Double, date_of_claim: Date, status: String) {
        self.id = id
        self.policy_id = policy_id
        self.claim_amount = claim_amount
        self.date_of_claim = date_of_claim
        self.status = status
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle `id` as String or Int
        if let idString = try? container.decode(String.self, forKey: .id), let id = Int(idString) {
            self.id = id
        } else {
            self.id = try container.decode(Int.self, forKey: .id)
        }
        
        self.policy_id = try container.decode(Int.self, forKey: .policy_id)
        self.claim_amount = try container.decode(Double.self, forKey: .claim_amount)
        self.date_of_claim = try container.decode(Date.self, forKey: .date_of_claim)
        self.status = try container.decode(String.self, forKey: .status)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(String(id), forKey: .id)  // Encode `id` as String
        try container.encode(policy_id, forKey: .policy_id)
        try container.encode(claim_amount, forKey: .claim_amount)
        try container.encode(date_of_claim, forKey: .date_of_claim)
        try container.encode(status, forKey: .status)
    }
}

class Payment: Codable {
    var id: Int
    var policy_id: Int
    var payment_amount: Double
    var payment_date: Date
    var payment_method: String
    var status: String

    // Custom CodingKeys to handle mismatched API keys and id type
    enum CodingKeys: String, CodingKey {
        case id
        case policy_id = "policyId"
        case payment_amount
        case payment_date
        case payment_method
        case status
    }

    // Custom initializer
    init(id: Int, policy_id: Int, payment_amount: Double, payment_date: Date, payment_method: String, status: String) {
        self.id = id
        self.policy_id = policy_id
        self.payment_amount = payment_amount
        self.payment_date = payment_date
        self.payment_method = payment_method
        self.status = status
    }

    // Decoding initializer to handle 'id' as String in API response
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Convert 'id' from String to Int
        let idString = try container.decode(String.self, forKey: .id)
        guard let id = Int(idString) else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "ID is not a valid integer")
        }
        self.id = id

        // Decode other properties
        self.policy_id = try container.decode(Int.self, forKey: .policy_id)
        self.payment_amount = try container.decode(Double.self, forKey: .payment_amount)

        // Handle date decoding with a custom date format
        let dateString = try container.decode(String.self, forKey: .payment_date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"  // Adjust this format if needed based on your API response
        guard let date = formatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(forKey: .payment_date, in: container, debugDescription: "Invalid date format")
        }
        self.payment_date = date

        self.payment_method = try container.decode(String.self, forKey: .payment_method)
        self.status = try container.decode(String.self, forKey: .status)
    }

    // Encoding method to convert 'id' from Int to String
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Convert 'id' to String for encoding
        try container.encode(String(id), forKey: .id)

        // Encode other properties
        try container.encode(policy_id, forKey: .policy_id)
        try container.encode(payment_amount, forKey: .payment_amount)

        // Encode date with custom formatter
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        try container.encode(formatter.string(from: payment_date), forKey: .payment_date)

        try container.encode(payment_method, forKey: .payment_method)
        try container.encode(status, forKey: .status)
    }
}

class customClaim{
    var claim_id: Int
    let policy_id: Int
    init(claim_id: Int, policy_id: Int) {
        self.claim_id = claim_id
        self.policy_id = policy_id
    }
}

class customPayment{
    let payment_id: Int
    let policy_id: Int
    init(payment_id: Int, policy_id: Int) {
        self.payment_id = payment_id
        self.policy_id = policy_id
    }
}

