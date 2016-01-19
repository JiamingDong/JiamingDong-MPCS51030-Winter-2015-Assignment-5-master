//
//  ViewController.m
//  Assignment5
//
//  Created by dongjiaming on 15/2/4.
//  Copyright (c) 2015年 The University of Chicago, Department of Computer Science. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Initialize stem_num, gridStates and gState
    self.step_num = 0;
    self.gState = GameStateRunning;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j ++) {
            gridStates[i][j] = Empty;
        }
    }
    
    // Initialize boardView
    self.boardView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width)];
    
    self.boardView.image = [UIImage imageNamed:@"tic-tac-toe-board.png"];
    [self.view addSubview:self.boardView];
    
    // Initialize x and o custom ImageView
    self.xDrag = [[dragImageView alloc] initWithFrame:CGRectMake(10, 500, 100, 100)];
    
    self.oDrag = [[dragImageView alloc] initWithFrame:CGRectMake(250, 500, 100, 100)];
    
    self.xDrag.image = [UIImage imageNamed:@"xDrag.png"];
    [self.view addSubview:self.xDrag];
    // animation
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.xDrag.frame = CGRectMake(10, 500, 200, 200);
                     }completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              self.xDrag.frame = CGRectMake(10, 500, 100, 100);
                                          }
                          ];
                     }
     ];
    self.oDrag.alpha = 0.5f;
    self.oDrag.image = [UIImage imageNamed:@"oDrag.png"];
    [self.view addSubview:self.oDrag];
    
    //Initialize 9 transparent UIViews
    float length = self.view.frame.size.width/3 - 30;
    
    UIImageView* grid11 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 115, length, length)];
    UIImageView* grid12 = [[UIImageView alloc] initWithFrame:CGRectMake(45 + length, 115, length, length)];
    UIImageView* grid13 = [[UIImageView alloc] initWithFrame:CGRectMake(75 + 2*length, 115, length, length)];
    UIImageView* grid21 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 145 + length, length, length)];
    UIImageView* grid22 = [[UIImageView alloc] initWithFrame:CGRectMake(45 + length, 145 + length, length, length)];
    UIImageView* grid23 = [[UIImageView alloc] initWithFrame:CGRectMake(75 + 2*length, 145 + length, length, length)];
    UIImageView* grid31 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 175 + 2*length, length, length)];
    UIImageView* grid32 = [[UIImageView alloc] initWithFrame:CGRectMake(45 + length, 175 + 2*length, length, length)];
    UIImageView* grid33 = [[UIImageView alloc] initWithFrame:CGRectMake(75 + 2*length, 175 + 2*length, length, length)];
    
    self.gridArray = [[NSMutableArray alloc] initWithObjects:[[NSMutableArray alloc] initWithObjects: grid11, grid12, grid13, nil], [[NSMutableArray alloc] initWithObjects: grid21, grid22, grid23, nil], [[NSMutableArray alloc] initWithObjects: grid31, grid32, grid33, nil], nil];
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            UIImageView* iv = [[self.gridArray objectAtIndex:i] objectAtIndex:j];
            iv.image = nil;
            [self.view addSubview:[[self.gridArray objectAtIndex:i] objectAtIndex:j] ];
        }
    }
    
    // Initialize xpan (gesture recognizer for x)
    self.xpan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleXPan:)];
    [self.xpan setMaximumNumberOfTouches:2];
    [self.xpan setDelegate:self];
    
    // Enable xDrag to receive touches initially and add the gesture xpan.
    [self.xDrag setUserInteractionEnabled:YES];
    [self.xDrag addGestureRecognizer:self.xpan];
    
    // Initialize opan (gesture recognizer for o)
    self.opan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOPan:)];
    [self.opan setMaximumNumberOfTouches:2];
    [self.opan setDelegate:self];
    
    // Prevent oDrag from receiving touches initially and add the gesture opan.
    [self.oDrag setUserInteractionEnabled:NO];
    [self.oDrag addGestureRecognizer:self.opan];
}

- (void) handleXPan: (UIPanGestureRecognizer *)sender{
    //if (gestureRecognizer.view == myView) return;
    
    UIView *piece = [sender view];
    [[piece superview] bringSubviewToFront:piece];
    
    //[self adjustAnchorPointForGestureRecognizer:sender];
    
    if ([sender state] == UIGestureRecognizerStateBegan ||
        [sender state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [sender translationInView:[piece superview]];
        [piece setCenter:CGPointMake([piece center].x + translation.x,
                                     [piece center].y + translation.y)];
        [sender setTranslation:CGPointZero inView:[piece superview]];
        
        if([sender state] == UIGestureRecognizerStateBegan) {
            // make a sound as a reminder
            self.voiceName= [[NSBundle mainBundle]pathForResource:@"press" ofType:@"mp3"];
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.voiceName] error:NULL];
            self.player.meteringEnabled = YES;
            self.player.delegate = self;
            [self.player prepareToPlay];
            [self.player play];
        }
    }
    if ([sender state] == UIGestureRecognizerStateEnded) {
        if(![self judgeAndAddImage:[piece center].x :[piece center].y]) {
            [UIView animateWithDuration:1.5
                             animations:^{
                                 [piece setCenter:CGPointMake(60, 550)];
                             }
             ];
        }
        else {
            //update the game state after each step
            [self updateGameState];
            //game is over
            if (self.gState != GameStateRunning) {
                [self endGame];
            }
            else {
                //animation
                [UIView animateWithDuration:0.5
                                 animations:^{
                                     self.oDrag.frame = CGRectMake(250, 500, 200, 200);
                                 }completion:^(BOOL finished){
                                     [UIView animateWithDuration:0.5
                                                      animations:^{
                                                          self.oDrag.frame = CGRectMake(250, 500, 100, 100);
                                                      }
                                      ];
                                 }
                 ];
            }
        }
        
        [piece setCenter:CGPointMake(60, 550)];
        [sender setTranslation:CGPointZero inView:[piece superview]];
    }
}

- (void) handleOPan: (UIPanGestureRecognizer *)sender{
    //if (gestureRecognizer.view == myView) return;
    
    UIView *piece = [sender view];
    [[piece superview] bringSubviewToFront:piece];
    
    //[self adjustAnchorPointForGestureRecognizer:sender];
    
    if ([sender state] == UIGestureRecognizerStateBegan ||
        [sender state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [sender translationInView:[piece superview]];
        [piece setCenter:CGPointMake([piece center].x + translation.x,
                                     [piece center].y + translation.y)];
        [sender setTranslation:CGPointZero inView:[piece superview]];
        
        if([sender state] == UIGestureRecognizerStateBegan) {
            // make a sound as a reminder
            self.voiceName= [[NSBundle mainBundle]pathForResource:@"press" ofType:@"mp3"];
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.voiceName] error:NULL];
            self.player.meteringEnabled = YES;
            self.player.delegate = self;
            [self.player prepareToPlay];
            [self.player play];
        }
    }
    if ([sender state] == UIGestureRecognizerStateEnded) {
        //judge if x or o is put into one of those 9 grid, add the x/o image and put 1 step forward
        if(![self judgeAndAddImage:[piece center].x :[piece center].y]) {
            [UIView animateWithDuration:1.5
                             animations:^{
                                 [piece setCenter:CGPointMake(300, 550)];
                             }
             ];
        }
        else {
            //update the game state after each step
            [self updateGameState];
            //game is over
            if (self.gState != GameStateRunning) {
                [self endGame];
            }
            else {
                //animation
                [UIView animateWithDuration:0.5
                                 animations:^{
                                     self.xDrag.frame = CGRectMake(10, 500, 200, 200);
                                 }completion:^(BOOL finished){
                                     [UIView animateWithDuration:0.5
                                                      animations:^{
                                                          self.xDrag.frame = CGRectMake(10, 500, 100, 100);
                                                      }
                                      ];
                                 }
                 ];
            }
        }
        
        
        
        [piece setCenter:CGPointMake(300, 550)];
        [sender setTranslation:CGPointZero inView:[piece superview]];
    }
}

// judge if the 'x' or 'o' belongs to which one of those 9 UIImageViews. If it belongs to one, add an Image a subview to that UIImageView and return true, else return false.

- (bool) judgeAndAddImage: (CGFloat) x : (CGFloat) y{
    CGFloat width = self.view.frame.size.width;
    CGFloat gridLength = width / 3;
    if (x >= 0 && x <= width && y >= 100 && y <= width + 100) {
        NSInteger row = (y - 100) / gridLength;
        NSInteger col =  x / gridLength;
        
        UIImageView *grid = [[self.gridArray objectAtIndex:row] objectAtIndex:col];
        
        // current grid has already been occupied.
        if (gridStates[row][col] != Empty) {
            // make a sound as a reminder
            self.voiceName= [[NSBundle mainBundle]pathForResource:@"buzzer" ofType:@"mp3"];
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.voiceName] error:NULL];
            self.player.meteringEnabled = YES;
            self.player.delegate = self;
            [self.player prepareToPlay];
            [self.player play];
            
            return false;
        }
        
        // It is x's turn
        if (self.step_num % 2 == 0) {
            //add image
            [grid setCenter:CGPointMake(x, y)];
            grid.image = [UIImage imageNamed:@"xDrag.png"];
            [UIView animateWithDuration:0.7
                             animations:^{
                                 [grid setCenter:CGPointMake(col * gridLength + gridLength/2, 100 + row*gridLength + gridLength/2)];
                             }
             ];
            //update gridStates[][]
            gridStates[row][col] = OccupiedByX;
            //let oDrag be able to be dragged and forbid xDrag.
            [self.xDrag setUserInteractionEnabled:NO];
            [self.oDrag setUserInteractionEnabled:YES];
            //swift alpha
            self.xDrag.alpha = 0.5f;
            self.oDrag.alpha = 1.0f;
            
        }
        // It is o's turn
        else {
            //add image
            [grid setCenter:CGPointMake(x, y)];
            grid.image = [UIImage imageNamed:@"oDrag.png"];
            [UIView animateWithDuration:0.7
                             animations:^{
                                 [grid setCenter:CGPointMake(col * gridLength + gridLength/2, 100 + row*gridLength + gridLength/2)];
                             }
             ];
            //update gridStates[][]
            gridStates[row][col] = OccupiedByO;
            //let xDrag be able to be dragged and forbid oDrag.
            [self.oDrag setUserInteractionEnabled:NO];
            [self.xDrag setUserInteractionEnabled:YES];
            //swift alpha
            self.xDrag.alpha = 1.0f;
            self.oDrag.alpha = 0.5f;
        }
        
        self.step_num ++;
        
        // make a sound as a reminder
        self.voiceName= [[NSBundle mainBundle]pathForResource:@"settle" ofType:@"wav"];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.voiceName] error:NULL];
        self.player.meteringEnabled = YES;
        self.player.delegate = self;
        [self.player prepareToPlay];
        [self.player play];
        
        return true;
    }
    else return false;
}

// Draw a line from (startX, startY) to (endX, endY)
- (void)drawLine: (CGFloat) startX : (CGFloat) startY : (CGFloat) endX : (CGFloat) endY {
    self.line = [[linePrinter alloc] initWithFrameCustomed:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) :startX :startY :endX :endY];
    [self.line setBackgroundColor:[UIColor clearColor]];
    [self.line setTag:111];
    [self.view addSubview:self.line];
}

- (void)updateGameState {
    CGFloat length = self.view.frame.size.width / 3;
    // check rows
    for (int i = 0; i < 3; i++) {
        if (gridStates[i][0] != Empty && gridStates[i][0] == gridStates[i][1] && gridStates[i][1] == gridStates[i][2]) {
            
            //draw a line from [i][0] to [i][2]
            [self drawLine: length/2 : 100 + length/2 + i*length :5*length/2 :100 + length/2 + i*length];
            //x wins
            if (gridStates[i][0] == OccupiedByX) {
                self.gState = GameStateXWin;
                return;
            }
            else //o wins
            {
                self.gState = GameStateOWin;
                return;
            }
        }
    }
    // check cols
    for (int i = 0; i < 3; i++) {
        if (gridStates[0][i] != Empty && gridStates[0][i] == gridStates[1][i] && gridStates[1][i] == gridStates[2][i]) {
            
            //draw a line from [0][i] to [2][i]
            [self drawLine: length/2 + i*length :100 + length/2 :length/2 + i*length :100 + 5*length/2];
            //x wins
            if (gridStates[0][i] == OccupiedByX) {
                self.gState = GameStateXWin;
                return;
            }
            else //o wins
            {
                self.gState = GameStateOWin;
                return;
            }
        }
    }
    // check 2 diagonals
    if ( (gridStates[0][0] == gridStates[1][1] && gridStates[1][1] == gridStates[2][2] &&gridStates[0][0] != Empty) || (gridStates[2][0] == gridStates[1][1] && gridStates[1][1] == gridStates[0][2] && gridStates[2][0] != Empty)){
        
        if (gridStates[0][0] == gridStates[1][1] && gridStates[1][1] == gridStates[2][2] &&gridStates[0][0] != Empty) {
            //draw a line from [0][0] to [2][2]
            [self drawLine: length/2 :100 + length/2 : 5*length/2 :100 + 5*length/2];
        }
        else
        {
            //draw a line from [0][2] to [2][0]
            [self drawLine: 5*length/2 : 100 + length/2 : length/2 :100 + 5*length/2];
        }
        //x wins
        if (gridStates[1][1] == OccupiedByX) {
            self.gState = GameStateXWin;
            return;
        }
        else //o wins
        {
            self.gState = GameStateOWin;
            return;
        }
    }
    // if all the grids are occupied, the result is draw.
    if (self.step_num > 8) {
        self.gState = GameStateDraw;
        return;
    }
}

- (void)endGame {
    NSString *str = nil;
    switch (self.gState) {
        case GameStateXWin:
            str = @"X wins!";
            break;
        case GameStateOWin:
            str = @"O wins!";
            break;
        case GameStateDraw:
            str = @"Draw!";
            break;
        default:
            break;
    }
    UIAlertView *endAlert = [[UIAlertView alloc] initWithTitle:@"Game Over!" message:str delegate:self cancelButtonTitle:@"New Game" otherButtonTitles:nil];
    
    // make a sound when the game is over.
    if (self.gState == GameStateDraw) {
        self.voiceName= [[NSBundle mainBundle]pathForResource:@"even" ofType:@"mp3"];
    }
    else self.voiceName= [[NSBundle mainBundle]pathForResource:@"congratulation" ofType:@"mp3"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.voiceName] error:NULL];
    self.player.meteringEnabled = YES;
    self.player.delegate = self;
    [self.player prepareToPlay];
    [self.player play];
    
    [endAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"New Game"])
    {
        //reset the game.
        [[alertView delegate] resetTheGame];
    }
}

- (void)resetTheGame {
    //make a sound for the disappearing of pieces
    self.voiceName= [[NSBundle mainBundle]pathForResource:@"disappear" ofType:@"wav"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.voiceName] error:NULL];
    self.player.meteringEnabled = YES;
    self.player.delegate = self;
    [self.player prepareToPlay];
    [self.player play];
    //animate the pieces off the secreen.
    [UIView animateWithDuration:1.5
                     animations:^{
                         for (int i = 0; i < 3; i++) {
                             for (int j = 0; j < 3; j++) {
                                 if (gridStates[i][j] != Empty) {
                                     UIImageView *iv = [[self.gridArray objectAtIndex:i] objectAtIndex:j];
                                     iv.alpha = 0;
                                 }
                             }
                         }
                         self.line.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         //reset all the relevant variables
                         self.gState = GameStateRunning;
                         self.step_num = 0;
                         for (int i = 0; i < 3; i++) {
                             for (int j = 0; j < 3; j++) {
                                 gridStates[i][j] = Empty;
                                 UIImageView *iv = [[self.gridArray objectAtIndex:i] objectAtIndex:j];
                                 iv.image = nil;
                                 iv.alpha = 1;
                             }
                         }
                         
                         //reset InteractionEnabled and alpha
                         [self.xDrag setUserInteractionEnabled:YES];
                         [self.oDrag setUserInteractionEnabled:NO];
                         self.xDrag.alpha = 1.0f;
                         self.oDrag.alpha = 0.5f;
                         //remove self.line from its super view.
                         UIView *line  = [self.view viewWithTag:111];
                         [line removeFromSuperview];
                         
                         //animation
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              self.xDrag.frame = CGRectMake(10, 500, 200, 200);
                                          }completion:^(BOOL finished){
                                              [UIView animateWithDuration:0.5
                                                               animations:^{
                                                                   self.xDrag.frame = CGRectMake(10, 500, 100, 100);
                                                               }
                                               ];
                                          }
                          ];
                     }
     ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressInfoButton:(id)sender {
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    self.inforView = [[InfoUIView alloc] initWithFrame: CGRectMake(0, -height,width,height)];
    [self.view addSubview: self.inforView];
    [UIView animateWithDuration:1.5 animations:^{
        [self.inforView setCenter:CGPointMake(width/2, height/2)];
    }];
}

- (IBAction)RestartGame:(id)sender {
    [self resetTheGame];
}
@end
