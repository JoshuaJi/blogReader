//
//  tableTableViewCell.m
//  麦大中文
//
//  Created by Joshua Ji on 2014-11-13.
//  Copyright (c) 2014 Ji Xu. All rights reserved.
//

#import "tableTableViewCell.h"

@implementation tableTableViewCell

@synthesize imageView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}

@end
