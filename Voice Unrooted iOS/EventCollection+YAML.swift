//
//  EventCollection+YAML.swift
//  SwiftAudioKitTest
//
//  Created by James Bean on 11/19/16.
//  Copyright © 2016 Hans Tutschku. All rights reserved.
//

extension EventCollection {
    
    // MARK: YAML Parsing
    
    public enum YAMLScoreError: Error {
        case incorrectFormat
    }
    
    public static func populate(with yamlScore: Yaml) throws {
        events = try makeEvents(from: yamlScore)
    }
    
    private static func makeEvents(from yamlScore: Yaml) throws -> [Event] {
        
        guard let score = yamlScore.dictionary else {
            throw YAMLScoreError.incorrectFormat
        }
        
        return try score.map { (indexYAML, attributesYAML) in
            
            guard let indexString = indexYAML.string else {
                throw YAMLScoreError.incorrectFormat
            }
            
            guard let index = Int(indexString) else {
                throw YAMLScoreError.incorrectFormat
            }
            
            guard let event = Event(index: index, attributes: attributesYAML) else {
                throw YAMLScoreError.incorrectFormat
            }
            
            return event
        }
    }
    
    public func populate(with yamlScore: Yaml) throws {
        EventCollection.events = try EventCollection.makeEvents(from: yamlScore)
    }
}
