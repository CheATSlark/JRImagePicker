//
//  ImageAlbumsView.swift
//  23
//
//  Created by 焦瑞洁 on 2020/8/26.
//  Copyright © 2020 ddcx. All rights reserved.
//

import UIKit

class ImageAlbumsView: UIView {
    
    @IBOutlet weak var table: UITableView!
    private var dataSource = [MTImagePickerAlbumModel]()
    weak var delegate:MTImagePickerDataSourceDelegate!
    var chooseAlbum: ((MTImagePickerAlbumModel) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "ImageAlbumTbCell", bundle: Bundle(for: ImageAlbumsView.self)), forCellReuseIdentifier: "cell")
        table.tableFooterView = UIView()
    }
    
    func fetchAlbums(){
        MTImagePickerDataSource.fetch(mediaTypes: delegate.mediaTypes, complete: { [unowned self](dataSource) in
            self.dataSource = dataSource
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        })
    }

}

extension ImageAlbumsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell as? ImageAlbumTbCell)?.setup(model: dataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chooseAlbum?(dataSource[indexPath.row])
        isHidden = true
    }
}
