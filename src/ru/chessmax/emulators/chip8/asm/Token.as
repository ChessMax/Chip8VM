/**
 * Created by ChessMax on 06.05.2014.
 */
package ru.chessmax.emulators.chip8.asm
{
    /**
     *
     * Created 06.05.2014
     * Version 1.0
     * Copyright (c) 2014
     * @author ChessMax (www.chessmax.ru)
     */
    public class Token
    {
        private var _type :String /*TokenType*/;
        private var _value:Object;

        public function Token(type:String, value:Object)
        {
            super();
            _type = type;
            _value = value;
        }

        public function get value():Object
        {
            return _value;
        }

        public function get type():String
        {
            return _type;
        }
    }
}
