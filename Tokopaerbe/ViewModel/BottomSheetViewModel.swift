//
//  BottomSheetViewModel.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 28/06/24.
//

import Foundation
import SwiftUI

struct ChipModel: Identifiable, Hashable, Equatable {
    var id = UUID()
    var isSelected: Bool?
    var titleKey: String
}

class BottomSheetViewModel: ObservableObject {
    @Published var chipSortArray: [ChipModel] = [
        ChipModel(isSelected: false, titleKey: "Ulasan"),
        ChipModel(isSelected: false, titleKey: "Penjualan"),
        ChipModel(isSelected: false, titleKey: "Harga Terendah"),
        ChipModel(isSelected: false, titleKey: "Harga Tertinggi")
    ]
    
    @Published var chipCategoryArray: [ChipModel] = [
        ChipModel(isSelected: false, titleKey: "Apple"),
        ChipModel(isSelected: false, titleKey: "Asus"),
        ChipModel(isSelected: false, titleKey: "Dell"),
        ChipModel(isSelected: false, titleKey: "Lenovo")
    ]
    
    @Published var selectedSortChip: String? = nil
    @Published var selectedCategoryChip: String? = nil
    @Published var hargaTerendah: String? = nil
    @Published var hargaTertinggi: String? = nil
    
    
    @Published var chipSortArrayTemp: [ChipModel] = [
        ChipModel(isSelected: nil, titleKey: "Ulasan"),
        ChipModel(isSelected: nil, titleKey: "Penjualan"),
        ChipModel(isSelected: nil, titleKey: "Harga Terendah"),
        ChipModel(isSelected: nil, titleKey: "Harga Tertinggi")
    ]
    
    @Published var chipCategoryArrayTemp: [ChipModel] = [
        ChipModel(isSelected: nil, titleKey: "Apple"),
        ChipModel(isSelected: nil, titleKey: "Asus"),
        ChipModel(isSelected: nil, titleKey: "Dell"),
        ChipModel(isSelected: nil, titleKey: "Lenovo")
    ]
    
    @Published var hargaTerendahTemp: String? = nil
    @Published var hargaTertinggiTemp: String? = nil
    
    
}
