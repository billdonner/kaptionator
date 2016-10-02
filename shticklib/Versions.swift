//
//  Versions.swift
//  sheetcheats
//
//  Created by william donner on 8/13/14.
//  Copyright (c) 2014 william donner. All rights reserved.
//

import Foundation

public class Versions {

	public class func make() -> Versions { return Versions() }

	public class func versionString () -> String {
		if let iDict = Bundle.main.infoDictionary {
		if let w:AnyObject =  iDict["CFBundleIdentifier"] as AnyObject? {
		if let x:AnyObject =  iDict["CFBundleName"] as AnyObject? {
			if let y:AnyObject = iDict["CFBundleShortVersionString"] as AnyObject? {
				if let z:AnyObject = iDict["CFBundleVersion"] as AnyObject? {
					return "\(w) \(x) \(y) \(z)"
				}
			}
			}
		}
		}
		return "**no version info**"
	}
	private func versionSave () {
		let userDefaults = UserDefaults.standard
		userDefaults.set(Versions.versionString(), forKey: "version")
		userDefaults.synchronize()
	}
	
	private func versionFetch() -> String? {
		 let userDefaults = UserDefaults.standard
			if let s : AnyObject = userDefaults.object(forKey: "version") as AnyObject? {
				return (s as! String)
			}
		return nil
	}
	
	func versionCheck() -> Bool {
		let s = Versions.versionString()
		if let v = versionFetch() {
			if s != v {
				versionSave()
				print ("versionCheck changed :::: \(s) - will reset and may be slow to delete existing files")
			} else {
				print ("versionCheck is stable :::: \(s)")
			}
			return s==v
		}
		// if nothing stored then store something, but we check OK
		versionSave()
		print("versionCheck first time up :::: \(s)")
		return true
	}
}
