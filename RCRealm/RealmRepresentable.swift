//
//  RealmRepresentable.swift
//  RCRealm
//
//  Created by Alex on 6/21/19.
//  Copyright © 2019 wolvesstudio. All rights reserved.
//

import Foundation
import RealmSwift
import RCKit

public protocol RealmRepresentable {
    associatedtype RealmType: DomainConvertibleType&Object
    func asRealm() -> RealmType
}
