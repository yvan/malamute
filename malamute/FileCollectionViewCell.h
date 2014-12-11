//
//  FileCellCollectionViewCell.h
//  malamute
//
//  Created by Yvan Scher & Enrique Lores on 11/21/14.
//  Copyright (c) 2014 Yvan Scher & Enrique Lores. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *cellLabel;
@property (nonatomic, strong) IBOutlet UIImageView *cellImage;

@end
