# PlayHaven Native Extension for Adobe AIR User and Reference #

<!--- This guide has the following sections:

* [Overview](#overview) 
* [Include the PlayHaven Library](#include) 
* [Integration](#integration) 
* [API Reference](#api_ref) 

-->

<a id="overview"></a>
##Overview

PlayHaven is a mobile game LTV-maximization platform to help you take control of the business of your games.

Acquire, retain, re-engage, and monetize your players with the help of PlayHaven's powerful marketing platform. Integrate once and embrace the flexibility of the web as you build, schedule, deploy, and analyze your in-game promotions and monetization in real-time through PlayHaven's easy-to-use, web-based dashboard.

Sign up for an account on [PlayHaven.com](http://www.playhaven.com) and create your apps. Then add the placements, widgets, rewards, content, and Virtual Goods Promotion items that you want to use.  Take note of the tokens, keys,and placement tags for your app.

A complete sample class demonstrating the functionality of PlayHaven Adobe Air extension is available in the `example` folder inside the PlayHaven extension zip file.

Refer to the [API reference documentation](http://docs.playhaven.com/adobe-air/) for more information on the packages and classes in this extension. 

<a id="include"></a>
## Include the PlayHaven library ##

**In Flash Professional:**

1. Create a new project of the type AIR for iOS.
2. Select File > Publish Settings.
3. Select the wrench icon next to Script for ActionScript Settings.
4. Select the Library Path tab.
5. Press the Browse for Native Extension (ANE) File button and select the `com.playhaven.extensions.PlayHaven.ane` file.

**In Flash Builder 4.6:**

1. Go to Project Properties (right-click your project in Package Explorer and select Properties).
2. Select ActionScript Build Path and click the Native Extensions tab.
3. Click Add ANE and navigate to the com.playhaven.extensions.PlayHaven.ane file.
4. Add the extension to the build target before compiling.

**In FlashDevelop:**

1. Copy the `PlayHavenAPI.swc` file to your project folder.
2. In the explorer panel, right-click the SWC and select Add To Library.
3. Right-click the SWC file in the explorer panel again, select Options, and then select External Library.

## Update your application descriptor ##

In order to use the PlayHaven Extension on Android, you'll need to update the `manifestAdditions` block in your your `application.xml` file:

	  <android>
        <manifestAdditions><![CDATA[
			<manifest android:installLocation="auto">
			    <uses-permission android:name="android.permission.INTERNET"/>
				<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
				<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
				<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
				<application>
					<activity android:name="com.playhaven.src.publishersdk.content.PHContentView" android:theme="@android:style/Theme.Dialog" android:windowSoftInputMode="adjustResize"></activity>
				</application>
			</manifest>			
		]]></manifestAdditions>
    </android>

To use the extension for either iOS or Android, add the extension identifier to the `<extensions>` block in `application.xml`:

	  <extensions>
		    <extensionID>com.playhaven.extensions.PlayHaven</extensionID>
		</extensions>

A sample application descriptor file is located in the `example` folder in the extension package zip file.

## Initialize the PlayHaven API ##

Import the PlayHaven API Packages:

	import com.playhaven.*;
	import com.playhaven.events.*;
	import com.playhaven.ui.*;

At the start of your application's execution, initialize the PlayHaven API by calling `PlayHaven.create()` with your app token and secret. You previously created these using the PlayHaven dashboard.  You can use the `PlayHaven.isSupported()` function to determine if the platform supports PlayHaven. Supported platforms are iOS and Android:


	if(PlayHaven.isSupported())
	{
		PlayHaven.create("your_token","your_secret");
	}
	else
	{
		trace("extension works on iOS And Android only.");
	}

If you are developing an application targeting both Android and iOS from a single code base, you can enter the iOS token, iOS secret, Android token, and Android secret, in that order:

	PlayHaven.create("your_ios_token","your_ios_secret","your_android_token","your_android_secret");

## Recording game opens##

When your game session begins, notify the PlayHaven service of the game open event:

	PlayHaven.playhaven.reportGameOpen();

You only need to perform this notification once at the start of your app.  The extension then automatically handles session open events going forward if your app exits or enters the foreground.

## Preload a content request (optional) ##

Optionally, you can preload a content placement before displaying it. If you do this soon after your app starts, then that content is immediately available later when the user triggers the action:

	PlayHaven.playhaven.preloadContentRequest("your_placement_id");

## Load and display a content request ##

The PlayHaven extension can display content placements (such as a More Games widget), and notify you using event listeners of changes to the content state:

	// set up event listeners for content overlays
	PlayHaven.playhaven.addEventListener(PlayHavenEvent.CONTENT_OVERLAY_DISMISSED,onContentDismissed);
	PlayHaven.playhaven.addEventListener(PlayHavenEvent.CONTENT_OVERLAY_DISPLAYED,onContentDisplayed);
	PlayHaven.playhaven.addEventListener(PlayHavenEvent.CONTENT_OVERLAY_FAILED,onContentFailed);

	// start the content request
	PlayHaven.playhaven.sendContentRequest("more_games");

The `CONTENT_OVERLAY_DISPLAYED` and `CONTENT_OVERLAY_DISMISSED` events allow you to track when an overlay is being shown or being removed from the screen.  Because these overlays are modal, and you may want to pause the game action or sound while they are visible:

	function onContentDisplayed(e:PlayhavenEvent):void
	{
		// an overlay is showing - pause for now...
		pauseGame();
		stopSounds();
	}

	funnction onContentDismissed(e:PlayHavenEvent):void
	{
		// overlay is closed - resume the game
		resumeGame();
		resumeSounds();

		// the event's contentDismissalReason property holds a value
		// from the ContentDismissalReason constants class- indicating
		// the reason the view was dismissed:

		switch(e.contentDismissalReason)
		{
			case ContentDismissalReason:USER_CONTENT_TRIGGERED:
				trace("the user or content unit closed the window.");
				break;
			case ContentDismissalReason:USER_BUTTON_CLOSED:
				trace("the close button was pushed.");
				break;
			case ContentDismissalReason.APP_BACKGROUNDED:
				trace("the app was sent to the background.");
				break;
			case ContentDismissalReason:NO_CONTENT_AVAILABLE:
				trace("no content was found for the placement.");
				break;
	}

If the content unit fails to load, the `CONTENT_OVERLAY_FAILED` event is dispatched:

	function onContentFailed(e:PlayHavenEvent):void
	{
		trace("content for "+e.placementId+" loading failed:"+e.errorMessage);
	}

## Create a notification badge ##

The PlayHaven extension can create a notification badge, which is a small DisplayObject containing a number indicating how many unread items exist for a given placement.  A common use is to display the badge near a More Games button to trigger a More Games content placement.  Using the notification badge can lead to more clicks for the content. For example:

	var badge:NotificationBadge=PlayHaven.playhaven.createNotificationBadge("more_games");
	badge.x=btnMoreGames.x+btnMoreGames.width;
	badge.y=btnMoreGames.y;
	addChild(badge);

If there is no new content pending for the placement (a value of 0), the badge is  invisible.  By setting the `testMode` property of the badge to `true`, you can make it remain visible even when the value is 0. This is useful when designing your app so you can actually see where the badge is placed:

	// setting this to true causes the badge to always appear,
	// even if there's no notification.  this makes it easier
	// to layout your design because you can always see the badge.
	// just remember to turn it off before publishing!
	
	badge.testMode=true; 

To refresh the value displayed on the  badge, use the `refresh()` method:

	// updates the number on the badge
	badge.refresh();

###Customizing the notification badge###

The default notification badge is a red circle containing the number.  To customize the look of the badge, implement the `com.playhaven.ui.NotificationBadgeRenderer` interface:

	import com.playhaven.ui.*;

	package
	{
		public class MyBadgeRenderer implements NotificationBadgeRenderer
		{
			public function MyBadgeRenderer()
			{
			}

			public function renderToSurface(surface:Sprite,value:int):void
			{
				// attach your custom badge view to the 'surface' object,
				// and display the number 'value'.
			}
		}
	}

Pass your custom renderer to the `createNotificationBadge` function as the second parameter:

	var badge:NotificationBadge=PlayHaven.playhaven.createNotificationBadge("more_games",new MyBadgeRenderer());

## Setting tracking opt-out (optional) ##

On the iOS platform, you may optionally display a UI and let the user opt out of tracking:

	PlayHaven.playhaven.setOptOutStatus(true);

## Handling rewards ##

If you've set up a reward in the PlayHaven dashboard and associated it with a placement, the extension notifies you when an award is unlocked using the `PlayHavenEvent.REWARD_UNLOCKED` event.  The event's properties include `rewardName`, `rewardQuantity`, and `rewardReceipt`. You can use the unique `rewardReceipt` property to prevent repeated unlocks of the same item or handle tracking otherwise:

	PlayHaven.playhaven.addEventListener(PlayHavenEvent.REWARD_UNLOCKED, onRewardUnlocked);

	function onRewardUnlocked(e:PlayHavenEvent):void
	{
		trace("the reward "+e.rewardName+" was unlocked, quantity="e.rewardQuantity+", receipt value string is "+e.rewardReceipt);
	}

## Handling virtual goods promotions (optional) ##

If you're using an In-App Purchase extension in your game, you can track purchases and implement Virtual Good Promotions (VGP) through the PlayHaven dashboard.  

When a PlayHaven content unit has triggered the purchase of a VGP item, the `PlayHavenEvent.PURCHASE_REPORTED` event is dispatched.  The event includes a `purchase` object, which is an instance of `PHPurchase`.  You can use the `purchase`'s `productId`, `quantity`, and `receipt` (a unique identifier for the transaction) properties to start the IAP process via a third party extension.  You should keep a reference to the `purchase` object until the transaction is complete.

The following example shows the handling of an in-app purchase, using the [Milkman Games iOS In-App Purchase Extension](http://www.adobe.com/devnet/air/articles/storekit-ane-ios.html) to handle the transaction:


	var pendingPhPurchase:PHPurchase;

	...


	PlayHaven.playhaven.addEventListener(PlayHavenEvent.PURCHASE_REPORTED,onPlayHavenPurchase);

	function onPlayHavenPurchase(e:PlayHavenPurchase):void
	{
		this.pendingPhPurchase=e.purchase;

		// start the purchase product using a third party extension
		StoreKit.storekit.purchaseProduct(e.purchase.productId,e.purchase.quantity);
	}

When your In-App Purchase extension reports the completion or failure of the transaction, report it back to PlayHaven with the `reportPurchaseResolution()` method. You should pass in the PHPurchase reference you stored earlier to complete the process, along with one of the `PHPurchaseResolution` constants indicating the result:


	
	function onPurchaseSuccess(e:StoreKitEvent):void
	{
		PlayHaven.playhaven.reportPurchaseResolution(pendingPurchase,PHPurchaseResolution.BUY);
	}

	function onPurchaseFailed(e:StoreKitErrorEvent):void
	{
		PlayHaven.playhaven.reportPurchaseResolution(pendingPurchase,PHPurchaseResolution.ERROR);
	}

	function onPurchaseCancel(e:StoreKitEvent):void
	{
		PlayHaven.playhaven.reportPurchaseResolution(pendingPurchase,PHPurchaseResolution.CANCEL);
	}

The following example shows the same process for Android, using the [Milkman Games Android In-App Billing Extension](http://www.adobe.com/devnet/air/articles/android-billing-ane.html) to handle the transaction:

	var pendingPhPurchase:PHPurchase;

	...


	PlayHaven.playhaven.addEventListener(PlayHavenEvent.PURCHASE_REPORTED,onPlayHavenPurchase);

	function onPlayHavenPurchase(e:PlayHavenPurchase):void
	{
		this.pendingPhPurchase=e.purchase;

		// start the purchase product using a third party extension
		AndroidIAB.androidIAB.purchaseItem(e.purchase.productId,e.purchase.quantity);
	}

	...

	function onPurchaseSuccess(e:AndroidBillingEvent):void
	{
		PlayHaven.playhaven.reportPurchaseResolution(pendingPurchase,PHPurchaseResolution.BUY);
	}

	function onPurchaseFail(e:AndroidBillingErrorEvent):void
	{
		PlayHaven.playhaven.reportPurchaseResolution(pendingPurchase,PHPurchaseResolution.ERROR);	
	}

	function onPurchaseCancel(e:AndroidBillingEvent):void
	{
		Playhaven.playhaven.reportPurchaseResolution(pendingPurchase,PurchaseResolution.CANCEL);
	}


## Building the application ##

**Flash CS6 or Flash Builder 4.6**

If you're using Flash Builder 4.6 or later, or Flash Professional CS6 or later, and have added the extension library as previously described, then you can compile as normal directly from the IDE. 

**FlashDevelop or Other Tools**

If not and you are building your app with the extension from the command line (or with FlashDevelop), then you'll need to specify the directory containing the `com.playhaven.extensions.PlayHaven.ane` file.

Next is an example build command line:

`[PATH_TO_AIR_SDK]\bin\adt -package -target apk-debug -storetype pkcs12 -keystore [YOUR_KEYSTORE_FILE] -storepass [YOUR_PASSWORD] anesample.apk app.xml anesample.swf -extdir [DIRECTORY_CONTAINING_ANE_FILE]`



	


	

