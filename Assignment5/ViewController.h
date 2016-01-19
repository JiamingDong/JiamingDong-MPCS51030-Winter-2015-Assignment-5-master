//
//  ViewController.h
//  Assignment5
//
//  Created by dongjiaming on 15/2/4.
//  Copyright (c) 2015年 The University of Chicago, Department of Computer Science. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dragImageView.h"
#import "linePrinter.h"
#import <AVFoundation/AVFoundation.h>
#import "InfoUIView.h"

typedef enum {
    GameStateRunning = 1,
    GameStateXWin = 2,
    GameStateOWin = 3,
    GameStateDraw = 4,
}GameState;

typedef enum {
    Empty = 1,
    OccupiedByX = 2,
    OccupiedByO = 3,
}GridState;

@interface ViewController : UIViewController<UIGestureRecognizerDelegate, UIAlertViewDelegate, AVAudioPlayerDelegate> {
    GridState gridStates[3][3]; //record the state of each grid: 0-empty; 1-'x'; 2-'o';
}

// the 2-dimension array to store the 9 UIImageViews.
@property NSMutableArray* gridArray;
@property UIPanGestureRecognizer* xpan;
@property UIPanGestureRecognizer* opan;
@property UIImageView* boardView;
@property dragImageView* xDrag;
@property dragImageView* oDrag;

@property int step_num;  //record the number of steps;
@property GameState gState; //record game state

@property CGContextRef context;

@property (strong,nonatomic) linePrinter* line;

@property (nonatomic) AVAudioPlayer* player;
@property NSString* voiceName;

@property InfoUIView* inforView;
//Game Information
- (IBAction)pressInfoButton:(id)sender;
- (IBAction)RestartGame:(id)sender;

@end

