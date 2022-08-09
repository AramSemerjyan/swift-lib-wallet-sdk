import Alamofire
import Foundation

enum OAuthApiRequestRouter {
    // POST
    case login(PSUserLoginRequest)
    case refreshToken(PSRefreshTokenRequest)
    case getPartnerTokens(PSPartnerTokensRequest)

    // PUT
    case activate(accessToken: String)
    
    // Delete
    case revoke(accessToken: String)

    private static let baseURL = URL(string: "https://wallet-api.paysera.com/oauth/v1")!
    
    private var method: HTTPMethod {
        switch self {
        case .login,
             .refreshToken,
             .getPartnerTokens:
            return .post
            
        case .activate:
            return .put
            
        case .revoke:
            return .delete
        }
    }
    
    private var path: String {
        switch self {
        case .login,
             .refreshToken,
             .revoke:
            return "token"
            
        case .activate(let accessToken):
            return "tokens/\(accessToken)/activate"
            
        case .getPartnerTokens:
            return "partner-tokens"
        }
    }
    
    private var parameters: Parameters? {
        switch self {
        case .refreshToken(let params):
            return params.toJSON()
            
        case .login(let userLoginData):
            return userLoginData.toJSON()
            
        case .revoke(let accessToken):
            return ["access_token": accessToken]
            
        case .getPartnerTokens(let partnerData):
            return partnerData.toJSON()
            
        default:
            return nil
        }
    }
}

// MARK: - URLRequestConvertible

extension OAuthApiRequestRouter: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let url = Self.baseURL.appendingPathComponent(path)
        var urlRequest = URLRequest(url: url)
        urlRequest.method = method
        
        switch self {
        case .refreshToken,
             .revoke,
             .login,
             .activate,
             .getPartnerTokens:
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        }
        
        return urlRequest
    }
}
