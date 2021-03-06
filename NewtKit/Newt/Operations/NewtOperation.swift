//
//  NewtOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 12/02/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import SwiftCBOR

class NewtOperation: Operation {
	
	private var _executing = false {
		willSet {
			willChangeValue(forKey: "isExecuting")
		}
		didSet {
			didChangeValue(forKey: "isExecuting")
		}
	}
	
	override var isExecuting: Bool {
		return _executing
	}
	
	private var _finished = false {
		willSet {
			willChangeValue(forKey: "isFinished")
		}
		
		didSet {
			didChangeValue(forKey: "isFinished")
		}
	}
	
	override var isFinished: Bool {
		return _finished
	}
	
	func executing(_ executing: Bool) {
		newtService?.willStartOperation(self)
		
		_executing = executing
	}
	
	func finish(_ finished: Bool) {
		_finished = finished
		
		newtService?.didEndOperation(self)
	}
	
	var packet: Packet!
	weak var newtService: NewtService?
	
	init(newtService: NewtService) {
		super.init()
		self.newtService = newtService
	}
	
	override func main() {
		guard !isCancelled else {
			finish(true)
			return
		}
		executing(true)
	}
	
	func sendPacket() {
		guard packet != nil else { return }
		
		let data = packet.serialized()
		newtService?.transport?.newtService(newtService!, write: data)
	}
	
	func didReceive(packet: Packet) { }
	func didTimeout() { }
	
	func responseCode(inCBOR: CBOR) -> ResponseCode? {
		print("cbor: \(inCBOR)")
		if let rc = inCBOR["rc"]?.int {
			print("rc \(rc)")
			return ResponseCode(rawValue: rc)
		}
		return nil
	}
	
	func finish() {
		executing(false)
		finish(true)
	}
}
