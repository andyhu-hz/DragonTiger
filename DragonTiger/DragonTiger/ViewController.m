//
//  ViewController.m
//  DragonTiger
//
//  Created by Andy Hu on 2021/10/25.
//

#import "ViewController.h"

enum select_type {
    TYPE_LONG = 0,
    TYPE_HU,
    TYPE_HE
};

uint8_t current_select = TYPE_LONG;
uint8_t winner = 0;  // 1:long 2:hu 3:he

uint32_t bet_long = 0;
uint32_t bet_hu = 0;
uint32_t bet_he = 0;

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
    for(uint8_t i=0; i<8; i++) {
        for(uint8_t j=0; j<4; j++) {
            for(uint8_t k=0; k<13; k++) {
                poker[i][j][k] = (j+1)*100 + k+1;
            }
        }
    }

    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    [self ReadPersonData];
    ((UILabel *)[self.view viewWithTag:11]).text = [NSString stringWithFormat: @"%d", myMoney];
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

- (IBAction)reStart:(id)obj {
    ++ click_count;
    if(100 == click_count) {
        click_count = 0;
        myMoney = 1000;
        bet_long = 0;
        bet_hu = 0;
        bet_he = 0;
        ((UILabel *)[self.view viewWithTag:11]).text = [NSString stringWithFormat: @"%d", myMoney];
    }
}

-(NSString*)ConvertSuit:(int)suit {
    NSString *result = nil;
    if(1 == suit) {
        result = [NSString stringWithString:@"红桃"];
    } else if(2 == suit) {
        result = [NSString stringWithString:@"方块"];
    } else if(3 == suit) {
        result = [NSString stringWithString:@"黑桃"];
    } else if(4 == suit) {
        result = [NSString stringWithString:@"梅花"];
    }
    return result;
}

-(NSString*)ConvertPoint:(int)point {
    NSString *result = nil;
    if(1 == point) {
        result = [NSString stringWithString:@"A"];
    } else if(11 == point) {
        result = [NSString stringWithString:@"J"];
    } else if(12 == point) {
        result = [NSString stringWithString:@"Q"];
    } else if(13 == point) {
        result = [NSString stringWithString:@"K"];
    } else {
        result = [NSString stringWithFormat:@"%d", point];
    }
    return result;
}

-(void)RoundEnd {
    uint8_t i = arc4random_uniform(8);
    uint8_t j = arc4random_uniform(4);
    uint8_t k = arc4random_uniform(13);
    uint32_t poker_long = poker[i][j][k];
    uint8_t point_long = poker_long % 100;
    NSString* suit_long_str = [self ConvertSuit: poker_long / 100];
    NSString* point_long_str = [self ConvertPoint:(point_long)];

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

    NSString* suit_hu_str = [self ConvertSuit: poker_hu / 100];
    NSString* point_hu_str = [self ConvertPoint:(point_hu)];
    
    if(nil == suit_long_str || nil == point_long_str || nil == suit_hu_str || nil == point_hu_str) {
        //NSLog(@"Bug: i= %d, j=%d, k=%d, ii=%d, jj=%d, kk=%d, long=%d, hu=%d \n", i, j, k, ii, jj, kk, poker_long, poker_hu);
        ((UILabel *)[self.view viewWithTag:55]).text = [NSString stringWithFormat: @"Bug!!"];
        return;
    }

    ((UILabel *)[self.view viewWithTag:22]).text = [NSString stringWithFormat: @"%@%@", suit_long_str, point_long_str];
    ((UILabel *)[self.view viewWithTag:33]).text = [NSString stringWithFormat: @"%@%@", suit_hu_str, point_hu_str];

    if(point_long > point_hu) {
        winner = TYPE_LONG;
        myMoney += 2 * bet_long;
        ((UILabel *)[self.view viewWithTag:55]).text = [NSString stringWithFormat: @"龍胜"];
    } else if (point_long < point_hu) {
        winner = TYPE_HU;
        myMoney += 2 * bet_hu;
        ((UILabel *)[self.view viewWithTag:55]).text = [NSString stringWithFormat: @"虎胜"];
    } else {
        winner = TYPE_HE;
        myMoney += bet_long / 2;
        myMoney += bet_hu / 2;
        myMoney += 8 * bet_he;
        ((UILabel *)[self.view viewWithTag:55]).text = [NSString stringWithFormat: @"和胜"];
    }
    
    bet_long = 0;
    bet_hu = 0;
    bet_he = 0;
    ((UILabel *)[self.view viewWithTag:66]).text = [NSString stringWithFormat: @"%d", bet_long];
    ((UILabel *)[self.view viewWithTag:77]).text = [NSString stringWithFormat: @"%d", bet_hu];
    ((UILabel *)[self.view viewWithTag:88]).text = [NSString stringWithFormat: @"%d", bet_he];
    if(myMoney >= 100) {
        ((UILabel *)[self.view viewWithTag:11]).text = [NSString stringWithFormat: @"%d", myMoney];
    } else {
        ((UILabel *)[self.view viewWithTag:11]).text = [NSString stringWithFormat: @"%d输光了", myMoney];
    }
    [self SavePersonData];
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
    [(UIButton*)obj setBackgroundColor:[UIColor orangeColor]];
    [(UIButton *)[self.view viewWithTag:2] setBackgroundColor:[UIColor systemGray6Color]];
    [(UIButton *)[self.view viewWithTag:3] setBackgroundColor:[UIColor systemGray6Color]];
}

- (IBAction)IsHuSelected:(id)obj {
    current_select = TYPE_HU;
    [(UIButton*)obj setBackgroundColor:[UIColor orangeColor]];
    [(UIButton *)[self.view viewWithTag:1] setBackgroundColor:[UIColor systemGray6Color]];
    [(UIButton *)[self.view viewWithTag:3] setBackgroundColor:[UIColor systemGray6Color]];
}

- (IBAction)IsHeSelected:(id)obj {
    current_select = TYPE_HE;
    [(UIButton*)obj setBackgroundColor:[UIColor orangeColor]];
    [(UIButton *)[self.view viewWithTag:1] setBackgroundColor:[UIColor systemGray6Color]];
    [(UIButton *)[self.view viewWithTag:2] setBackgroundColor:[UIColor systemGray6Color]];
}

-(void) UpdateBet:(int)num {
    if(myMoney >= num) {
        myMoney -= num;
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
- (IBAction)add10m:(id)obj {
    [self UpdateBet:10000000];
}
@end
