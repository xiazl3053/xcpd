//
//  DirectViewCell.m
//  FreeIp
//
//  Created by xiongchi on 15-5-4.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "DirectViewCell.h"
#import "XCButton.h"
#import "UIView+Extension.h"

@implementation DirectViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    XCButton *btnSelect = [[XCButton alloc] initWithFrame:Rect(17, 16, 44, 44) normal:@"" high:@"" select:@""];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:Rect(78, 16, 44, 44)];
    
    [self.contentView addSubview:btnSelect];
    [self.contentView addSubview:imgView];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:Rect(imgView.width+imgView.x+12, imgView.y, 200, 24)];
    
    
    
    
    
    return self;
}



@end
