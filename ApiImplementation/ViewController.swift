//
//  ViewController.swift
//  ApiImplementation
//
//  Created by Siva Mouniker  on 25/07/23.
//
import UIKit

struct Album :Decodable{
    let userId: Int
    let id: Int
    let title: String
}

class ViewController: UIViewController {
    
    var tableView: UITableView!
    var albums: [Album] = []
    var userAlbums: [Int: [(id: Int, title: String)]] = [:]
    var sortedUserIds: [Int] = [] // To store sorted UserIDs
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
                    self?.sortAlbumsAndGroup()
                    self?.tableView.reloadData()
                }
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func sortAlbumsAndGroup() {
        albums.sort(by: { $0.userId < $1.userId })
        
        for album in albums {
            if var userAlbums = userAlbums[album.userId] {
                userAlbums.append((id: album.id, title: album.title))
                self.userAlbums[album.userId] = userAlbums
            } else {
                userAlbums[album.userId] = [(id: album.id, title: album.title)]
            }
        }
        sortedUserIds = userAlbums.keys.sorted()
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return userAlbums.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let userId = Array(userAlbums.keys)[section]
        return expandedRows.contains(userId) ? userAlbums[userId]!.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let userId = Array(userAlbums.keys.sorted())[indexPath.section]
        let userAlbumData = userAlbums[userId]!
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "User ID: \(userId)"
        } else {
            let albumData = userAlbumData[indexPath.row - 1]
            cell.textLabel?.text = "ID: \(albumData.id)\nTitle: \(albumData.title)"
            cell.textLabel?.numberOfLines = 0
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userId = Array(userAlbums.keys)[indexPath.section]
        if expandedRows.contains(userId) {
            expandedRows.remove(userId)
        } else {
            expandedRows.insert(userId)
        }
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 44 : 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}
