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
    public class LToken
    {
        private var _type :int /*LTokenType*/;
        private var _value:Object;

        public function LToken(type:int, value:Object)
        {
            super();
            _type = type;
            _value = value;
        }

        public function get type():int
        {
            return _type;
        }

        public function get value():Object
        {
            return _value;
        }
    }
}
