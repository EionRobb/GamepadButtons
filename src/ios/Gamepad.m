
#import <GameController/GameController.h>
#import <Cordova/CDV.h>

@interface Gamepad : CDVPlugin
{
}

@property (nonatomic, copy) GCExtendedGamepadValueChangedHandler extendedValueChangedHandler;
@property (nonatomic, copy) GCGamepadValueChangedHandler valueChangedHandler;
@property (nonatomic, copy) void (^pauseEventHandler)(GCController *controller);


@end

@implementation Gamepad

-(void)sendButtonEvent:(int)buttonId value:(float)value pressed:(BOOL)pressed gamepad:(int)gamepadId
{
	[self writeJavascript:[NSString stringWithFormat:@"cordova.fireWindowEvent('GamepadMotion', {deviceId:%d, button:%d, value:%f});", gamepadId, buttonId, value]];
}

-(void)sendAxisEvent:(int)gamepadId x:(float)x y:(float)y z:(float)z z1:(float)z1
{
	[self writeJavascript:[NSString stringWithFormat:@"cordova.fireWindowEvent('GamepadMotion', {deviceId:%d, axes:[%f, %f, %f, %f]});", gamepadId, x, y, z, z1]];
}

- (void)pluginInitialize
{
	
	self.valueChangedHandler = ^(GCGamepad *gamepad, GCControllerElement *element)
	{
		int gamepadId = gamepad.controller.playerIndex;
		if (element == gamepad.buttonB) [self sendButtonEvent:0 value:gamepad.buttonB.value pressed:gamepad.buttonB.pressed gamepad:gamepadId];
		if (element == gamepad.buttonA) [self sendButtonEvent:1 value:gamepad.buttonA.value pressed:gamepad.buttonA.pressed gamepad:gamepadId];
		if (element == gamepad.buttonY) [self sendButtonEvent:2 value:gamepad.buttonY.value pressed:gamepad.buttonY.pressed gamepad:gamepadId];
		if (element == gamepad.buttonX) [self sendButtonEvent:3 value:gamepad.buttonX.value pressed:gamepad.buttonX.pressed gamepad:gamepadId];
		if (element == gamepad.leftShoulder) [self sendButtonEvent:4 value:gamepad.leftShoulder.value pressed:gamepad.leftShoulder.pressed gamepad:gamepadId];
		if (element == gamepad.rightShoulder) [self sendButtonEvent:5 value:gamepad.rightShoulder.value pressed:gamepad.rightShoulder.pressed gamepad:gamepadId];
		
		if (element == gamepad.dpad)
		{
			[self sendButtonEvent:12 value:gamepad.dpad.up.value pressed:gamepad.dpad.up.pressed gamepad:gamepadId];
			[self sendButtonEvent:13 value:gamepad.dpad.down.value pressed:gamepad.dpad.down.pressed gamepad:gamepadId];
			[self sendButtonEvent:14 value:gamepad.dpad.left.value pressed:gamepad.dpad.left.pressed gamepad:gamepadId];
			[self sendButtonEvent:15 value:gamepad.dpad.right.value pressed:gamepad.dpad.right.pressed gamepad:gamepadId];
		}
	};
	
	self.extendedValueChangedHandler = ^(GCExtendedGamepad *gamepad, GCControllerElement *element)
	{
		int gamepadId = gamepad.controller.playerIndex;
		if (element == gamepad.buttonB) [self sendButtonEvent:0 value:gamepad.buttonB.value pressed:gamepad.buttonB.pressed gamepad:gamepadId];
		if (element == gamepad.buttonA) [self sendButtonEvent:1 value:gamepad.buttonA.value pressed:gamepad.buttonA.pressed gamepad:gamepadId];
		if (element == gamepad.buttonY) [self sendButtonEvent:2 value:gamepad.buttonY.value pressed:gamepad.buttonY.pressed gamepad:gamepadId];
		if (element == gamepad.buttonX) [self sendButtonEvent:3 value:gamepad.buttonX.value pressed:gamepad.buttonX.pressed gamepad:gamepadId];
		if (element == gamepad.leftShoulder) [self sendButtonEvent:4 value:gamepad.leftShoulder.value pressed:gamepad.leftShoulder.pressed gamepad:gamepadId];
		if (element == gamepad.rightShoulder) [self sendButtonEvent:5 value:gamepad.rightShoulder.value pressed:gamepad.rightShoulder.pressed gamepad:gamepadId];
		if (element == gamepad.leftTrigger) [self sendButtonEvent:6 value:gamepad.leftTrigger.value pressed:gamepad.leftTrigger.pressed gamepad:gamepadId];
		if (element == gamepad.rightTrigger) [self sendButtonEvent:7 value:gamepad.rightTrigger.value pressed:gamepad.rightTrigger.pressed gamepad:gamepadId];
		
		if (element == gamepad.dpad)
		{
			[self sendButtonEvent:12 value:gamepad.dpad.up.value pressed:gamepad.dpad.up.pressed gamepad:gamepadId];
			[self sendButtonEvent:13 value:gamepad.dpad.down.value pressed:gamepad.dpad.down.pressed gamepad:gamepadId];
			[self sendButtonEvent:14 value:gamepad.dpad.left.value pressed:gamepad.dpad.left.pressed gamepad:gamepadId];
			[self sendButtonEvent:15 value:gamepad.dpad.right.value pressed:gamepad.dpad.right.pressed gamepad:gamepadId];
		}
		
		if (element == gamepad.leftThumbstick || element == gamepad.rightThumbstick)
		{
			[self sendAxisEvent:gamepadId x:gamepad.leftThumbstick.xAxis.value y:gamepad.leftThumbstick.yAxis.value
				z:gamepad.rightThumbstick.xAxis.value z1:gamepad.rightThumbstick.yAxis.value];
		}
	};
	
	self.pauseEventHandler = ^(GCController *controller)
	{
		[self sendButtonEvent:9 value:1 pressed:YES gamepad:controller.playerIndex];
		[self sendButtonEvent:9 value:0 pressed:NO gamepad:controller.playerIndex];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerStateChanged) name:GCControllerDidConnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerStateChanged) name:GCControllerDidDisconnectNotification object:nil];
	[GCController startWirelessControllerDiscoveryWithCompletionHandler:^{
		[self controllerStateChanged];
	};
}

-(void)controllerStateChanged {
	for(int i = 0; i < [[GCController controllers] count]; i++)
	{
		GCController *controller = [GCController controllers][i];
		if (controller.playerIndex == -1)
			controller.playerIndex = i;
		if (controller.extendedGamepad != nil)
		{
			controller.extendedGamepad.valueChangedHandler = self.extendedValueChangedHandler;
		} else {
			controller.gamepad.valueChangedHandler = self.valueChangedHandler;
		}
		controller.controllerPausedHandler = self.pauseEventHandler;
	}
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GCControllerDidConnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GCControllerDidDisconnectNotification object:nil];
    [super dealloc];
}
