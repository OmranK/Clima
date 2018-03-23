//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

struct PropertyKeys {
    static var changeCitySegueIdentifier = "changeCityName"
}

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    var weatherFormat = "Celcius"
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    
    }
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            getWeatherData(url: "http://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&APPID=858028822f3fb68be88652c46b8e7075")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    
    func getWeatherData(url: String) {
        
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                print(weatherJSON)
            } else {
                print("Error \(response.result.error)")
                self.cityLabel.text = "Connection Issue"
            }
        }
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    func updateWeatherData(json : JSON) {
        if let tempResult = json["main"]["temp"].double {
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        } else if json["cod"] == "404"{
            cityLabel.text = "City Name Not Recognized "
        } else {
            cityLabel.text = "Weather Unavailable "
        }
    }
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    func updateUIWithWeatherData () {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)ºC"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }

    //MARK: - Change to Fahrenheit
    /***************************************************************/
    
    @IBAction func changeToFahrenheitButtonTapped(_ sender: UIButton) {
        if weatherFormat == "Celcius" {
            temperatureLabel.text = "\(Int(Double(weatherDataModel.temperature) * 1.8 + 32))ºF"
            weatherFormat = "Fahrenheit"
        } else if weatherFormat == "Fahrenheit" {
            temperatureLabel.text = "\(weatherDataModel.temperature)ºC"
            weatherFormat = "Celcius"
        }
    }
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    func userEnteredANewCityName(city: String) {
        
        getWeatherData(url: "http://api.openweathermap.org/data/2.5/weather?q=\(city)&APPID=858028822f3fb68be88652c46b8e7075")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PropertyKeys.changeCitySegueIdentifier {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
}



