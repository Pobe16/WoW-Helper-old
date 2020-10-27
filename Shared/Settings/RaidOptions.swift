//
//  RaidOptions.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 05/09/2020.
//

import SwiftUI

struct RaidOptions: View {
    @State var raidFarmingOptions: Int              = 1
    
    @State var imagesDeleted: Bool                  = false
    @State var existingImages: Int                  = 0
    @State var numberOfDeletedImages: Int           = 0
    
    @State var JSONDeleted: Bool                    = false
    @State var existingJSONDataNodes: Int           = 0
    @State var numberOfDeletedJSONDataNodes: Int    = 0
    
    #if os(iOS)
    var listStyle = InsetGroupedListStyle()
    #elseif os(macOS)
    var listStyle =  DefaultListStyle()
    #endif
    
    
    var body: some View {
        
        List(){
            
            Section(header: Text("Farming order").whiteTextWithBlackOutlineStyle()) {
                NavigationLink(destination:
                                FarmingOrder()) {
                    Text("Farming order")
                }
            }.padding(.horizontal)
            
            Section(header:
                        Text("Difficulty")
                        .whiteTextWithBlackOutlineStyle()
                        .padding(.horizontal)
            ) {
                Picker(selection: $raidFarmingOptions, label: Text("")) {
                    Text("Highest").tag(1)
                    Text("All modes").tag(2)
                    Text("No LFR").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: raidFarmingOptions) { (value) in
                    saveOptionsSelection(value)
                }
            }
            
            Section(header:
                        Text("Game data storage")
                        .whiteTextWithBlackOutlineStyle()
                        .padding(.horizontal)
            ) {
                
                Button(action: {
                    deleteAllJSONData()
                }, label: {
                    
                    HStack {
                        Text("Delete game data")
                            .foregroundColor(.red)
                        Spacer()
                        Text("\(existingJSONDataNodes)")
                    }
                    
                })
                .disabled(existingJSONDataNodes == 0)
                
                if numberOfDeletedJSONDataNodes > 0 {
                    Text("Deleted \(numberOfDeletedJSONDataNodes) nodes of game data.")
                }
                
            }
            
            Section(header:
                        Text("Images storage")
                        .whiteTextWithBlackOutlineStyle()
                        .padding(.horizontal)
            ) {
                
                Button(action: {
                    deleteAllImages()
                }, label: {
                    
                    HStack {
                        Text("Delete all images")
                            .foregroundColor(.red)
                        Spacer()
                        Text("\(existingImages)")
                    }
                    
                })
                .disabled(existingImages == 0)
                
                if numberOfDeletedImages > 0 {
                    Text("Deleted \(numberOfDeletedImages) images.")
                }
                
            }
        }
        .padding(.horizontal)
        .listStyle(listStyle)
        .background(
            BackgroundTexture(texture: .ice, wall: .horizontal)
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Raid settings")
            }
        }
        .onAppear{
            loadOptionsSelection()
            loadCoreDataCount()
        }
    }
    
    func loadCoreDataCount() {
        let allImages = CoreDataImagesManager.shared.fetchAllImages()
        existingImages = allImages?.count ?? 0
        let allData = JSONCoreDataManager.shared.fetchAllJSONData()
        existingJSONDataNodes = allData?.count ?? 0
    }
    
    func loadOptionsSelection() {
        let option = UserDefaults.standard.integer(forKey: UserDefaultsKeys.raidFilteringOptions)
        raidFarmingOptions = option == 0 ? 1 : option
    }
    
    func saveOptionsSelection(_ value: Int) {
        UserDefaults.standard.setValue(value, forKey: UserDefaultsKeys.raidFilteringOptions)
    }
    
    func deleteAllImages() {
        let allImages = CoreDataImagesManager.shared.fetchAllImages()
        numberOfDeletedImages = allImages?.count ?? 0
        allImages?.forEach({ (imageObj) in
            CoreDataImagesManager.shared.deleteImage(image: imageObj)
        })
        withAnimation {
            existingImages = 0
            imagesDeleted = true
        }
    }
    
    func deleteAllJSONData() {
        let allData = JSONCoreDataManager.shared.fetchAllJSONData()
        numberOfDeletedJSONDataNodes = allData?.count ?? 0
        allData?.forEach({ item in
            JSONCoreDataManager.shared.deleteJSONData(data: item)
        })
        
        withAnimation {
            existingJSONDataNodes = 0
            JSONDeleted = true
        }
    }
}

struct RaidOptions_Previews: PreviewProvider {
    static var previews: some View {
        RaidOptions()
            .previewDevice("iPhone SE (1st generation)")
            .environmentObject(FarmCollectionsOrder())
    }
}
