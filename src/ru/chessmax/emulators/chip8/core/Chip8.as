/**
 * Created by ChessMax on 28.04.2014.
 */
package ru.chessmax.emulators.chip8.core
{
    import ru.chessmax.emulators.chip8.util.ArrayUtil;

    /**
     * Эмулятор процессора
     * Created 28.04.2014
     * Version 1.0
     * Copyright (c) 2014
     * @author ChessMax (www.chessmax.ru)
     */
    public class Chip8
    {
        private static const FONT_SET:Array =
        [
            0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
            0x20, 0x60, 0x20, 0x20, 0x70, // 1
            0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
            0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
            0x90, 0x90, 0xF0, 0x10, 0x10, // 4
            0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
            0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
            0xF0, 0x10, 0x20, 0x40, 0x40, // 7
            0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
            0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
            0xF0, 0x90, 0xF0, 0x90, 0x90, // A
            0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
            0xF0, 0x80, 0x80, 0x80, 0xF0, // C
            0xE0, 0x90, 0x90, 0x90, 0xE0, // D
            0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
            0xF0, 0x80, 0xF0, 0x80, 0x80  // F
        ];

        /**
         * Память
         */
        private var _memory:IMemory;
        /**
         * Экран
         */
        private var _display:IDisplay;
        /**
         * 8 битные регистры
         */
        private var _V:Array /*Byte*/;

        /**
         * Индекс регистр 0x000 to 0xFFF
         */
        private var _I:uint = 0;
        /**
         * Program counter 0x000 to 0xFFF
         */
        private var _PC:uint = 0;

        private var _delayTimer:uint;
        private var _soundTimer:uint;

        private var _sp:uint;
        private var _key:Array;
        private var _stack:Array;

        /**
         * Текущий опкод
         */
        private var _opcode:uint;

        public function Chip8(memory:IMemory, display:IDisplay)
        {
            super();

            _memory = memory;
            _display = display;

            _V = ArrayUtil.zeroFill(new Array(16));
            _key = ArrayUtil.zeroFill(new Array(16));
            _stack = ArrayUtil.zeroFill(new Array(16));

            initialize();
        }

        private function initialize():void
        {
            _PC = 0x200;
            _I = 0;
            _opcode = 0;
            _sp = 0;

            _display.clear();
            ArrayUtil.zeroFill(_stack);
            ArrayUtil.zeroFill(_V);
            _memory.clear();

            // загружаем шрифт
            for (var i:int = 0;i<FONT_SET.length;++i)
            {
                _memory.writeByte(i, FONT_SET[i]);
            }

            _delayTimer = 0;
            _soundTimer = 0;
        }

        private var _index:uint;

        /**
         *
         */
        public function step():void
        {
            ++_index;

            var X:int;
            var Y:int;
            var t:int;

            // получаем текущий опкод
            _opcode = _memory.readByte(_PC) << 8 | _memory.readByte(_PC + 1);

            if (_opcode === 0xF775)
            {
                _PC+= 42;
                return;
            }

            // декодируем

            if (_opcode === 0x00E0)//Clears the screen.
            {
                _display.clear ();
                _display.unlock();
                _PC += 2;
            }
            else
            if (_opcode === 0x00EE)//Returns from a subroutine.
            {
                --_sp;
                _PC = _stack[_sp];
                _PC += 2;
            }
            else
            {
                switch(_opcode & 0xF000)
                {
                    // Some opcodes //

                    case 0x1000://1NNN Jumps to address NNN.
                    {
                        _PC = _opcode & 0x0FFF;
                        break;
                    }

                    case 0x2000://2NNN Calls subroutine at NNN.
                    {
                        _stack[_sp] = _PC;
                        ++_sp;
                        _PC = _opcode & 0x0FFF;
                        break;
                    }

                    case 0x3000://3XNN Skips the next instruction if VX equals NN.
                    {
                        X = (_opcode & 0x0F00) >> 8;
                        _PC += (_V[X] === (_opcode & 0x00FF)) ? 4 : 2;
                        break;
                    }

                    case 0x4000: //4XNN	Skips the next instruction if VX doesn't equal NN.
                    {
                        X = (_opcode & 0x0F00) >> 8;
                        _PC+= (_V[X] !== (_opcode & 0x00FF)) ? 4 : 2;

                        break;
                    }

                    case 0x5000: //5XY0	Skips the next instruction if VX equals VY.
                    {
                        X = (_opcode & 0x0F00) >> 8;
                        Y = (_opcode & 0x00F0) >> 4;

                        _PC+= (_V[X] === _V[Y]) ? 4 : 2;
                        break;
                    }

                    case 0x6000: //6XNN	Sets VX to NN.
                    {
                        X = (_opcode & 0x0F00) >> 8;
                        _V[X] = _opcode & 0x00FF;
                        _PC+= 2;
                        break;
                    }

                    case 0x7000: //7XNN	Adds NN to VX.
                    {
                        X = (_opcode & 0x0F00) >> 8;
                        t = _V[X] + (_opcode & 0x00FF);

                        t%= 256;

                        _V[X] = t;

                        _PC+= 2;
                        break;
                    }

                    case 0x8000:
                        switch (_opcode & 0x000F)
                        {
                            case 0x0000://8XY0	Sets VX to the value of VY.
                            {
                                X = (_opcode & 0x0F00) >> 8;
                                Y = (_opcode & 0x00F0) >> 4;

                                _V[X] = _V[Y];
                                _PC+= 2;

                                break;
                            }

                            case 0x0001: //8XY1	Sets VX to VX or VY.
                            {
                                X = (_opcode & 0x0F00) >> 8;
                                Y = (_opcode & 0x00F0) >> 4;

                                _V[X] |= _V[Y];

                                _PC+= 2;

                                break;
                            }

                            case 0x0002://8XY2	Sets VX to VX and VY.
                            {
                                X = (_opcode & 0x0F00) >> 8;
                                Y = (_opcode & 0x00F0) >> 4;

                                _V[X] &= _V[Y];

                                _PC+= 2;

                                break;
                            }

                            case 0x0003://Sets VX to VX xor VY.
                            {
                                X = (_opcode & 0x0F00) >> 8;
                                Y = (_opcode & 0x00F0) >> 4;

                                _V[X] ^= _V[Y];

                                _PC+= 2;

                                break;
                            }

                            case 0x0004://Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.
                            {
                                X = (_opcode & 0x0F00) >> 8;
                                Y = (_opcode & 0x00F0) >> 4;

                                t = _V[X] + _V[Y];

                                _V[0xF] = t > 255 ? 1 : 0;
                                t%= 256;

                                _V[X] = t;

                                _PC+= 2;

                                break;
                            }

                            case 0x0005://8XY5	VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
                            {
                                X = (_opcode & 0x0F00) >> 8;
                                Y = (_opcode & 0x00F0) >> 4;

                                t = _V[X] - _V[Y];

                                if (t < 0)
                                {
                                    _V[0xF] = 0;
                                    t = t + 256;
                                }
                                else
                                {
                                    _V[0xF] = 1;
                                }

                                _V[X] = t;

                                _PC+= 2;

                                break;
                            }

                            case 0x0006://8XY6	Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift.[2]
                            {
                                X = (_opcode & 0x0F00) >> 8;
                                Y = (_opcode & 0x00F0) >> 4;

                                _V[0xF] = _V[X] & 0x1;

                                _V[X] = _V[X] >> 1;

                                _PC+= 2;

                                break;
                            }

                            case 0x0007://8XY7	Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
                            {
                                X = (_opcode & 0x0F00) >> 8;
                                Y = (_opcode & 0x00F0) >> 4;

                                t = _V[Y] - _V[X];

                                if (t < 0)
                                {
                                    t = 256 + t;
                                    _V[0xF] = 0;
                                }
                                else
                                {
                                    _V[0xF] = 1;
                                }

                                _V[X] = t;

                                _PC+= 2;

                                break;
                            }

                            case 0x000E://8XYE	Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift.[2]
                            {
                                X = (_opcode & 0x0F00) >> 8;
                                //Y = (_opcode & 0x00F0) >> 4;

                                t = _V[X];
                                _V[0xF] = t >> 7;

                                t = t << 1;
                                t%= 256;
                                _V[X] = t;

                                _PC+= 2;

                                break;
                            }

                            default:
                                trace ("Unknown opcode: 0x" + _opcode.toString(16));
                        }
                    break;

                    case 0x9000://9XY0	Skips the next instruction if VX doesn't equal VY.
                    {
                        X = (_opcode & 0x0F00) >> 8;
                        Y = (_opcode & 0x00F0) >> 4;

                        if (_V[X] !== _V[Y])
                        {
                            _PC+= 4;
                        }
                        else
                        {
                            _PC+= 2;
                        }

                        break;
                    }

                    case 0xA000: // ANNN: Sets I to the address NNN
                        // Execute opcode
                        _I = _opcode & 0x0FFF;
                        _PC += 2;
                        break;

                    case 0xB000://BNNN	Jumps to the address NNN plus V0.
                    {
                        _PC = _opcode & 0x0FFF + _V[0];
                        break;
                    }

                    case 0xC000://CXNN	Sets VX to a random number and NN.
                    {
                        X = (_opcode & 0x0F00) >> 8;
                        _V[X] = (int(Math.random() * 256)) & (_opcode & 0x00FF);

                        _PC+= 2;
                        break;
                    }

                    case 0xD000://DXYN	Draws a sprite at coordinate (VX, VY)
                                // that has a width of 8 pixels and a height of N pixels.
                                // Each row of 8 pixels is read as bit-coded
                                // (with the most significant bit of each byte displayed on the left)
                                // starting from memory location I; I value doesn't change
                                // after the execution of this instruction. As described above,
                                // VF is set to 1 if any screen pixels are flipped from set to unset
                                // when the sprite is drawn, and to 0 if that doesn't happen.
                    {
                        var x:uint = _V[(_opcode & 0x0F00) >> 8];
                        var y:uint = _V[(_opcode & 0x00F0) >> 4];
                        var height = _opcode & 0x000F;
                        var pixel:uint;

                        _V[0xF] = 0;
                        for (var yline:int = 0; yline < height; yline++)
                        {
                            pixel = _memory.readByte(_I + yline);
                            for(var xline:int = 0; xline < 8; xline++)
                            {
                                if((pixel & (0x80 >> xline)) != 0)
                                {
                                    if (_display.readByte((x + xline + ((y + yline) * 64))) === 1)
                                    {
                                        _V[0xF] = 1;
                                    }
                                    _display.writeByte(
                                        x + xline + ((y + yline) * 64),
                                        _display.readByte(x + xline + ((y + yline) * 64)) ^ 1);
                                }
                            }
                        }

                        _display.unlock();
                        _PC += 2;

                        break;
                    }

                    case 0xE000://EX9E	Skips the next instruction if the key stored in VX is pressed.
                        switch(_opcode & 0x00FF)
                        {
                            case 0x009E: // EX9E: Skips the next instruction if the key stored in VX is pressed
                                if(_key[_V[(_opcode & 0x0F00) >> 8]] != 0)
                                    _PC += 4;
                                else
                                    _PC += 2;
                                break;

                            case 0x00A1: // EXA1: Skips the next instruction if the key stored in VX isn't pressed
                                if(_key[_V[(_opcode & 0x0F00) >> 8]] == 0)
                                    _PC += 4;
                                else
                                    _PC += 2;
                                break;

                            default:
                                trace ("Unknown opcode: 0x" + _opcode.toString(16));
                        }
                        break;

                    case 0xF000:
                        switch (_opcode & 0x00FF)
                        {
                            case 0x0007://FX07	Sets VX to the value of the delay timer.
                            {
                                X = (_opcode & 0x0F00) >> 8;
                                _V[X] = _delayTimer;
                                _PC+=2;

                                break;
                            }

                            case 0x000A: // FX0A: A key press is awaited, and then stored in VX
                            {
                                var keyPress:Boolean = false;

                                for(var i:int = 0; i < 16; ++i)
                                {
                                    if(_key[i] != 0)
                                    {
                                        _V[(_opcode & 0x0F00) >> 8] = i;
                                        keyPress = true;
                                    }
                                }

                                // If we didn't received a keypress, skip this cycle and try again.
                                if(!keyPress)
                                    return;

                                _PC += 2;
                                break;
                            }

                            case 0x0015://FX15	Sets the delay timer to VX.
                            {
                                X = (_opcode & 0x0F00) >> 8;
                                _delayTimer = _V[X];
                                _PC+=2;
                                break;
                            }

                            case 0x0018://FX18	Sets the sound timer to VX.
                            {
                                X = (_opcode & 0x0F00) >> 8;
                                _soundTimer = _V[X];
                                _PC+=2;
                                break;
                            }

                            case 0x001E://FX1E	Adds VX to I.[3]VF is set to 1 when range overflow (I+VX>0xFFF), and 0 when there isn't.
                            {
                                X = (_opcode & 0x0F00) >> 8;
                                if (_I + _V[X] > 0xFFF)
                                {
                                    _V[0xF] = 1;
                                    _I+= _V[X];
                                    _I%=0xFFF;
                                }
                                else
                                {
                                    _V[0xF] = 0;
                                    _I+= _V[X];
                                }
                                _PC+= 2;
                                break;
                            }

                            case 0x0029://FX29	Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.
                            {
                                X = (_opcode & 0x0F00) >> 8;
                                _I = _V[X] * 0x5;
                                _PC += 2;
                                break;
                            }

                            case 0x0033: // FX33: Stores the Binary-coded decimal representation of VX at the addresses I, I plus 1, and I plus 2
                                _memory.writeByte(_I, _V[(_opcode & 0x0F00) >> 8] / 100);
                                _memory.writeByte(_I + 1, (_V[(_opcode & 0x0F00) >> 8] / 10) % 10);
                                _memory.writeByte(_I + 2, (_V[(_opcode & 0x0F00) >> 8] % 100) % 10);
                                _PC += 2;
                                break;

                            case 0x0055: // FX55: Stores V0 to VX in memory starting at address I
                                for (var i:int = 0; i <= ((_opcode & 0x0F00) >> 8); ++i)
                                {
                                    _memory.writeByte(_I + i, _V[i]);
                                }

                                // On the original interpreter, when the operation is done, I = I + X + 1.
                                _I += ((_opcode & 0x0F00) >> 8) + 1;
                                _PC += 2;
                                break;

                            case 0x0065: // FX65: Fills V0 to VX with values from memory starting at address I
                                for (var i:int = 0; i <= ((_opcode & 0x0F00) >> 8); ++i)
                                {
                                    _V[i] = _memory.readByte(_I + i);
                                }

                                // On the original interpreter, when the operation is done, I = I + X + 1.
                                _I += ((_opcode & 0x0F00) >> 8) + 1;
                                _PC += 2;
                                break;
                            default:
                                trace ("Unknown opcode: 0x" + _opcode.toString(16))
                        }
                    break;

                    default:
                        trace ("Unknown opcode: 0x" + _opcode.toString(16));
                }
            }

            if (_PC > 0xFFF)
            {
                _PC-= 0xFFF;
            }
            if (_I > 0xFFF)
            {
                _I-= 0xFFF;
            }

            // обновляем таймер
            if (_delayTimer > 0)
            {
                --_delayTimer;
            }

            if (_soundTimer > 0)
            {
                if (_soundTimer === 1)
                {
                    trace("Beep");
                }
                --_soundTimer;
            }
        }

        public function clear():void
        {

        }

        public function setKeyState(key:int, state:int):void
        {
            _key[key] = state;
        }
    }
}
