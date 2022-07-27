//
//  main.swift
//  directoryParser
//
//  Created by Nikos Grigoriadis on 11/5/20.
//

import Foundation

enum RunOption: String {
    case iOS_find_errors
    case iOS_fetch_translations
    case android_find_errors
    case android_fetch_translations
    case fetch_translations_for_both
    case compareTranslations
}

let option = RunOption(rawValue: ProcessInfo.processInfo.environment["runOption"]!)!

switch option {
case .iOS_find_errors:
    iOSParser.run_find_errors()
case .iOS_fetch_translations:
    let translations = iOSParser.run_extract_translations()
    jsonprint(object: translations)
    print("total words: \(translations.count)")
case .android_find_errors:
    AndroidParser.run_find_errors()
case .android_fetch_translations:
    let translations = AndroidParser.run_extract_translations()
    jsonprint(object: translations)
    print("total words: \(translations.count)")
case .compareTranslations:
    
    let iosTranslations = Set(iOSParser.run_extract_translations())
    let androidTranslations = Set(AndroidParser.run_extract_translations())
    
    let iOSonly = iosTranslations.subtracting(androidTranslations)
    let androidOnly = androidTranslations.subtracting(iosTranslations)
    let common = iosTranslations.filter{(translation)->Bool in
        return androidTranslations.contains(translation)
    }
    
    print("ios total: \(iosTranslations.count)")
    print("android total: \(androidTranslations.count)")
    print("only on ios: \(iOSonly.count)")
    print("only on android: \(androidOnly.count)")
    print("common: \(common.count)")
    
    var similar_1: [String:[String]] = ["":[]]
    var similar_2: [String:[String]] = ["":[]]
    var similar_3: [String:[String]] = ["":[]]
    for iosWord in iOSonly {
        for androidWord in androidOnly {
            let countDif = abs(androidWord.count - iosWord.count)
            if countDif == 1 && iosWord.levenshtein(androidWord) == 1 {
                if similar_1[iosWord] == nil {
                    similar_1[iosWord] = [androidWord]
                } else {
                    similar_1[iosWord]!.append(androidWord)
                }
            } else if countDif == 2 && iosWord.levenshtein(androidWord) == 2 {
                if similar_2[iosWord] == nil {
                    similar_2[iosWord] = [androidWord]
                } else {
                    similar_2[iosWord]!.append(androidWord)
                }
            } else if countDif == 3 && iosWord.levenshtein(androidWord) == 3 {
                if similar_3[iosWord] == nil {
                    similar_3[iosWord] = [androidWord]
                } else {
                    similar_3[iosWord]!.append(androidWord)
                }
            }
        }
    }
    print("need 1 change: \(similar_1)")
    
case .fetch_translations_for_both:
    var translations = iOSParser.run_extract_translations()
    translations = translations + AndroidParser.run_extract_translations()
    translations = Array(Set(translations))
    jsonprint(object: translations)
    print("total words: \(translations.count)")
}
