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
    case iOS_fetch_lemmata
    case android_find_errors
    case android_fetch_translations
    case fetch_translations_for_both
    case compareTranslations
    case combineTranslations
}

let option = RunOption(rawValue: ProcessInfo.processInfo.environment["runOption"]!)!

switch option {
case .iOS_find_errors:
    
    iOSParser.run_find_errors()
case .iOS_fetch_translations:
    
    let translations = iOSParser.run_extract_translations(runLemmataOnly: false)
    printTranslations(object: translations.sorted(), printOption: .json)
    print("total words: \(translations.count)")
case .iOS_fetch_lemmata:
    
    let translations = iOSParser.run_extract_translations(runLemmataOnly: true)
    printTranslations(object: translations.sorted(), printOption: .json)
    print("total words: \(translations.count)")
case .android_find_errors:
    
    AndroidParser.run_find_errors()
case .android_fetch_translations:
    
    let translations = AndroidParser.run_extract_translations()
    printTranslations(object: translations.sorted(), printOption: .json)
    print("total words: \(translations.count)")
case .compareTranslations:
    
    let iosTranslations = Set(iOSParser.run_extract_translations(replaceFormatters: true, runLemmataOnly: nil))
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
    var translations = iOSParser.run_extract_translations(runLemmataOnly: nil)
    translations = translations + AndroidParser.run_extract_translations()
    translations = Array(Set(translations))
    printTranslations(object: translations, printOption: .json)
    print("total words: \(translations.count)")
    
    
case .combineTranslations:
    
    let iosLegacy = Set(loadWordsJson(.iosLegacy))
    let iosSigma = Set(loadWordsJson(.iosSigma))
    let androidLegacy = Set(loadWordsJson(.androidLegacy))
    let androidSigma = Set(loadWordsJson(.androidSigma))
    let lemmata = Set(loadWordsJson(.Lemmata))
    
    let iOSOnlyOnLegacy = iosLegacy.subtracting(iosSigma)
    let iOSOnlyOnSigma = iosSigma.subtracting(iosLegacy)
    
    let androidOnlyLegacy = androidLegacy.subtracting(androidSigma)
    let androidOnlySigma = androidSigma.subtracting(androidLegacy)
    
    let totalWords = iosLegacy.union(iosSigma).union(androidLegacy).union(androidSigma).union(lemmata)
    
    print("iOS Legacy:\(iosLegacy.count) words")
    print("iOS Sigma:\(iosSigma.count) words")
    print("android Legacy:\(androidLegacy.count) words")
    print("android Sigma:\(androidSigma.count) words")
    print("iOS only on Legacy:\(iOSOnlyOnLegacy.count) words")
    print("iOS only on Sigma:\(iOSOnlyOnSigma.count) words")
    print("android only on Legacy:\(androidOnlyLegacy.count) words")
    print("android only on Sigma:\(androidOnlySigma.count) words")
    print("total words: \(totalWords.count) words")
    
    printTranslations(object: totalWords.sorted(), printOption: .json)

    
    
}
