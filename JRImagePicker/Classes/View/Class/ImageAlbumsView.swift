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
    var chooseIndex = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "ImageAlbumTbCell", bundle: Bundle(for: ImageAlbumsView.self)), forCellReuseIdentifier: "cell")
        table.tableFooterView = UIView()
    }
    
    func fetchAlbums(){
        MTImagePickerDataSource.fetch(mediaTypes: delegate.mediaTypes, complete: { [unowned self](dataSource) in
            var index: Int?
            for (i,albumModel) in dataSource.enumerated() {
                /// 过滤点最近删除的照片 Recently Deleted
                if let name = albumModel.getAlbumName()?.albumCnName {
                    if name == "最近删除" {
                        index = i
                    }
                }
            }
            self.dataSource = dataSource
            if let i = index {
                self.dataSource.remove(at: i)

            }
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ImageAlbumTbCell
        cell.setup(model: dataSource[indexPath.row])
        if indexPath.row == chooseIndex {
            cell.posterImageView.layer.borderWidth = 2
            cell.posterImageView.layer.borderColor = UIColor(red: 222.0/255.0, green: 134.0/255.0, blue: 86.0/255.0, alpha: 1).cgColor
        }else {
            cell.posterImageView.layer.borderWidth = 0
            cell.posterImageView.layer.borderColor = UIColor(red: 222.0/255.0, green: 134.0/255.0, blue: 86.0/255.0, alpha: 1).cgColor
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chooseAlbum?(dataSource[indexPath.row])
        chooseIndex = indexPath.row
        isHidden = true
        table.reloadData()
    }
}
