//
//  BaseRealmRepository.swift
//  RxCleanKit
//
//  Created by Alex on 4/6/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation
import RCKit
import RealmSwift
import RxSwift


open class BaseRealmRepository<T:RealmRepresentable>: BaseAbstractRepository where T.RealmType.DomainType == T {
    
    private let configuration: Realm.Configuration
    private let scheduler: Scheduler
    
    
    public lazy var realm: Realm = {
        return try! Realm(configuration: self.configuration)
    }()
    
    public init(configuration: Realm.Configuration, scheduler: Scheduler) {
        self.configuration = configuration
        self.scheduler = scheduler
    }
    
    open func save(value: T) {
        self.scheduler.performSync {
            try! self.realm.write{
                self.realm.add(value.asRealm(), update: .all)
            }
        }
    }
    
    open func insert(value:T){
        self.scheduler.performSync {
            try! self.realm.write{
                self.realm.add(value.asRealm(), update: .all)
            }
        }
    }
    
    
    open func saveMany(value: [T]) {
        self.scheduler.performSync {
            try! self.realm.write{
                self.realm.add(value.map({$0.asRealm()}), update: .all)
            }
        }
    }
    
    
    open func remove(value:T){
        self.scheduler.performSync {
            try! self.realm.write{
                self.realm.delete(value.asRealm())
            }
        }
        
    }
    
    open func remove(id:String){
        self.scheduler.performSync {
            try! self.realm.write{
                if let value = self.realm.object(ofType: T.RealmType.self, forPrimaryKey: id){
                    self.realm.delete(value)
                }
            }
        }
    }
    
    open func remove(predicate: NSPredicate){
        self.scheduler.performSync {
            try! self.realm.write{
                let filtered = self.realm.objects(T.RealmType.self).filter(predicate)
                guard filtered.count > 0 else { return }
                self.realm.delete(filtered)
            }
        }
    }
    
    
    open func get(predicate: NSPredicate)->T?{
        return self.scheduler.performSync {
            return self.realm.objects(T.RealmType.self).filter(predicate).first?.asDomain()
        }
    }
    
    
    open func getById(id: String) -> T? {
        return self.scheduler.performSync {
            return self.realm.object(ofType: T.RealmType.self, forPrimaryKey: id)?.asDomain()
        }
    }
    
    
    
    open func subscribeForDeletion(id:String)->Observable<Void>{
        return Observable.create{[weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            let token = self.realm.object(ofType: T.RealmType.self, forPrimaryKey: id)!.observe({ (change) in
                switch change{
                case .deleted:
                    observer.onNext(())
                    observer.onCompleted()
                default:
                    break
                }
            })
            return Disposables.create {
                token.invalidate()
            }
            }.subscribeOn(self.scheduler)
    }
    
    open func getContainer(predicates: [NSPredicate]=[], sort: (keyPath:String, ascending: Bool)?)->LazyContainer<T>{
        return self.scheduler.performSync {
            var results = self.realm.objects(T.RealmType.self)
            predicates.forEach{
                results = results.filter($0)
            }
            if let sort = sort{
                results = results.sorted(byKeyPath: sort.keyPath, ascending: sort.ascending)
            }
            return LazyContainer.init(results: results, scheduler: self.scheduler)
        }
    }
    
    private func subscribeFor<U>(predicates: [NSPredicate], force: Bool, mapper: @escaping ((Results<T.RealmType>)->U))->Observable<U> {
        return Observable.create({ [weak self](observer) -> Disposable in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            var results =  self.realm.objects(T.RealmType.self)
            for filter in predicates{
                results = results.filter(filter)
            }
            let token = results.observe({ (change) in
                switch change {
                case .initial(let initial):
                    if force {
                        observer.onNext(mapper(initial))
                    }
                case .error(let err):
                    observer.onError(err)
                case .update(let updated, _, _, _):
                    observer.onNext(mapper(updated))
                }
            })
            return Disposables.create {
                token.invalidate()
            }
        }).subscribeOn(self.scheduler)
    }
    
    open func subscribeFor(predicates: [NSPredicate], force: Bool)->Observable<[T]> {
        return subscribeFor(predicates: predicates, force: force, mapper: { (results) -> [T] in
            return results.map({$0.asDomain()})
        })
    }
    
    open func subscribeForOneObject(predicates: [NSPredicate], force: Bool)->Observable<T?> {
        return subscribeFor(predicates: predicates, force: force, mapper: { (results) -> T? in
            return results.first?.asDomain()
        })
    }
}


