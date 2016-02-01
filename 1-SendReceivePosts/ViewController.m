//
//  ViewController.m
//  1-SendReceivePosts
//
//  Created by Blayne Chong on 2015-10-07.
//  Copyright © 2015 blayncecameron. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize facebookAccount;
@synthesize postTextField, informationDisplay;

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - buttons
- (IBAction)facebookButton:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *facebookPost = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookPost setInitialText:postTextField.text];
        [facebookPost addURL:[NSURL URLWithString:@"www.google.com"]];
        
        [self presentViewController:facebookPost animated:YES completion:NULL];
    }
    
    postTextField.text = @"";
    
}

- (IBAction)twitterButton:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *twitterPost = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterPost setInitialText:postTextField.text];
        [twitterPost addURL:[NSURL URLWithString:@"www.google.com"]];
        
        [self presentViewController:twitterPost animated:YES completion:NULL];
    }
    
    postTextField.text = @"";
    
}

- (IBAction)getFBPost:(id)sender {
    [self getFBInfo];
}

- (IBAction)getTwitterPost:(id)sender {
    [self getTwitterInfo];
}

#pragma mark - get social media data
-(void)getTwitterInfo {
    ACAccountStore *accountsStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountsStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountsStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [accountsStore accountsWithAccountType:accountType];
            
            if (accounts.count > 0) {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:@"blaynecameron" forKey:@"screen_name"]];
                [twitterInfoRequest setAccount:twitterAccount];
                
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        // checks if limit was reached
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        
                        // check for error
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        
                        // checks for response data
                        if (responseData) {
                            NSError *error = nil;
                            NSArray *twitterData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            NSLog(@"%@", twitterData);
                            
                            NSString *screenName = [(NSDictionary *)twitterData objectForKey:@"name"];
                            informationDisplay.text = screenName;
                            
                        }
                    });
                }];
                
            }
        } else {
            NSLog(@"Access Denied");
        }
    }];
}


// to effectively get FB data, must create a test account for an official program registered
-(void)getFBInfo {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSDictionary *options = @{ACFacebookAppIdKey: @"",
                              ACFacebookPermissionsKey: @[@"user_about_me"]
                              };
    
    [accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error) {
        
        if (granted) {
            NSArray *fbAccount = [accountStore accountsWithAccountType:accountType];
            ACAccount *account = [fbAccount lastObject];
            NSString *user = [account username];
            
            NSLog(@"fb Username: %@", user);
            
            NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me"];
            SLRequest *facebookRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                            requestMethod:SLRequestMethodGET
                                                                      URL:url
                                                               parameters:nil];
            facebookRequest.account = account;
            
            [facebookRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (responseData) {
                        NSError *jsonError;
                        NSDictionary *list = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&jsonError];
                        NSLog(@"%@", list);
                    }
                    
                    if (error) {
                        NSLog(@"error: %@", error.localizedDescription);
                    }
                    
                });
            }];
            
        } else {
            NSLog(@"Access denied:: %@",error);
        }
        
    }];
}


@end
