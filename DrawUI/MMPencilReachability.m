//
//  MMPencilReachability.m
//  infinite-draw
//
//  Created by Adam Wulf on 10/7/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMPencilReachability.h"
@import CoreBluetooth;

NSString *const PencilReachabilityChangedNotification = @"PencilReachabilityChanged";


@interface MMPencilReachability () <CBCentralManagerDelegate>

@end


@implementation MMPencilReachability {
    CBCentralManager *_centralManager;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        // Save a reference to the central manager. Without doing this, we never get
        // the call to centralManagerDidUpdateState method.
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:nil
                                                             options:nil];
    }

    return self;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([central state] == CBManagerStatePoweredOn) {
        // Device information UUID
        NSArray *myArray = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"180A"]];

        BOOL updatedConnection = NO;
        NSArray *peripherals =
            [_centralManager retrieveConnectedPeripheralsWithServices:myArray];
        for (CBPeripheral *peripheral in peripherals) {
            if ([[peripheral name] isEqualToString:@"Apple Pencil"]) {
                // The Apple pencil is connected
                updatedConnection = YES;
            }
        }

        if (updatedConnection != _pencilConnected) {
            _pencilConnected = updatedConnection;
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:PencilReachabilityChangedNotification object:self]];
        }
    }
}

@end
