//
//  ViewController.m
//  SocketClusterIOSSample
//
//  Created by Lihan Li on 8/05/2015.
//  Copyright (c) 2015 TopCloud. All rights reserved.
//

#import "ViewController.h"
#import "SocketCluster.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (strong, nonatomic) SocketCluster *sc;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UITextField *emitEventName;
@property (weak, nonatomic) IBOutlet UITextField *emitEventValue;
@property (weak, nonatomic) IBOutlet UITextField *channelName;
@property (weak, nonatomic) IBOutlet UITextField *channelValue;
@property (weak, nonatomic) IBOutlet UITextField *hostValue;
@property (weak, nonatomic) IBOutlet UITextField *portValue;
@property (weak, nonatomic) IBOutlet UISwitch *isSecureSwitch;

@end

@implementation ViewController

- (void)viewDidLoad {
    self.sc = [[SocketCluster alloc] init];
    self.sc.delegate = self;
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)logMessage:(NSString *)message
{
    self.logTextView.selectedRange = NSMakeRange(0, 0);
    [self.logTextView insertText:message];
    [self.logTextView insertText:@"\n"];
    
}
- (IBAction)getIdTapped:(UIButton *)sender {
    [self logMessage:self.sc.socketId];
}

- (IBAction)connectBtnTapped:(id)sender {
    [self.sc connectToHost:@"127.0.0.1" onPort:8000 securly:NO];
}
- (IBAction)disconnectBtnTapped:(id)sender {
    [self.sc disconnect];
}
- (IBAction)getStateBtnTapped:(id)sender {
    self.stateLabel.text = [self.sc getState];
}
- (IBAction)listenToRandTapped:(id)sender {
    [self.sc registerEvent:@"rand"];
}


- (void)socketClusterDidConnect
{
    [self logMessage:@"Connected"];
}
- (void)socketClusterDidDisconnect
{
    [self logMessage:@"Disconnected"];
}
- (void)socketClusterOnError:(NSString *)errorString
{
    [self logMessage:errorString];
}

- (IBAction)emitBtnTapped
{
    NSString *event = self.emitEventName.text;
    NSString *eventData = self.emitEventValue.text;
    [self.sc emitEvent:event WithData:eventData];
}
- (IBAction)subscribeChannelTapped:(id)sender
{
    NSString *channelName = self.channelName.text;
    [self.sc subscribeToChannel:channelName];
}

- (IBAction)unSubscribeChannelTapped:(id)sender
{
    NSString *channelName = self.channelName.text;
    [self.sc unsubscribeFromChannel:channelName];
}

- (IBAction)publishChannelSubscribed:(id)sender
{
    NSString *channelName = self.channelName.text;
    NSString *value = self.channelValue.text;
    [self.sc publishToChannel:channelName WithData:value];
}

- (IBAction)getSubscriptionsTapped:(UIButton *)sender
{
    NSArray *result = [self.sc getSubscriptions];
    NSString *log = [NSString stringWithFormat:@"%@", result];
    [self logMessage:log];
}

- (IBAction)getSubscriptionsIncludePendingTapped:(id)sender
{
    NSArray *result = [self.sc getSubscriptionsIncludingPending];
    NSString *log = [NSString stringWithFormat:@"%@", result];
    [self logMessage:log];
}

- (void)socketClusterReceivedEvent:(NSString *)eventName WithData:(NSDictionary *)data;
{
    if ([@"rand" isEqualToString:eventName]) {
        NSArray *positiveFaces = @[@";p", @":D", @":)", @":3", @";)"];
        NSNumber *index = data[@"rand"];
        NSString *face = [positiveFaces objectAtIndex:[index intValue]];
        NSString *msg = [NSString stringWithFormat:@"rand event received: %@", face];
        [self logMessage:msg];
    }
}

- (void)socketclusterChannelReceivedEvent:(NSString *)channel WithData:(NSDictionary *)data
{
    if ([@"pong" isEqualToString:channel]) {
        [self logMessage:[NSString stringWithFormat:@"Channel %@ received message %@", channel, data[@"data"]]];
    }
    
}



@end
