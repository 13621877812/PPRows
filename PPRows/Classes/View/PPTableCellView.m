//
//  PPTableCellView.m
//  PPRows
//
//  Created by AndyPang on 2017/3/4.
//  Copyright © 2017年 AndyPang. All rights reserved.
//

#import "PPTableCellView.h"
#import "PPRowsEngine.h"
#import "PPCounter.h"
#import "NSAttributedString+PPRows.h"

@interface PPTableCellView ()
/** 文件图片*/
@property (weak) IBOutlet NSImageView *fileImageView;
/** 文件名*/
@property (weak) IBOutlet NSTextField *fileName;
/** 文件夹内文件数量*/
@property (weak) IBOutlet NSTextField *fileNumber;
/** 该文件内总代码行数*/
@property (weak) IBOutlet NSTextField *codeRows;
/** 计算完成时显示的图片*/
@property (weak) IBOutlet NSImageView *finishedImageView;

@end

@implementation PPTableCellView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.finishedImageView.hidden = YES;
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
}

- (void)fillCellWithFilePath:(NSString *)path index:(NSUInteger)index
{
    NSArray *folderArray = [path componentsSeparatedByString:@"/"];
    self.finishedImageView.hidden = YES;
    self.fileName.stringValue = [NSString stringWithFormat:@"%ld. %@",index, folderArray.lastObject];
    self.fileNumber.stringValue = @"计算中...";
    self.codeRows.stringValue = @"";
    self.fileName.textColor = [NSColor gridColor];
    self.fileNumber.textColor = [NSColor gridColor];
    self.codeRows.textColor = [NSColor gridColor];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[PPRowsEngine rowsEngine] computeWithFilePath:path completion:^(NSUInteger codeFileNumber, NSUInteger codeRows) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self countCodeRows:codeRows];
                [self countCodeFiles:codeFileNumber];
            });
            
        } error:^(NSString *errorInfo) {
            NSLog(@"%@",errorInfo);
        }];
    });
}

- (void)countCodeFiles:(NSUInteger)fileNumber
{
    [[PPCounterEngine counterEngine] fromNumber:0 toNumber:fileNumber duration:1.5f animationOptions:PPCounterAnimationOptionCurveEaseOut currentNumber:^(CGFloat number) {
        self.fileNumber.stringValue = [NSString stringWithFormat:@"CodeFiles: %ld",(NSInteger)number];
    } completion:^{
        
        [self countFinished];
        
        NSAttributedString *string = [NSAttributedString pp_attributesWithText:self.fileNumber.stringValue
                                                                    rangeText:NSStringFormat(@"%ld",fileNumber)
                                                                rangeTextFont:[NSFont boldSystemFontOfSize:12]
                                                               rangeTextColor:!fileNumber?[NSColor redColor]:NSColorHex(0x1AB394)];
        self.fileNumber.attributedStringValue = string;
    }];
}
- (void)countCodeRows:(NSUInteger)codeRows
{
    [[PPCounterEngine counterEngine] fromNumber:0 toNumber:codeRows duration:1.5f animationOptions:PPCounterAnimationOptionCurveEaseOut currentNumber:^(CGFloat number) {
        self.codeRows.stringValue = [NSString stringWithFormat:@"CodeRows: %ld",(NSInteger)number];
    } completion:^{
        
        [self countFinished];
        
        NSAttributedString *attributedString = [NSAttributedString pp_attributesWithText:self.codeRows.stringValue
                                                                               rangeText:NSStringFormat(@"%ld",codeRows)
                                                                           rangeTextFont:[NSFont boldSystemFontOfSize:12]
                                                                          rangeTextColor:!codeRows?[NSColor redColor]:NSColorHex(0x1AB394)];
        self.codeRows.attributedStringValue = attributedString;
    }];
}

- (void)countFinished
{
    self.fileName.textColor = [NSColor whiteColor];
    self.fileNumber.textColor = [NSColor whiteColor];
    self.codeRows.textColor   = [NSColor whiteColor];
    self.finishedImageView.hidden = NO;
}

@end
