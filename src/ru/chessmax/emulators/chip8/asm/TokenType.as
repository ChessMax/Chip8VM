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
    public class TokenType
    {
        public static const UNKNOWN:String;
        public static const ARGS_SEPARATOR:String = ",";
        public static const LABEL  :String = ":";
        public static const COMMENT:String = ";";
        public static const COMMAND_SEPARATOR:String = " ";
        public static const COMMAND:String = "command";
    }
}
