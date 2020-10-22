//
//  ItemIcon.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 15/10/2020.
//

import SwiftUI

struct ItemIcon: View {
    @EnvironmentObject var authorization: Authentication
    
    let item: QualityItemStub
    @State var icon: Data? = nil
    
    @State var retries = 0
    
    var body: some View {
        
        if icon == nil {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .onAppear {
                    loadMediaData()
                }
            
        } else {
            #if os(iOS)
            Image(uiImage: UIImage(data: icon!)!)
                .resizable()
                .scaledToFit()
            #else
            Image(nsImage: NSImage(data: icon!)!)
                .resizable()
                .scaledToFit()
            #endif
        }
    }
    
    fileprivate func loadMediaData() {
        retries += 1
        guard retries < 6 else { return }
        let requestUrlAPIHost = UserDefaults.standard.object(forKey: UserDefaultsKeys.APIRegionHost) as? String ?? APIRegionHostList.Europe
        let requestUrlAPIFragment = "/data/wow/media/item" +
            "/\(item.id)"
        let regionShortCode = APIRegionShort.Code[UserDefaults.standard.integer(forKey: UserDefaultsKeys.loginRegion)]
        let requestAPINamespace = "static-\(regionShortCode)"
        let requestLocale = UserDefaults.standard.object(forKey: UserDefaultsKeys.localeCode) as? String ?? APIRegionHostList.Europe
        
        
        let fullRequestURL = URL(string:
                                    requestUrlAPIHost +
                                    requestUrlAPIFragment +
                                    "?namespace=\(requestAPINamespace)" +
                                    "&locale=\(requestLocale)" +
                                    "&access_token=\(authorization.oauth2.accessToken ?? "")"
        )!
        
        let req = authorization.oauth2.request(forURL: fullRequestURL)
        
        let task = authorization.oauth2.session.dataTask(with: req) { data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadMediaData()
                }
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let dataResponse = try decoder.decode(BlizzardMediaFormat.self, from: data)
                guard let iconMedia = dataResponse.assets.first(where: { (asset) -> Bool in
                    asset.key == "icon"
                }) else {
                    loadMediaData()
                    return
                }
                
                loadIcon(from: iconMedia.value)
                
            } catch {
                print(error)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadMediaData()
                }
            }
            
            if let error = error {
                
                // something went wrong, check the error
                print("error")
                print(error.localizedDescription)
                loadMediaData()
            }
        }
        task.resume()
    }
    
    func loadIcon(from url: String) {
        let iconURL = URL(string: url)!
        guard let storedImage = CoreDataImagesManager.shared.fetchImage(withName: url, maximumAgeInDays: 10) else {
            
            let dataTask = URLSession.shared.dataTask(with: iconURL) { data, response, error in
                guard error == nil,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      let data = data else {
                    
                    loadMediaData()
                    return
                    
                }
                
                CoreDataImagesManager.shared.updateImage(name: url, data: data)
                DispatchQueue.main.async {
                    icon = data
                }
            }
            dataTask.resume()
            return
        }
        
        
        DispatchQueue.main.async {
            icon = storedImage.data!
        }
    }
}

struct ItemIcon_Previews: PreviewProvider {
    static var previews: some View {
        ItemIcon(item: placeholders.qualityItemStub)
    }
}
