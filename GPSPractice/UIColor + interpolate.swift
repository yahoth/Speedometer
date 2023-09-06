//
//  UIColor + interpolate.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/07.
//

import UIKit

extension UIColor {
    static func interpolateColor(from startColor: UIColor, to endColor: UIColor, with value: CGFloat) -> UIColor {
        var startRed: CGFloat = 0
        var startGreen: CGFloat = 0
        var startBlue: CGFloat = 0
        var startAlpha: CGFloat = 0

        // Extract the RGB and alpha components from the start color
        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)

        var endRed: CGFloat = 0
        var endGreen: CGFloat = 0
        var endBlue: CGFloat = 0
        var endAlpha: CGFloat = 0

        // Extract the RGB and alpha components from the end color
        endColor.getRed(&endRed, green:&endGreen , blue:&endBlue , alpha:&endAlpha)

        // Interpolate between the two colors
        let redComponent = (endRed - startRed) * value + startRed
        let greenComponent = (endGreen - startGreen) * value + startGreen
        let blueComponent = (endBlue - startBlue) * value + startBlue

        return UIColor(red:redComponent , green:greenComponent , blue :blueComponent,alpha:endAlpha)
    }
}
