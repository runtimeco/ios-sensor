//
//  ResourceManager.swift
//  ios-sensor
//
//  Created by Brian Giori on 11/16/17.
//  Copyright © 2017 Brian Giori. All rights reserved.
//

import Foundation

class ResourceManager {
    
    /// Dictionary for keeping track of resources. The initial key is the
    /// resource's address, and the sub-key is the resource's URI
    static var resources = [String:[String:OcResource]]()
    
    /// Get a dictionary of resources for a gien address. The return
    /// Dictionary is keyed by the resource URI.
    static func getResourcesForAddress(_ address: String) -> [String:OcResource]? {
        return resources[address]
    }
    /// Get a resource from the resources dictionary given an
    /// addresse and a URI
    static func getResourceWithAddress(_ address: String, andUri: String) -> OcResource?{
        return resources[address]?[andUri]
    }
    
    /// Put an OcResource into the dictionary
    static func putResource(_ resource: OcResource) {
        if var resDictForAddr = resources[resource.address] {
            resDictForAddr.updateValue(resource, forKey: resource.uri)
        } else {
            var resDictForAddr = [String:OcResource]()
            resDictForAddr.updateValue(resource, forKey: resource.uri)
            resources.updateValue(resDictForAddr, forKey: resource.address)
        }
    }
    
}
