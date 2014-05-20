package ru.chessmax.emulators.chip8
{

    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.KeyboardEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.ui.Keyboard;
    import flash.utils.ByteArray;

    import ru.chessmax.emulators.chip8.asm.Assembler;
    import ru.chessmax.emulators.chip8.core.Chip8;

    import ru.chessmax.emulators.chip8.core.Chip8VM;

    public class Main extends Sprite
    {
        [Embed("assets/pong2.c8", mimeType="application/octet-stream")]
        private static const C8_PONG2:Class;

        [Embed("assets/invaders.c8", mimeType="application/octet-stream")]
        private static const C8_INVADERS:Class;

        [Embed("assets/tetris.c8", mimeType="application/octet-stream")]
        private static const C8_TETRIS:Class;

        [Embed("assets/BRIX", mimeType="application/octet-stream")]
        private static const C8_BRIX:Class;

        [Embed("assets/SCTEST", mimeType="application/octet-stream")]
        private static const C8_TEST:Class;

        [Embed("assets/Division Test [Sergey Naydenov, 2010].ch8", mimeType="application/octet-stream")]
        private static const C8_DIVISION_TEST:Class;

        [Embed("assets/Tank.ch8", mimeType="application/octet-stream")]
        private static const C8_TANK:Class;

        private var _debug:TextField;

        private var _vm:Chip8VM;
        private var _display:Bitmap;

        public function Main()
        {
            super();

            stage.frameRate = 60;
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

            _display = new Bitmap();
            addChild(_display);
            _display.x = 100;
            _display.y = 100;
            _display.scaleX = _display.scaleY = 10;
            _vm = new Chip8VM(_display);

            _debug = new TextField();
            _debug.autoSize = TextFieldAutoSize.LEFT;
            addChild(_debug);
            _debug.x = _display.x;
            _debug.y = _display.y + _display.height + 5;

//           trace((524-2).toString(16));
//            trace((0x200 + 16 * 7).toString(16));
//            return;

            var x:int = 3;

            var
            simple:ByteArray = new ByteArray();
            simple.writeShort(0x00E0);//cls
            simple.writeShort(0x650F);//	Sets VX to NN.)
            simple.writeShort(0xF529);//	Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.)
            simple.writeShort(0x6005);//	V0 - x
            simple.writeShort(0x6105);//	V1 - y
            simple.writeShort(0xD015);//	Draws a sprite at coordinate (VX, VY) that has a width of 8 pixels and a height of N pixels. Each row of 8 pixels is read as bit-coded (with the most significant bit of each byte displayed on the left) starting from memory location I; I value doesn't change after the execution of this instruction. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesn't happen.)
            simple.writeShort(0x6000);//	V1 -
            var f:int = 0xB000 + 0x200 + simple.position - 2;
            trace(f);
            simple.writeShort(f);
            //simple.writeShort(0xB20c);//0x200 + 	Jumps to the address NNN plus V0.)
            trace(simple.position);
            simple.position = 0;
            trace(simple.length);

            var str:String = <![CDATA[
                ;main label
                main:
                ADD V5, 5
                ADD V5, V6
                add i, v5
                jp main
            ]]>;
            Chip8.DEBUG = function(value:Array, _I, _delayTimer, _soundTimer):void
            {
                _debug.text = "VX: " + value.map(function(a,...abc):String{a = a.toString(16);if(a.length<2)a = "0"+a;return a}).join(" ") + "\nI: " + _I.toString(16)+ "\nDT: " + _delayTimer.toString(16)+ "\nST: " + _soundTimer.toString(16);
            }
            _vm.load(new Assembler().assemble(str));
            return;

            simple = new ByteArray();
            simple.writeShort(0x6000);
            simple.writeShort(0x6100);
            simple.writeShort(0xA222);
            simple.writeShort(0xC201);
            simple.writeShort(0x3201);
            simple.writeShort(0xA2E1);
            simple.writeShort(0xD014);
            simple.writeShort(0x7004);
            simple.writeShort(0x3040);
            simple.writeShort(0x1204);
            simple.writeShort(0x6000);
            simple.writeShort(0x7104);
            simple.writeShort(0x3120);
            simple.writeShort(0x1204);
            simple.writeShort(0x121C);
            simple.writeShort(0x8040);
            simple.writeShort(0x2010);
            simple.writeShort(0x2040);
            simple.writeShort(0x8010);
            simple.writeShort(0x0000);

            _vm.load(new C8_PONG2());
        }

        private function onKeyDown(event:KeyboardEvent):void
        {
            var key:int = -1;
            switch (event.keyCode)
            {
                case Keyboard.NUMBER_1: key = 0x1;break;
                case Keyboard.NUMBER_2: key = 0x2;break;
                case Keyboard.NUMBER_3: key = 0x3;break;
                case Keyboard.NUMBER_4: key = 0xC;break;

                case Keyboard.Q: key = 0x4;break;
                case Keyboard.W: key = 0x5;break;
                case Keyboard.E: key = 0x6;break;
                case Keyboard.R: key = 0xD;break;

                case Keyboard.A: key = 0x7;break;
                case Keyboard.S: key = 0x8;break;
                case Keyboard.D: key = 0x9;break;
                case Keyboard.F: key = 0xE;break;

                case Keyboard.Z: key = 0xA;break;
                case Keyboard.X: key = 0x0;break;
                case Keyboard.C: key = 0xB;break;
                case Keyboard.V: key = 0xF;break;
            }

            if (key !== -1)
            {
                _vm.setKeyState(key, 1);
            }
        }

        private function onKeyUp(event:KeyboardEvent):void
        {
            var key:int = -1;
            switch (event.keyCode)
            {
                case Keyboard.NUMBER_1: key = 0x1;break;
                case Keyboard.NUMBER_2: key = 0x2;break;
                case Keyboard.NUMBER_3: key = 0x3;break;
                case Keyboard.NUMBER_4: key = 0xC;break;

                case Keyboard.Q: key = 0x4;break;
                case Keyboard.W: key = 0x5;break;
                case Keyboard.E: key = 0x6;break;
                case Keyboard.R: key = 0xD;break;

                case Keyboard.A: key = 0x7;break;
                case Keyboard.S: key = 0x8;break;
                case Keyboard.D: key = 0x9;break;
                case Keyboard.F: key = 0xE;break;

                case Keyboard.Z: key = 0xA;break;
                case Keyboard.X: key = 0x0;break;
                case Keyboard.C: key = 0xB;break;
                case Keyboard.V: key = 0xF;break;
            }

            if (key !== -1)
            {
                _vm.setKeyState(key, 0);
            }
        }
    }
}
