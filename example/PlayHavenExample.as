package  
{
import com.playhaven.ui.NotificationBadge;
import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.text.TextField;
import com.playhaven.*;
import com.playhaven.events.*;
import flash.utils.setTimeout;

/** PlayHaven Example App */
public class PlayHavenExample extends Sprite
{
	//
	// Definitions
	//
	
	/** iOS Publisher Token */
	public static const IOS_PUBLISHER_TOKEN:String="your_ios_token";
	
	/** iOS Publisher Secret */
	public static const IOS_PUBLISHER_SECRET:String="your_ios_secret";
	
	/** Android Publisher Token */
	public static const ANDROID_PUBLISHER_TOKEN:String="your_android_token";
	
	/** Android Publisher Secret */
	public static const ANDROID_PUBLISHER_SECRET:String="your_android_secret";

	//
	// Instance Variables
	//
	
	/** Status */
	private var txtStatus:TextField;
	
	/** Buttons */
	private var buttonContainer:Sprite;
	
	/** More Games Button */
	private var btnMoreGames:SimpleButton;
	
	/** Notifcation Badge */
	private var badge:NotificationBadge;
	
	//
	// Public Methods
	//
	
	/** Create New PlayHavenExample */
	public function PlayHavenExample() 
	{		
		createUI();
		
		if (!PlayHaven.isSupported())
		{
			log("PlayHaven is not supported on this platform (not android or ios!)");
			return;
		}
		
		log("initializing PH...");

		// (when using only ios or only android) 
		//PlayHaven.create(PUBLISHER_TOKEN,PUBLISHER_SECRET);
		
		// (both ios and android with the same code)
		PlayHaven.create(IOS_PUBLISHER_TOKEN,IOS_PUBLISHER_SECRET,ANDROID_PUBLISHER_TOKEN,ANDROID_PUBLISHER_SECRET);
				
		
		// listeners for content windows 
		PlayHaven.playhaven.addEventListener(PlayHavenEvent.CONTENT_OVERLAY_DISMISSED,onContentDismissed);
		PlayHaven.playhaven.addEventListener(PlayHavenEvent.CONTENT_OVERLAY_DISPLAYED,onContentDisplayed);
		PlayHaven.playhaven.addEventListener(PlayHavenEvent.CONTENT_OVERLAY_FAILED,onContentFailed);

		// listener for rewards
		PlayHaven.playhaven.addEventListener(PlayHavenEvent.REWARD_UNLOCKED,onReward);
		
		// listeners for in-app Virtual Good Promotions
		PlayHaven.playhaven.addEventListener(PlayHavenEvent.PURCHASE_REPORTED,onPurchaseReported);
		PlayHaven.playhaven.addEventListener(PlayHavenEvent.PURCHASE_REQUESTED,onPurchaseRequested);
		PlayHaven.playhaven.addEventListener(PlayHavenEvent.PURCHASE_REPORT_FAILED,onPurchaseReportFailed);

		log("PlayHaven Initialized!");
		
		log("sending game open...");
		PlayHaven.playhaven.reportGameOpen();
		log("->Reported game open.");
	}
	
	/** Show Test Placement */
	public function showTestPlacement():void
	{
		log("Showing test01 placement");
		PlayHaven.playhaven.sendContentRequest("test",true);
		log("send test01 request.");
	}
	
	/** Show More Games */
	public function showMoreGames():void
	{
		log("Starting more games placement..");
		PlayHaven.playhaven.sendContentRequest("more_games",true);
		log("requested more games placement.");
	}
	
	/** Set Opt Out Status YES */
	public function setOptOutYes():void
	{
		PlayHaven.playhaven.setOptOutStatus(true);
		log("Set optout=true");
	}
	
	/** Set Opt out Status NO */
	public function setOptOutNo():void
	{
		PlayHaven.playhaven.setOptOutStatus(false);
		log("set optout=false");
	}
	
	/** Show Notification Badge */
	public function showBadge():void
	{
		log("Showing badge...");
		
		if (this.badge!=null)
		{
			log("Already have a badge.");
			return;
		}
		
		this.badge=PlayHaven.playhaven.createNotificationBadge("more_games");
		
		// setting this makes the badge render on the screen, even if the value is 0.
		// this can be useful during testing for proper alignment, etc.
		this.badge.testMode=true;
		
		var badgeX:Number=btnMoreGames.parent.x+btnMoreGames.x+btnMoreGames.width;
		var badgeY:Number=btnMoreGames.parent.y+btnMoreGames.y;
		

		badgeX-=10;
		this.badge.x=badgeX;
		this.badge.y=badgeY;
		
		stage.addChild(this.badge);
		
		log("badge created, added to stage.");
	}
	
	/** Remove Badge */
	public function removeBadge():void
	{
		log("Removing badge...");
		this.badge.parent.removeChild(this.badge);
		this.badge=null;
		log("Badge removed.");
	}
	
	/** Refresh Badge */
	public function refreshBadge():void
	{
		log("Refreshing badge...");
		if (this.badge==null)
		{
			log("No badge to refresh.");
			return;
		}
		this.badge.refresh();
		log("Badge refreshed.");
	}
	
	/** Preload Content */
	public function preloadContent():void
	{
		log("preloading...");
		PlayHaven.playhaven.preloadContentRequest("more_games");
		log("request preload.");
	}
	
	//
	// Events
	//	

	/** On Content Failed */
	private function onContentFailed(e:PlayHavenEvent):void
	{
		log("ContentFailed:"+e.placementId+"="+e.errorMessage);
	}
	
	/** On Content Dismissed */
	private function onContentDismissed(e:PlayHavenEvent):void
	{
		log("Content dismissed: "+e.contentDismissalReason);
	}
	
	/** Content Displayed */
	private function onContentDisplayed(e:PlayHavenEvent):void
	{
		log("Content displayed:"+e.placementId);
	}
	
	/** On Reward */
	private function onReward(e:PlayHavenEvent):void
	{
		log("Reward "+e.rewardName+","+e.rewardQuantity+","+e.rewardReceipt);
	}
	
	/** Purchase Requested */
	private function onPurchaseRequested(e:PlayHavenEvent):void
	{
		log("purchase requested:"+e.purchase.receipt+"/"+e.purchase.productId);
		
		/**
		 * At this point, you should use your In-App Purchase third party native extension to start a
		 * transaction.  When the transaction finishes, you call PlayHaven.playhaven.reportPurcaseResolution,
		 * with the purchase object and one of the PHPurchaseResolution constants: BUY, ERROR, or CANCEL.
		 * 
		 * The code below automatically calls the 'BUY' resolution as an example to test the implementation,
		 * but you'll need to add your own callback from your in-app purchase extension.  For more information,
		 * see the documentation ('index.html' in the /docs folder of the extension zip.)
		 */
		
		var purchase:PHPurchase=e.purchase;
		var myLog:Function=this.log;
		
		var closePurchase:Function=function():void
		{
			myLog("Close purchase...");
			PlayHaven.playhaven.reportPurchaseResolution(purchase,PHPurchaseResolution.BUY);
			myLog("did report close.");
		}
		log("set timeout purchase callback...");
		setTimeout(closePurchase,5000);
		
	}
	
	/** Purchase Reported */
	private function onPurchaseReported(e:PlayHavenEvent):void
	{
		log("purchase reported:"+e.purchase);
	}
	
	/** Purchase Report Failed */
	private function onPurchaseReportFailed(e:PlayHavenEvent):void
	{
		log("purchase report failed:"+e.errorMessage);
	}
	
	//
	// Impelementation
	//
	
	/** Create UI */
	public function createUI():void
	{
		txtStatus=new TextField();
		txtStatus.defaultTextFormat=new flash.text.TextFormat("Arial",25,0xFFFFFF);
		txtStatus.width=stage.stageWidth;
		txtStatus.height=100;
		txtStatus.multiline=true;
		txtStatus.wordWrap=true;
		txtStatus.text="Ready";
		addChild(txtStatus);
		
		if (buttonContainer)
		{
			removeChild(buttonContainer);
			buttonContainer=null;
		}
		
		buttonContainer=new Sprite();
		buttonContainer.y=txtStatus.height;
		addChild(buttonContainer);
		
		var uiRect:Rectangle=new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
		var layout:ButtonLayout=new ButtonLayout(uiRect,19);
		btnMoreGames=new SimpleButton(new Command("More Games",showMoreGames));
		layout.addButton(btnMoreGames);
		layout.addButton(new SimpleButton(new Command("Test Placement",showTestPlacement)));
		layout.addButton(new SimpleButton(new Command("Set Optout YES",setOptOutYes)));
		layout.addButton(new SimpleButton(new Command("Set Optout NO",setOptOutNo)));
		layout.addButton(new SimpleButton(new Command("Show Badge",showBadge)));
		layout.addButton(new SimpleButton(new Command("Remove Badge",removeBadge)));
		layout.addButton(new SimpleButton(new Command("Refresh Badge",refreshBadge)));
		layout.addButton(new SimpleButton(new Command("Preload",preloadContent)));
		layout.attach(buttonContainer);
		layout.layout();	
	}
	
	/** Log */
	private function log(msg:String):void
	{
		trace("[PlayHaven] "+msg);
		txtStatus.text=msg;
	}	
	
}
}


import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/** Simple Button */
class SimpleButton extends Sprite
{
	//
	// Instance Variables
	//
	
	/** Command */
	private var cmd:Command;
	
	/** Width */
	private var _width:Number;
	
	/** Label */
	private var txtLabel:TextField;
	
	//
	// Public Methods
	//
	
	/** Create New SimpleButton */
	public function SimpleButton(cmd:Command)
	{
		super();
		this.cmd=cmd;
		
		mouseChildren=false;
		mouseEnabled=buttonMode=useHandCursor=true;
		
		txtLabel=new TextField();
		txtLabel.defaultTextFormat=new TextFormat("Arial",44,0xFFFFFF);
		txtLabel.mouseEnabled=txtLabel.mouseEnabled=txtLabel.selectable=false;
		txtLabel.text=cmd.getLabel();
		txtLabel.autoSize=TextFieldAutoSize.LEFT;
		
		redraw();
		
		addEventListener(MouseEvent.CLICK,onSelect);
	}
	
	/** Set Width */
	override public function set width(val:Number):void
	{
		this._width=val;
		redraw();
	}

	
	/** Dispose */
	public function dispose():void
	{
		removeEventListener(MouseEvent.CLICK,onSelect);
	}
	
	//
	// Events
	//
	
	/** On Press */
	private function onSelect(e:MouseEvent):void
	{
		this.cmd.execute();
	}
	
	//
	// Implementation
	//
	
	/** Redraw */
	private function redraw():void
	{		
		txtLabel.text=cmd.getLabel();
		_width=_width||txtLabel.width*1.1;
		
		graphics.clear();
		graphics.beginFill(0x444444);
		graphics.lineStyle(2,0);
		graphics.drawRoundRect(0,0,_width,txtLabel.height*1.1,txtLabel.height*.8);
		graphics.endFill();
		
		txtLabel.x=_width/2-(txtLabel.width/2);
		txtLabel.y=txtLabel.height*.05;
		addChild(txtLabel);
	}
}

/** Button Layout */
class ButtonLayout
{
	private var buttons:Array;
	private var rect:Rectangle;
	private var padding:Number;
	private var parent:DisplayObjectContainer;
	
	public function ButtonLayout(rect:Rectangle,padding:Number)
	{
		this.rect=rect;
		this.padding=padding;
		this.buttons=new Array();
	}
	
	public function addButton(btn:SimpleButton):uint
	{
		return buttons.push(btn);
	}
	
	public function attach(parent:DisplayObjectContainer):void
	{
		this.parent=parent;
		for each(var btn:SimpleButton in this.buttons)
		{
			parent.addChild(btn);
		}
	}
	
	public function layout():void
	{
		var btnX:Number=rect.x+padding;
		var btnY:Number=rect.y;
		for each( var btn:SimpleButton in this.buttons)
		{
			btn.width=rect.width-(padding*2);
			btnY+=this.padding;
			btn.x=btnX;
			btn.y=btnY;
			btnY+=btn.height;
		}
	}
}

/** Inline Command */
class Command
{
	/** Callback Method */
	private var fnCallback:Function;
	
	/** Label */
	private var label:String;
	
	//
	// Public Methods
	//
	
	/** Create New Command */
	public function Command(label:String,fnCallback:Function)
	{
		this.fnCallback=fnCallback;
		this.label=label;
	}
	
	//
	// Command Implementation
	//
	
	/** Get Label */
	public function getLabel():String
	{
		return label;
	}
	
	/** Execute */
	public function execute():void
	{
		fnCallback();
	}
}