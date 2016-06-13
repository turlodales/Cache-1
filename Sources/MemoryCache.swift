//
//  MemoryCache.swift
//  Cache
//
//  Created by Sam Soffes on 5/6/16.
//  Copyright © 2016 Sam Soffes. All rights reserved.
//

#if os(iOS) || os(tvOS)
	import UIKit
#else
	import Foundation
#endif

public final class MemoryCache<T>: Cache {

	// MARK: - Properties

	private let storage = Foundation.Cache<NSString, Box<T>>()


	// MARK: - Initializers

	#if os(iOS) || os(tvOS)
		public init(countLimit: Int? = nil, automaticallyRemoveAllObjects: Bool = false) {
			storage.countLimit = countLimit ?? 0

			if automaticallyRemoveAllObjects {
				let notificationCenter = NotificationCenter.default()
				notificationCenter.addObserver(storage, selector: #selector(storage.dynamicType.removeAllObjects), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
				notificationCenter.addObserver(storage, selector: #selector(storage.dynamicType.removeAllObjects), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
			}
		}

		deinit {
			NotificationCenter.default().removeObserver(storage)
		}
	#else
		public init(countLimit: Int? = nil) {
			storage.countLimit = countLimit ?? 0
		}
	#endif


	// MARK: - Cache

	public func set(key: String, value: T, completion: (() -> Void)? = nil) {
		storage.setObject(Box(value), forKey: key)
		completion?()
	}

	public func get(key: String, completion: ((T?) -> Void)) {
		let box = storage.object(forKey: key)
		let value = box.flatMap({ $0.value })
		completion(value)
	}

	public func remove(key: String, completion: (() -> Void)? = nil) {
		storage.removeObject(forKey: key)
		completion?()
	}

	public func removeAll(completion: (() -> Void)? = nil) {
		storage.removeAllObjects()
		completion?()
	}
	
	
	// MARK: - Synchronous
	
	public subscript(key: String) -> T? {
		get {
			return (storage.object(forKey: key))?.value
		}
		
		set(newValue) {
			if let newValue = newValue {
				storage.setObject(Box(newValue), forKey: key)
			} else {
				storage.removeObject(forKey: key)
			}
		}
	}
}
