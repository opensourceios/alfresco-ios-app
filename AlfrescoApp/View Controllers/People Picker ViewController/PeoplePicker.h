//
//  PeoplePicker.h
//  AlfrescoApp
//
//  Created by Mohamad Saeedi on 05/03/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultiSelectActionsToolbar.h"

@class PeoplePicker;

typedef NS_ENUM(NSInteger, PeoplePickerMode)
{
    PeoplePickerModeMultiSelect,
    PeoplePickerModeSingleSelect
};

@protocol PeoplePickerDelegate <NSObject>

@optional
- (void)peoplePicker:(PeoplePicker *)peoplePicker didSelectPeople:(NSArray *)selectedPeople;
- (void)peoplePicker:(PeoplePicker *)peoplePicker didDeselectPerson:(AlfrescoPerson *)person;

@end

@interface PeoplePicker : NSObject <MultiSelectActionsDelegate>

@property (nonatomic, assign) PeoplePickerMode mode;
@property (nonatomic, weak) id<PeoplePickerDelegate> delegate;

/*
 * Initiate People Picker giving it reference to nav controller so it can push viewcontrollers e.g people controller
 * @param NavigationController
 */
- (instancetype)initWithSession:(id<AlfrescoSession>)session navigationController:(UINavigationController *)navigationController;

/*
 * Initiate People Picker giving it reference to nav controller so it can push viewcontrollers e.g people controller
 * @param NavigationController
 * @param delegate - call back object comforming to PeoplePickerDelegate
 */
- (instancetype)initWithSession:(id<AlfrescoSession>)session navigationController:(UINavigationController *)navigationController delegate:(id<PeoplePickerDelegate>)delegate;

/*
 * start people picker
 * @param People Picker Mode
 * @param modally - whether or not to display the picker modally
 */
- (void)startWithPeople:(NSMutableArray *)people mode:(PeoplePickerMode)mode modally:(BOOL)modally;

/*
 * cancel people picker
 */
- (void)cancel;


/*
 * Bellow methods are internal to PeoplePicker controllers (accessed from PeoplePickerViewController)
 */
- (BOOL)isPersonSelected:(AlfrescoPerson *)person;
- (void)deselectPerson:(AlfrescoPerson *)person;
- (void)deselectAllPeople;
- (void)selectPerson:(AlfrescoPerson *)person;
- (void)replaceSelectedPeopleWithPeople:(NSArray *)people;
- (NSArray *)selectedPeople;

- (void)pickingPeopleComplete;

- (void)showMultiSelectToolBar;
- (void)hideMultiSelectToolBar;

@end