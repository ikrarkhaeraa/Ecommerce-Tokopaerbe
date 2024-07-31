import Foundation

func hitApi<responseClass: Codable, requestClass: Codable>(requestBody: requestClass, urlApi: String, methodApi: String, token: String, type: String ,completion: @escaping (Bool, GeneralResponse<responseClass>?) -> Void) {
    
    var fixedUrl = urlApi
    
    if type.contains("product detail") {
        let productDetailRequest = requestBody as! ProductDetailRequest
        fixedUrl = "\(urlApi)/\(productDetailRequest.id)"
    } else if type.contains("review") {
        let reviewRequest = requestBody as! ReviewRequest
        fixedUrl = "\(urlApi)/\(reviewRequest.id)"
    }
    
    guard var urlComponents = URLComponents(string: fixedUrl) else {
            completion(false, nil)
            return
        }
    
    // Add query parameters if URL contains "products"
       if type.contains("products") {
           let productsQuery = requestBody as! ProductsQuery
           var queryItems = [URLQueryItem]()
           // Add your query parameters here
           if productsQuery.search != nil {
               queryItems.append(URLQueryItem(name: "search", value: "\(productsQuery.search!)"))
           }
           if productsQuery.brand != nil {
               queryItems.append(URLQueryItem(name: "brand", value: "\(productsQuery.brand!)"))
           }
           if productsQuery.lowest != nil {
               queryItems.append(URLQueryItem(name: "lowest", value: "\(productsQuery.lowest!)"))
           }
           if productsQuery.highest != nil {
               queryItems.append(URLQueryItem(name: "highest", value: "\(productsQuery.highest!)"))
           }
           if productsQuery.sort != nil {
               queryItems.append(URLQueryItem(name: "sort", value: "\(productsQuery.sort!)"))
           }
           if productsQuery.limit != nil {
               queryItems.append(URLQueryItem(name: "limit", value: "\(productsQuery.limit!)"))
           }
           if productsQuery.page != nil {
               queryItems.append(URLQueryItem(name: "page", value: "\(productsQuery.page!)"))
           }
           urlComponents.queryItems = queryItems
       }
    
    
    if type.contains("search") {
        let searchQuery = requestBody as! SearchQuery
        Log.d("\(searchQuery.query!)")
        var queryItems = [URLQueryItem]()
        // Add your query parameters here
        if searchQuery.query != nil {
            queryItems.append(URLQueryItem(name: "query", value: "\(searchQuery.query!)"))
        }
        urlComponents.queryItems = queryItems
    }
    
    guard let url = urlComponents.url else {
           completion(false, nil)
           return
       }
    
    var request = URLRequest(url: url)
    var body = Data()
    let boundary = UUID().uuidString
    
    request.httpMethod = methodApi
    
    if type.contains("profile") {
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    } else {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    request.addValue("6f8856ed-9189-488f-9011-0ff4b6c08edc", forHTTPHeaderField: "API_KEY")
    
    if (!type.contains("register") || !type.contains("login")) {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    if (type.contains("profile")) {
        let requestProfile = requestBody as! ProfileBody
        let username = requestProfile.userName
        let userimage = requestProfile.userImage
        
        // Add userName parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"userName\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(username)\r\n".data(using: .utf8)!)
        
        // Add userImage parameter if it exists
        if userimage != nil {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"userImage\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append("\(userimage!)\r\n".data(using: .utf8)!)
        }
        
        // Close the multipart form data
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
    }

    Log.d("\(url)")

    do {
        
        if methodApi != "GET" {
            let jsonData = try JSONEncoder().encode(requestBody)
            
            if (!fixedUrl.contains("profile")) {
                request.httpBody = jsonData
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    Log.d("\(error.localizedDescription)")
                    completion(false, nil) // Notify about failure
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                DispatchQueue.main.async {
                    let responseCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    Log.d("\(responseCode)")
                    
                    if let data = data {
                        Log.d("\(data)")
                        do {
                            let responseBackend = try JSONDecoder().decode(GeneralResponse<responseClass>.self, from: data)
                            DispatchQueue.main.async {
                                Log.d("Response Message: \(responseBackend)")
                                
                                if responseBackend.code == 401 {
                                    
                                    let refreshToken = RefreshBody(token: UserDefaults().string(forKey: "refreshToken") ?? "")
                                    hitApiRefresh(requestBody: refreshToken, urlApi: Url.Endpoints.refresh, methodApi: "POST", token: "") {
                                        (success: Bool, refreshResponse: GeneralResponse<RefreshResponse>?) in
                                        
                                        if success, let refreshData = refreshResponse {
                                            // Save new tokens
                                            UserDefaults.standard.setValue(refreshResponse?.data?.accessToken, forKey: "bearerToken")
                                            UserDefaults.standard.setValue(refreshResponse?.data?.refreshToken, forKey: "refreshToken")
                                            UserDefaults.standard.setValue(refreshResponse?.data?.expiresAt, forKey: "expiresAt")
                                            
                                            // Retry original request with new token
                                            hitApi(requestBody: requestBody, urlApi: fixedUrl, methodApi: methodApi, token: UserDefaults.standard.string(forKey: "bearerToken")!,type: type, completion: completion)
                                        } else {
                                            Log.d("gagal refresh")
                                            DispatchQueue.main.async {
                                                completion(true, responseBackend) // Notify about failure
                                            }
                                        }
                                    }
                                    
                                } else {
                                    Log.d("masuk  success not expired")
                                    completion(true, responseBackend)
                                }
                            
                            }
                        } catch {
                            DispatchQueue.main.async {
                                Log.d("Failed to decode response")
                                completion(false, nil) // Notify about failure
                            }
                        }
                    } else {
                        Log.d("masuk data nil")
                        completion(false, nil) // Notify about failure
                    }
                }
                return
            }
        }.resume()
    } catch {
        DispatchQueue.main.async {
            Log.d("Unknown Error")
            completion(false, nil) // Notify about failure
        }
    }
}


func hitApiRefresh<responseClass: Codable, requestClass: Codable>(requestBody: requestClass, urlApi: String, methodApi: String, token: String ,completion: @escaping (Bool, GeneralResponse<responseClass>?) -> Void) {
    guard let url = URL(string: urlApi) else { return }
    var request = URLRequest(url: url)

    
    request.httpMethod = methodApi
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("6f8856ed-9189-488f-9011-0ff4b6c08edc", forHTTPHeaderField: "API_KEY")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    Log.d("\(url)")

    do {
        let jsonData = try JSONEncoder().encode(requestBody)
        
        if (!urlApi.contains("profile")) {
            request.httpBody = jsonData
        }

        // Print the body of the request as a string
        if let bodyString = String(data: jsonData, encoding: .utf8) {
            Log.d("HTTP Body: \(bodyString)")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    Log.d("\(error.localizedDescription)")
                    completion(false, nil) // Notify about failure
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                DispatchQueue.main.async {
                    let responseCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    Log.d("\(responseCode)")
                    
                    if let data = data {
                        Log.d("\(data)")
                        do {
                            let responseBackend = try JSONDecoder().decode(GeneralResponse<responseClass>.self, from: data)
                            DispatchQueue.main.async {
                                Log.d("Response Message: \(responseBackend)")
                                
                                if responseBackend.code == 200 {
                                    completion(true, responseBackend)
                                } else {
                                    Log.d("masuk  success not expired")
                                    completion(false, responseBackend)
                                }
                            
                            }
                        } catch {
                            DispatchQueue.main.async {
                                Log.d("Failed to decode response")
                                completion(false, nil) // Notify about failure
                            }
                        }
                    } else {
                        Log.d("masuk data nil")
                        completion(false, nil) // Notify about failure
                    }
                }
                return
            }
        }.resume()
    } catch {
        DispatchQueue.main.async {
            Log.d("Unknown Error")
            completion(false, nil) // Notify about failure
        }
    }
}

