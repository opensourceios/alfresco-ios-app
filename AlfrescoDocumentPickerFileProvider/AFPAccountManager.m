/*******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile iOS App.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import "AFPAccountManager.h"
#import "KeychainUtils.h"
#import "UserAccountWrapper.h"
#import "FileMetadata.h"
#import <FileProvider/FileProvider.h>

@interface AFPAccountManager()

@property (nonatomic, strong) NSMutableDictionary *accountIdentifierToSessionMappings;

@end

@implementation AFPAccountManager

+ (instancetype)sharedManager
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

- (NSMutableDictionary *)accountIdentifierToSessionMappings
{
    if (!_accountIdentifierToSessionMappings)
    {
        _accountIdentifierToSessionMappings = [NSMutableDictionary dictionary];
    }
    return _accountIdentifierToSessionMappings;
}

- (void)loginToAccount:(id<AKUserAccount>)account completionBlock:(void (^)(BOOL successful, id<AlfrescoSession> session, NSError *loginError))completionBlock
{
    AKLoginService *loginService = [[AKLoginService alloc] init];
    __weak typeof(self) weakSelf = self;
    [loginService loginToAccount:account networkIdentifier:account.selectedNetworkIdentifier completionBlock:^(BOOL successful, id<AlfrescoSession> session, NSError *loginError) {
        if (successful)
        {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.accountIdentifierToSessionMappings[account.identifier] = session;
        }
        
        completionBlock(successful, session, loginError);
    }];
}

- (UserAccountWrapper *)userAccountForMetadataItem:(FileMetadata *)metadata
{
    return [self userAccountForAccountIdentifier:metadata.accountIdentifier networkIdentifier:metadata.networkIdentifier];
}

- (UserAccountWrapper *)userAccountForAccountIdentifier:(NSString *)accountIdentifier networkIdentifier:(NSString *)networkIdentifier
{
    NSError *keychainError = nil;
    NSArray *accounts = [KeychainUtils savedAccountsForListIdentifier:kAccountsListIdentifier error:&keychainError];
    
    if (keychainError)
    {
        AlfrescoLogError(@"Error retreiving accounts. Error: %@", keychainError.localizedDescription);
    }
    
    // Get the account for the file
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountIdentifier == %@", accountIdentifier];
    NSArray *accountArray = [accounts filteredArrayUsingPredicate:predicate];
    UserAccount *keychainAccount = accountArray.firstObject;
    UserAccountWrapper *account = [[UserAccountWrapper alloc] initWithUserAccount:keychainAccount];
    account.selectedNetworkIdentifier = networkIdentifier;
    
    return account;
}

+ (BOOL)isPINAuthenticationSet {
    NSError *error = nil;
    NSString *pin = [KeychainUtils retrieveItemForKey:kPinKey
                                                error:&error];
    
    BOOL isPINSet = NO;
    
    if (error && error.code != errSecItemNotFound)
    {
        AlfrescoLogError(@"Error retrieving PIN key from keychain. Reason: %@", error.localizedDescription);
    } else
    {
        isPINSet = pin.length ? YES : NO;
    }
    
    return isPINSet;
}

+ (NSError *)authenticationError
{
    NSError *error = nil;
    if (@available(iOS 11.0, *))
    {
        error = [NSError errorWithDomain:NSFileProviderErrorDomain
                                    code:NSFileProviderErrorNotAuthenticated
                                userInfo:nil];
    }
    
    return error;
}

#pragma mark - Public methods

- (void)getSessionForAccountIdentifier:(NSString *)accountIdentifier networkIdentifier:(NSString *)networkIdentifier withCompletionBlock:(void (^)(id<AlfrescoSession>, NSError *))completionBlock
{
    id<AlfrescoSession> cachedSession = self.accountIdentifierToSessionMappings[accountIdentifier];
    if(cachedSession)
    {
        completionBlock(cachedSession, nil);
    }
    else
    {
        UserAccountWrapper *account = [self userAccountForAccountIdentifier:accountIdentifier networkIdentifier:networkIdentifier];
        [self loginToAccount:account completionBlock:^(BOOL successful, id<AlfrescoSession> session, NSError *loginError) {
            completionBlock(session, loginError);
        }];
    }
}

+ (NSError *)authenticationErrorForPIN {
    if ([self isPINAuthenticationSet]) {
        return [self authenticationError];
    }
    
    return nil;
}

@end
