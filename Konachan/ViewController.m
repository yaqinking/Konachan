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
    NSString *pageSize = [self.pageSize stringValue];
    NSString *pageNumber = [self.pageNumber stringValue];
    NSString *tags = [self.searchTags stringValue];
    [self.logTextField setStringValue:[NSString stringWithFormat:@"Start downloading %@ pictures",pageSize]];
    if ((pageSize != NULL) && (pageNumber != NULL) && (tags != NULL)) {
        NSString *strURL = [NSString stringWithFormat:@KONACHAN_POST_LIMIT_PAGE_TAGS,pageSize,pageNumber,tags];
        NSData *data= [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
        NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];//返回一個數組
        NSMutableArray *sampleURLArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in jsonArr) {
            NSLog(@"value -> %@",[dict valueForKey:@KONACHAN_DOWNLOAD_TYPE_FILE]);//根據 key 取出 dict 中的 value
            [sampleURLArr addObject:[dict valueForKey:@KONACHAN_DOWNLOAD_TYPE_FILE]];
        }
        
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        for (NSString *url in sampleURLArr) {
            NSURL *sURL = [NSURL URLWithString:url];
            NSURLRequest *request = [NSURLRequest requestWithURL:sURL];
            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                NSURL *docDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                return [docDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                NSLog(@"File downloaded to : %@",filePath);
                [self.logTextField setStringValue:[NSString stringWithFormat:@"%i downloaded to %@",(self.endPoint +1),filePath]];
                self.endPoint ++;
                if (self.endPoint == sampleURLArr.count) {
                    [self.logTextField setStringValue:@"All pictures downloaded to ~/Download/"];
                    self.endPoint = 0;
                }
            }];
            
            [downloadTask resume];
        }

    }
    
}
@end
