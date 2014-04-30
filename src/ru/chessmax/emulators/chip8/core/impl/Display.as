/**
 * Created by ChessMax on 28.04.2014.
 */
package ru.chessmax.emulators.chip8.core.impl
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Rectangle;

    import ru.chessmax.emulators.chip8.core.IDisplay;

    import ru.chessmax.emulators.chip8.core.IMemory;
    import ru.chessmax.emulators.chip8.util.ArrayUtil;

    /**
     *
     * Created 28.04.2014
     * Version 1.0
     * Copyright (c) 2014
     * @author ChessMax (www.chessmax.ru)
     */
    public class Display implements IDisplay
    {
        private static const WIDTH :uint = 64;
        private static const HEIGHT:uint = 32;

        private var _data:BitmapData;
        private var _gfx:Array;

        public function Display(displayRenderer:Bitmap)
        {
            super();
            _gfx = ArrayUtil.zeroFill(new Array(WIDTH * HEIGHT));

            _data = new BitmapData(WIDTH, HEIGHT, false, 0x000000);
            displayRenderer.bitmapData = _data;
            _data.lock();
        }

        public function writeByte(position:uint, value:int):void
        {
            var x:uint = position % WIDTH;
            var y:uint = position / WIDTH;

            _data.setPixel(x, y, value === 0 ? 0x000000 : 0xFFFFFF);
            _gfx[position] = value;
        }

        public function readByte(position:uint):uint
        {
            var x:uint = position % WIDTH;
            var y:uint = position / WIDTH;
            var p:uint = _data.getPixel(x, y);
           /* //*/return p !== 0xFFFFFF ? 0 : 1;
           /* return _gfx[position];*/
        }

        public function unlock():void
        {
            _data.unlock();
            _data.lock  ();

            /*var str:String = "";
            // Draw
            for(var y:int = 0; y < 32; ++y)
            {
                for(var x:int = 0; x < 64; ++x)
                {
                    if(_gfx[(y*64) + x] == 0)
                        str+="O";
                    else
                        str+=" ";
                }
                str+="\n";
            }
            str+="\n";

            trace(str + "\n")*/
        }

        /**
         * Очистить экран
         */
        public function clear():void
        {
            _data.fillRect(new Rectangle(0, 0, WIDTH, HEIGHT), 0x000000);
        }
    }
}
