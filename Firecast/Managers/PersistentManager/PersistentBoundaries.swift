protocol saveCredentialsBoundaries {
    func saveGoogle(idToken: String, accessToken: String, email: String)
    func saveFaceBook(token: String, email: String)
    func saveTwitter(authToken: String, authTokenSecret: String, email: String)
    func savePhone(_ phoneNo: String, verificationID: String, verificationCode: String)
}

protocol deleteCredentialsBoundaries {
    func deleteGoogleLoginCredentialsFor(email: String)
    func deleteFaceBookLoginCredentialsFor(email: String)
    func deleteTwitterLoginCredentialsFor(email: String)
    func deletePhoneLoginCredentialsFor(_ phoneNo: String)
}

protocol getCredentialsBoundaries {
    func getGoogleLoginCredentialsFor(email: String) -> (String, String)?
    func getFaceBookLoginCredentialsFor(email: String) -> String?
    func getTwitterLoginCredentialsFor(email: String) -> (String, String)?
    func getPhoneLoginCredentialsFor(phone: String) -> (String, String)?
}

typealias  PersistentBoundaries = saveCredentialsBoundaries & deleteCredentialsBoundaries & getCredentialsBoundaries

