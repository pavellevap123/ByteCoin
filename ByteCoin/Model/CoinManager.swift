//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(_ coinManager: CoinManager, currencyModel: CurrencyModel)
    func didEndWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "?apikey=5866F0E7-84B1-4CC4-B2CF-6D0FCF477B26"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)\(apiKey)"
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didEndWithError(error: error!)
                }
                if let safeData = data {
                    if let price = parseJSON(safeData) {
                        let currencyModel = CurrencyModel(price: price, name: currency)
                        delegate?.didUpdatePrice(self, currencyModel: currencyModel)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let jsonDecoder = JSONDecoder()
        do {
            let decodedData = try jsonDecoder.decode(CoinData.self, from: data)
            return decodedData.rate
        }
        catch {
            print(error)
            return nil
        }
    }
}
