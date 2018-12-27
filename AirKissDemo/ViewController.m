//
//  ViewController.m
//  AirKiss
//
//  Created by Feng on 2018/11/21.
//  Copyright © 2018年 Feng. All rights reserved.
//

#import "ViewController.h"
#import "SunMBHubUtils.h"
#import "SunAlertUtils.h"
#import <iOS_LarkAirKiss_Public/LarkAirKiss.h>

@interface ViewController ()<LarkAirKissDelegate,UITextFieldDelegate>{
    NSTimer *m_timer;//超时定时器
    NSInteger timerCount;

}

@property(strong,nonatomic)LarkAirKiss *airKiss;

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (weak, nonatomic) IBOutlet UITextField *m_ssid;

@property (weak, nonatomic) IBOutlet UITextField *m_psk;

@property (weak, nonatomic) IBOutlet UITextField *m_packet_interval;

@property (weak, nonatomic) IBOutlet UITextField *m_SNAP_InterVal;


@property (weak, nonatomic) IBOutlet UITextField *m_timeOut;

@property (weak, nonatomic) IBOutlet UITextView *m_textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.m_ssid.text = @"sunseagroup";
    self.m_psk.text = @"sunsea888";
    self.m_packet_interval.text = @"5";
    self.m_SNAP_InterVal.text = @"100";
    self.m_timeOut.text = @"30000";
    m_timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [m_timer setFireDate:[NSDate distantFuture]];
}

-(LarkAirKiss *)airKiss {
    if (!_airKiss) {
        _airKiss = [[LarkAirKiss alloc] init];
        _airKiss.delegate = self;
    }
    return _airKiss;
}

-(void)timerAction:(NSTimer *)timer{
    
    timerCount ++ ; //1ms
    
    int me_seconds = timerCount%1000;
    
    int seconds = (timerCount/1000)%60;

    int minutes = ((timerCount/1000)/60)%60;
    
    int hour = ((timerCount/1000)/60)/60;
    
    self.timerLabel.text = [NSString stringWithFormat:@"%d:%d:%d:%d",hour,minutes,seconds,me_seconds];

}


- (IBAction)startAirKissButtonAction:(id)sender {
    if ([self.m_ssid.text isEqualToString:@""]) {
        [SunAlertUtils showAlert:@"请输入WiFi name" message:@"" sureTitle:@"确定" completionBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
            
        } parentVc:self];
        return;
    }
    if (![self.m_packet_interval.text isEqualToString:@"5"] && ![self.m_packet_interval.text isEqualToString:@""] ) {
        self.airKiss.packetInterval = [self.m_packet_interval.text integerValue];
    }
    if (![self.m_SNAP_InterVal.text isEqualToString:@"100"] && ![self.m_SNAP_InterVal.text isEqualToString:@""]) {
        self.airKiss.SNAPInterval = [self.m_SNAP_InterVal.text integerValue];
    }
    if (![self.m_timeOut.text isEqualToString:@"30000"] &&![self.m_timeOut.text isEqualToString:@""]) {
        self.airKiss.timeOut = [self.m_timeOut.text integerValue];
    }
    
    self.m_textView.text = @"start airKiss";
    self.timerLabel.text = @"00:00:00:00";

    timerCount = 0;
    [m_timer setFireDate:[NSDate distantPast]];

    [SunMBHubUtils showLoading];
    [self.airKiss start:self.m_ssid.text psk:self.m_psk.text token:@""];
}

-(void)LarkAirKiss:(id)sender dsn:(NSString *)dsn token:(NSString *)setUpToken{
    NSLog(@"airKiss dsn = %@ setUpToken = %@",dsn,setUpToken);
    self.m_textView.text = [NSString stringWithFormat:@"DSN:%@\n\nsetUpToken:%@",dsn,setUpToken];
}

-(void)LarkAirKissFinish:(id)sender{
    NSLog(@"airKiss Finish");
    [SunAlertUtils showAlert:@"airKiss Finish" message:@"" sureTitle:@"确定" completionBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        
    } parentVc:self];
    [m_timer setFireDate:[NSDate distantFuture]];
    [SunMBHubUtils hiddenLoading];
    [self.airKiss stop];
}

-(void)LarkAirKissError:(id)sender type:(int)type message:(NSString *)error{
    NSLog(@"airKiss error type :%d content:%@",type,error);
    [SunAlertUtils showAlert:[NSString stringWithFormat:@"airKiss error type :%d content:%@",type,error] message:@"" sureTitle:@"确定" completionBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        
    } parentVc:self];
    [m_timer setFireDate:[NSDate distantFuture]];
    [SunMBHubUtils hiddenLoading];
    [self.airKiss stop];
    self.m_textView.text = error;
}

@end
