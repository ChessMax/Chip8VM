/**
 * Created by ChessMax on 30.04.2014.
 */
package ru.chessmax.emulators.chip8.asm
{
    /**
     *
     * Created 30.04.2014
     * Version 1.0
     * Copyright (c) 2014
     * @author ChessMax (www.chessmax.ru)
     */
    public class Assembler
    {
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

        private var _tokens:Array /*Token*/ = [];
        /**
         * _labels[labelName] = label address
         */
        private var _labels:Object /*String*/ = {};

        public function Assembler()
        {
            super();
        }

        public function assemble(value:String):void
        {
            if (!value || value.length < 3)
            {
                throw "Can't compile empty project";
            }

            var index:uint = 0;
            do
            {
                var char:String = value.charAt(index);
                switch (char)
                {
                    case ";"://ignore line comment
                        ++index;
                        while (index < value.length)
                        {
                            char = value.charAt(index++);
                            if (char === "\n" || char === "\r")
                            {
                                break;
                            }
                        }
                    break;

                    
                }
            }
            while (true)
        }
    }
}

class Token
{
    private var _name:String;
    private var _args:Array;

    public function Token(name:String, args:Array = null)
    {
        super();
        _name = name;
        _args = args;
    }
}