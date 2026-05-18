//
//  SplashScreenView.swift
//  Gold
//
//  Created by Rana Alqubaly on 01/12/1447 AH.
//

internal import SwiftUI

struct SplashScreenView: View {
    @State private var blobScale: CGFloat = 2.5
    var onFinished: () -> Void

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
           

            ZStack {
                Color("background").ignoresSafeArea()

                Color("maincolor")
                    .frame(maxWidth: .infinity)
                    .frame(height: geo.safeAreaInsets.top + w * 0.3)
                    .ignoresSafeArea(edges: .top)
                    .frame(maxHeight: .infinity, alignment: .top)

                Circle()
                    .fill(Color("maincolor"))
                    .frame(width: w * 1.4, height: w * 1.4)
                    .position(x: 200, y: 180)
                    .scaleEffect(blobScale, anchor: .top)
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.75).delay(0.3)) {
                blobScale = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashScreenView {
        print("Splash finished")
    }
}
