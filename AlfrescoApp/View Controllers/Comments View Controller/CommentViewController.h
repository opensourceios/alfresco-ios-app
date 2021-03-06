/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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
  
#import "ParentListViewController.h"
#import "NodeUpdatableProtocol.h"

@class CommentViewController;

@protocol CommentViewControllerDelegate <NSObject>

- (void)commentViewController:(CommentViewController *)controller didUpdateCommentCount:(NSUInteger)commentDisplayedCount hasMoreComments:(BOOL)hasMoreComments;

@end

@interface CommentViewController : ParentListViewController <NodeUpdatableProtocol>

@property (nonatomic, weak, readonly) id<CommentViewControllerDelegate> delegate;

- (id)initWithAlfrescoNode:(AlfrescoNode *)node permissions:(AlfrescoPermissions *)permissions session:(id<AlfrescoSession>)session delegate:(id<CommentViewControllerDelegate>)delegate;
- (void)focusCommentEntry:(BOOL)shouldFocus;

@end
