//
//  DataStore.swift
//  SwiftAudioKitTest
//
//  Created by James Bean on 11/5/16.
//  Copyright © 2016 Hans Tutschku. All rights reserved.
//

import Alamofire
import AudioKit
// TODO: Import `YamlSwift` as framework rather that injecting source directly

public struct DataStore {
    
    // TODO: Implement DataRetrievalError
    
    private static var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// Produce the YAML score stored on the machine
    public static func retrieveScoreFromLocalStore(name: String) throws -> Yaml {
        let path = documentDirectory.appendingPathComponent("\(name)_score.yaml")
        let yamlString = try String(contentsOf: path)
        
        print("YAML: \(yamlString)")
        
        return try Yaml.load(yamlString)
    }
    
    /// Downloads score from `tutschku.com`
    public static func retrieveScoreFromNetwork(
        pieceName: String = "voice_unrooted",
        completion: @escaping () -> ()
    ) throws
    {
        // Format file name with piece name
        let fileName = "\(pieceName)_score.yaml"
        
        // Web storage of score
        let sourceURL = "http://tutschku.com/iPhone-events/voice_unrooted/\(fileName)"
        
        // Tell Alamofire to download score to `documentDirectory`.
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        // Download score with configuration, performing `completion` upon success.
        Alamofire.download(sourceURL, to: destination).response { _ in completion() }
    }
    
    /// Returns the names for audio files that do not exist on the machine
    public static func audioFilesUnavailableLocally(from names: [String]) -> [String] {
        
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Return only the names for files which do not exist on the machine
        return names.filter { name in
            let filePath = url.appendingPathComponent("\(name).caf").path
            return !fileManager.fileExists(atPath: filePath)
        }
    }

    internal static func retrieveAudioFilesFromNetwork(
        audioFileNames: [String],
        progress: @escaping () -> ()
    ) throws
    {
        // The location from which we will download the audio files
        let hansURL = "http://tutschku.com/iPhone-events/voice_unrooted/sound_files"
        
        // Tell Alamofire to download score to `documentDirectory`.
        let destination = DownloadRequest.suggestedDownloadDestination(
            for: .documentDirectory
        )
        
        // Download score with configuration, performing `progress` upon success of each.
        audioFileNames.forEach { name in
            let sourceURL = "\(hansURL)/\(name).caf"
            Alamofire.download(sourceURL, to: destination).response { _ in progress() }
        }
    }
}
