/**
 * Created by ChessMax on 28.04.2014.
 */
package ru.chessmax.emulators.chip8.util
{
    /**
     *
     * Created 28.04.2014
     * Version 1.0
     * Copyright (c) 2014
     * @author ChessMax (www.chessmax.ru)
     */
    public class ArrayUtil
    {
        public static function zeroFill(value:Array):Array
        {
            if (value)
            {
                for (var i:int = 0;i<value.length;++i)
                {
                    value[i] = 0;
                }
            }
            return value;
        }
    }
}
