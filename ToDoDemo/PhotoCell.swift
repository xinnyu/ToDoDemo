//
//  PhotoCell.swift
//  ToDoDemo
//
//  Created by panxinyu on 2017-29-06.
//  Copyright © 2017年 panxinyu. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var checkmark: UIImageView!
    @IBOutlet weak var imageView: UIImageView!

    var representedAssetIdentifier: String!
    var isCheckmarked: Bool = false

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
    }

    func flipCheckmark() {
        self.isCheckmarked = !self.isCheckmarked
    }

    func selected() {
        self.flipCheckmark()
        setNeedsDisplay()

        UIView.animate(withDuration: 0.1,
                       animations: { [weak self] in

                        if let isCheckmarked = self?.isCheckmarked {
                            self?.checkmark.alpha = isCheckmarked ? 1 : 0
                        }
        })
    }

}
