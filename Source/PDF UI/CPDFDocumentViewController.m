//
//  PDFReaderViewController.m
//  PDFReader
//
//  Created by Jonathan Wight on 02/19/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CPDFDocumentViewController.h"

#import "CPDFDocument.h"
#import "CPagingView.h"
#import "CPDFPageView.h"
#import "CPreviewBar.h"
#import "CPageControl.h"
#import "CPDFPage.h"

@interface CPDFDocumentViewController () <CPagingViewDataSource, CPDFDocumentDelegate, CPreviewBarDelegate>
@end

@implementation CPDFDocumentViewController

@synthesize document = _document;
@synthesize pagingView = _pagingView;
@synthesize pagePlaceholderView = _pagePlaceholderView;
@synthesize pageControl = _pageControl;
@synthesize chromeView = _chromeView;
@synthesize previewBar = _previewBar;

- (id)init
	{
	if ((self = [super initWithNibName:NSStringFromClass([self class]) bundle:NULL]) != NULL)
		{
		}
	return(self);
	}

- (id)initWithURL:(NSURL *)inURL;
    {
	if ((self = [self init]) != NULL)
		{
        _document = [[CPDFDocument alloc] initWithURL:inURL];
        _document.delegate = self;
		}
	return(self);
    }

- (void)didReceiveMemoryWarning
    {
    [super didReceiveMemoryWarning];
    }

#pragma mark - View lifecycle

- (void)viewDidLoad
    {
    [super viewDidLoad];

    self.pagingView.dataSource = self;

    UITapGestureRecognizer *theRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:theRecognizer];

    UISwipeGestureRecognizer *theSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    theSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:theSwipeRecognizer];

    theSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    theSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:theSwipeRecognizer];

    theSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    theSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:theSwipeRecognizer];

    theSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    theSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:theSwipeRecognizer];

    self.previewBar.delegate = self;
    [self.previewBar addTarget:self action:@selector(previewSelected:) forControlEvents:UIControlEventValueChanged];
    [self.previewBar sizeToFit];

    self.pageControl.target = self;
    self.pageControl.nextAction = @selector(nextPage:);
    self.pageControl.previousAction = @selector(previousPage:);
    }

- (void)viewDidUnload
    {
    [super viewDidUnload];
    }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
    {
    return(YES);
    }

- (IBAction)tap:(UITapGestureRecognizer *)inSender
    {
    [UIView animateWithDuration:0.25 delay:0.0 options:0 animations:^(void) {
        self.chromeView.alpha = 1.0 - self.chromeView.alpha;
    } completion:NULL];

    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];


//    [[UIApplication sharedApplication] setStatusBarHidden:![UIApplication sharedApplication].statusBarHidden withAnimation:YES];
    }


- (IBAction)swipe:(UISwipeGestureRecognizer *)inSender
    {
    switch (inSender.direction)
        {
        case UISwipeGestureRecognizerDirectionRight:
        case UISwipeGestureRecognizerDirectionDown:
            [self.pagingView scrollToPreviousPageAnimated:YES];
            break;
        case UISwipeGestureRecognizerDirectionLeft:
        case UISwipeGestureRecognizerDirectionUp:
            [self.pagingView scrollToNextPageAnimated:YES];
            break;
        }
    }

- (NSInteger)numberOfPreviewsInPreviewBar:(CPreviewBar *)inPreviewBar
    {
    return(self.document.numberOfPages);
    }

- (UIImage *)previewBar:(CPreviewBar *)inPreviewBar previewAtIndex:(NSInteger)inIndex;
    {
    UIImage *theImage = [self.document pageForPageNumber:inIndex + 1].thumbnail;
    return(theImage);
    }

#pragma mark -

- (void)nextPage:(id)inSender
    {
    [self.pagingView scrollToNextPageAnimated:YES];
    }

- (void)previousPage:(id)inSender
    {
    [self.pagingView scrollToPreviousPageAnimated:YES];
    }

- (void)previewSelected:(id)inSender
    {
    [self.pagingView scrollToPageAtIndex:self.previewBar.selectedPreviewIndex animated:YES];
    }

#pragma mark -

- (NSUInteger)numberOfPagesInPagingView:(CPagingView *)inPagingView;
    {
    return(self.document.numberOfPages);
    }

- (UIView *)pagingView:(CPagingView *)inPagingView viewForPageAtIndex:(NSUInteger)inIndex
    {
    CPDFPageView *thePageView = [[CPDFPageView alloc] initWithFrame:(CGRect){ .size = { 0, 0 } }];
    thePageView.page = [[CPDFPage alloc] initWithDocument:self.document pageNumber:inIndex + 1];
    return(thePageView);
    }

- (void)PDFDocument:(CPDFDocument *)inDocument didUpdateThumbnailForPage:(CPDFPage *)inPage
    {
    [self.previewBar updatePreviewAtIndex:inPage.pageNumber - 1];
    }

@end