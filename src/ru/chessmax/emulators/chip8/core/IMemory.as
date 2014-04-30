/**
 * Created by ChessMax on 28.04.2014.
 */
package ru.chessmax.emulators.chip8.core
{
    /**
     *
     * Created 28.04.2014
     * Version 1.0
     * Copyright (c) 2014
     * @author ChessMax (www.chessmax.ru)
     */
    public interface IMemory
    {
        function clear():void;

        /**
         * Записать байт в память
         * @param position
         * @param value
         */
        function writeByte(position:uint, value:int):void;

        /**
         * Прочитать значение из памяти
         * @param position
         * @return
         */
        function readByte(position:uint):uint;
    }
}
