/**
 * Created by ChessMax on 28.04.2014.
 */
package ru.chessmax.emulators.chip8.core
{
    import flash.display.Bitmap;
    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.ByteArray;
    import flash.utils.Timer;

    import ru.chessmax.emulators.chip8.core.impl.Display;
    import ru.chessmax.emulators.chip8.core.impl.Memory;

    /**
     * Виртуальная машина
     * Created 28.04.2014
     * Version 1.0
     * Copyright (c) 2014
     * @author ChessMax (www.chessmax.ru)
     */
    public class Chip8VM
    {
        private var _frames:uint;
        private var _timer:Timer;
        private var _memory:IMemory;
        private var _display:IDisplay;
        private var _processor:Chip8;

        public function Chip8VM(displayRenderer:Bitmap)
        {
            super();

            _memory = new Memory();
            _display = new Display(displayRenderer);
            _processor = new Chip8(_memory, _display);

            initialize();
        }

        /**
         * Инициализация
         */
        private function initialize():void
        {
            //_memory.clear();
            _display.clear();
            _processor.clear();
        }

        /**
         * Загрузить программу в память
         * @param value
         */
        public function load(value:ByteArray):void
        {
            value.position = 0;

            while (value.position < value.length)
            {
                _memory.writeByte(0x200 + value.position, value.readUnsignedByte());
            }
            trace("loaded");
            start();
        }

        /**
         * Запустить виртуальную машину
         */
        public function start():void
        {
            _timer = new Timer(0);
            _timer.addEventListener(TimerEvent.TIMER, onTimer);
            _timer.start();
        }

        /**
         * Обработчик таймера
         * @param e
         */
        private function onTimer(e:Event):void
        {
            ++_frames;
            _processor.step();
            _processor.step();

//            if (_frames % 5 === 0)
//            {
//                _processor.step();
//                _processor.step();
//            }
        }

        public function setKeyState(key:int, state:int):void
        {
            _processor.setKeyState(key, state);
        }
    }
}
