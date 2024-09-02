//
//  Utils.swift
//  directoryParser
//
//  Created by Nikos Grigoriadis on 11/5/20.
//

import Foundation


enum PrintOption {
    case json
    case array
}

func printTranslations(object: Any, printOption: PrintOption)
{
    if printOption == .json {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            exit(1)
        }
        let textsJSON = String(data: data, encoding: String.Encoding.utf8)
        
        print("\(textsJSON ?? "")")
    } else if let translations = object as? [String], printOption == .array {
        
        for translation in translations {
            print(translation)
        }
    }
    
}


func isCodeFile(atPath path: String) -> Bool
{
    let pathExtension = URL(fileURLWithPath: path).pathExtension
    return pathExtension == "swift" || pathExtension == "m" || pathExtension == "java" || pathExtension == "kt"//|| pathExtension == "xml"
}

func isObjcFile(atPath path: String) -> Bool
{
    let pathExtension = URL(fileURLWithPath: path).pathExtension
    return pathExtension == "m"
}

func isDirectoryFile(atPath path: String) -> Bool
{
    var isDir : ObjCBool = false
    if FileManager.default.fileExists(atPath: path, isDirectory:&isDir) {
        return isDir.boolValue
    } else {
        return false
    }
}

func getAllFilesFromDirectory(atPath path: String) -> [String]
{
    let rootDir = NSURL(fileURLWithPath: path)
    let rootFiles = try! FileManager.default.contentsOfDirectory(atPath: rootDir.path!)
    var filesList : [String] = []
    
    for aPath in rootFiles {
        let currentFileURL = rootDir.appendingPathComponent(aPath)!.path
        if isDirectoryFile(atPath: currentFileURL) {
            if !currentFileURL.contains("DerivedData") && !currentFileURL.contains(".git") {
                filesList = filesList + getAllFilesFromDirectory(atPath: currentFileURL)
            } 
        } else {
            if isCodeFile(atPath: currentFileURL) && !currentFileURL.hasSuffix("TextViewController.m") && !currentFileURL.hasSuffix("AWSSTSResources.m") && !currentFileURL.hasSuffix("AWSS3Resources.m") {
                filesList.append(currentFileURL)
            }
        }
    }
    
    return filesList
}



func parseJavaFileForAndroid(atPath path: String) -> [String]
{
    var matchedStrings : [String] = []
    
    let text = try! String(contentsOfFile: path)
    let regex = try! NSRegularExpression(pattern: "getMobileText(?:(?![])]).)*")
    
    let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex...,in: text))
    for aMatch in matches {
        var matchedString = String(text[Range(aMatch.range, in: text)!])
        matchedString = matchedString.replacingOccurrences(of: "getMobileText:@\"", with: "")
        matchedString = matchedString.replacingOccurrences(of: "getMobileText:", with: "")
        matchedString = matchedString.replacingOccurrences(of: "getMobileText(\"", with: "")
        matchedString = matchedString.replacingOccurrences(of: "\"", with: "")
        matchedStrings.append(matchedString)
    }
    
    return matchedStrings
}

func parseXMLFileForAndroid(atPath path: String) -> [String]
{
    var matchedStrings : [String] = []
    
    let text = try! String(contentsOfFile: path)
    let regex = try! NSRegularExpression(pattern: "app:mobileText(?:(?![])]).)*")
    
    let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex...,in: text))
    for aMatch in matches {
        var matchedString = String(text[Range(aMatch.range, in: text)!])
        matchedString = matchedString.replacingOccurrences(of: "app:mobileText=\'@{\"", with: "")
        matchedString = matchedString.replacingOccurrences(of: "app:mobileText=\"@{", with: "")
        matchedString = matchedString.replacingOccurrences(of: "\"}\'", with: "")
        matchedString = matchedString.replacingOccurrences(of: "}\"", with: "")
        matchedStrings.append(matchedString)
    }
    
    return matchedStrings
}

enum JSONFileType: String {
    case iosLegacy
    case iosSigma
    case androidLegacy
    case androidSigma
}

func loadWordsJson(_ filename: JSONFileType) -> [String] {
    
    let rootDir = NSURL(fileURLWithPath: "/Users/nikosgrigoriadis/PhpstormProjects/schoox_translationsParser/directoryParser/\(filename.rawValue).json")
    do {
        let data = try Data(contentsOf: rootDir as URL)
        let decoder = JSONDecoder()
        let jsonData = try decoder.decode([String].self, from: data)
        return jsonData
    } catch {
        print("Error reading or decoding file: \(error)")
    }
    return []
}

func uniq<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
    var buffer = [T]()
    var added = Set<T>()
    for elem in source {
        if !added.contains(elem) {
            buffer.append(elem)
            added.insert(elem)
        }
    }
    return buffer
}

func getJson(from object:Any) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
        return nil
    }
    return String(data: data, encoding: String.Encoding.utf8)
}


extension String {
    subscript(index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}

extension String {
    public func levenshtein(_ other: String) -> Int {
        let sCount = self.count
        let oCount = other.count

        guard sCount != 0 else {
            return oCount
        }

        guard oCount != 0 else {
            return sCount
        }

        let line : [Int]  = Array(repeating: 0, count: oCount + 1)
        var mat : [[Int]] = Array(repeating: line, count: sCount + 1)

        for i in 0...sCount {
            mat[i][0] = i
        }

        for j in 0...oCount {
            mat[0][j] = j
        }

        for j in 1...oCount {
            for i in 1...sCount {
                if self[i - 1] == other[j - 1] {
                    mat[i][j] = mat[i - 1][j - 1]       // no operation
                }
                else {
                    let del = mat[i - 1][j] + 1         // deletion
                    let ins = mat[i][j - 1] + 1         // insertion
                    let sub = mat[i - 1][j - 1] + 1     // substitution
                    mat[i][j] = min(min(del, ins), sub)
                }
            }
        }

        return mat[sCount][oCount]
    }
}
