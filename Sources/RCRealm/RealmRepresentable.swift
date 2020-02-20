//
//  RealmRepresentable.swift
//  RCRealm
//
//  Created by Alex on 6/21/19.
//  Copyright © 2019 techprostudio. All rights reserved.
//

import Foundation
import RealmSwift
import RCKit

public protocol RealmRepresentable: Identifiable {
    associatedtype RealmType: DomainConvertibleType&Object
    func asRealm() -> RealmType
}
