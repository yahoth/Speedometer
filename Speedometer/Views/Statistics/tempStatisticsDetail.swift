//
//  tempStatisticsDetail.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/20.
//

import SwiftUI

struct tempStatisticsDetail: View {
    let result: SavedResult
    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                VStack {
                    if let data = result.image, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .frame(width: proxy.size.width - 40, height: proxy.size.width * 4 / 3)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    let coreDataManger = CoreDataManager()
    let result = SavedResult(context: coreDataManger.context)

    result.time = 10
    result.distance = 0
    result.averageSpeed = 0
    result.topSpeed = 0
    result.altitude = 0
    result.startDate = Date()
    result.endDate = Date()
    result.title = "title"

    if let data = UIImage(named: "image")?.pngData() {
        result.image = data
        result.mapView = data
        return tempStatisticsDetail(result: result)
    } else {
        return tempStatisticsDetail(result: SavedResult())
    }
}
