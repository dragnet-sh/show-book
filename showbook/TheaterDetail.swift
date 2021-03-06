//
//  TheaterDetail.swift
//  showbook
//
//  Created by Binay Budhthoki on 11/16/17.
//  Copyright © 2017 Mojo Monkies. All rights reserved.
//

import UIKit
import CleanroomLogger
import Parse
import Gloss

class TheaterDetail: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
 
    @IBOutlet weak var moviePicker: UIPickerView!
    @IBOutlet weak var theaterLabel: UILabel!
    @IBOutlet weak var labelSelectedMovie: UILabel!
    
    var selectedTheater:String = ""
    var selectedMovie: String = ""
    
    var movieData:Array<String> = []
    var timePickerData:Array<String> = []
    
    var mojoShow: Show?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.theaterLabel.text = selectedTheater

        moviePicker.delegate = self
        moviePicker.dataSource = self

        self.timePickerData = ["8 AM", "12 PM", "3 PM", "7 PM", "10 PM"]
        
        // Sample GLOSS Section to see if the JSON gets parsed
        let json: AnyObject
        
        let url = Bundle.main.url(forResource: "movie", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        
        json = try! JSONSerialization.jsonObject(with: data, options: []) as AnyObject
        let dictionary = json as? [String: Any]
        
        // Loading the movies array form the JSON file
        let movies = ShowBookMovies(json: dictionary!)
        for movie in (movies?.movies)! {
            self.movieData.append(movie.title!)
        }
    }
    
    
    // JSON Parse Classes - GLOSS
    public struct ShowBookMovies: JSONDecodable {
        public let movies: [Movies]?
        
        public init?(json: JSON) {
            self.movies = "movies" <~~ json
        }
    }
    
    public struct Movies: JSONDecodable {
        public let title: String?
        
        public init?(json: JSON) {
            self.title = "title" <~~ json
        }
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return movieData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return movieData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedMovie = movieData[row]
        Log.info?.message("Selected Movie is \(selectedMovie)")
        labelSelectedMovie.text = "Your selected movie is \(selectedMovie) !!"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let lower : UInt32 = 0
        let upper : UInt32 = 6
        let randomNumber = arc4random_uniform(upper - lower) + lower
        Log.info?.message("Random \(randomNumber)")
        
        moviePicker.selectRow(Int(randomNumber), inComponent: 0, animated: true)
        selectedMovie = movieData[Int(randomNumber)]
        labelSelectedMovie.text = "Mojo Recommends \(selectedMovie) !!"
    }
    
    @IBAction func btnBookShowPress(_ sender: Any) {
        Log.info?.message("## Book Show ##")
        
        let myMovie = Movie(title: selectedMovie)
        let myTheater = Theater(name: selectedTheater)
        
        mojoShow?.setMovie(movie: myMovie)
        mojoShow?.setTheater(theater: myTheater)
        mojoShow?.save()
        
        Log.info?.message((mojoShow?.describe())!)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}

