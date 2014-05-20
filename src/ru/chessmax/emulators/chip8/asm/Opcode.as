/**
 * Created by ChessMax on 07.05.2014.
 */
package ru.chessmax.emulators.chip8.asm
{
    import flash.utils.ByteArray;

    import ru.chessmax.emulators.chip8.asm.ArgumentType;

    /**
     *
     * Created 07.05.2014
     * Version 1.0
     * Copyright (c) 2014
     * @author ChessMax (www.chessmax.ru)
     */
    public class Opcode
    {
        private static function parseAddr(value:String):int
        {
            return parseInt(value) & 0x0FFF;
        }
        private static function parseByte(value:String):int
        {
            return parseInt(value) & 0x00FF;
        }
        private static function getRegister(value:String):int
        {
            return parseInt(value.charAt(1), 16) & 0x000F;
        }

        public static const LIST:Object =
        {
            add:
            [
                /**
                 * #FX1E  ADD   I, VX           ; CHIP8, CHIP48, SCHIP10, SCHIP11
                 ; Set I = I + VX
                 */
                new Opcode("add", [ArgumentType.REGISTER_I, ArgumentType.REGISTER_VX],
                function (args:Array /*String*/):int
                {
                    return 0xF01E | (getRegister(args[1]) << 8);
                }),
                /**
                 * #7XKK  ADD   VX, Byte        ; CHIP8, CHIP48, SCHIP10, SCHIP11
                 ; Set VX = VX + Byte
                 */
                new Opcode("add", [ArgumentType.REGISTER_VX, ArgumentType.BYTE], function(args:Array):int
                {
                    return 0x7000 | (getRegister(args[0]) << 8) | parseByte(args[1]);
                }),
                /**
                 * #8XY4  ADD   VX, VY          ; CHIP8, CHIP48, SCHIP10, SCHIP11
                 ; Set VX = VX + VY, VF = carry
                 */
                new Opcode("add", [ArgumentType.REGISTER_VX, ArgumentType.REGISTER_VY], function(args:Array):int
                {
                    return 0x8004 | (getRegister(args[0]) << 8) | (getRegister(args[1]) << 4);
                })
            ],
            jp:
            [
                /**
                 * #1NNN  JP    Addr        Jump to Addr
                 */
                new Opcode("jp", [ArgumentType.ADDR], function (args:Array):int
                {
                    return 0x1000 | parseAddr(args[0]);
                })
            ]
        };

        private var _name:String;
        private var _args:Array;
        private var _encode:Function;

        public function Opcode(name:String, args:Array/*Function(value:String):Boolean*/=null, encode:Function/*...args*/=null)
        {
            super();
            _name = name;
            _args = args;
            _encode = encode;
            //LIST[_name] = this;
        }

        public function encode(args:Array):int
        {
            return _encode(args);
        }

        public function validateArgs(value:Array /* String */):Boolean
        {
            var numArgs :uint = value ? value.length : 0;
            var needArgs:uint = _args ? _args.length : 0;
            if (numArgs === needArgs)
            {
                if (needArgs === 0)
                {
                    return true;
                }
                for (var i:int = 0;i<needArgs;++i)
                {
                    var arg  :String = value[i] as String;
                    var check:Function = _args[i] as Function;
                    if (!check(arg))
                    {
                        return false;
                    }
                }
                return true;
            }
            /*if (value && _args && value.length === _args.length)
            {
                for (var i:int = 0;i<value.length;++i)
                {
                    var arg:String = value[i] as String;
                    var check:Function = _args[i] as Function;
                    if (check !== null && check(arg))
                    {
                        return;
                    }
                    else
                    {
                        var temp:Array = _args[i] as Array;
                        for (var j:int = 0;j<temp.length;++j)
                        {
                            check = temp[j] as Function;
                            if (check !== null && check(arg))
                            {
                                return;
                            }
                        }
                    }
                }
            }*/
            //throw "Invalid opcode \"" + _name + "\" args (" + value + ")";
            return false;
        }
    }
}
