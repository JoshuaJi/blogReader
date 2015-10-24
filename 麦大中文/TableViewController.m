//
//  TableViewController.m
//  麦大中文
//
//  Created by Joshua Ji on 2014-11-10.
//  Copyright (c) 2014 Ji Xu. All rights reserved.
//

#import "TableViewController.h"
#import "ViewController.h"
#import "tableTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface TableViewController () {
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *author;
    NSMutableString *category;
    NSMutableString *imgUrl;
    UIImage *imgReal;
    NSString *element;
    NSURL *feedUrl;
    double screenWidth;
    UIImageView *imagesArray[4];
    UILabel *sliderText[4];
    UIButton *sliderButton[4];
    NSUserDefaults *imgDefault;
    int h;
}

@end

@implementation NSString (Contains)

- (BOOL)myContainsString:(NSString*)other {
    NSRange range = [self rangeOfString:other];
    return range.length != 0;
}

@end

@implementation TableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationItem.title = @"麦大中文";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"Hiragino Mincho ProN" size:20.0]};
    }

- (void)viewDidLoad {
    [super viewDidLoad];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    screenWidth = [[UIScreen mainScreen] bounds].size.width;
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenWidth*0.56)];
    _tableViewScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenWidth*0.56)];
    [_tableViewScroll setPagingEnabled:YES];
    _tableViewScroll.showsHorizontalScrollIndicator = NO;
    _tableViewScroll.showsVerticalScrollIndicator = NO;
    [_tableViewScroll setDelegate:self];
    [_tableViewScroll setContentSize:CGSizeMake(4*screenWidth, screenWidth*0.56)];
    
    tablePageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _tableViewScroll.frame.size.height - 20, _tableViewScroll.frame.size.width, 20)];
    tablePageControl.currentPage = 0;
    tablePageControl.numberOfPages = 4;

    [headerView addSubview: _tableViewScroll];
    [headerView addSubview: tablePageControl];
    self.tableView.tableHeaderView = headerView;
    self.tableView.showsVerticalScrollIndicator = NO;
    for (int i = 0; i < 4; i++) {
        sliderButton[i] = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth*i, 0, screenWidth, screenWidth*0.56)];
        sliderText[i] = [[UILabel alloc]initWithFrame:CGRectMake(_tableViewScroll.frame.size.width*i+20, _tableViewScroll.frame.size.height - 90, _tableViewScroll.frame.size.width-40, 100)];
        sliderText[i].textAlignment = NSTextAlignmentLeft;
        sliderText[i].lineBreakMode = NSLineBreakByWordWrapping;
        sliderText[i].numberOfLines = 0;
        sliderText[i].textColor = [UIColor whiteColor];
        [sliderText[i] setFont:[UIFont boldSystemFontOfSize:22]];
        imagesArray[i] = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth*i, 0, screenWidth, screenWidth*0.56)];
        imagesArray[i].contentMode = UIViewContentModeScaleAspectFill;
        imagesArray[i].clipsToBounds = YES;
        imagesArray[i].image = [UIImage imageNamed:@"sliderPlaceHolder.png"];
        [_tableViewScroll addSubview:imagesArray[i]];
        [_tableViewScroll addSubview:sliderText[i]];
        [_tableViewScroll addSubview:sliderButton[i]];
    }
    [sliderButton[0] addTarget:self action:@selector(pushNewView1) forControlEvents:UIControlEventTouchUpInside];
    [sliderButton[1] addTarget:self action:@selector(pushNewView2) forControlEvents:UIControlEventTouchUpInside];
    [sliderButton[2] addTarget:self action:@selector(pushNewView3) forControlEvents:UIControlEventTouchUpInside];
    [sliderButton[3] addTarget:self action:@selector(pushNewView4) forControlEvents:UIControlEventTouchUpInside];
    
    
    imgDefault = [NSUserDefaults standardUserDefaults];

    [self refreshData];
    
    
    [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor colorWithRed:211/255.0 green:47/255.0 blue:47/255.0 alpha:1.0];
}

- (void)refreshData {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    feeds = [[NSMutableArray alloc]init];
    feedUrl = [NSURL URLWithString:@"http://www.cssamu.ca/feed"];
    parser = [[NSXMLParser alloc]initWithContentsOfURL:feedUrl];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    
    [parser parse];
    [self.refreshControl endRefreshing];
    
    //load slider's image
    for (int i = 0; i < 4; i++) {
        NSString *temp = [[feeds objectAtIndex:i]objectForKey:@"title"];
        sliderText[i].text = temp;
        [imagesArray[i] sd_setImageWithURL:[NSURL URLWithString:[[feeds objectAtIndex:i] objectForKey:@"description"]]
                      placeholderImage:[UIImage imageNamed:@"sliderPlaceHolder.png"]];
        [self fadeInLayer:tableSlider.layer];
    }


//
//        if ((![[[feeds objectAtIndex:i]objectForKey:@"description"] isEqualToString:@""]) && ([imgDefault objectForKey:[[feeds objectAtIndex:i]objectForKey:@"description"]] == nil)) {
//            dispatch_queue_t imageQueue = dispatch_queue_create("imageDownloader", nil);
//            dispatch_async(imageQueue, ^{
//            
//                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[feeds objectAtIndex: i]objectForKey:@"description"]]];
//                imgReal = [UIImage imageWithData:imgData scale:100.0];
//            
//                // Get image path in user's folder and store file with name image_CurrentTimestamp.jpg (see documentsPathForFileName below)
//                NSString *imagePath = [self documentsPathForFileName:[NSString stringWithFormat:@"image_%f.png", [NSDate timeIntervalSinceReferenceDate]]];
//            
//                // Write image data to user's folder
//                [imgData writeToFile:imagePath atomically:YES];
//            
//                // Store path in NSUserDefaults
//                [imgDefault setObject:imagePath forKey:[[feeds objectAtIndex:0]objectForKey:@"description"]];
//            
//                // Sync user defaults
//                [imgDefault synchronize];
//                NSString *temp = [[feeds objectAtIndex:i]objectForKey:@"title"];
//            
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    sliderText[i].text = temp;
//                    imagesArray[i].image = imgReal;
//                    [self fadeInLayer:tableSlider.layer];
//                });
//            });
//        }else if([imgDefault objectForKey:[[feeds objectAtIndex:i]objectForKey:@"description"]]){
//            NSString *imagePath = [[NSUserDefaults standardUserDefaults] objectForKey:[[feeds objectAtIndex:i]objectForKey:@"description"]];
//            if (imagePath) {
//                NSString *temp = [[feeds objectAtIndex:i]objectForKey:@"title"];
//                sliderText[i].text = temp;
//                imagesArray[i].image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
//                [self fadeInLayer:tableSlider.layer];
//            }
//        }

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)fadeInLayer:(CALayer *)l {
    CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimate.duration            = 0.5;
    fadeInAnimate.repeatCount         = 1;
    fadeInAnimate.autoreverses        = NO;
    fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
    fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
    fadeInAnimate.removedOnCompletion = YES;
    [l addAnimation:fadeInAnimate forKey:@"animateOpacity"];
    return;
}

- (NSString *)documentsPathForFileName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

- (void)pushNewView0{
    [self performSegueWithIdentifier:@"showWeb" sender:self];
    
}

- (void)pushNewView1{
    [self performSegueWithIdentifier:@"showWeb1" sender:self];
    
}

- (void)pushNewView2{
    [self performSegueWithIdentifier:@"showWeb2" sender:self];
}

- (void)pushNewView3{
    [self performSegueWithIdentifier:@"showWeb3" sender:self];
}

- (void)pushNewView4{
    [self performSegueWithIdentifier:@"showWeb4" sender:self];
}

- (void)onTimer{
    if (h < screenWidth * 3) {
        h += screenWidth;
    }else{
        h = 0;
    }
    [_tableViewScroll setContentOffset:CGPointMake(h, 0) animated:YES];
    tablePageControl.currentPage = h/screenWidth;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    element = elementName;
    if ([element isEqualToString:@"item"]) {
        item = [[NSMutableDictionary alloc]init];
        title = [[NSMutableString alloc]init];
        author = [[NSMutableString alloc]init];
        link = [[NSMutableString alloc]init];
        imgUrl = [[NSMutableString alloc]init];
        imgReal = [[UIImage alloc]init];
        category = [[NSMutableString alloc]init];
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    }else if([element isEqualToString:@"link"]){
        [link appendString:string];
    }else if([element isEqualToString:@"category"]){
        [category appendString:string];
    }else if([element isEqualToString:@"dc:creator"]){
        [author appendString:string];
    }else if([element isEqualToString:@"description"]){
        if ([string rangeOfString:@"<img src=\""].location != NSNotFound) {
            NSRange range = [string rangeOfString:@"src=\"" options:NSCaseInsensitiveSearch];
            NSString *subString = [string substringWithRange:NSMakeRange(range.location + 5, string.length - range.location - 5)];
            range = [subString rangeOfString:@"\""];
            subString = [subString substringWithRange:NSMakeRange(0, range.location)];
            
            NSString *tempString = [NSString stringWithString:[subString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            [imgUrl appendString:tempString];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"item"] && ([category myContainsString:@"麦大中文报"] || [category myContainsString:@"麦大最新"])) {
        [item setObject:title forKey:@"title"];
        [item setObject:link forKey:@"link"];
        [item setObject:author forKey:@"dc:creator"];
        [item setObject:imgUrl forKey:@"description"];
        [feeds addObject:[item copy]];
    }
}


- (void)parserDidEndDocument:(NSXMLParser *)parser{
    [self.tableView reloadData];
}

    
#pragma mark - Table view data source
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return feeds.count;
}
    
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    tableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // Configure the cell...
    cell.title.text = [[feeds objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.subTitle.text = [[feeds objectAtIndex:indexPath.row] objectForKey:@"dc:creator"];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[[feeds objectAtIndex:indexPath.row] objectForKey:@"description"]]
                          placeholderImage:[UIImage imageNamed:@"sliderPlaceHolder.png"]];
    [self fadeInLayer:tableSlider.layer];

    
//    if ((![[[feeds objectAtIndex:indexPath.row]objectForKey:@"description"] isEqualToString:@""]) && ([imgDefault objectForKey:[[feeds objectAtIndex:indexPath.row]objectForKey:@"description"]] == nil)) {
//        cell.imageView.image = [UIImage imageNamed:@"sliderPlaceHolder.png"];
//
//            dispatch_queue_t imageQueue = dispatch_queue_create("imageDownloader", NULL);
//            dispatch_async(imageQueue, ^{
//                
//            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[feeds objectAtIndex: indexPath.row]objectForKey:@"description"]]];
//            imgReal = [UIImage imageWithData:imgData scale:200.0];
//                
//            // Get image path in user's folder and store file with name image_CurrentTimestamp.jpg (see documentsPathForFileName below)
//            NSString *imagePath = [self documentsPathForFileName:[NSString stringWithFormat:@"image_%f.png", [NSDate timeIntervalSinceReferenceDate]]];
//                
//            // Write image data to user's folder
//            [imgData writeToFile:imagePath atomically:YES];
//                
//            // Store path in NSUserDefaults
//            [imgDefault setObject:imagePath forKey:[[feeds objectAtIndex:indexPath.row]objectForKey:@"description"]];
//                
//            // Sync user defaults
//            [imgDefault synchronize];
//                
//            dispatch_async(dispatch_get_main_queue(), ^{
//                cell.imageView.image = imgReal;
//                [self fadeInLayer:cell.imageView.layer];
//            });
//        });
//    }else if([imgDefault objectForKey:[[feeds objectAtIndex:indexPath.row]objectForKey:@"description"]]){
//
//        NSString *imagePath = [[NSUserDefaults standardUserDefaults] objectForKey:[[feeds objectAtIndex:indexPath.row]objectForKey:@"description"]];
//        if (imagePath) {
//                cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
//                //[self fadeInLayer:cell.imageView.layer];
//
//        }
//        NSLog(@"%@", imagePath);
//    }
    return cell;
}


#pragma mark - scroll view delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isMemberOfClass:[UITableView class]]) {
        
    }else{
        tablePageControl.currentPage = scrollView.contentOffset.x/screenWidth;
        h = scrollView.contentOffset.x;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showWeb"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *url = [[feeds objectAtIndex:indexPath.row]objectForKey:@"link"];
        [[segue destinationViewController]setUrl:url];
        NSLog(@"%@", indexPath);

    }else if ([segue.identifier isEqualToString:@"showWeb1"]){
        NSString *url = [[feeds objectAtIndex:0]objectForKey:@"link"];
        [[segue destinationViewController]setUrl:url];
    }else if ([segue.identifier isEqualToString:@"showWeb2"]){
        NSString *url = [[feeds objectAtIndex:1]objectForKey:@"link"];
        [[segue destinationViewController]setUrl:url];
    }else if ([segue.identifier isEqualToString:@"showWeb3"]){
        NSString *url = [[feeds objectAtIndex:2]objectForKey:@"link"];
        [[segue destinationViewController]setUrl:url];
    }else if ([segue.identifier isEqualToString:@"showWeb4"]){
        NSString *url = [[feeds objectAtIndex:3]objectForKey:@"link"];
        [[segue destinationViewController]setUrl:url];
    }
}

@end
