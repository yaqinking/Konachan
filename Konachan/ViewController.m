//
//  ViewController.m
//  Konachan
//
//  Created by yaqinking on 4/26/15.
//  Copyright (c) 2015 yaqinking. All rights reserved.
//

#import "ViewController.h"
#import "KonachanAPI.h"
#import "AFNetworking.h"

@interface ViewController()<NSTextFieldDelegate>

@property (nonatomic, strong) AFURLSessionManager *manager;
@property (nonatomic, strong) NSURL *docDirectoryURL;
@property (weak) IBOutlet NSProgressIndicator *progress;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)startDownload:(id)sender {
    NSString *pageSize   = self.pageSize.stringValue;
    NSString *pageNumber = self.pageNumber.stringValue;
    NSString *tags       = self.searchTags.stringValue;
    
    self.logTextField.stringValue = [NSString stringWithFormat:@"Start downloading %@ pictures",pageSize];
    
    if ((pageSize != NULL) && (pageNumber != NULL) && (tags != NULL)) {
        NSString *strURL = [NSString stringWithFormat:@KONACHAN_POST_LIMIT_PAGE_TAGS,pageSize,pageNumber,tags];
        NSData *data     = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
        
        
        NSArray *jsonArr             = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];//返回一個數組
        if (jsonArr.count == 0) {
            self.logTextField.stringValue = @"No pictures OwO";
            return;
        }
        NSMutableArray *sampleURLArr = [[NSMutableArray alloc] initWithCapacity:jsonArr.count];
        NSLog(@"The count is %lul",[jsonArr count]);
        [jsonArr enumerateObjectsUsingBlock:^(id  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
            if (stop) {
                [sampleURLArr addObject:[dict valueForKey:@KONACHAN_DOWNLOAD_TYPE_FILE]];
            }
        }];
        
        for (NSString *url in sampleURLArr) {
            NSURL *sURL = [NSURL URLWithString:url];
            NSURLRequest *request = [NSURLRequest requestWithURL:sURL];
            if (request) {
                NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request
                                                                                      progress:nil
                                                                              destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    return [self.docDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                    //NSLog(@"File downloaded to : %@",filePath);
                    if (!error) {
                        self.logTextField.stringValue = [NSString stringWithFormat:@"%i downloaded to %@",(self.endPoint +1),filePath];
                        [self.progress incrementBy:1];
                        self.endPoint ++;
                        if (self.endPoint == sampleURLArr.count) {
                            self.logTextField.stringValue = @"All pictures downloaded to ~/Downloads/";
                            self.endPoint = 0;
                            long nextPage = [self.pageNumber.stringValue integerValue] + 1;
                            self.pageNumber.stringValue = [NSString stringWithFormat:@"%li",nextPage];
                        }
                    } else {
                        self.endPoint ++;
                        self.logTextField.stringValue = @"Request time out >_<";
                        NSLog(@"Error -> %@",[error localizedDescription]);
                    }
                }];
                
                [downloadTask resume];
                    
            }
        }
    }
    
}


- (AFURLSessionManager *)manager {
    if (!_manager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _manager;
    
}

- (NSURL *)docDirectoryURL {
    if (!_docDirectoryURL) {
        _docDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDownloadsDirectory
                                                                        inDomain:NSUserDomainMask
                                                               appropriateForURL:nil
                                                                          create:NO
                                                                    error:nil];
    }
    return _docDirectoryURL;
    
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    if ([notification.userInfo[@"NSTextMovement"] intValue] == NSReturnTextMovement) {
        [self startDownload:nil];
    }
    
}

@end
