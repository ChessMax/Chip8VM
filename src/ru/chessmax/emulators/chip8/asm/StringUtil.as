/**
 * Created by ChessMax on 07.05.2014.
 */
package ru.chessmax.emulators.chip8.asm
{
    /**
     *
     * Created 07.05.2014
     * Version 1.0
     * Copyright (c) 2014
     * @author ChessMax (www.chessmax.ru)
     */
    public class StringUtil
    {
        private static const WHITE_SPACES_TRIM:RegExp = /^\s+|\s+$/g;

        public static function isHexChar(value:String):Boolean
        {
            return value && value.length === 1 && "0123456789ABCDEF".indexOf(value.toUpperCase()) !== -1;
        }

        public static function isDigit(value:String):Boolean
        {
            return value && value.length === 1 && (value === "." || (value >= "0" && value <= "9"));
        }

        public static function trim(value:String):String
        {
            return value ? value.replace(WHITE_SPACES_TRIM, "") : "";
        }

        public static function isWhiteSpace(value:String):Boolean
        {
            return value && value.match(/\s/);
        }
    }
}
