//
//  ViewController.m
//  SmartCentral
//
//  Created on 24/06/15.
//  Copyright (c) 2015 H. All rights reserved.
//

#import "ViewController.h"
#import "MelodyManager.h"

@interface ViewController () <MelodyManagerDelegate,MelodySmartDelegate,UITextFieldDelegate>{
    MelodyManager *melodyManager;
    NSMutableArray *_objects;
}
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (strong, nonatomic) IBOutlet UIView *cyclingModeBtn;
@property (weak, nonatomic) IBOutlet UITextView *degubInfoTextView;
@property (weak, nonatomic) IBOutlet UITextField *commandTextField;
@property (strong, nonatomic) MelodySmart *melodySmart;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.degubInfoTextView.text=@"";
//    bleShield = [[BLE alloc] init];
//    [bleShield controlSetup];
//    bleShield.delegate = self;
    
    //Melody Manager
    melodyManager = [MelodyManager new];
    [melodyManager setForService:nil andDataCharacterisitc:nil andPioReportCharacteristic:nil andPioSettingCharacteristic:nil];
    melodyManager.delegate = self;

    
}
- (void)viewDidAppear:(BOOL)animated {
//    [self scan];
}

- (void)viewDidDisappear:(BOOL)animated {
//    [melodyManager stopScanning];
}
- (void)scan {
    [self clearObjects];
    [melodyManager scanForMelody];
    [self performSelector:@selector(stop) withObject:nil afterDelay:3.0];
    [NSTimer scheduledTimerWithTimeInterval:(float)3.2 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
}
- (void)stop{
    [self.melodySmart disconnect];
}
- (void)clearObjects {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < _objects.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [_objects removeAllObjects];
}
- (void)insertNewObject:(MelodySmart*)device
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects addObject:device];
}
-(void) connectionTimer:(NSTimer *)timer
{
    self.melodySmart = [_objects count]?_objects[0]:nil;
    
    if(self.melodySmart!=nil)
    {
        self.melodySmart.delegate = self;
        [self.melodySmart connect];
    }else{
        if (str == nil) {
            str = [NSMutableString stringWithFormat:@"No BLE found \n"];
        } else {
            [str appendFormat:@"No BLE found \n"];
        }
        self.degubInfoTextView.text =str;
    }
    
    
//    if(bleShield.peripherals.count > 0)
//    {
//        [bleShield connectPeripheral:[bleShield.peripherals objectAtIndex:0]];
//    }
//    else
//    {
////        [activityIndicator stopAnimating];
//    }
}
#pragma mark - Smart Melody Delegates-
-(void)melodySmart:(MelodySmart *)melody didSendData:(NSError *)error {
    
}
- (void)melodySmart:(MelodySmart *)melody didConnectToMelody:(BOOL)result {
    NSLog(@"didConnectToMelody");
    [self.scanBtn setTitle:@"Disconnect" forState:UIControlStateNormal];
    if (str == nil) {
        str = [NSMutableString stringWithFormat:@"Connected to %@\n",self.melodySmart.name];
    } else {
        [str appendFormat:@"Connected to %@\n",self.melodySmart.name];
    }
    self.degubInfoTextView.text =str;
}
-(void)melodySmartDidDisconnectFromMelody:(MelodySmart *)melody {
    NSLog(@"didDisconnectFromMelody");
    [self.scanBtn setTitle:@"Connect" forState:UIControlStateNormal];
    if (str == nil) {
        str = [NSMutableString stringWithFormat:@"Disconnected \n"];
    } else {
        [str appendFormat:@"Disconnected\n"];
    }
    self.degubInfoTextView.text =str;
    
}
-(void)melodySmart:(MelodySmart *)melody didReceiveData:(NSData *)data {
    NSString *temp =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (str == nil) {
        str = [NSMutableString stringWithFormat:@"%@\n", temp];
    } else {
        [str appendFormat:@"%@\n", temp];
    }
    self.degubInfoTextView.text =str;
    
}
- (void)melodySmart:(MelodySmart *)melody didReceiveCommandReply:(NSData *)data {
    NSString *temp =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (str == nil) {
        str = [NSMutableString stringWithFormat:@"%@\n", temp];
    } else {
        [str appendFormat:@"%@\n", temp];
    }
    self.degubInfoTextView.text =str;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [_melodySmart sendRemoteCommand:self.commandTextField.text];
    NSData* data = [self.commandTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    if([self.melodySmart sendData:data]){
        if (str == nil) {
            str = [NSMutableString stringWithFormat:@"%@\n", self.commandTextField.text];
        } else {
            [str appendFormat:@"%@\n", self.commandTextField.text];
        }
    }else{
        if (str == nil) {
            str = [NSMutableString stringWithFormat:@"Error in sending data\n"];
        } else {
            [str appendFormat:@"Error in sending data\n"];
        }
    }
    
    [self.commandTextField resignFirstResponder];
    
    
    self.degubInfoTextView.text =str;
    return YES;
}


#pragma mark MelodyManager delegate

-(void)melodyManagerDiscoveryDidRefresh:(MelodyManager *)manager {
    //    NSLog(@"discoveryDidRefresh");
    for (NSInteger i = _objects.count; i < [MelodyManager numberOfFoundDevices]; i++) {
        [self insertNewObject:[MelodyManager foundDeviceAtIndex:i]];
    }

}
- (IBAction)ScanForBLE:(id)sender
{
    if(self.melodySmart.isConnected){
        [self stop];
    }else{
        [self scan];
    }
//    if (bleShield.activePeripheral)
//        if(bleShield.activePeripheral.state == CBPeripheralStateConnected)
//        {
//            [[bleShield CM] cancelPeripheralConnection:[bleShield activePeripheral]];
//            return;
//        }
//    
//    if (bleShield.peripherals)
//        bleShield.peripherals = nil;
//    
//    [bleShield findBLEPeripherals:3];
//    
//    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
//    
}
-(void) bleResponse:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"bleResponse::%@",error);
}
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    
    NSMutableString *bleData = [NSMutableString string ];
    
    for (int i=0; i<length; i++)
        [bleData  appendFormat:@"%02x", data[i]];
    
    [bleData appendFormat:@"\n"];
    
    switch (data[1]) {
        case 0xB0:
        {
            NSLog(@"System msg");
            break;
        }
        case 0xB1:
        {
            NSLog(@"H/W msg");
        }
        case 0xB2:
        {
            NSLog(@"Info msg");
        }
        case 0xB3:
        {
            NSLog(@"Ackn msg");
        }
        default:
            break;
    }
    
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSLog(@"%@", s);

}

NSTimer *rssiTimer;

-(void) readRSSITimer:(NSTimer *)timer
{
    [bleShield readRSSI];
}

- (void) bleDidDisconnect
{
    NSLog(@"bleDidDisconnect");
    [self.scanBtn setTitle:@"Connect" forState:UIControlStateNormal];
    
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

-(void) bleDidConnect
{
    [self.scanBtn setTitle:@"Disconnect" forState:UIControlStateNormal];

    
    NSLog(@"bleDidConnect");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(int) decimalIntoHex:(char) number
{
    char ge  =number/10*16;
    char shi =number%10;
    int total =ge +shi;
    return total;
}
- (IBAction)setCyclingMode:(id)sender{
    
    uint8_t send[] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    /*
     4.3.1 System Message Format
     MSGID|MSGTYP|NODEID|VCSID|CMDTYP||CMD||CMDPKT|PRI|TIMSTMP
     */
    //    uint8_t send[20];

     NSString *hxStr = [self stringToHex:@"SEND"];
    send[0] =[hxStr intValue];//[[NSString stringWithFormat:@"%ld", strtoul([@"send" UTF8String],0,16)] intValue];
    send[1]=[self decimalIntoHex:1];
    send[2]=0xB0;//MSG Type-0xB0:Sys, 0xB1:HW,0xB2:info, 0xB3:ACT
    send[3]=0x00;//5 bit, used for H/w msg type: 0xFD
    send[4]=0xC3;
    send[5]=0xA0;//CMD type, 0xA0:SET, 0xA1:GET, 0xA2:ACT
    send[6]=0xA0;//CMD,e,g: SetSysMod:0xEC
    send[7]=0x01; // 0x01:Cycling
    send[8]=0x01;//Priority: (0x01)in HEX==1 in Decimal
    send[9]=[self decimalIntoHex:[[NSDate date] timeIntervalSince1970]];// Get Sencond in since, convert ot HEX
    send[10] ='\r';//[self decimalIntoHex:[[NSString stringWithFormat:@"%ld", strtoul([@"\r" UTF8String],0,16)] intValue]];
    NSData *data = [[NSData alloc] initWithBytes:send length:11];
    if (bleShield.activePeripheral.state == CBPeripheralStateConnected) {
        [bleShield write:data];
        NSMutableString *temp = [[NSMutableString alloc] init];
        for (int i = 0; i < 11; i++) {
            
//            NSString *strTmp = [NSString stringWithFormat:@"%x",send[i]];
//            if([strTmp length]<2)
//                [temp appendFormat:@" 0x0%x ", send[i]];
//            else
//            if(i==0){
//                NSString *hexStr = [self ];
//            }
            
                [temp appendFormat:@" 0x%0.2hhx ", send[i]];
        }
        if (str == nil) {
            str = [NSMutableString stringWithFormat:@"%@\n", temp];
        } else {
            [str appendFormat:@"%@\n", temp];
        }
        self.degubInfoTextView.text =str;
    }
}
- (IBAction)setLED:(UISwitch*)sender{
    
    uint8_t send[] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    /*
     4.3.1 System Message Format
     MSGID|MSGTYP|NODEID|VCSID|CMDTYP||CMD||CMDPKT|PRI|TIMSTMP
     */
    //    uint8_t send[20];
    send[0]=[self decimalIntoHex:1];
    send[1]=0xB0;//MSG Type-0xB0:Sys, 0xB1:HW,0xB2:info, 0xB3:ACT
    send[2]=0x00;//5 bit, used for H/w msg type: 0xFD
    send[3]=0xC3;
    send[4]=0xA0;//CMD type, 0xA0:SET, 0xA1:GET, 0xA2:ACT
    send[5]=0xA0;//CMD,e,g: SetSysMod:0xEC
    send[6]=0x01; // 0x01:Cycling
    send[7]=0x01;//Priority: (0x01)in HEX==1 in Decimal
    send[8]=[self decimalIntoHex:[[NSDate date] timeIntervalSince1970]];// Get Sencond in since, convert ot HEX
    NSData *data = [[NSData alloc] initWithBytes:send length:9];
    if (bleShield.activePeripheral.state == CBPeripheralStateConnected) {
        [bleShield write:data];
    }
}
- (NSString *)stringToHex:(NSString *)stringInput
{
    NSUInteger len = [stringInput length];
    unichar *chars = malloc(len * sizeof(unichar));
    [stringInput getCharacters:chars];
    
    NSMutableString *hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
    {
        // [hexString [NSString stringWithFormat:@"%02x", chars[i]]]; /*previous input*/
        [hexString appendFormat:@"%02x", chars[i]]; /*EDITED PER COMMENT BELOW*/
    }
    free(chars);
    
    return hexString;
}
- (NSString *) stringFromHex:(NSString *)stringInput
{
    NSMutableData *stringData = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [stringInput length] / 2; i++) {
        byte_chars[0] = [stringInput characterAtIndex:i*2];
        byte_chars[1] = [stringInput characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [stringData appendBytes:&whole_byte length:1];
    }
    
    return [[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding];
}
/*
 NAV_VCS: 0xC0
 ELE_VCS: 0xC1
 IMGP_VCS: 0xC2
 SYSC_VSC: 0xC3
 ---
 NDFRMN_1: 0xFD
 ----
 SYS_MSG: 0xB0
 SYS_MSG: 0xB0
 INFO_MSG: 0xB2
 ￼ACT_MSG: 0xB3
 --------
 SET: 0xA0
 GET: 0xA1
 ACT: 0xA2
 -----
 4.3.1 System Message Format
 MSGID
 MSGTYP
 ￼NODEID
 ￼VCSID
 CMDTYP
 ￼CMD
 CMDPKT
 ￼￼PRI
 TIMSTMP
 
 4.3.2 Hardware Message Format
 MSGID
 MSGTYP
 ￼NODEID
 HRWDID
 CMDTYPE
 ￼￼CMD
 CMDPKT
 ￼PRI
 TIMSTMP
 
 4.3.3 Informational Message Format
 MSGID
 MSGTYP
 VCSID
 STATMSG
 PRI
 TIMSTMP
 
 4.3.4 Acknowledge Message Format
 MSGID
 MSGTYPE ￼
 ACKTYP
 ￼￼MSGRESP
 PRI
 TIMSTMP
 
 
 */
- (IBAction)getDateNavVCS:(id)sender {
    /*
    GetDate:0x0A
    Desc: This command retrieves the current date for the Navigation VCS
    Type:  Get
     */
    
}
- (IBAction)setHeadLightON:(id)sender {
    /*
     ActHdLit:0x06
     The command sets the Smart Helmet’s Head Lights on/off option.
     Head Lights On/Off
     Type: Set
     */
}
- (IBAction)setHeadLightOFF:(id)sender {
}
- (IBAction)setFrontCamModeVideo:(id)sender {
    /*Set_ftcam_mod: 0x03
     This command sets the front camera’s mode. This command contains a single parameter which identifies the camera mode.
         0x01-Stills, 0x02-Video
    Type: Set
    */
}
- (IBAction)setFrontCamModeStill:(id)sender {
}
@end