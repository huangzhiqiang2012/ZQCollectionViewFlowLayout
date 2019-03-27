//
//  ZQCollectionViewCell.swift
//  ZQCollectionViewFlowLayoutDemo
//
//  Created by Darren on 2019/3/27.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

class ZQCollectionViewCell: UICollectionViewCell {
    
    fileprivate lazy var titleLabel: UILabel = {
        let titleLabel: UILabel = UILabel()
        titleLabel.textColor = UIColor.red
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    var title:String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.brown
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = contentView.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
