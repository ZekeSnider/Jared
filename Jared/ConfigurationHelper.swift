//
//  ConfigurationHelper.swift
//  Jared
//
//  Created by Zeke Snider on 8/22/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import Foundation
import AppKit

struct ConfigurationHelper {
    static let fileManager = FileManager.default

    static func getConfiguration() -> ConfigurationFile {
        let configPath = ConfigurationHelper.getSupportDirectory()
            .appendingPathComponent("config.json")
        ConfigurationHelper.createConfigFileIfNotExists(at: configPath, using: fileManager)

        do {
            let jsonData = try NSData(contentsOfFile: configPath.path, options: .mappedIfSafe)
            let parsedConfig = try JSONDecoder().decode(ConfigurationFile.self, from: jsonData as Data)
            return parsedConfig
        } catch {
            let errorMessage = "Unable to parse configuration file, using default. error was \(error)"
            print(errorMessage)

            let alert = NSAlert(error: error)
            alert.messageText = "Configuration Error"
            alert.informativeText = errorMessage
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()



            return ConfigurationFile()


        }
    }

    static func getSupportDirectory() -> URL {
        let filemanager = FileManager.default
        let appsupport = filemanager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let supportDir = appsupport.appendingPathComponent("Jared")

        try! filemanager.createDirectory(at: supportDir, withIntermediateDirectories: true, attributes: nil)

        return supportDir
    }

    static func getPluginDirectory() -> URL {
        let supportDir = getSupportDirectory()
            .appendingPathComponent("Plugins")

        try! fileManager.createDirectory(at: supportDir, withIntermediateDirectories: true, attributes: nil)

        return supportDir
    }

    //Copy an empty config file if the conig file does not exist
    private static func createConfigFileIfNotExists(at path: URL, using fileManager: FileManager) {
        //Copy an empty config file if the conig file does not exist
        if !fileManager.fileExists(atPath: path.path) {
            try! fileManager.copyItem(at: (Bundle.main.resourceURL?.appendingPathComponent("config.json"))!, to: path)
        }
    }
}
