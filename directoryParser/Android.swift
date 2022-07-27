//
//  Android.swift
//  directoryParser
//
//  Created by Nikos Grigoriadis on 4/5/22.
//

import Foundation

class AndroidParser
{
    private static var androidProjectDirectory = getAllFilesFromDirectory(atPath: "/Users/nikosgrigoriadis/PhpstormProjects/schoox_android")
    
    class func run_find_errors()
    {
        var errorDict: [String:[String]] = [:]
        var percentage = 0
        
        for aFile in androidProjectDirectory {
            
//            if let foundErrors = find_LeadingAppendPlus(atPath: aFile), !foundErrors.isEmpty {
//                errorDict[aFile] = foundErrors
//                print("files with error: \(errorDict.keys.count)")
//            }
//
//            if let foundErrors = find_TrailingAppendPlus(atPath: aFile), !foundErrors.isEmpty {
//                errorDict[aFile] = foundErrors
//                print("files with error: \(errorDict.keys.count)")
//            }
//
//            if let foundErrors = find_getTextMobile(atPath: aFile), !foundErrors.isEmpty {
//                errorDict[aFile] = foundErrors
//                print("files with error: \(errorDict.keys.count)")
//            }
//            
//            if let foundErrors = parseXMLFileForAndroid(atPath: aFile), !foundErrors.isEmpty {
//                errorDict[aFile] = foundErrors
//                print("files with error: \(errorDict.keys.count)")
//            }
//            if let foundErrors = find_doubleTextMobile(atPath: aFile), !foundErrors.isEmpty {
//                errorDict[aFile] = foundErrors
//                print("files with error: \(errorDict.keys.count)")
//            }
//            if let foundErrors = parseJavaFileForAndroid(atPath: aFile), !foundErrors.isEmpty {
//                errorDict[aFile] = foundErrors
//                print("files with error: \(errorDict.keys.count)")
//            }

            
            if let foundErrors = find_translationTextError(atPath: aFile), !foundErrors.isEmpty {
                errorDict[aFile] = foundErrors
                print("files with error: \(errorDict.keys.count)")
            }
            //auto vriskei String.format(Utils.GetMobileText kapou sto string
//            if let foundErrors = find_StringFormatAndGetMobileText(atPath: aFile), !foundErrors.isEmpty {
//                    errorDict[aFile] = foundErrors
//                    print("files with error: \(errorDict.keys.count)")
//            }
//
                
            let current = androidProjectDirectory.firstIndex(of: aFile)!
            
            let updatedPercentage =  Int(Double(current) / Double(androidProjectDirectory.count) * 100.0)
            if updatedPercentage != percentage {
                percentage = updatedPercentage
                print("\(percentage)%")
            }
        }
        
        var errorCounter = 0
        
        for aFile in errorDict.keys {
            print();print();print();print()
            print("FILE: \(aFile)")
            print("ERRORS:")
            var counter = 1
            let errorsList = errorDict[aFile]! as [String]
            for anError in errorsList {
                print("\(counter):" + anError)
                counter += 1
            }
            errorCounter = errorCounter + errorsList.count
            print();print();print();print()
            
        }
        print("Total number: \(errorCounter)")
    }
    
    class func run_extract_translations() -> Array<String>
    {
        var texts: [String] = []
        var percentage = 0
        
        for aFile in androidProjectDirectory {
            
            texts = texts + parseJavaFileForAndroid(atPath: aFile)
            texts = texts + parseXMLFileForAndroid(atPath: aFile)
            
            let current = androidProjectDirectory.firstIndex(of: aFile)!
            let updatedPercentage =  Int(Double(current) / Double(androidProjectDirectory.count) * 100.0)
            if updatedPercentage != percentage {
                percentage = updatedPercentage
                print("\(percentage)%")
            }
        }
        
        return Array(Set(texts))
    }
    
    private class func find_LeadingAppendPlus(atPath path: String) -> [String]?
    {
        var matchedStrings : [String] = []
        
        guard let text = try? String(contentsOfFile: path) else {
            return nil
        }
        //for text between quotes: (["'])(?:(?=(\\?))\2.)*?\1
        let regex = try! NSRegularExpression(pattern: ".*([+]|(append)).*Utils.getMobileText.*")
        
        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex...,in: text))
        for aMatch in matches {
            
            let matchedString = String(text[Range(aMatch.range, in: text)!])
            //let quoteIndex = matchedString.firstIndex(of: "\"")
            matchedStrings.append(matchedString)
        }
        
        return matchedStrings
    }
    
    private class func find_TrailingAppendPlus(atPath path: String) -> [String]?
    {
        var matchedStrings : [String] = []
        
        guard let text = try? String(contentsOfFile: path) else {
            return nil
        }
        //for text between quotes: (["'])(?:(?=(\\?))\2.)*?\1
        let regex = try! NSRegularExpression(pattern: ".*Utils.getMobileText.*([+]|(append)).*")
        
        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex...,in: text))
        for aMatch in matches {
            
            let matchedString = String(text[Range(aMatch.range, in: text)!])
            //let quoteIndex = matchedString.firstIndex(of: "\"")
            matchedStrings.append(matchedString)
        }
        
        return matchedStrings
    }
    
    private class func find_getTextMobile(atPath path: String) -> [String]?
    {
        var matchedStrings : [String] = []
        
        guard let text = try? String(contentsOfFile: path) else {
            return nil
        }
        //for text between quotes: (["'])(?:(?=(\\?))\2.)*?\1
        let regex = try! NSRegularExpression(pattern: ".*getMobileText.*")
        
        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex...,in: text))
        for aMatch in matches {
            
            let matchedString = String(text[Range(aMatch.range, in: text)!])
            //let quoteIndex = matchedString.firstIndex(of: "\"")
            matchedStrings.append(matchedString)
        }
        
        return matchedStrings
    }
    
    /*
     unicode errors
     leading whitespaces
     trailing whitespaces
     */
    private class func find_translationTextError(atPath path: String) -> [String]?
    {
        var translations : [String] = []
        
        if path.hasSuffix("java") {
            translations = parseJavaFileForAndroid(atPath: path)
        } else if path.hasSuffix("xml") {
             translations = parseXMLFileForAndroid(atPath: path)
        } else {
            return nil
        }
       
        var matchedStrings: [String] = []
        for aTranslation in translations {
            if aTranslation.contains("...") || aTranslation.hasSuffix(" ") || aTranslation.hasPrefix(" ") {
                matchedStrings = matchedStrings + [aTranslation]
            }
        }
        return matchedStrings
    }
    
    private class func parseJavaFileForAndroid(atPath path: String) -> [String]
    {
        var matchedStrings : [String] = []
        
        guard let text = try? String(contentsOfFile: path) else {
            return []
        }
        
        let regex = try! NSRegularExpression(pattern: "getMobileText(?:(?![])]).)*")
        
        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex...,in: text))
        for aMatch in matches {
            var matchedString = String(text[Range(aMatch.range, in: text)!])
            matchedString = matchedString.replacingOccurrences(of: "getMobileText:@\"", with: "")
            matchedString = matchedString.replacingOccurrences(of: "getMobileText:", with: "")
            matchedString = matchedString.replacingOccurrences(of: "getMobileText(\"", with: "")
            matchedString = matchedString.replacingOccurrences(of: "\"", with: "")
            if matchedString.contains(" ") {
                matchedStrings.append(matchedString)
            }
        }
        
        return matchedStrings
    }

    private class func parseXMLFileForAndroid(atPath path: String) -> [String]
    {
        var matchedStrings : [String] = []
        
        guard let text = try? String(contentsOfFile: path) else {
            return []
        }
        
        let regex = try! NSRegularExpression(pattern: "app:mobileText(?:(?![])]).)*")
        
        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex...,in: text))
        for aMatch in matches {
            var matchedString = String(text[Range(aMatch.range, in: text)!])
            matchedString = matchedString.replacingOccurrences(of: "app:mobileText=\'@{\"", with: "")
            matchedString = matchedString.replacingOccurrences(of: "app:mobileText=\"@{", with: "")
            matchedString = matchedString.replacingOccurrences(of: "\"}\'", with: "")
            matchedString = matchedString.replacingOccurrences(of: "}\"", with: "")
            if matchedString.contains(" ") {
                matchedStrings.append(matchedString)
            }
        }
        
        return matchedStrings
    }
    
    private class func find_doubleTextMobile(atPath path: String) -> [String]?
    {
        var matchedStrings : [String] = []
        
        guard let text = try? String(contentsOfFile: path) else {
            return nil
        }
        //for text between quotes: (["'])(?:(?=(\\?))\2.)*?\1
        let regex = try! NSRegularExpression(pattern: ".*getMobileText.*getMobileText.*")
        
        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex...,in: text))
        for aMatch in matches {
            
            let matchedString = String(text[Range(aMatch.range, in: text)!])
            //let quoteIndex = matchedString.firstIndex(of: "\"")
            matchedStrings.append(matchedString)
        }
        
        return matchedStrings
    }

    
    private class func find_StringFormatAndGetMobileText(atPath path: String) -> [String]?
    {
        if !path.hasSuffix("java") && !path.hasSuffix("java") {
            return nil
        }
        
        var matchedStrings : [String] = []
        
        guard let text = try? String(contentsOfFile: path) else {
            return nil
        }
        //for text between quotes: (["'])(?:(?=(\\?))\2.)*?\1
        let regex = try! NSRegularExpression(pattern: ".*String.format.Utils.*.getMobileText.*")
        
        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex...,in: text))
        for aMatch in matches {
            
            let matchedString = String(text[Range(aMatch.range, in: text)!])
            //let quoteIndex = matchedString.firstIndex(of: "\"")
            matchedStrings.append(matchedString)
        }
        
        return matchedStrings
    }
}
