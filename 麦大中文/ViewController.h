//
//  ViewController.h
//  麦大中文
//
//  Created by Joshua Ji on 2014-11-11.
//  Copyright (c) 2014 Ji Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet NSString *url;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end
