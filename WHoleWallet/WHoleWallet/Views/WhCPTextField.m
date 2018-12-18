//
//  WhCPTextField.m
//  WHoleWallet
//
//  Created by fft on 2018/11/9.
//  Copyright © 2018年 wormhole. All rights reserved.
//

#import "WhCPTextField.h"


@interface UIColor (HexColor)

+ (UIColor*) colorWithHex:(long)hexColor;
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;
@end

@implementation UIColor (HexColor)

+ (UIColor*) colorWithHex:(long)hexColor{
    return [UIColor colorWithHex:hexColor alpha:1.];
}

+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}

@end




@implementation WhCPTextField{
    UIColor *_borderColorForEditing;
    UIColor *_borderColorNormal;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _borderColorNormal      = [UIColor colorWithHex:0xE1E4E8];
        _borderColorForEditing  = [UIColor blueColor];
        self.layer.cornerRadius = 6;
        self.layer.borderWidth  = 1.5;
        
        self.layer.borderColor = _borderColorNormal.CGColor;
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(didEditting:) name:UITextFieldTextDidBeginEditingNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(didEndEditting:) name:UITextFieldTextDidEndEditingNotification object:self];
        
    }
    return self;
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _borderColorNormal      = [UIColor colorWithHex:0xE1E4E8];
        _borderColorForEditing  = [UIColor blueColor];
        
        self.layer.borderColor = _borderColorNormal.CGColor;
        self.layer.cornerRadius = 6;
        self.layer.borderWidth  = 1.5;

        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(didEditting:) name:UITextFieldTextDidBeginEditingNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(didEndEditting:) name:UITextFieldTextDidEndEditingNotification object:self];
        
    }
    return self;
}

-(void)didEditting:(NSNotification *)notification{
    if (notification.object==self) {
        self.layer.borderColor = _borderColorForEditing.CGColor;
    }
    
}

-(void)didEndEditting:(NSNotification *)notification{
    if (notification.object==self) {
        self.layer.borderColor = _borderColorNormal.CGColor;
    }
    
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(paste:))
    {
        return YES;
    }
    else if (action == @selector(copy:))
    {
        return NO;
    }
    else if (action == @selector(select:))
    {
        return NO;
    }
    
    return [super canPerformAction:action withSender:sender];
}


-(void)setBorderColor:(UIColor *)color forEditing:(BOOL)editting{
    if (editting) {
        _borderColorForEditing = color;
    }else{
        _borderColorNormal = color;
    }
}


- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(15, bounds.origin.y, bounds.size.width-30, bounds.size.height);
}


- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(15, bounds.origin.y, bounds.size.width-30, bounds.size.height);
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
