//
//  EraseOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 14/02/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import SwiftCBOR
import Result

public typealias EraseResultClosure = ((Result<Void, NewtError>) -> Void)

class EraseOperation: NewtOperation {
	private var resultClosure: EraseResultClosure?
	
	init(newtService: NewtService, result: EraseResultClosure?) {
		self.resultClosure = result
		
		super.init(newtService: newtService)
		
		self.packet = Packet(op: .write, flags: 0, length: 0, group: NMGRGroup.image, seq: 0, id: NMGRImagesCommand.erase.rawValue, data: Data())
		
	}
	
	override func main() {
		super.main()
		
		sendPacket()
	}
	
	override func didReceive(packet: Packet) {
		if let cbor = packet.cborFromData() {
			if let responseCode = responseCode(inCBOR: cbor) {
				if responseCode == .ok {
					resultClosure?(.success(()))
				} else {
					resultClosure?(.failure(responseCode))
				}
			}
		} else {
			resultClosure?(.failure(.invalidCbor))
		}
		
		executing(false)
		finish(true)
	}
}
