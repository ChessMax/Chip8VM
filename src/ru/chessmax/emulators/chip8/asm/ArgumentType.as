/**
 * Created by ChessMax on 07.05.2014.
 */
package ru.chessmax.emulators.chip8.asm
{
    import ru.chessmax.emulators.chip8.asm.StringUtil;

    /**
     *
     * Created 07.05.2014
     * Version 1.0
     * Copyright (c) 2014
     * @author ChessMax (www.chessmax.ru)
     */
    public class ArgumentType
    {
        public static function ADDR(value:String):Boolean
        {
            // либо это константная ссылка
            // либо метка
            return BYTE(value) || value.length > 0;//todo
        };

        public static function REGISTER_I(value:String):Boolean
        {
            return value && value.toUpperCase() === "I";
        }

        public static function REGISTER_VX(value:String):Boolean
        {
            return value
                && value.length === 2
                && value.charAt(0).toUpperCase() === "V"
                && StringUtil.isHexChar(value.charAt(1));
        }

        public static function REGISTER_VY(value:String):Boolean
        {
            return REGISTER_VX(value);
        }

        public static function BYTE(value:String):Boolean
        {
            //todo check expression
            var num:Number;
            if (value && value.length > 0)
            {
                var radix:int = 10;
                if (value.length > 1 && value.charAt(0) === "#")
                {
                    radix = 16;
                    value = value.substring(1, value.length - 1);
                }
                else
                if (value.length > 1 && value.charAt(0) === "@")
                {
                    radix = 8;
                    value = value.substring(1, value.length - 1);
                }
                else
                if (value.length > 1 && value.charAt(0) === "$")
                {
                    radix = 2;
                    value = value.substring(1, value.length - 1).split(".").join("0");
                }
                num = parseInt(value, radix);
            }

            return !isNaN(num);
        }
    }
}
