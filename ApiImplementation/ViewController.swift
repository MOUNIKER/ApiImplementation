//
//  ViewController.swift
//  ApiImplementation
//
//  Created by Siva Mouniker  on 25/07/23.
//

import UIKit

struct Album : Decodable{
    let userId: Int
    let id: Int
    let title: String
}

class ViewController: UIViewController {
    
    var tableView: UITableView!
    var albums: [Album] = []
    var expandedRows: Set<Int> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchAlbumsData()
    }

    func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
    }

    func fetchAlbumsData() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/albums") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let albums = try JSONDecoder().decode([Album].self, from: data)
                DispatchQueue.main.async {
                    self?.albums = albums
                    self?.tableView.reloadData()
                }
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        }.resume()
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let album = albums[indexPath.row]
        cell.textLabel?.text = "User ID: \(album.userId)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = albums[indexPath.row]
        if expandedRows.contains(album.userId) {
            expandedRows.remove(album.userId)
        } else {
            expandedRows.insert(album.userId)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let album = albums[indexPath.row]
        return expandedRows.contains(album.userId) ? 80 : 44
    }
}







