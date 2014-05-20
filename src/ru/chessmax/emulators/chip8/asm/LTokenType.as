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
    public class LTokenType
    {
        public static const LABEL     :uint = 1;//
        public static const OPERATOR  :uint = 2;//+-*/()~&|
        public static const NUMBER    :uint = 3;
        public static const IDENTIFIER:uint = 4;
    }
}
