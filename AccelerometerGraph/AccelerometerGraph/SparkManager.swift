//
//  SparkManager.swift
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 11/06/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

import Foundation

let _sparkManagerSharedInstsance = SparkManager()

class SparkManager: NSObject {
    let SparkCoreToolPath: String = "/opt/local/bin/spark"
    let SparkCoreConfigPath: String = "~/.spark/spark.config.json"
    let SparkHostName: String = "api.spark.io"
    var sparkList: Dictionary<String, AnyObject> = Dictionary()
    var sparkConfig: Dictionary<String, String> = NSJSONSerialization.JSONObjectWithData(NSData.dataWithContentsOfFile(("~/.spark/spark.config.json" as NSString).stringByStandardizingPath()) as NSData, options:NSJSONReadingOptions(0), error:nil) as Dictionary<String, String>
    var connectionInfo: Array<NSMutableDictionary> = Array()
    
    @objc(sharedInstance)
    class func sharedInstance() -> SparkManager
    {
        return _sparkManagerSharedInstsance
    }
    
    func accessToken() -> String
    {
        var result:String? = sparkConfig["access_token"]
        
        return result ? result! : ""
    }
    
    func userName() -> String
    {
        var result:String? = sparkConfig["username"]

        return result ? result! : ""
    }
    
    func urlWithPath(path: String, arguments: Dictionary<String, String>?) -> NSURL!
    {
        var argumentString: String = ""
        
        if arguments {
            for (key, value) in arguments as Dictionary<String, String>! {
                if countElements(argumentString) == 0 {
                    argumentString = "?"
                } else {
                    argumentString += "&"
                }
                argumentString += key + "=" + value
            }
        }
        return NSURL.URLWithString("https://" + SparkHostName + "/v1" + path + argumentString) as NSURL
    }
    
    func requestWithURL(url: NSURL) -> NSMutableURLRequest
    {
        var result: NSMutableURLRequest = NSMutableURLRequest.requestWithURL(url) as NSMutableURLRequest
        
        return result
    }
    
    func connectionWithURL(url: NSURL, callback: ((connection: NSURLConnection, error: NSError, info: NSDictionary) -> Void)?) -> NSURLConnection?
    {
        var result: NSURLConnection
        var request: NSMutableURLRequest = requestWithURL(url)
        var info: NSMutableDictionary
        
        result = NSURLConnection(request: request, delegate:self)
        info["connection"] = result
        if callback {
            info.setObject(callback! as AnyObject!, forKey: "callback")
        }
        connectionInfo.append(info)
        return result;
    }
    
    func fetchList(mycallback: (error: NSError, list: NSArray))-> String[]
    {
        var url: NSURL
        
        url = urlWithPath("devices", arguments: [ "access_token": accessToken() ])
        connectionWithURL(url, callback: { (connection: NSURLConnection, error: NSError, info: NSDictionary) -> () in
            })
        return []
    }
    
    func connectionInfoForConnection(connection: NSURLConnection) -> NSMutableDictionary?
    {
        var result: NSMutableDictionary? = nil
        
        for (info: NSMutableDictionary in connectionInfo) {
            if info["connection"] === connection {
                result = info
                break
            }
        }
        return result
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError)
    {
        var connectionInfo: NSMutableDictionary
        
        if (connectionInfo) {
            var callback: Any = connectionInfo["callback"]
            if callback {
                (callback as (NSURLConnection, NSError, NSDictionary) -> Void) (connection, error, connectionInfo)
            }
            connectionInfo.removeObject(connectionInfo)
        }
    }
    
//    func connectionDidFinishLoading:(NSURLConnection *)connection
//    {
//    NSMutableDictionary *connectionInfo = [self connectionInfoForConnection:connection];
//    
//    if (connectionInfo) {
//    ((void (^)(NSURLConnection *connection, NSError *error, NSDictionary *info))connectionInfo[@"callback"])(connection, nil, connectionInfo);
//    [self.connectionInfo removeObject:connectionInfo];
//    }
//    }
//    
//    func connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//    {
//    NSMutableDictionary *connectionInfo = [self connectionInfoForConnection:connection];
//    
//    if (connectionInfo) {
//    connectionInfo[@"response"] = response;
//    }
//    }
//    
//    func connection:(NSURLConnection *)connection didReceiveData:(NSData *)receivedData
//    {
//    NSMutableDictionary *connectionInfo = [self connectionInfoForConnection:connection];
//    
//    if (connectionInfo) {
//    NSMutableData *connectionData;
//    
//    connectionData = connectionInfo[@"data"];
//    if (!connectionData) {
//    connectionData = [NSMutableData data];
//    connectionInfo[@"data"] = connectionData;
//    }
//    [connectionData appendData:receivedData];
//    }
//    }
}