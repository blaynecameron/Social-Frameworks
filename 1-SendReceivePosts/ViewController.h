//
//  ViewController.h
//  1-SendReceivePosts
//
//  Created by Blayne Chong on 2015-10-07.
//  Copyright © 2015 blayncecameron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface ViewController : UIViewController

@property ACAccount *facebookAccount;

@property (weak, nonatomic) IBOutlet UITextField *postTextField;
@property (weak, nonatomic) IBOutlet UILabel *informationDisplay;

- (IBAction)facebookButton:(id)sender;
- (IBAction)twitterButton:(id)sender;
- (IBAction)getFBPost:(id)sender;
- (IBAction)getTwitterPost:(id)sender;

@end

