//
//  SpeakToSnapViewController.m
//  SpeakToSnap
//
//  Created by Neeraj Baid on 9/8/13.
//  Copyright (c) 2013 Neeraj Baid. All rights reserved.
//

#import "SpeakToSnapViewController.h"
#import "R1PhotoEffectsSDK.h"

@interface SpeakToSnapViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) NSArray *strings;
@property (strong, nonatomic) UIImagePickerController *cameraUI;

@end

@implementation SpeakToSnapViewController

@synthesize pocketsphinxController;
@synthesize openEarsEventsObserver;

#pragma mark - Camera

- (void)presentCamera
{
    _cameraUI = [[UIImagePickerController alloc] init];
    _cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    _cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
    _cameraUI.allowsEditing = NO;
    _cameraUI.delegate = self;
    
    [self presentViewController:_cameraUI animated:YES completion:^{
        [_spinner stopAnimating];
        _spinner.alpha = 0;
    }];
}

#pragma mark - Image

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIViewController *r1vc = [[R1PhotoEffectsSDK sharedManager]
                              photoEffectsControllerForImage: [info objectForKey:UIImagePickerControllerOriginalImage]
                            delegate: self
                            cropSupport: YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:r1vc animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self presentCamera];
    }];
}

- (void)photoEffectsEditingViewController:(R1PhotoEffectsEditingViewController *)controller didFinishWithImage:(UIImage *)image
{
    [self dismissViewControllerAnimated:YES completion:^{
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        [self savedImage];
    }];
}

- (void)savedImage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Image saved to Camera Roll!"
                                                   delegate:self cancelButtonTitle:@"Awesome" otherButtonTitles: nil];
    [alert show];
}

- (void)photoEffectsEditingViewControllerDidCancel:(R1PhotoEffectsEditingViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self presentCamera];
}

#pragma mark - OpenEars

- (PocketsphinxController *)pocketsphinxController {
	if (pocketsphinxController == nil) {
		pocketsphinxController = [[PocketsphinxController alloc] init];
	}
	return pocketsphinxController;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
}

- (BOOL)containsRelevantString:(NSString *)hyp
{
    for (int a = 0; a < [_strings count]; a++)
    {
        if ([hyp rangeOfString:[_strings objectAtIndex:a]].location != NSNotFound)
            return YES;
    }
    return NO;
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID
{
    if ([self containsRelevantString:hypothesis])
        [_cameraUI takePicture];
    
	NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
}

- (void) pocketsphinxDidStartCalibration {
    [self presentCamera];
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}
- (void) testRecognitionCompleted {
	NSLog(@"A test file that was submitted for recognition is now complete.");
}

# pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _strings = [NSArray arrayWithObjects:@"TAKE A PICTURE", @"PICTURE", @"PIC", @"TAKE PIC", @"TAKE A PIC", nil];
    
    LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
    NSMutableArray *words = [NSMutableArray arrayWithArray:_strings];
    
    NSArray *additionalWords = [NSArray arrayWithObjects:@"the",@"of",@"and",@"a",@"to",@"in",@"is",@"you",@"that",@"it",@"he",@"was",@"for",@"on",@"are",@"as",@"with",@"his",@"they",@"I",@"at",@"be",@"this",@"have",@"from",@"or",@"one",@"had",@"by",@"word",@"but",@"not",@"what",@"all",@"were",@"we",@"when",@"your",@"can",@"said",@"there",@"use",@"an",@"each",@"which",@"she",@"do",@"how",@"their",@"if",@"will",@"up",@"other",@"about",@"out",@"many",@"then",@"them",@"these",@"so",@"some",@"her",@"would",@"make",@"like",@"him",@"into",@"time",@"has",@"look",@"two",@"more",@"write",@"go",@"see",@"number",@"no",@"way",@"could",@"people",@"my",@"than",@"first",@"water",@"been",@"call",@"who",@"oil",@"its",@"now",@"find",@"long",@"down",@"day",@"did",@"get",@"come",@"made",@"may",@"part", nil];
    
    [words addObjectsFromArray:additionalWords];
    
    NSString *name = @"NameIWantForMyLanguageModelFiles";
    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    NSDictionary *languageGeneratorResults = nil;
    
    NSString *lmPath = nil;
    NSString *dicPath = nil;
	
    if([err code] == noErr) {
        
        languageGeneratorResults = [err userInfo];
		
        lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
        dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
		
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    
    [self.openEarsEventsObserver setDelegate:self];
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    
    [_backgroundImage setBackgroundColor:[UIColor blackColor]];
    [_spinner startAnimating];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
