//
//  TriviaCategory.swift
//  
//
//  Created by Tino on 23/12/2022.
//

import Foundation

public enum TriviaCategory: CaseIterable, Identifiable, Hashable {
    static public var allCases: [TriviaCategory] = [
        .anyCategory, .generalKnowledge, .mythology, .sports, .geography, .history, .politics,
        .art, .celebrities, .animals, .vehicles
    ]
    + TriviaCategory.Entertainment.allCases.map { TriviaCategory.entertainment($0) }
    + TriviaCategory.Science.allCases.map { TriviaCategory.science($0) }
    
    public enum Entertainment: CaseIterable, Identifiable, Hashable {
        case books
        case film
        case music
        case musicalsAndTheatres
        case television
        case videoGames
        case boardGames
        case comics
        case japaneseAnimeAndManga
        case cartoonAndAnimations
        
        public var id: Int {
            switch self {
            case .books:
                return 10
            case .film:
                return 11
            case .music:
                return 12
            case .musicalsAndTheatres:
                return 13
            case .television:
                return 14
            case .videoGames:
                return 15
            case .boardGames:
                return 16
            case .comics:
                return 29
            case .japaneseAnimeAndManga:
                return 31
            case .cartoonAndAnimations:
                return 32
            }
        }
        
        public var title: String {
            switch self {
            case .books: return "Books"
            case .film: return "Film"
            case .music: return "Music"
            case .musicalsAndTheatres: return "Musicals and Theatres"
            case .television: return "Television"
            case .videoGames: return "Video games"
            case .boardGames: return "Boardgames"
            case .comics: return "Comics"
            case .japaneseAnimeAndManga: return "Japanese Anime and Manga"
            case .cartoonAndAnimations: return "Cartoon and Animations"
            }
        }
    }
    
    public enum Science: CaseIterable, Identifiable, Hashable {
        case scienceAndNature
        case computers
        case mathematics
        case gadgets
        
        public var id: Int {
            switch self {
            case .scienceAndNature:
                return 17
            case .computers:
                return 18
            case .mathematics:
                return 19
            case .gadgets:
                return 30
            }
        }
        
        public var title: String {
            switch self {
            case .scienceAndNature: return "Science and Nature"
            case .computers: return "Computers"
            case .mathematics: return "Mathematics"
            case .gadgets: return "Gadgets"
            }
        }
    }
    
    case anyCategory
    case generalKnowledge
    case mythology
    case sports
    case geography
    case history
    case politics
    case art
    case celebrities
    case animals
    case vehicles
    case entertainment(Entertainment)
    case science(Science)
    
    public var id: Int {
        switch self {
        case .anyCategory:
            return 0
        case .generalKnowledge:
            return 9
        case .mythology:
            return 20
        case .sports:
            return 21
        case .geography:
            return 22
        case .history:
            return 23
        case .politics:
            return 24
        case .art:
            return 25
        case .celebrities:
            return 26
        case .animals:
            return 27
        case .vehicles:
            return 28
        case .entertainment(let entertainment):
            return entertainment.id
        case .science(let science):
            return science.id
        }
    }
    
    public var title: String {
        switch self {
        case .anyCategory: return "Any Category"
        case .generalKnowledge: return "General Knowledge"
        case .mythology: return "Mythology"
        case .sports: return "Sports"
        case .geography: return "Geography"
        case .history: return "History"
        case .politics: return "Politics"
        case .art: return "Art"
        case .celebrities: return "Celebrities"
        case .animals: return "Animals"
        case .vehicles: return "Vehicles"
        case .entertainment(let entertainment): return entertainment.title
        case .science(let science): return science.title
        }
    }
}
