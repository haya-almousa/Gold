//
//  TojoryView.swift
//  Gold
//
//  Created by Rana Alqubaly on 27/11/1447 AH.
//


//  TojoryView.swift
//  Gold

internal import SwiftUI

struct TojoryView: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("background").ignoresSafeArea()

            Text("قريباً")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color("maincolor"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    
}
