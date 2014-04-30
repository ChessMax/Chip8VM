/**
 * Created by ChessMax on 28.04.2014.
 */
package ru.chessmax.emulators.chip8.core.impl
{
    import ru.chessmax.emulators.chip8.core.IMemory;
    import ru.chessmax.emulators.chip8.util.ArrayUtil;

    /**
     *
     * Created 28.04.2014
     * Version 1.0
     * Copyright (c) 2014
     * @author ChessMax (www.chessmax.ru)
     */
    public class Memory implements IMemory
    {
        private var _data:Array /* Byte */;

        public function Memory()
        {
            super();

            _data = new Array(4 * 1024);

        }

        /**
         * Записать байт в память
         * @param position
         * @param value
         */
        public function writeByte(position:uint, value:int):void
        {
            _data[position] = value;
        }

        /**
         * Прочитать значение из памяти
         * @param position
         * @return
         */
        public function readByte(position:uint):uint
        {
            return _data[position];
        }

        /**
         * Очистить память
         */
        public function clear():void
        {
            ArrayUtil.zeroFill(_data);
        }
    }
}
