//
//  iOS.swift
//  directoryParser
//
//  Created by Nikos Grigoriadis on 12/4/22.
//

import Foundation
import AppKit

class iOSParser
{
    private static var iosProjectDirectory = getAllFilesFromDirectory(atPath: "/Users/nikosgrigoriadis/schoox_ios2")
    
    class func run_find_errors()
    {
        NSSpellChecker.shared.setLanguage("en")
        NSSpellChecker.shared.learnWord("coachee")
        NSSpellChecker.shared.learnWord("enrollment")
        NSSpellChecker.shared.learnWord("initializing")
        NSSpellChecker.shared.learnWord("unsubmitted")
        NSSpellChecker.shared.learnWord("coachees")
        NSSpellChecker.shared.learnWord("organization")
        NSSpellChecker.shared.learnWord("organizational")
        NSSpellChecker.shared.learnWord("personalized")
        NSSpellChecker.shared.learnWord("authorized")
        NSSpellChecker.shared.learnWord("Unassign")
        NSSpellChecker.shared.learnWord("Curriculum")
        NSSpellChecker.shared.learnWord("Unassign Curriculum")
        NSSpellChecker.shared.learnWord("Unassign Event")
        NSSpellChecker.shared.learnWord("Unassign Course")
        NSSpellChecker.shared.learnWord("member`s")
        NSSpellChecker.shared.learnWord("synchronization")
        NSSpellChecker.shared.learnWord("Synchronizing")
        
        
        //
        var errorDict: [String:[String]] = [:]
        var percentage = 0
        
        for aFile in iosProjectDirectory {
          //  print("checking file \(aFile)")
            if let foundErrors = find_Punctunation_Errors(atPath: aFile), !foundErrors.isEmpty {
                errorDict[aFile] = foundErrors
                print("files with error: \(errorDict.keys.count)")
            }

            if let foundErrors = find_Append_Errors(atPath: aFile), !foundErrors.isEmpty {
                errorDict[aFile] = foundErrors
                print("files with error: \(errorDict.keys.count)")
            }

            if let foundErrors = find_LeadingErrors_objc(atPath: aFile), !foundErrors.isEmpty {
                errorDict[aFile] = foundErrors
                print("files with error: \(errorDict.keys.count)")
            }

            if let foundErrors = find_doubleTextMobile(atPath: aFile), !foundErrors.isEmpty {
                errorDict[aFile] = foundErrors
                print("files with error: \(errorDict.keys.count)")
            }

            if let foundErrors = find_wrongStringFormat_Errors(atPath: aFile), !foundErrors.isEmpty {
                errorDict[aFile] = foundErrors
                print("files with error: \(errorDict.keys.count)")
            }

            if let foundErrors = find_translationTextError(atPath: aFile), !foundErrors.isEmpty {
                errorDict[aFile] = foundErrors
                print("files with error: \(errorDict.keys.count)")
            }
            if let foundErrors = fetchWrongStringFormatError(atPath: aFile), !foundErrors.isEmpty {
                errorDict[aFile] = foundErrors
                print("files with error: \(errorDict.keys.count)")
            }
//
            let current = iosProjectDirectory.firstIndex(of: aFile)!
            
            let updatedPercentage =  Int(Double(current) / Double(iosProjectDirectory.count) * 100.0)
            if updatedPercentage != percentage {
                percentage = updatedPercentage
                print("\(percentage)%")
            }
        }
        
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
        }
    }
    
    class func run_extract_translations(replaceFormatters: Bool = false) -> Array<String>
    {
        var texts: [String] = []
        var percentage = 0
        
        for aFile in iosProjectDirectory {
            
            texts = texts + fetchTranslations(atPath: aFile)
            
            let current = iosProjectDirectory.firstIndex(of: aFile)!
            let updatedPercentage =  Int(Double(current) / Double(iosProjectDirectory.count) * 100.0)
            if updatedPercentage != percentage {
                percentage = updatedPercentage
                print("\(percentage)%")
            }
        }
        
        
        if replaceFormatters {
            return Array(Set(texts)).map {
                $0.replacingOccurrences(of: "%@", with: "{formatter}")
                    .replacingOccurrences(of: "%d", with: "{formatter}")
                    .replacingOccurrences(of: "%lu", with: "{formatter}")
                    .replacingOccurrences(of: "%ld", with: "{formatter}")
                    .replacingOccurrences(of: "%.f", with: "{formatter}")
                    .replacingOccurrences(of: "%.0f", with: "{formatter}")
                    .replacingOccurrences(of: "%02ld", with: "{formatter}")
            }
        } else {
            return Array(Set(texts))
        }
//        guard let data = try? JSONSerialization.data(withJSONObject: uniqueTexts, options: []) else {
//            return
//        }
//        let textsJSON = String(data: data, encoding: String.Encoding.utf8)
//
//        print("\(textsJSON ?? "")")
//        print("end")
    }
    
    private class func find_LeadingErrors_objc(atPath path: String) -> [String]?
    {
        if !isObjcFile(atPath: path) {
            return nil
        }
        var matchedStrings : [String] = []
        
        guard let text = try? String(contentsOfFile: path) else {
            return nil
        }
        //for text between quotes: (["'])(?:(?=(\\?))\2.)*?\1
        let regex = try! NSRegularExpression(pattern: "(.*%@[:|!]|.*[\\?]).*getTextMobile.*")
        
        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex...,in: text))
        for aMatch in matches {
            
            let matchedString = String(text[Range(aMatch.range, in: text)!])
            //let quoteIndex = matchedString.firstIndex(of: "\"")
            matchedStrings.append(matchedString)
        }
        
        return matchedStrings
    }
    /*
     elegxos se obj gia to stringWithFormat
     la8os:
     [self.pollStatusLabel setText:[NSString stringWithFormat:@"%@",[StringsContainer getTextMobile:@"Completed"]]];
     swsto
     [self.pollStatusLabel setText:[StringsContainer getTextMobile:@"Completed"]];
     */
    private class func find_wrongStringFormat_Errors(atPath path: String) -> [String]?
    {
        if !path.hasSuffix("m") {
            return nil
        }
        var matchedStrings : [String] = []
        
        guard let text = try? String(contentsOfFile: path) else {
            return nil
        }
        let regex = try! NSRegularExpression(pattern: "..*%@.*getTextMobile.*")//leading side
        matchedStrings = get(matchesForRegularExpression:regex, fromText: text)
        
        return matchedStrings
    }
    
    /*
     elegxos meta to =
     oxi (,!,?,: prin kai meta to getTextMobile
     
     examples:
     newInstance?.staticStratingDate.text = "?" + StringsContainer.getTextMobile("Due Date")+":"
     
     */
    private class func find_Punctunation_Errors(atPath path: String) -> [String]?
    {
        if !path.hasSuffix("swift") && !path.hasSuffix("m") {
            return nil
        }
        var matchedStrings : [String] = []
        
        guard let text = try? String(contentsOfFile: path) else {
            return nil
        }
        //for text between quotes: (["'])(?:(?=(\\?))\2.)*?\1
        let notAllowedChars = ":|?|!|)|(|.|,|<|>|_|+|-"
        
        var regex = try! NSRegularExpression(pattern: ".*=.*(\"+.*\\\\?[" + notAllowedChars + "]+[ ]*\").*getTextMobile.*")//leading side
        matchedStrings = get(matchesForRegularExpression:regex, fromText: text)
        
        regex = try! NSRegularExpression(pattern: ".*=.*getTextMobile[\\s:(@]+([\"'])(?:(?=(\\\\?))\\2.)*?\\1.*(\"+.*\\\\?[" + notAllowedChars + "]+[ ]*\").*")//trailing side
        matchedStrings = get(matchesForRegularExpression: regex, fromText: text, UsingExistingMatches: matchedStrings)
        
        return matchedStrings
    }

    /*
     return all lines that have a leading/trailing "+" when there is a getTextMobile
     */
    private class func find_Append_Errors(atPath path: String) -> [String]?
    {
        if !path.hasSuffix("swift") && !path.hasSuffix("m") {
            return nil
        }
        guard let text = try? String(contentsOfFile: path) else {
            return nil
        }
        
        var matchedStrings : [String] = []
        if path.hasSuffix("swift") {
            //swift leading "+" symbol
            var regex = try! NSRegularExpression(pattern: ".*(\\+)+.*getTextMobile.*")
            matchedStrings = get(matchesForRegularExpression:regex, fromText: text)
            //swift trailing "+" symbol
            regex = try! NSRegularExpression(pattern: ".*getTextMobile.*(\\+)+.*")
            matchedStrings = matchedStrings + get(matchesForRegularExpression:regex, fromText: text)
        }
        
        //ignore withspace strings
        var resultArray : [String] = []
        for matchedString in matchedStrings {
            
            if matchedString.components(separatedBy: " ").count == matchedString.components(separatedBy: "+").count
                || matchedString.components(separatedBy: "  ").count == matchedString.components(separatedBy: "+").count {
                print("ignored string: \(matchedString)")
            } else {
                resultArray = resultArray + [matchedString]
            }
        }
        
        return resultArray
    }
    
    /*
     return all lines that container two or more getTextMobile
     */
    private class func find_doubleTextMobile(atPath path: String) -> [String]?
    {
        if !path.hasSuffix("swift") && !path.hasSuffix("m") {
            return nil
        }
        
        var matchedStrings : [String] = []
        
        guard let text = try? String(contentsOfFile: path) else {
            return nil
        }
        //for text between quotes: (["'])(?:(?=(\\?))\2.)*?\1
        let regex = try! NSRegularExpression(pattern: ".*getTextMobile.*getTextMobile.*")
        
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
     ends with period
     contains "are you sure?"
     spell checking
     */
    private class func find_translationTextError(atPath path: String) -> [String]?
    {
        if !path.hasSuffix("swift") && !path.hasSuffix("m") {
            return nil
        }
        var matchedStrings : [String] = []
        
        let texts = fetchTranslations(atPath: path)
        for aText in texts {
            if aText.contains("...")
                || aText.contains("\\u")
                || aText.hasPrefix(" ")
                || aText.hasSuffix(" ")
                || aText.hasSuffix(".")
                || aText.lowercased().contains("are you sure?")
                || !isCorrect(word: aText)
                || aText.contains("|")
                || aText.lowercased().contains("e.g")
                || aText.contains("Eg.")
                || aText.lowercased().contains("user")
                || aText.contains("|")
                || aText.contains("•")
                || (aText.contains("-") && !aText.contains("-%"))
                || aText.contains("--"){
                matchedStrings.append(aText)
            }
        }
        //… \u2026
        //• \u2022
        //© \u00A9
        
        
        return matchedStrings
    }
    
    private class func isCorrect(word: String)->Bool{
        
        let range = NSSpellChecker.shared.checkSpelling(of: word, startingAt: 0)
        //let range = NSSpellChecker.shared.checkGrammar(of: word, startingAt: 0, language: "en", wrap: true, inSpellDocumentWithTag: 0, details: nil)
        if range.location != NSNotFound {
            print("O:" + word)
            print("I:" + NSString(string: word).substring(with: range))
        }
        return range.location == NSNotFound
    }
    /*
     return all lines that use a translated string and getTextMobile is not its format
     */
    private class func fetchWrongStringFormatError(atPath path: String) -> [String]?
    {
        if !path.hasSuffix("swift") && !path.hasSuffix("m") {
            return nil
        }
        
        var matchedStrings : [String] = []
        
        guard let text = try? String(contentsOfFile: path) else {
            return nil
        }
        //for text between quotes: (["'])(?:(?=(\\?))\2.)*?\1
        let regex = try! NSRegularExpression(pattern: ".*format.*%@.*.getTextMobile.*")
        
        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex...,in: text))
        for aMatch in matches {
            
            let matchedString = String(text[Range(aMatch.range, in: text)!])
            //let quoteIndex = matchedString.firstIndex(of: "\"")
            matchedStrings.append(matchedString)
        }
        return matchedStrings
    }
    
    /*
     fetches all translations from the given file
     */
    private class func fetchTranslations(atPath path: String) -> [String]
    {
        var matchedStrings : [String] = []
        
        let text = try! String(contentsOfFile: path)
        //for text between quotes: (["'])(?:(?=(\\?))\2.)*?\1
        
        let regex = try! NSRegularExpression(pattern: "getTextMobile[\\s:(@]+([\"'])(?:(?=(\\\\?))\\2.)*?\\1")
        
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
        
        
        if text.contains("TranslatableTextAPI") {
            let regex = try! NSRegularExpression(pattern: "return \"(.*)\"")
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
        }
        
        return matchedStrings
    }
    
    private class func get(matchesForRegularExpression regex: NSRegularExpression, fromText text: String, UsingExistingMatches matchedStrings: [String] = []) -> [String]
    {
        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex...,in: text))
        var mutableMatchedStrings = [] + matchedStrings
        
        for aMatch in matches {
            let matchedString = String(text[Range(aMatch.range, in: text)!])
            if !mutableMatchedStrings.contains(matchedString) {
                mutableMatchedStrings.append(matchedString)
            }
        }
        
        return mutableMatchedStrings
    }
    
    //find lines that contain "format" followed by "getTextMobile"
//    private class func find_StringFormatAndGetMobileText(atPath path: String) -> [String]?
//    {
//        if !path.hasSuffix("swift") && !path.hasSuffix("m") {
//            return nil
//        }
//        var matchedStrings : [String] = []
//
//        guard let text = try? String(contentsOfFile: path) else {
//            return nil
//        }
//        //for text between quotes: (["'])(?:(?=(\\?))\2.)*?\1
//        let regex = try! NSRegularExpression(pattern: ".*format.*.getTextMobile.*")
//
//        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex...,in: text))
//        for aMatch in matches {
//
//            let matchedString = String(text[Range(aMatch.range, in: text)!])
//            //let quoteIndex = matchedString.firstIndex(of: "\"")
//            matchedStrings.append(matchedString)
//        }
//
//        return matchedStrings
//    }
    
    
    
    /*
     NSString *test = [NSString stringWithFormat:[StringsContainer getTextMobile:@"Estimated Time Required %@"], @"test"];
     let test = String(format: StringsContainer.getTextMobile("Estimated Time Required %@"), "test")
     let test = StringsContainer.getTextMobile("Estimated Time Required test")
     */
    
    /*
     examples
     
     should be ok:
     
     leading issues:
     
     newInstance?.staticStratingDate.text = "?" + StringsContainer.getTextMobile("Due Date")+":"
     futureAssignmentsOptionalLabel.text = "("+StringsContainer.getTextMobile("Optional")+")"
     self.successStaticLabel.text = [NSString stringWithFormat:@"%@!", [StringsContainer getTextMobile:@"Success"]];
     
     trailing issues:
     
     staticNextLevelLabel.text = StringsContainer.getTextMobile("Level")+":"
     progressStaticLabel.text = "\(StringsContainer.getTextMobile("Progress")!):"
     sendCopyToInboxStaticLabel.text = StringsContainer.getTextMobile("Send copy to inbox")+"?"
     futureAssignmentsOptionalLabel.text = "("+StringsContainer.getTextMobile("Optional")+")"
     cellStatusLabel.text = StringsContainer.getTextMobile("Pending") + "!"

     
     
     inside quotes issues:
     
     StringsContainer.getTextMobile("Preparing...")
     
     
     inline ifs:
     numberOfTasks.text = String(goalItem.nrOfTasks)+" "+(goalItem.nrOfTasks == 1 ? StringsContainer.getTextMobile("Task") : StringsContainer.getTextMobile("Tasks"))
     
     multiple getTextMobile:
     generalDashboardItem.updateDateString = [NSString stringWithFormat:@"%@ %@ %@ %@",[StringsContainer getTextMobile:@"Last update on"],[DateUtils getDateStringWithTimestamp:newTime format:@"MMM dd, yyyy" isMiliseconds:NO],[StringsContainer getTextMobile:@"at"],[DateUtils getDateStringWithTimestamp:newTime format:@"hh:mm aa" isMiliseconds:NO]];
     let string = StringsContainer.getTextMobile("Attachments")+" \u{2022} "+StringsContainer.getTextMobile("Recipients")+" \u{2022} "
     
     */
    
    //den exw piasei akoma
    
    //uploadedFileDownloadButton.titleLabel?.text = String(format: "%@", StringsContainer.getTextMobile("Download"))

}
