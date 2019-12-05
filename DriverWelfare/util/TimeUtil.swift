//
//  TimeUtil.swift
//  DriverWelfare
//
//  Created by Anderson Calixto on 05/12/19.
//  Copyright © 2019 Anderson Calixto. All rights reserved.
//

import Foundation

class TimeUtil {
    static func getHour(_ perc:Float) -> Int {
        let segs = Int(perc * (86400))
        var horas = segs / 60 / 60
        if (horas == 24) { horas = 0 }
        return horas
    }
    
    static func getMin(_ perc:Float) -> Int {
        let segs = Int(perc * (86400))
        let horas = segs / 60 / 60
        var minutos = segs / 60
        minutos -= (horas * 60)
        if (minutos > 0) {
            minutos -= (minutos % 10)
        }
        return minutos
    }
    
    static func getFormatHour(_ perc:Float) -> String {
        return "\(String(format: "%02d", getHour(perc))):\(String(format: "%02d", getMin(perc)))"
    }

    static func getTimePerc(hour: Int, minute: Int) -> Float {
        let segHours = hour * 60 * 60
        let segMinutes = minute * 60
        return (Float(segHours + segMinutes) / (86400.0 - 0.0))
    }
}
