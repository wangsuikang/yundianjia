//
//  AddressNewViewController.h
//  Shops-iPhone
//
//  Created by rujax on 2013-11-01.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, AddressTextFieldTag) {
    NameTextField = 201,
    StreetTextField,
    PhoneTextField,
    InvoiceTextField,
    NoteTextField,
    ContactPhoneTextField
};

@interface AddressNewViewController : UIViewController

@property (nonatomic, strong) NSDictionary *address;
@property (nonatomic, strong) NSArray *addressArray;

@end
