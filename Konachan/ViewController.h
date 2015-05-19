//
//  ViewController.h
//  Konachan
//
//  Created by yaqinking on 4/26/15.
//  Copyright (c) 2015 yaqinking. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSTextField *pageSize;
@property (weak) IBOutlet NSTextField *pageNumber;
@property (weak) IBOutlet NSTextField *searchTags;
@property (weak) IBOutlet NSTextField *logTextField;

@property int endPoint;
- (IBAction)startDownload:(id)sender;

@end

