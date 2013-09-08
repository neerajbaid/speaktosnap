//
//  SpeakToSnapViewController.h
//  SpeakToSnap
//
//  Created by Neeraj Baid on 9/8/13.
//  Copyright (c) 2013 Neeraj Baid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/AcousticModel.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import "R1PhotoEffectsSDK.h"

@interface SpeakToSnapViewController : UIViewController <OpenEarsEventsObserverDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, R1PhotoEffectsEditingViewControllerDelegate, UIAlertViewDelegate>
{
    PocketsphinxController *pocketsphinxController;
    OpenEarsEventsObserver *openEarsEventsObserver;
}

@property (nonatomic, strong) PocketsphinxController *pocketsphinxController;
@property (nonatomic, strong) OpenEarsEventsObserver *openEarsEventsObserver;

@end
