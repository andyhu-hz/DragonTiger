//
//  ViewController.m
//  DragonTiger
//
//  Created by Andy Hu on 2021/10/25.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>


enum select_type {
    TYPE_LONG = 0,
    TYPE_HU,
    TYPE_HE
};

uint8_t current_select = TYPE_LONG;

uint32_t bet_long = 0;
uint32_t bet_hu = 0;
uint32_t bet_he = 0;
uint32_t bet_total = 0;

uint32_t poker[8][4][13] = {0};
uint8_t timer_count = 0;

uint32_t myMoney = 1000;
uint8_t click_count = 0;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self Init];
}

-(void)tapDetected{
    ++ click_count;
    if(100 == click_count && myMoney < 100) {
        AudioServicesPlaySystemSound (1520);
        click_count = 0;
        myMoney = 1000;
        bet_long = 0;
        bet_hu = 0;
        bet_he = 0;
        ((UILabel *)[self.view viewWithTag:11]).text = [NSString stringWithFormat: @"%d", myMoney];
    } else {
        AudioServicesPlaySystemSound (1521);
    }
}


-(void)Init {
    for(uint8_t i=0; i<8; i++) {
        for(uint8_t j=0; j<4; j++) {
            for(uint8_t k=0; k<13; k++) {
                poker[i][j][k] = (j+1)*100 + k+1;
            }
        }
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"113" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    [((UIImageView *)[self.view viewWithTag:177]) setImage:image];
    
    path = [[NSBundle mainBundle] pathForResource:@"313" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    [((UIImageView *)[self.view viewWithTag:188]) setImage:image];
    
    path = [[NSBundle mainBundle] pathForResource:@"longhudou" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    [((UIImageView *)[self.view viewWithTag:300]) setImage:image];
    
    path = [[NSBundle mainBundle] pathForResource:@"goldcoin" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    [((UIImageView *)[self.view viewWithTag:200]) setImage:image];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [((UIImageView *)[self.view viewWithTag:200])  setUserInteractionEnabled:YES];
    [((UIImageView *)[self.view viewWithTag:200])  addGestureRecognizer:singleTap];
  
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    [self ReadPersonData];
    ((UILabel *)[self.view viewWithTag:11]).text = [NSString stringWithFormat: @"%d", myMoney];
    [(UIButton *)[self.view viewWithTag:1] setBackgroundColor:[UIColor greenColor]];
}

-(void)SavePersonData {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithInt:myMoney] forKey:@"money"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)ReadPersonData {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    int hasInitialized = [[ userDefault objectForKey:@"initialized"] intValue];
    if(1 == hasInitialized) {
        myMoney = [[ userDefault objectForKey:@"money"] intValue];
    } else {
        [userDefault setObject:[NSNumber numberWithInt:1] forKey:@"initialized"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)RoundEnd {
    uint8_t i = arc4random_uniform(8);
    uint8_t j = arc4random_uniform(4);
    uint8_t k = arc4random_uniform(13);
    uint32_t poker_long = poker[i][j][k];
    uint8_t point_long = poker_long % 100;

    uint8_t ii = arc4random_uniform(8);
    uint8_t jj = arc4random_uniform(4);
    uint8_t kk = arc4random_uniform(13);
    
    while(i == ii && j == jj && k == kk) {
        ii = arc4random_uniform(8);
        jj = arc4random_uniform(4);
        kk = arc4random_uniform(13);
    }

    uint32_t poker_hu = poker[ii][jj][kk];
    uint8_t point_hu = poker_hu % 100;

    
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%i",poker_long] ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    [((UIImageView *)[self.view viewWithTag:177]) setImage:image];
    
    path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%i",poker_hu] ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    [((UIImageView *)[self.view viewWithTag:188]) setImage:image];
    
    int32_t outcome = 0;
    NSString* winner = nil;
    if(point_long > point_hu) {
        myMoney += 2 * bet_long;
        outcome = 2 * bet_long - bet_total;
        winner = [NSString stringWithFormat: @"龙胜"];
        ((UILabel *)[self.view viewWithTag:55]).text = [NSString stringWithFormat: @"龙胜  %d", outcome];
    } else if (point_long < point_hu) {
        myMoney += 2 * bet_hu;
        outcome = 2 * bet_hu - bet_total;
        winner = [NSString stringWithFormat: @"虎胜"];
    } else {
        int32_t award = bet_long/2 + bet_hu/2 + 9 * bet_he;
        myMoney += award;
        outcome = award - bet_total;
        winner = [NSString stringWithFormat: @"和胜"];
    }
    ((UILabel *)[self.view viewWithTag:55]).text = winner;
    if(outcome >=  0) {
        ((UILabel *)[self.view viewWithTag:199]).text = [NSString stringWithFormat: @"+%d", outcome];
    } else {
        ((UILabel *)[self.view viewWithTag:199]).text = [NSString stringWithFormat: @"%d", outcome];
    }

    bet_long = 0;
    bet_hu = 0;
    bet_he = 0;
    bet_total = 0;

    ((UILabel *)[self.view viewWithTag:66]).text = [NSString stringWithFormat: @"%d", bet_long];
    ((UILabel *)[self.view viewWithTag:77]).text = [NSString stringWithFormat: @"%d", bet_hu];
    ((UILabel *)[self.view viewWithTag:88]).text = [NSString stringWithFormat: @"%d", bet_he];
    if(myMoney >= 100) {
        ((UILabel *)[self.view viewWithTag:11]).text = [NSString stringWithFormat: @"%d", myMoney];
    } else {
        ((UILabel *)[self.view viewWithTag:11]).text = [NSString stringWithFormat: @"%d 破产了", myMoney];
    }
    [self SavePersonData];
    AudioServicesPlaySystemSound(1100);
}

-(void) onTimer {
    timer_count ++;
    if(10 < timer_count) {
        timer_count = 0;
        [self RoundEnd];
    }
    [(UIProgressView *)[self.view viewWithTag:10] setProgress:((float)timer_count/10.0) animated:YES];
    //NSLog(@"UIProgressView : timer_count = %d", timer_count);
}

- (IBAction)IsDragonSelected:(id)obj {
    current_select = TYPE_LONG;
    [(UIButton*)obj setBackgroundColor:[UIColor greenColor]];
    [(UIButton *)[self.view viewWithTag:2] setBackgroundColor:[UIColor systemGray6Color]];
    [(UIButton *)[self.view viewWithTag:3] setBackgroundColor:[UIColor systemGray6Color]];
}

- (IBAction)IsHuSelected:(id)obj {
    current_select = TYPE_HU;
    [(UIButton*)obj setBackgroundColor:[UIColor greenColor]];
    [(UIButton *)[self.view viewWithTag:1] setBackgroundColor:[UIColor systemGray6Color]];
    [(UIButton *)[self.view viewWithTag:3] setBackgroundColor:[UIColor systemGray6Color]];
}

- (IBAction)IsHeSelected:(id)obj {
    current_select = TYPE_HE;
    [(UIButton*)obj setBackgroundColor:[UIColor greenColor]];
    [(UIButton *)[self.view viewWithTag:1] setBackgroundColor:[UIColor systemGray6Color]];
    [(UIButton *)[self.view viewWithTag:2] setBackgroundColor:[UIColor systemGray6Color]];
}

-(void) UpdateBet:(int)num {
    if(myMoney >= num) {
        myMoney -= num;
        bet_total += num;
        if(TYPE_LONG == current_select) {
            bet_long += num;
        } else if(TYPE_HU == current_select) {
            bet_hu += num;
        } else if(TYPE_HE == current_select) {
            bet_he += num;
        }
        ((UILabel *)[self.view viewWithTag:66]).text = [NSString stringWithFormat: @"%d", bet_long];
        ((UILabel *)[self.view viewWithTag:77]).text = [NSString stringWithFormat: @"%d", bet_hu];
        ((UILabel *)[self.view viewWithTag:88]).text = [NSString stringWithFormat: @"%d", bet_he];
        ((UILabel *)[self.view viewWithTag:11]).text = [NSString stringWithFormat: @"%d", myMoney];
    }
}

- (IBAction)add100:(id)obj {
    [self UpdateBet:100];
}
- (IBAction)add1k:(id)obj {
    [self UpdateBet:1000];
}
- (IBAction)add10k:(id)obj {
    [self UpdateBet:10000];
}
- (IBAction)add100k:(id)obj {
    [self UpdateBet:100000];
}
- (IBAction)add1m:(id)obj {
    [self UpdateBet:1000000];
}

@end
