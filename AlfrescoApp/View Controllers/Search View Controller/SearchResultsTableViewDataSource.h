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

#import <Foundation/Foundation.h>

@protocol SearchResultsTableViewDataSourceDelegate <NSObject>
@optional
- (void)dataSourceUpdated;
@end

@interface SearchResultsTableViewDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) id<AlfrescoSession> session;
@property (nonatomic, assign) BOOL moreItemsAvailable;
@property (nonatomic, strong) AlfrescoListingContext *defaultListingContext;
@property (nonatomic, strong) NSMutableArray *searchResultsArray;
@property (nonatomic, weak) id<SearchResultsTableViewDataSourceDelegate>delegate;

- (instancetype)initWithDataSourceType:(SearchViewControllerDataSourceType)dataSourceType searchString:(NSString *)searchString session:(id<AlfrescoSession>)session delegate:(id<SearchResultsTableViewDataSourceDelegate>)delegate listingContext:(AlfrescoListingContext *)listingContext;
- (instancetype)initWithDataSourceType:(SearchViewControllerDataSourceType)dataSourceType results:(NSArray *)results delegate:(id<SearchResultsTableViewDataSourceDelegate>)delegate;

- (void)retrieveNextItems:(AlfrescoListingContext *)moreListingContext;
- (void)searchKeyword:(NSString *)keyword session:(id<AlfrescoSession>)session listingContext:(AlfrescoListingContext *)listingContext;
- (void)clearDataSource;

+ (AlfrescoKeywordSearchOptions *)searchOptionsForSearchType:(SearchViewControllerDataSourceType)searchType;

@end
