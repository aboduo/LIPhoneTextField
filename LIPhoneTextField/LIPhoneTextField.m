//
//  LIPhoneTextField.m
//  LionLiving
//
//  Created by sheng on 5/31/16.
//  Copyright © 2016 com.youxiduo. All rights reserved.
//

#import "LIPhoneTextField.h"

@implementation LIPhoneTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit
{
    [self addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
}


#pragma mark - action

- (void)textFieldEditChanged:(UITextView *)textField
{
    /**
     *  判断正确的光标位置
     */
    NSUInteger targetCursorPostion = [textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.selectedTextRange.start];
    NSString *phoneNumberWithoutSpaces = [self removeNonDigits:textField.text andPreserveCursorPosition:&targetCursorPostion];
    
    NSString *regexString = @"^1[0-9]{0,10}";
    NSRange range = [phoneNumberWithoutSpaces rangeOfString:regexString options:NSRegularExpressionSearch];
    NSString *phoneNumber = nil;
    if (range.location != NSNotFound)
    {
        ////这里会导致光标位置错乱，
        phoneNumber = [phoneNumberWithoutSpaces substringWithRange:range];
    }

//    if([phoneNumberWithoutSpaces length]>11) {
//        /**
//         *  避免超过11位的输入
//         */
//        
////        [textField setText:_previousTextFieldContent];
////        textField.selectedTextRange = _previousSelection;
//        textField.text = [textField.text substringToIndex:13];
//        return;
//    }
    
    //修正光标位置
    NSString *phoneNumberWithSpaces = [self insertSpacesEveryFourDigitsIntoString:phoneNumber andPreserveCursorPosition:&targetCursorPostion];
    targetCursorPostion = MIN(targetCursorPostion, phoneNumberWithSpaces.length);
    
    textField.text = phoneNumberWithSpaces;
    UITextPosition *targetPostion = [textField positionFromPosition:textField.beginningOfDocument offset:targetCursorPostion];
    [textField setSelectedTextRange:[textField textRangeFromPosition:targetPostion toPosition:targetPostion]];
}


#pragma mark - private

/**
 *  除去非数字字符，确定光标正确位置
 *
 *  @param string         当前的string
 *  @param cursorPosition 光标位置
 *
 *  @return 处理过后的string
 */
- (NSString *)removeNonDigits:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition {
    NSUInteger originalCursorPosition =*cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    
    for (NSUInteger i=0; i<string.length; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        
        if(isdigit(characterToAdd)) {
            NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
            [digitsOnlyString appendString:stringToAdd];
        }
        else {
            if(i<originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    return digitsOnlyString;
}

/**
 *  将空格插入我们现在的string 中，并确定我们光标的正确位置，防止在空格中
 *
 *  @param string         当前的string
 *  @param cursorPosition 光标位置
 *
 *  @return 处理后有空格的string
 */
- (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition{
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    
    for (NSUInteger i=0; i<string.length; i++) {
        if(i>0)
        {
            if(i==3 || i==7) {
                [stringWithAddedSpaces appendString:@"-"];
                
                if(i<cursorPositionInSpacelessString) {
                    (*cursorPosition)++;
                }
            }
        }
        
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    return stringWithAddedSpaces;
}

//#pragma mark - UITextFieldDelegate
//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    _previousSelection = textField.selectedTextRange;
//    _previousTextFieldContent = textField.text;
//    
//    if(range.location==0) {
//        if(string.integerValue >1)
//        {
//            return NO;
//        }
//    }
//    
//    return YES;
//}

@end
