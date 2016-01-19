//
//  InfoUIView.m
//  Assignment5
//
//  Created by dongjiaming on 15/2/7.
//  Copyright (c) 2015年 The University of Chicago, Department of Computer Science. All rights reserved.
//

#import "InfoUIView.h"

@implementation InfoUIView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UITextView *text = [[UITextView alloc] initWithFrame: CGRectMake(10, 20, width - 20, height - 30)];
    text.editable = false;
    text.text = @"\nEnglish: \nTic-tac-toe (or Noughts and crosses, Xs and Os) is a paper-and-pencil game for two players, X and O, who take turns marking the spaces in a 3×3 grid. The player who succeeds in placing three respective marks in a horizontal, vertical, or diagonal row wins the game.\n\n中文:\n井字棋，又称为井字游戏、圈圈叉叉。是种纸笔游戏。两个玩家，一个打圈(O)，一个打叉(X)，轮流在3乘3的格上打自己的符号，最先以横、直、斜连成一线则为胜。如果双方都下得正确无误，将得和局。\n\nEspañol:\nEl tres en línea, también conocido como tres en raya, juego del gato, tatetí, triqui, totito, triqui traka, tres en gallo, michi, ceritos, equis cero o la vieja, es un juego de lápiz y papel entre dos jugadores: O y X, que marcan los espacios de un tablero de 3×3 alternadamente. Un jugador gana si consigue tener una línea de tres de sus símbolos: la línea puede ser horizontal, vertical o diagonal.";
    text.backgroundColor = [UIColor whiteColor];
    [self addSubview:text];
    
    
    UIButton *dismiss = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
    dismiss.backgroundColor = [UIColor whiteColor];
    dismiss.layer.cornerRadius = 5;
    dismiss.clipsToBounds = YES;
    dismiss.tag = 123;
    [dismiss setFrame:CGRectMake(width/2 - 30, height - 60, 60, 20)];
    
    [self addSubview:dismiss];
    [dismiss addTarget:self action:@selector(dismissSheet:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
    
    return self;
}

-(void) dismissSheet: (UIButton *)sender {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    if (sender.tag == 123) {
        [UIView animateWithDuration:1.5 animations:^{
            [self setCenter:CGPointMake(width/2, 3*height/2)];
        }];
    }
}


@end
