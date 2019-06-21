//
//  LazyContainer.swift
//
//
//  Created by Alex Moiseenko on 4/6/19.
//  Copyright © 2019 Alex Moiseenko. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RCKit

public struct ChangeSet{
    let modified: [Int]
    let deleted: [Int]
    let inserted: [Int]
    
    var isEmpty: Bool{
        return (modified.count + deleted.count + inserted.count) == 0
    }
}


open class LazyContainer<T: RealmRepresentable>: Collection where T.RealmType.DomainType == T{
    
    public func index(after i: Int) -> Int {
        return self.scheduler.performSync{
            return self.results.index(after: i)
        }
    }
    
    public typealias Element = T
    public typealias Index = Int
    
    private let results: Results<T.RealmType>
    private unowned let scheduler: Scheduler
    public init(results: Results<T.RealmType>, scheduler: Scheduler){
        self.results = results
        self.scheduler = scheduler
    }
    
    public func subscribeForValues()->Observable<[T]>{
        return Observable.create{ observer in
            let token = self.results.observe({ (change) in
                switch change{
                case .initial(let values), .update(let values,_, _, _):
                    observer.onNext(values.map({$0.asDomain()}))
                default:
                    break
                }
            })
            return Disposables.create {
                token.invalidate()
            }
            }.subscribeOn(self.scheduler)
    }
    
    
    public func subscribeForCount()->Observable<Int>{
        return Observable.create{ observer in
            let token = self.results.observe({ (change) in
                switch change{
                case .initial(let values), .update(let values,_, _, _):
                    observer.onNext(values.count)
                default:
                    break
                }
            })
            return Disposables.create {
                token.invalidate()
            }
            }.subscribeOn(self.scheduler)
    }
    
    public func subscribeForChanges()->Observable<ChangeSet>{
        return Observable.create{[weak self] observer in
            guard let self = self else{
                observer.onCompleted()
                return Disposables.create()
            }
            let token = self.results.observe({ (change) in
                switch change{
                case .update(_, let deletions, let insertions, let modifications):
                    observer.onNext(ChangeSet(modified: modifications, deleted: deletions, inserted: insertions))
                default:
                    break
                }
            })
            return Disposables.create {
                token.invalidate()
            }
            }.subscribeOn(self.scheduler)
    }
    
    public subscript(index: Int)->T{
        return self.scheduler.performSync{
            return self.results[index].asDomain()
        }
    }
    
    public var endIndex: Int{
        return self.scheduler.performSync{
            return self.results.endIndex
        }
    }
    
    public var startIndex: Int{
        return self.scheduler.performSync{
            return self.results.startIndex
        }
    }
    
    
    
}
