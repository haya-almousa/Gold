//
//  EducationView.swift
//  Gold
//
//  Created by Rana Alqubaly on 27/11/1447 AH.
//


//  EducationView.swift
//  Gold

internal import SwiftUI

struct EducationView: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color("background").ignoresSafeArea()
            
            Text("قريباً")
                .font(.appTitle2(.bold))
                .foregroundColor(Color("maincolor"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    
}
