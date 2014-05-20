/**
 * Created by ChessMax on 07.05.2014.
 */
package ru.chessmax.emulators.chip8.asm
{
    /**
     * Simple Lexer
     * Created 07.05.2014
     * Version 1.0
     * Copyright (c) 2014
     * @author ChessMax (www.chessmax.ru)
     */
    public class Lexer
    {
        private var _index:int = -1;
        private var _input:String;

        public function Lexer()
        {
            super();
        }

        private function isDigit(value:String):Boolean
        {
            return value && "#@.$0123456789".indexOf(value) !== -1;
        }

        public function apply(value:String):Vector.<LToken>
        {
            _input = value;
            if (!value && value.length === 0)
            {
                throw "Empty input is unexpected";
            }
            var c:String;
            var tokens:Vector.<LToken> = new <LToken>[];

            while (_index < _input.length)
            {
                c = _input[_index];

                if (StringUtil.isWhiteSpace(c))
                {
                    next();
                    continue;
                }

                if (isDigit(c))
                {
                    var temp:String = c;
                    //while ()
                }
            }
        }

        private function next():void
        {
            ++_index;
        }
    }
}
