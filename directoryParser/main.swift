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
    printTranslations(object: translations, printOption: .json)
    print("total words: \(translations.count)")
case .android_find_errors:
    AndroidParser.run_find_errors()
case .android_fetch_translations:
    let translations = AndroidParser.run_extract_translations()
    printTranslations(object: translations.sorted(), printOption: .array)
    print("total words: \(translations.count)")
case .compareTranslations:
    
    let iosTranslations = Set(iOSParser.run_extract_translations(replaceFormatters: true))
    let androidTranslations = Set(AndroidParser.run_extract_translations(replaceFormatters: true))
    
    var iOSonly = iosTranslations.subtracting(androidTranslations)
    iOSonly = Set(iOSonly.sorted())
    var androidOnly = androidTranslations.subtracting(iosTranslations)
    androidOnly = Set(androidOnly.sorted())
    let common = iosTranslations.filter{(translation)->Bool in
        return androidTranslations.contains(translation)
    }
    
    print("ios total: \(iosTranslations.count)")
    print("android total: \(androidTranslations.count)")
    print("only on ios: \(iOSonly.count)")
    print("only on android: \(androidOnly.count)")
    print("common: \(common.count)")
    

    
case .fetch_translations_for_both:
    var translations = iOSParser.run_extract_translations()
    translations = translations + AndroidParser.run_extract_translations()
    translations = Array(Set(translations))
    printTranslations(object: translations, printOption: .json)
    print("total words: \(translations.count)")
}
