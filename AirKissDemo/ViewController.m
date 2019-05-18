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
#import "FengAirKiss.h"


@interface ViewController ()<FengAirKissDelegate,UITextFieldDelegate>{
    NSTimer *m_timer;//超时定时器
    NSInteger timerCount;

}
@property (weak, nonatomic) IBOutlet UIButton *startAirKissButton;

@property(strong,nonatomic)FengAirKiss *airKiss;

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
    
    self.m_ssid.text = @"helloword";
    self.m_psk.text = @"csy10841054";
    
    self.m_packet_interval.text = @"5";
    self.m_SNAP_InterVal.text = @"100";
    self.m_timeOut.text = @"60000";
    m_timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [m_timer setFireDate:[NSDate distantFuture]];
}

-(FengAirKiss *)airKiss {
    if (!_airKiss) {
        _airKiss = [[FengAirKiss alloc] init];
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

//    [SunMBHubUtils showLoading];
    self.startAirKissButton.enabled = NO;
    [self.airKiss start:self.m_ssid.text psk:self.m_psk.text];
}

- (IBAction)stopAirKiss:(id)sender {
    if (self.airKiss) {
        [self.airKiss stop];
        [m_timer setFireDate:[NSDate distantFuture]];
        self.m_textView.text = @"cancel airKiss";
    }
    self.startAirKissButton.enabled = YES;
}

-(void)FengAirKissFinish:(id)sender dsn:(NSString *)dsn token:(NSString *)setUpToken{
    NSLog(@"airKiss Finish dsn = %@ setUpToken = %@",dsn,setUpToken);
    self.m_textView.text = [NSString stringWithFormat:@"DSN:%@\n\nsetUpToken:%@",dsn,setUpToken];
    
    [SunAlertUtils showAlert:@"airKiss Finish" message:@"" sureTitle:@"确定" completionBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        
    } parentVc:self];
    [m_timer setFireDate:[NSDate distantFuture]];
    [SunMBHubUtils hiddenLoading];
    [self.airKiss stop];
    self.startAirKissButton.enabled = YES;
}

-(void)FengAirKissError:(id)sender message:(NSString *)error{
    NSLog(@"airKiss error content:%@",error);
    [SunAlertUtils showAlert:[NSString stringWithFormat:@"airKiss error content:%@",error] message:@"" sureTitle:@"确定" completionBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        
    } parentVc:self];
    [m_timer setFireDate:[NSDate distantFuture]];
    [SunMBHubUtils hiddenLoading];
    [self.airKiss stop];
    self.m_textView.text = error;
    self.startAirKissButton.enabled = YES;
}

#pragma mark --键盘消失
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

@end
