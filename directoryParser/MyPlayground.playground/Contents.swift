import Cocoa
import Foundation


func find_group(forString string: NSString) -> NSString
{
    var matchedStrings : [NSString] = []
    
    
    //for text between quotes: (["'])(?:(?=(\\?))\2.)*?\1
    let regex = try! NSRegularExpression(pattern: "\\b(Curriculum|curriculum|a curriculum)\\b")
    
    let matches = regex.matches(in: string, options: [], range: NSRange(string.startIndex...,in: string))
    for aMatch in matches {
        
        let matchedString = String(string[Range(aMatch.range, in: string)!])
        print(matchedString)
        //let quoteIndex = matchedString.firstIndex(of: "\"")
        matchedStrings.append(matchedString)
        
        //let regex = try! NSRegularExpression(pattern: "([A-HK-PRSVWY][A-HJ-PR-Y])\\s?([0][2-9]|[1-9][0-9])\\s?[A-HJ-PR-Z]{3}", options: NSRegularExpression.Options.caseInsensitive)
       // let range = NSMakeRange(0, myString.count)
       // let modString = regex.stringByReplacingMatches(in: myString, options: [], range: range, withTemplate: "XX")//
       // print(modString)
        
        string.replacingOccurrences(of: matchedString, with: "lol", options: .anchored, range: aMatch.range)
       // [regexExpression stringByReplacingMatchesInString:strText options:0 range:NSMakeRange(0, [strText length]) withTemplate:@"B"];
       // string.replaceSubrange(aMatch.range, with: "lol")
    }
    
    return string
}


print(find_group(forString: "this a Curriculum and that is a curriculum and a curriculum"))


