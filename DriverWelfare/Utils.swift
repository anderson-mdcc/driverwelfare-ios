//
//  Utils.swift
//  DriverWelfare
//
//  Created by Anderson Calixto on 31/10/19.
//  Copyright © 2019 Anderson Calixto. All rights reserved.
//

import Foundation
import CoreLocation

enum Turno: String, CustomStringConvertible {
    case MANHA = "Dia"
    case TARDE = "Tarde"
    case NOITE = "Noite"
    case MADRUGADA = "Madrugada"
    var description: String {
        get {
            return self.rawValue
        }
    }
}

public struct Lugares {
    static let casa = CLLocation(latitude: -3.73453, longitude: -38.487068)
    static let walterCantidio = CLLocation(latitude: -3.749303, longitude: -38.551548)
    static let maternidadeEscola = CLLocation(latitude: -3.748274, longitude: -38.552837)
}
