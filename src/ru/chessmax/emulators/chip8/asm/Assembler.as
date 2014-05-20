/**
 * Created by ChessMax on 30.04.2014.
 */
package ru.chessmax.emulators.chip8.asm
{
    import flash.utils.ByteArray;

    import ru.chessmax.emulators.chip8.asm.StringUtil;

    /**
     *
     * Created 30.04.2014
     * Version 1.0
     * Copyright (c) 2014
     * @author ChessMax (www.chessmax.ru)
     */
    public class Assembler
    {
        private static const ENTRY_POINT:int = 0x200;
        /*
             NNN         indicates a 12 bit address.
             KK          means an 8 bit constant.
             X           denotes a 4 bit register number.
             Y           denotes a 4 bit register number.
             1..9, A..F  are hexadecimal digits.

             Word        represents an expression defining a 16 bit constant.
             Addr        is an expression resulting in a 12 bit address.
             Byte        results in an 8 bit constant.
             Nibble      would be a 4 bit constant.
             Expr        may be any of the above expressions.
             Char        is an ASCII character.
             String      is a sequence of ASCII characters.


            #FX1E  ADD   I, VX           ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                         ; Set I = I + VX
            #7XKK  ADD   VX, Byte        ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                         ; Set VX = VX + Byte
            #8XY4  ADD   VX, VY          ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set VX = VX + VY, VF = carry
             #8XY2  AND   VX, VY          ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set VX = VX & VY, VF updates
             #2NNN  CALL  Addr            ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Call subroutine at Addr (16 levels)
             #00E0  CLS                   ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Clear display
             #DXYN  DRW   VX, VY, Nibble  ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Draw Nibble byte sprite stored at
                                          ; [I] at VX, VY. Set VF = collision
             #DXY0  DRW   VX, VY, 0       ; SCHIP10, SCHIP11
                                          ; Draw extended sprite stored at [I]
                                          ; at VX, VY. Set VF = collision
             #00FD  EXIT                  ; SCHIP10, SCHIP11
                                          ; Terminate the interpreter
             #00FF  HIGH                  ; SCHIP10, SCHIP11
                                          ; Enable extended screen mode
             #1NNN  JP    Addr            ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Jump to Addr
             #BNNN  JP    V0, Addr        ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Jump to Addr + V0
             #FX33  LD    B, VX           ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Store BCD of VX in [I], [I+1], [I+2]
             #FX15  LD    DT, VX          ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set delaytimer = VX
             #FX29  LD    F, VX           ; CHIP8, CHIP48
                                          ; Point I to 5 byte numeric sprite
                                          ; for value in VX
             #FX30  LD    HF, VX          ; SCHIP10, SCHIP11
                                          ; Point I to 10 byte numeric sprite
                                          ; for value in VX
             #ANNN  LD    I, Addr         ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set I = Addr
             #FX29  LD    LF, VX          ; SCHIP10, SCHIP11
                                          ; Point I to 5 byte numeric sprite
                                          ; for value in VX
             #FX75  LD    R, VX           ; SCHIP10, SCHIP11
                                          ; Store V0 .. VX in RPL user flags.
                                          ; Only V0 .. V7 valid
             #FX18  LD    ST, VX          ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set soundtimer = VX
             #6XKK  LD    VX, Byte        ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set VX = Byte
             #FX07  LD    VX, DT          ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set VX = delaytimer
             #FX0A  LD    VX, K           ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set VX = key, wait for keypress
             #FX85  LD    VX, R           ; SCHIP10, SCHIP11
                                          ; Read V0 .. VX from RPL user flags.
                                          ; Only V0 .. V7 valid
             #8XY0  LD    VX, VY          ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set VX = VY, VF updates
             #FX65  LD    VX, [I]         ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Read V0 .. VX from [I] .. [I+X]
             #FX55  LD    [I], VX         ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Store V0 .. VX in [I] .. [I+X]
             #00FE  LOW                   ; SCHIP10, SCHIP11
                                          ; Disable extended screen mode
             #8XY1  OR    VX, VY          ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set VX = VX | VY, VF updates
             #00EE  RET                   ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Return from subroutine (16 levels)
             #CXKK  RND   VX , Byte       ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set VX = random & Byte
             #00CN  SCD   Nibble          ; SCHIP11
                                          ; Scroll screen Nibble lines down
             #00FC  SCL                   ; SCHIP11
                                          ; Scroll screen 4 pixels left
             #00FB  SCR                   ; SCHIP11
                                          ; Scroll screen 4 pixels right
             #3XKK  SE    VX, Byte        ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Skip next instruction if VX == Byte
             #5XY0  SE    VX, VY          ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Skip next instruction if VX == VY
             #8XYE  SHL   VX {, VY}       ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set VX = VX << 1, VF = carry
             #8XY6  SHR   VX {, VY}       ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set VX = VX >> 1, VF = carry
             #EX9E  SKP   VX              ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Skip next instruction if key VX down
             #EXA1  SKNP  VX              ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Skip next instruction if key VX up
             #4XKK  SNE   VX, Byte        ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Skip next instruction if VX != Byte
             #9XY0  SNE   VX, VY          ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Skip next instruction if VX != VY
             #8XY5  SUB   VX, VY          ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set VX = VX - VY, VF = !borrow
             #8XY7  SUBN  VX, VY          ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set VX = VY - VX, VF = !borrow
             #0NNN  SYS   Addr            ; CHIP8
                                          ; Call CDP1802 code at Addr. This
                                          ; is not implemented on emulators
             #8XY3  XOR   VX, VY          ; CHIP8, CHIP48, SCHIP10, SCHIP11
                                          ; Set VX = VX ^ VY, VF updates

         */

        /**
         * OPCODES[command] -> Opcode
         */
        private static const OPCODES:Object = Opcode.LIST;

        private var _tokens:Array /*Token*/ = [];
        /**
         * _labels[labelName] = label address
         */
        private var _labels:Object /*String*/ = {};

        private var _lineIndex:int = -1;

        private static const EMPTY_STRING     :String = "";
        private static const WHITE_SPACES_TRIM:RegExp = /^\s+|\s+$/g;
        private static const LINE_BREAK       :RegExp = /\n/g;
        private var _data:ByteArray;

        public function Assembler()
        {
            super();
        }

        public function assemble(value:String):ByteArray
        {
            if (value)
            {
                // trim white spaces
                value = StringUtil.trim(value);
                var list:Array /* String */ = value.split(LINE_BREAK);
                var tokens:Array = [];

                for (_lineIndex = 0;_lineIndex<list.length;++_lineIndex)
                {
                    var // trim string
                    line:String = StringUtil.trim(list[_lineIndex] as String);
                    // remove comment
                    var index:int = line.indexOf(TokenType.COMMENT);
                    if (index !== -1)
                    {
                        line = index > 0 ? line.substring(0, index) : "";
                    }
                    if (line && line.length > 1)
                    {
                        // check is a label
                        index = line.indexOf(TokenType.LABEL);
                        if (index !== -1)
                        {
                            var label:String = line.substring(0, index);
                            validateLabelName(label);

                            _labels[label] = ENTRY_POINT + 2 * tokens.length;

                            //tokens[tokens.length] = new Token(TokenType.LABEL, label);

                            continue;
                        }
                        var command:String = "";
                        var args:String = "";
                        // check command and args
                        index = line.indexOf(TokenType.COMMAND_SEPARATOR);
                        if (index !== -1)
                        {
                            command = line.substring(0, index).toLowerCase();
                            args = line.substring(index + 1, line.length);
                        }
                        else
                        {
                            // иначе это все комманда
                            command = line.toLowerCase();
                        }

                        tokens[tokens.length] = new Token(TokenType.COMMAND, getOpcodeInfo(command, args));
                        continue;
                    }

                    if (line && line.length > 0)
                    {
                        throw "Unknown code line: " + line;
                    }
                }

                trace("Tokenization completed");
            }

            if (!value || value.length < 3)
            {
                throw "Can't compile empty project";
            }

            build(tokens);
            return _data;
        }

        /**
         * Создать билд
         */
        private function build(value:Array/*Token*/):void
        {
            _data = new ByteArray();

            trace("Build started: ------------------");
            var build:String = "";

            for (var i:int = 0;i<value.length;++i)
            {
                var token:Token = value[i];
                if (token && token.type === TokenType.COMMAND)
                {
                    var opcode:Opcode = token.value.shift() as Opcode;

                    // replace label to Addr
                    var args:Array = token.value as Array;
                    for (var j:int = 0;j<args.length;++j)
                    {
                        var arg:String = args[j] as String;
                        if (arg && arg in _labels)
                        {
                            args[j] = _labels[arg];
                        }
                    }

                    var word:int = opcode.encode(args);
                    build+= word.toString(16) + " ";

                    if ((i + 1) % 6 === 0) build+= "\n";

                    _data.writeShort(word);
                }
            }

            trace(build);
            trace("End build")
        }

        /**
         * Return true if value is a valid label name
         * @param value
         * @return
         */
        private function validateLabelName(value:String):void
        {
            if (value && value.length > 0)
            {
                var char:String = value.charAt(0);
                if (StringUtil.isDigit(char))
                {
                    throw "Invalid label name. Label name shouldn't starts with a digit (" + _lineIndex + ": 0)";
                }
                for (var i:int = 0;i<value.length;++i)
                {
                    char = value.charAt(i);
                    if (char < "A" || char > "z")
                    {
                        throw "Invalid label name. Label name shouldn't contains invalid char \"" + char + "\" (" + _lineIndex + ": " + i + ")";
                    }
                    else
                    if (char > "a" && char < "Z")
                    {
                        throw "Invalid label name. Label name shouldn't contains invalid char \"" + char + "\" (" + _lineIndex + ": " + i + ")";
                    }
                }
            }
        }

        /**
         * Возвращает информацию об опкоде
         * @param command
         * @param params
         * @return
         */
        private function getOpcodeInfo(command:String, params:String):Array /* [Opcode, ...args]*/
        {
            var opcodes:Array /*Opcode*/ = OPCODES[command] as Array;
            if (opcodes && opcodes.length > 0)
            {
                // split & trim args
                var args:Array = params.split(TokenType.ARGS_SEPARATOR);
                for (var i:int = 0;i<args.length;++i)
                {
                    args[i] = StringUtil.trim(args[i] as String);
                }

                // search for a appropriate opcode
                for (var i:int = 0;i<opcodes.length;++i)
                {
                    var opcode:Opcode = opcodes[i] as Opcode;
                    if (opcode && opcode.validateArgs(args))
                    {
                        args.unshift(opcode);
                        return args;
                    }
                }
                throw "Invalid arguments found \"" + params + "\" (" + _lineIndex + ")";
            }
            else
            {
                throw "Unknown command found \"" + command + "\" (" + _lineIndex + ")";
            }
        }
    }
}