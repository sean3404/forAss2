//
//  spoonacular.swift
//  HomT
//
//  Created by Sean on 31/5/20.
//  Copyright © 2020 Changkeun Hyun. All rights reserved.
//

import Foundation
class Spoonacular : NSObject{
    public var recipes = [Recipe]()
    public var favRecipes = [String:Date]()
    var session = URLSession.shared
    
    override init() {
        super.init()
    }
    
    func createURLFromParameters(_ parameters: [String:AnyObject], withSubdomain: String? = nil,withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Spoonacular.Constants.ApiScheme
        components.host = (withSubdomain ?? "") + Spoonacular.Constants.ApiHost
        components.path = (withPathExtension ?? "")
        if parameters.count > 0{
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
    
    func taskForGETMethod(_ Subdomain:String, method: String, parameters: [String:AnyObject],  completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var urlParameters = parameters
        
        let request = NSMutableURLRequest(url: createURLFromParameters(urlParameters, withSubdomain: Subdomain, withPathExtension: method))
        print(request.url!)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        task.resume()
        
        return task
    }
    
    func convertDataWithCompletionHandler(_ data: Data,  completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    class func sharedInstance() -> Spoonacular {
        struct Singleton {
            static var sharedInstance = Spoonacular()
        }
        return Singleton.sharedInstance
    }
}
