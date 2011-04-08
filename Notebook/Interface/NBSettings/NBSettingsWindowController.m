/*
 * Copyright 2011 Tim Horton. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY TIM HORTON "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL TIM HORTON OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* Copyright (c) 2011, individual contributors
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#import "NBSettingsWindowController.h"

#import "NBSettings.h"
#import "NBThemeListDataSource.h"
#import "VLPreferencesToolbarItem.h"

@implementation NBSettingsWindowController

@synthesize languageBrowser;
@synthesize themeList;

- (void)awakeFromNib
{
    [languageBrowser reloadData];

    NBThemeListDataSource * dataSource = [themeList dataSource];
    NSString * themeName = [[NBSettings sharedInstance] themeName];
    NSIndexSet * selectedIndex = [NSIndexSet indexSetWithIndex:[dataSource.themeNames indexOfObject:themeName]];

    [themeList selectRowIndexes:selectedIndex byExtendingSelection:NO];
    
    NSArray * items = [[[self window] toolbar] items];
    NSString * ident = [[[self window] toolbar] selectedItemIdentifier];
    
    for(VLPreferencesToolbarItem * item in items)
    {
        if([[item itemIdentifier] isEqualToString:ident])
        {
            currentView = [item preferencesView];
            currentItem = item;
            
            [[self window] setTitle:[item label]];
            
            CGFloat height = [currentView frame].size.height;
            height -= [[[self window] contentView] frame].size.height;
            
            NSRect windowFrame = [[self window] frame];
            windowFrame.size.height += height;
            windowFrame.origin.y -= height;
            [[self window] setFrame:windowFrame display:YES];
            
            [currentView setFrame:[[[self window] contentView] bounds]];
            [[[self window] contentView] addSubview:currentView];
        }
    }
    
    transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [transition setSubtype:kCATransitionFromRight];
    NSDictionary* anim = [NSDictionary dictionaryWithObject:transition forKey:@"subviews"];
    [[[self window] contentView] setAnimations:anim];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NBThemeListDataSource * dataSource = [themeList dataSource];
    NSString * themeName = [dataSource.themeNames objectAtIndex:[[themeList selectedRowIndexes] firstIndex]];

    [[NSUserDefaults standardUserDefaults] setObject:themeName forKey:NBThemeNameKey];
}

-(IBAction)toolbarItemClicked:(id)sender
{
    // choose the correct transition
    NSArray * items = [[[self window] toolbar] items];
    [transition setSubtype:[items indexOfObject:sender] < [items indexOfObject:currentItem] ?
    kCATransitionFromLeft : kCATransitionFromRight];
    currentItem = sender;
    
    // select the toolbar item
    [[[self window] toolbar] setSelectedItemIdentifier:[sender itemIdentifier]];
    
    // set the window's title
    [[self window] setTitle:[sender label]];
    
    // set the window's height
    CGFloat height = [[sender preferencesView] desiredHeight];
    height -= [[[self window] contentView] frame].size.height;
    
    [[[[self window] contentView] animator] replaceSubview:currentView with:[sender preferencesView]];
    [[sender preferencesView] setFrame:[[[self window] contentView] bounds]];
    currentView = [sender preferencesView];
    
    NSRect windowFrame = [[self window] frame];
    windowFrame.size.height += height;
    windowFrame.origin.y -= height;
    [[self window] setFrame:windowFrame display:YES animate:YES];
}

-(NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar
{
    NSArray * items = [[[self window] toolbar] items];
    NSMutableArray * ids = [NSMutableArray arrayWithCapacity:[items count]];
    
    for (int i = 0; i < [items count]; i++)
    {
        [ids addObject:[[items objectAtIndex:i] itemIdentifier]];
    }
    
    return ids;
}


@end
