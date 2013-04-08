package ;

import nme.display.DisplayObject;
import nme.geom.Point;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.Lib;
import nme.text.TextField;
import nme.utils.ByteArray;
import nme.utils.Timer;

/**
 * ...
 * @author Lars Doucet
 */

class Main extends Sprite 
{
	var inited:Bool;
	
	private var the_text:TextField;

	/* ENTRY POINT */
	
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;
		
		testText();
		
		//testThreshold();
		testThreshold2();
		//benchmark();
	}
	
	private function testText():Void {		
		if (the_text != null) {
			if (contains(the_text)){
				removeChild(the_text);
			}
			the_text = null;
		}
		if(the_text == null){
			var t:TextField = new TextField();
			addChild(t);
			t.width = stage.stageWidth;
			t.multiline = true;
			t.y = 70;
			the_text = t;
		}
		//the_text.text = "nme.display.BitmapData.threshold() test suite\n Press 1-3 for tests.\n Test 3 is a benchmark and might take a while.";
	}

	private function clear():Void {
		var i:Int = 0;
		var failsafe:Int = 0;
		while (i < numChildren && numChildren > 0 && failsafe < 100) {
			var d:DisplayObject = getChildAt(i);
			if (d != null) {
				removeChild(d);
				if (Std.is(d, Bitmap)) {
					var b:Bitmap = cast d;
					b.bitmapData.dispose();
				}
				i--;
			}
			i++;
			failsafe++;
		}
		testText();
	}
	
	/*private function onKeyDown(e:KeyboardEvent):Void {
		
		switch(e.keyCode) {
			case 49: //"1"
				clear();
				testThreshold();
			case 50: //"2"
				clear();
				testThreshold2();
			case 51: //"3"
				clear();
				benchmark();
		}
		testText();
		trace(e.keyCode);
	}*/
	
	private function benchmark():Void{
		var time:Float = 0;
		
		var runs:Int = 100;
		
		var max:Float = 0;
		var min:Float = 999999;
		
		for (i in 0...runs) {
			var final:Bool = i == (runs - 1);
			var test:Float = _benchmark(final);
			if (test > max) { max = test; }
			if (test < min) { min = test; }
			time += test;
		}
		
		var t:TextField = new TextField();
		t.y = 0;
		t.width = 400;
		
		addChild(t);
		
		var b:BitmapData = Assets.getBitmapData("img/face_sheet.png", false);
		
		t.text = "Benchmark :\n1 operation (==), 3 color tests, no offset, " + b.width + "x" + b.height + " pixels";
		t.text += "\n"+runs + "x runs = " + time + " ms,\nAvg (" + (time / runs) + " ms), Min ("+min+" ms), Max ("+max+" ms)";
		
		b.dispose();
	}
	
	private function _benchmark(final:Bool):Float{
		var bd:BitmapData = Assets.getBitmapData("img/face_sheet.png",false);
		
		var a:Float = Lib.getTimer();
		
		bd.threshold(bd, bd.rect, new nme.geom.Point(), "==", 0xFFc59d05, 0xFF009dc5);
		bd.threshold(bd, bd.rect, new nme.geom.Point(), "==", 0xFFf3dd28, 0xFF00ddf3);
		bd.threshold(bd, bd.rect, new nme.geom.Point(), "==", 0xFFfcf091, 0xFF91f0fc);

		var b:Float = Lib.getTimer();
		
		if (!final) {
			bd.dispose();
			bd = null;
		}else{
			var bmp:Bitmap = new Bitmap(bd);
			bmp.x = 10;
			bmp.y = 120;
			addChild(bmp);
			
			var t:TextField = new TextField();
			t.x = bmp.x;
			t.y = bmp.y - 20;
			addChild(t);
		}
		return b - a;
	}
	
	private function testThreshold2():Void {
		var time:Float = 0;
		
		var runs:Int = 100;
		
		for (i in 0...runs) {
			var final:Bool = i == (runs-1);
			time += _testThreshold2(final);
		}
		
		var max:Float = 0;
		var min:Float = 999999;
		
		for (i in 0...runs) {
			var final:Bool = i == (runs - 1);
			var test:Float = _testThreshold2(final);
			if (test > max) { max = test; }
			if (test < min) { min = test; }
			time += test;
		}
		
		var t:TextField = new TextField();
		t.y = 0;
		t.width = 400;
		
		addChild(t);
		
		var b:BitmapData = Assets.getBitmapData("img/greyscale.png", false);
		
		t.text = "Test 2:\n6 operations, 1 color test, destPoint offset, " + b.width + "x" + b.height + " pixels";
		t.text += "\n"+runs + "x runs = " + time + " ms,\nAvg (" + (time / runs) + " ms), Min ("+min+" ms), Max ("+max+" ms)";
		
		b.dispose();
	}
	
	private function _testThreshold2(final:Bool=false):Float{

		var bd_eq:BitmapData = Assets.getBitmapData("img/greyscale.png",false);
		var bd_lt:BitmapData = Assets.getBitmapData("img/greyscale.png",false);
		var bd_gt:BitmapData = Assets.getBitmapData("img/greyscale.png",false);
		var bd_un_eq:BitmapData = Assets.getBitmapData("img/greyscale.png",false);
		var bd_lt_eq:BitmapData = Assets.getBitmapData("img/greyscale.png",false);
		var bd_gt_eq:BitmapData = Assets.getBitmapData("img/greyscale.png",false);
		
		var bd_blue = Assets.getBitmapData("img/bluescale.png",false);
		
		var bmp_eq = new Bitmap(bd_eq);
		bmp_eq.x = 10;
		bmp_eq.y = the_text.y + the_text.height;
		
		var bmp_lt = new Bitmap(bd_lt);
		bmp_lt.x = 10 + bmp_eq.x + bmp_eq.width;
		bmp_lt.y = bmp_eq.y;
		
		var bmp_gt = new Bitmap(bd_gt);
		bmp_gt.x = 10 + bmp_lt.x + bmp_lt.width;
		bmp_gt.y = bmp_eq.y;
		
		var bmp_un_eq = new Bitmap(bd_un_eq);
		bmp_un_eq.x = 10;
		bmp_un_eq.y = bmp_eq.y + bmp_eq.height + 20;
		
		var bmp_lt_eq = new Bitmap(bd_lt_eq);
		bmp_lt_eq.x = 10 + bmp_un_eq.x + bmp_un_eq.width;
		bmp_lt_eq.y = bmp_un_eq.y;
		
		var bmp_gt_eq = new Bitmap(bd_gt_eq);
		bmp_gt_eq.x = 10 + bmp_lt_eq.x + bmp_lt_eq.width;
		bmp_gt_eq.y = bmp_un_eq.y;
		
		var col1:BitmapInt32 = 0xFF0000FF;
		var col2:BitmapInt32 = 0xFFFF0000;
		
		//the_text.text = "";
				
		var pt:Point = new Point(4, 4);
		var a:Int = Lib.getTimer();
		var eq:Int = bd_eq.threshold(bd_blue, bd_blue.rect, pt, "==", col1, col2, 0xFFFFFFFF,true);
		var lt:Int = bd_lt.threshold(bd_blue, bd_blue.rect, pt, "<", col1, col2, 0xFFFFFFFF,true);
		var gt:Int = bd_gt.threshold(bd_blue, bd_blue.rect, pt, ">", col1, col2, 0xFFFFFFFF,true);
		var un_eq:Int = bd_un_eq.threshold(bd_blue, bd_blue.rect, pt, "!=", col1, col2, 0xFFFFFFFF,true);
		var lt_eq:Int = bd_lt_eq.threshold(bd_blue, bd_blue.rect, pt, "<=", col1, col2, 0xFFFFFFFF,true);
		var gt_eq:Int = bd_gt_eq.threshold(bd_blue, bd_blue.rect, pt, ">=", col1, col2, 0xFFFFFFFF,true);
		var b:Int = Lib.getTimer();
		
		if (!final) {
			bd_eq.dispose();
			bd_lt.dispose();
			bd_gt.dispose();
			bd_un_eq.dispose();
			bd_lt_eq.dispose();
			bd_gt_eq.dispose();
			bd_blue.dispose();
			bd_eq = null;
			bd_lt = null;
			bd_gt = null;
			bd_un_eq = null;
			bd_lt_eq = null;
			bd_gt_eq = null;
			bd_blue = null;
		}else{
			the_text.text = "\nPixels changed per operation:" + "\n (==): " + eq + ", (<): " + lt + ", (>): " + gt + "\n(!=): " + un_eq + ", (<=): " + lt_eq + ", (>=): " + gt_eq;
			
			var txt_eq:TextField = new TextField();
			txt_eq.x = bmp_eq.x; 
			txt_eq.y = bmp_eq.y - 20; 
			txt_eq.text = " == "; 
			
			var txt_lt:TextField = new TextField();
			txt_lt.x = bmp_lt.x; 
			txt_lt.y = bmp_lt.y - 20; 
			txt_lt.text = " < "; 
			
			var txt_gt:TextField = new TextField();
			txt_gt.x = bmp_gt.x; 
			txt_gt.y = bmp_gt.y - 20; 
			txt_gt.text = " > "; 
			
			var txt_un_eq:TextField = new TextField();
			txt_un_eq.x = bmp_un_eq.x; 
			txt_un_eq.y = bmp_un_eq.y - 20; 
			txt_un_eq.text = " != "; 
					
			var txt_gt_eq:TextField = new TextField();
			txt_gt_eq.x = bmp_gt_eq.x; 
			txt_gt_eq.y = bmp_gt_eq.y - 20; 
			txt_gt_eq.text = " >= "; 
			
			var txt_lt_eq:TextField = new TextField();
			txt_lt_eq.x = bmp_lt_eq.x; 
			txt_lt_eq.y = bmp_lt_eq.y - 20; 
			txt_lt_eq.text = " <= ";
		
			addChild(txt_eq);
			addChild(txt_lt);
			addChild(txt_gt);
			addChild(txt_un_eq);
			addChild(txt_gt_eq);
			addChild(txt_lt_eq);
			
			addChild(bmp_eq);
			addChild(bmp_lt);
			addChild(bmp_gt);
			addChild(bmp_un_eq);
			addChild(bmp_gt_eq);
			addChild(bmp_lt_eq);
		}
		return b - a;
	}
	
	private function testThreshold():Void {
		var time:Float = 0;
		
		var runs:Int = 100;
		
		var max:Float = 0;
		var min:Float = 999999;
		
		
		for (i in 0...runs) {
			var final:Bool = i == (runs-1);
			var test:Float = _testThreshold(final);
			if (test > max) { max = test; }
			if (test < min) { min = test; }
			time += test;
		}
				
		for (i in 0...runs) {
			var final:Bool = i == (runs - 1);
		}		
		
		var t:TextField = new TextField();
		t.y = 0;
		t.width = 400;
		
		addChild(t);
		
		var b:BitmapData = Assets.getBitmapData("img/greyscale.png", false);
		
		t.text = "Test 1:\n6 operations, 1 color test, no offset, " + b.width + "x" + b.height + " pixels";
		t.text += "\n"+runs + "x runs = " + time + " ms,\nAvg (" + (time / runs) + " ms), Min ("+min+" ms), Max ("+max+" ms)";
		
		b.dispose();
	}
	
	private function _testThreshold(final:Bool=false):Float{
		var bd_eq:BitmapData = Assets.getBitmapData("img/greyscale.png",false);
		var bd_lt:BitmapData = Assets.getBitmapData("img/greyscale.png",false);
		var bd_gt:BitmapData = Assets.getBitmapData("img/greyscale.png",false);
		var bd_un_eq:BitmapData = Assets.getBitmapData("img/greyscale.png",false);
		var bd_lt_eq:BitmapData = Assets.getBitmapData("img/greyscale.png",false);
		var bd_gt_eq:BitmapData = Assets.getBitmapData("img/greyscale.png",false);
		
		var bmp_eq = new Bitmap(bd_eq);
		bmp_eq.x = 10;
		bmp_eq.y = the_text.y + the_text.height;
		
		var bmp_lt = new Bitmap(bd_lt);
		bmp_lt.x = 10 + bmp_eq.x + bmp_eq.width;
		bmp_lt.y = bmp_eq.y;
		
		var bmp_gt = new Bitmap(bd_gt);
		bmp_gt.x = 10 + bmp_lt.x + bmp_lt.width;
		bmp_gt.y = bmp_eq.y;
		
		var bmp_un_eq = new Bitmap(bd_un_eq);
		bmp_un_eq.x = 10;
		bmp_un_eq.y = bmp_eq.y + bmp_eq.height + 20;
		
		var bmp_lt_eq = new Bitmap(bd_lt_eq);
		bmp_lt_eq.x = 10 + bmp_un_eq.x + bmp_un_eq.width;
		bmp_lt_eq.y = bmp_un_eq.y;
		
		var bmp_gt_eq = new Bitmap(bd_gt_eq);
		bmp_gt_eq.x = 10 + bmp_lt_eq.x + bmp_lt_eq.width;
		bmp_gt_eq.y = bmp_un_eq.y;
		
		var col1:BitmapInt32 = 0xFF808080;
		var col2:BitmapInt32 = 0xFFFF0000;
		
		var a:Float = Lib.getTimer();
		var eq = bd_eq.threshold(bd_eq, bd_eq.rect, new nme.geom.Point(0,0), "==", col1, col2);
		var lt = bd_lt.threshold(bd_lt, bd_lt.rect, new nme.geom.Point(0,0), "<", col1, col2);
		var gt = bd_gt.threshold(bd_gt, bd_gt.rect, new nme.geom.Point(0,0), ">", col1, col2);
		var un_eq = bd_un_eq.threshold(bd_un_eq, bd_un_eq.rect, new nme.geom.Point(0,0), "!=", col1, col2);
		var lt_eq = bd_lt_eq.threshold(bd_lt_eq, bd_lt_eq.rect, new nme.geom.Point(0,0), "<=", col1, col2);
		var gt_eq = bd_gt_eq.threshold(bd_gt_eq, bd_gt_eq.rect, new nme.geom.Point(0,0), ">=", col1, col2);
		var b:Float = Lib.getTimer();
		
		if (!final) {
			bd_eq.dispose();
			bd_lt.dispose();
			bd_gt.dispose();
			bd_un_eq.dispose();
			bd_lt_eq.dispose();
			bd_gt_eq.dispose();
			bd_eq = null;
			bd_lt = null;
			bd_gt = null;
			bd_un_eq = null;
			bd_lt_eq = null;
			bd_gt_eq = null;
		}else{
			the_text.text += "\nPixels changed per operation:" + "\n (==): " + eq + ", (<): " + lt + ", (>): " + gt + "\n(!=): " + un_eq + ", (<=): " + lt_eq + ", (>=): " + gt_eq;
			
			var txt_eq:TextField = new TextField();
			txt_eq.x = bmp_eq.x; 
			txt_eq.y = bmp_eq.y - 20; 
			txt_eq.text = " == "; 
			
			var txt_lt:TextField = new TextField();
			txt_lt.x = bmp_lt.x; 
			txt_lt.y = bmp_lt.y - 20; 
			txt_lt.text = " < "; 
			
			var txt_gt:TextField = new TextField();
			txt_gt.x = bmp_gt.x; 
			txt_gt.y = bmp_gt.y - 20; 
			txt_gt.text = " > "; 
			
			var txt_un_eq:TextField = new TextField();
			txt_un_eq.x = bmp_un_eq.x; 
			txt_un_eq.y = bmp_un_eq.y - 20; 
			txt_un_eq.text = " != "; 
					
			var txt_gt_eq:TextField = new TextField();
			txt_gt_eq.x = bmp_gt_eq.x; 
			txt_gt_eq.y = bmp_gt_eq.y - 20; 
			txt_gt_eq.text = " >= "; 
			
			var txt_lt_eq:TextField = new TextField();
			txt_lt_eq.x = bmp_lt_eq.x; 
			txt_lt_eq.y = bmp_lt_eq.y - 20; 
			txt_lt_eq.text = " <= ";
		
			addChild(txt_eq);
			addChild(txt_lt);
			addChild(txt_gt);
			addChild(txt_un_eq);
			addChild(txt_gt_eq);
			addChild(txt_lt_eq);
			
			addChild(bmp_eq);
			addChild(bmp_lt);
			addChild(bmp_gt);
			addChild(bmp_un_eq);
			addChild(bmp_gt_eq);
			addChild(bmp_lt_eq);
		}
		return b - a;
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		nme.Lib.current.stage.align = nme.display.StageAlign.TOP_LEFT;
		nme.Lib.current.stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		nme.Lib.current.addChild(new Main());
	}
	
}
