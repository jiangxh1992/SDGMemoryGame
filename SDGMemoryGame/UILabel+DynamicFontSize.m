//
//  UILabel+DynamicFontSize.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 1/3/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "UILabel+DynamicFontSize.h"

@implementation UILabel (DynamicFontSize)

#define CATEGORY_DYNAMIC_FONT_SIZE_MAXIMUM_VALUE 35
#define CATEGORY_DYNAMIC_FONT_SIZE_MINIMUM_VALUE 3

-(void)adjustFontSizeToFillItsSize {
    NSString* text = self.text;
    
    for (int i = CATEGORY_DYNAMIC_FONT_SIZE_MAXIMUM_VALUE; i>CATEGORY_DYNAMIC_FONT_SIZE_MINIMUM_VALUE; i--) {
        
        UIFont *font = [UIFont fontWithName:self.font.fontName size:(CGFloat)i];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font}];
        
        CGRect rectSize = [attributedText boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        if (rectSize.size.height <= self.frame.size.height) {
            self.font = [UIFont fontWithName:self.font.fontName size:(CGFloat)i];
            break;
        }
    }
    
}

@end
