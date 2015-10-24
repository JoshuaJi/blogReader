//
//  tableTableViewCell.h
//  麦大中文
//
//  Created by Joshua Ji on 2014-11-13.
//  Copyright (c) 2014 Ji Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tableTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
