//
//  GenreProviderImage.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/28/25.
//

enum GenreImage: String {
    case action = "Action"
    case adventure = "Adventure"
    case animation = "Animation"
    case comedy = "Comedy"
    case crime = "Crime"
    case documentary = "Documentary"
    case drama = "Drama"
    case family = "Family"
    case fantasy = "Fantasy"
    case history = "History"
    case horror = "Horror"
    case music = "Music"
    case mystery = "Mystery"
    case romance = "Romance"
    case scienceFiction = "Science Fiction"
    case tvMovie = "TV Movie"
    case thriller = "Thriller"
    case war = "War"
    case western = "Western"
    
    // TV genres (ek olarak)
    case kids = "Kids"
    case news = "News"
    case reality = "Reality"
    case sciFiFantasy = "Sci-Fi & Fantasy"
    case soap = "Soap"
    case talk = "Talk"
    case warPolitics = "War & Politics"
    case actionAdventure = "Action & Adventure"
    
    /// Genre string'ten enum oluşturmak için initializer
    init?(rawGenreName: String) {
        self.init(rawValue: rawGenreName)
    }
    
    var imageName: String {
        switch self {
        case .action: return "genre_action"
        case .adventure: return "genre_adventure"
        case .animation: return "genre_animation"
        case .comedy: return "genre_comedy"
        case .crime: return "genre_crime"
        case .documentary: return "genre_documentary"
        case .drama: return "genre_drama"
        case .family: return "genre_family"
        case .fantasy: return "genre_fantasy"
        case .history: return "genre_history"
        case .horror: return "genre_horror"
        case .music: return "genre_music"
        case .mystery: return "genre_mystery"
        case .romance: return "genre_romance"
        case .scienceFiction: return "genre_scifi"
        case .tvMovie: return "genre_tvmovie"
        case .thriller: return "genre_thriller"
        case .war: return "genre_war"
        case .western: return "genre_western"
        case .kids: return "genre_kids"
        case .news: return "genre_news"
        case .reality: return "genre_reality"
        case .sciFiFantasy: return "genre_scifi"
        case .soap: return "genre_soap"
        case .talk: return "genre_talk"
        case .warPolitics: return "genre_war"
        case .actionAdventure: return "genre_action"
        }
    }
}
