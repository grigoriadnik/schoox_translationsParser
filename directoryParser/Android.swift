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
            if let foundErrors = find_LeadingAppendPlus(atPath: aFile), !foundErrors.isEmpty {
                errorDict[aFile] = foundErrors
                print("files with error: \(errorDict.keys.count)")
            }
//
            if let foundErrors = find_TrailingAppendPlus(atPath: aFile), !foundErrors.isEmpty {
                errorDict[aFile] = foundErrors
                print("files with error: \(errorDict.keys.count)")
            }

//            if let foundErrors = find_getTextMobile(atPath: aFile), !foundErrors.isEmpty {
//                errorDict[aFile] = foundErrors
//                print("files with error: \(errorDict.keys.count)")
//            }

            if let foundErrors = find_doubleTextMobile(atPath: aFile), !foundErrors.isEmpty {
                errorDict[aFile] = foundErrors
                print("files with error: \(errorDict.keys.count)")
            }


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
    
    class func run_extract_translations(replaceFormatters: Bool = false) -> Array<String>
    {
        var texts: [String] = []
        var percentage = 0
        
        for aFile in androidProjectDirectory {
            
            texts = texts + parseJavaFileForAndroid(atPath: aFile)
            texts = texts + parseLemma(atPath: aFile)
            //texts = texts + parseXMLFileForAndroid(atPath: aFile)
            
            let current = androidProjectDirectory.firstIndex(of: aFile)!
            let updatedPercentage =  Int(Double(current) / Double(androidProjectDirectory.count) * 100.0)
            if updatedPercentage != percentage {
                percentage = updatedPercentage
                print("\(percentage)%")
            }
        }
        
        if replaceFormatters {
            return Array(Set(texts)).map {
                $0.replacingOccurrences(of: "%s", with: "{formatter}")
                .replacingOccurrences(of: "%d", with: "{formatter}")
                .replacingOccurrences(of: "%1$s", with: "{formatter}")
                .replacingOccurrences(of: "%2$s", with: "{formatter}")
                .replacingOccurrences(of: "%3$s", with: "{formatter}")
                .replacingOccurrences(of: "%1$d", with: "{formatter}")
                .replacingOccurrences(of: "%3d", with: "{formatter}")
                .replacingOccurrences(of: "%1d", with: "{formatter}")
                .replacingOccurrences(of: "%2d", with: "{formatter}")
            }
        } else {
            return Array(Set(texts))
        }
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
            if aTranslation.contains("...")
                || aTranslation.hasSuffix(" ")
                || aTranslation.hasPrefix(" ")
                || aTranslation.hasSuffix(".")
                || aTranslation.lowercased().contains("user")
                || aTranslation.lowercased().contains("on time")
                || aTranslation.contains("|")
                || aTranslation.contains("•")
            {
                matchedStrings = matchedStrings + [aTranslation]
            }
        }
        return matchedStrings
    }
    
    private class func parseJavaFileForAndroid(atPath path: String) -> [String]
    {
        var matchedStrings : [String] = []
        
        let text = try! String(contentsOfFile: path)
        //for text between quotes: (["'])(?:(?=(\\?))\2.)*?\1
        let regex = try! NSRegularExpression(pattern: "getMobileText[\\s:(@]+([\"'])(?:(?=(\\\\?))\\2.)*?\\1")
        
        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex...,in: text))
        for aMatch in matches {
            
            var matchedString = String(text[Range(aMatch.range, in: text)!])
            let quoteIndex = matchedString.firstIndex(of: "\"")
            let replace1 = String(matchedString[..<quoteIndex!])
            
            matchedString = matchedString.replacingOccurrences(of: replace1, with: "")
            matchedString = String(matchedString.dropFirst())
            matchedString = String(matchedString.dropLast())
            matchedStrings.append(matchedString)
        }
        return matchedStrings
    }
    
    private class func parseLemma(atPath path: String) -> [String] {
        if !path.contains("Lemma.kt") {
            return []
        }
        var matchedStrings : [String] = []
        let text = try! String(contentsOfFile: path)
        let regex = try! NSRegularExpression(pattern: "\\w+\\(\"([^\"]*)\"\\)")
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            
            for match in matches {
                if let range = Range(match.range(at: 1), in: text) {
                    let extractedText = text[range]
                    matchedStrings.append(String(extractedText))
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
