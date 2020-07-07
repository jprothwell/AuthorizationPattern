//
//  UserNotificationsAuthorizationItem.m
//  AuthorizationPattern
//
//  Created by LeonJing on 2020/7/7.
//  Copyright © 2020 Bq. All rights reserved.
//

#import "UserNotificationsAuthorizationItem.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

API_AVAILABLE(ios(10.0))
AuthorizationStatus authorizationStatusWithUNAuthorizationStatus(UNAuthorizationStatus userNotifyStatus) {
    AuthorizationStatus status = AuthorizationStatusUnknown;
    switch (userNotifyStatus) {
        case UNAuthorizationStatusProvisional:
        case UNAuthorizationStatusAuthorized:{
            status = AuthorizationStatusAuthorized;
        } break;
        case UNAuthorizationStatusDenied:{
            status = AuthorizationStatusDenied;
        } break;
        case UNAuthorizationStatusNotDetermined:{
            status = AuthorizationStatusUnknown;
        } break;
    }
    return status;
}

@implementation UserNotificationsAuthorizationItem
- (void)commonInit {
    self.authorizationName = @"通知";
    self.currentStatusHandler = ^(AuthorizationStatusBlock statusHandler) {
        if (@available(iOS 10.0, *)) {
            [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AuthorizationStatus status = AuthorizationStatusUnknown;
                    status = authorizationStatusWithUNAuthorizationStatus([settings authorizationStatus]);
                    statusHandler(status);
                });
            }];
        } else {
            BOOL result = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
            statusHandler(result ? AuthorizationStatusAuthorized : AuthorizationStatusDenied);
        }
    };
    self.requestHandler = ^(AuthorizationStatusBlock statusHandler) {
        if (@available(iOS 10.0, *)) {
            UNAuthorizationOptions options = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
                AuthorizationStatus status = granted ? AuthorizationStatusAuthorized : AuthorizationStatusDenied;
                statusHandler(status);
            }];
        } else if (@available(iOS 9.0, *)) {
            UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
            UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            UIUserNotificationType currentTypes = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];

            AuthorizationStatus status = (currentTypes != UIUserNotificationTypeNone) ? AuthorizationStatusAuthorized : AuthorizationStatusDenied;
            statusHandler(status);
        } else if (@available(iOS 8.0, *)) {
            UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
            UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            UIUserNotificationType currentTypes = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
            
            AuthorizationStatus status = (currentTypes != UIUserNotificationTypeNone) ? AuthorizationStatusAuthorized : AuthorizationStatusDenied;
            statusHandler(status);
        } else {
            #if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
                UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge;
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
            #endif
        }
    };
}
@end
