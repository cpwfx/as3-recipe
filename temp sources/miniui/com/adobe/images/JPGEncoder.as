//class JPGEncoder
package com.adobe.images 
{
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.*;
    
    public class JPGEncoder extends Object
    {
        public function JPGEncoder(arg1:Number=50)
        {
            ZigZag = [0, 1, 5, 6, 14, 15, 27, 28, 2, 4, 7, 13, 16, 26, 29, 42, 3, 8, 12, 17, 25, 30, 41, 43, 9, 11, 18, 24, 31, 40, 44, 53, 10, 19, 23, 32, 39, 45, 52, 54, 20, 22, 33, 38, 46, 51, 55, 60, 21, 34, 37, 47, 50, 56, 59, 61, 35, 36, 48, 49, 57, 58, 62, 63];
            YTable = new Array(64);
            UVTable = new Array(64);
            fdtbl_Y = new Array(64);
            fdtbl_UV = new Array(64);
            std_dc_luminance_nrcodes = [0, 0, 1, 5, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0];
            std_dc_luminance_values = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
            std_ac_luminance_nrcodes = [0, 0, 2, 1, 3, 3, 2, 4, 3, 5, 5, 4, 4, 0, 0, 1, 125];
            std_ac_luminance_values = [1, 2, 3, 0, 4, 17, 5, 18, 33, 49, 65, 6, 19, 81, 97, 7, 34, 113, 20, 50, 129, 145, 161, 8, 35, 66, 177, 193, 21, 82, 209, 240, 36, 51, 98, 114, 130, 9, 10, 22, 23, 24, 25, 26, 37, 38, 39, 40, 41, 42, 52, 53, 54, 55, 56, 57, 58, 67, 68, 69, 70, 71, 72, 73, 74, 83, 84, 85, 86, 87, 88, 89, 90, 99, 100, 101, 102, 103, 104, 105, 106, 115, 116, 117, 118, 119, 120, 121, 122, 131, 132, 133, 134, 135, 136, 137, 138, 146, 147, 148, 149, 150, 151, 152, 153, 154, 162, 163, 164, 165, 166, 167, 168, 169, 170, 178, 179, 180, 181, 182, 183, 184, 185, 186, 194, 195, 196, 197, 198, 199, 200, 201, 202, 210, 211, 212, 213, 214, 215, 216, 217, 218, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250];
            std_dc_chrominance_nrcodes = [0, 0, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0];
            std_dc_chrominance_values = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
            std_ac_chrominance_nrcodes = [0, 0, 2, 1, 2, 4, 4, 3, 4, 7, 5, 4, 4, 0, 1, 2, 119];
            std_ac_chrominance_values = [0, 1, 2, 3, 17, 4, 5, 33, 49, 6, 18, 65, 81, 7, 97, 113, 19, 34, 50, 129, 8, 20, 66, 145, 161, 177, 193, 9, 35, 51, 82, 240, 21, 98, 114, 209, 10, 22, 36, 52, 225, 37, 241, 23, 24, 25, 26, 38, 39, 40, 41, 42, 53, 54, 55, 56, 57, 58, 67, 68, 69, 70, 71, 72, 73, 74, 83, 84, 85, 86, 87, 88, 89, 90, 99, 100, 101, 102, 103, 104, 105, 106, 115, 116, 117, 118, 119, 120, 121, 122, 130, 131, 132, 133, 134, 135, 136, 137, 138, 146, 147, 148, 149, 150, 151, 152, 153, 154, 162, 163, 164, 165, 166, 167, 168, 169, 170, 178, 179, 180, 181, 182, 183, 184, 185, 186, 194, 195, 196, 197, 198, 199, 200, 201, 202, 210, 211, 212, 213, 214, 215, 216, 217, 218, 226, 227, 228, 229, 230, 231, 232, 233, 234, 242, 243, 244, 245, 246, 247, 248, 249, 250];
            bitcode = new Array(65535);
            category = new Array(65535);
            DU = new Array(64);
            YDU = new Array(64);
            UDU = new Array(64);
            VDU = new Array(64);
            super();
            if (arg1 <= 0) 
            {
                arg1 = 1;
            }
            if (arg1 > 100) 
            {
                arg1 = 100;
            }
            var loc1:*=0;
            if (arg1 < 50) 
            {
                loc1 = int(5000 / arg1);
            }
            else 
            {
                loc1 = int(200 - arg1 * 2);
            }
            initHuffmanTbl();
            initCategoryNumber();
            initQuantTables(loc1);
            return;
        }

        internal function writeSOF0(arg1:int, arg2:int):void
        {
            writeWord(65472);
            writeWord(17);
            writeByte(8);
            writeWord(arg2);
            writeWord(arg1);
            writeByte(3);
            writeByte(1);
            writeByte(17);
            writeByte(0);
            writeByte(2);
            writeByte(17);
            writeByte(1);
            writeByte(3);
            writeByte(17);
            writeByte(1);
            return;
        }

        internal function initHuffmanTbl():void
        {
            YDC_HT = computeHuffmanTbl(std_dc_luminance_nrcodes, std_dc_luminance_values);
            UVDC_HT = computeHuffmanTbl(std_dc_chrominance_nrcodes, std_dc_chrominance_values);
            YAC_HT = computeHuffmanTbl(std_ac_luminance_nrcodes, std_ac_luminance_values);
            UVAC_HT = computeHuffmanTbl(std_ac_chrominance_nrcodes, std_ac_chrominance_values);
            return;
        }

        internal function writeDQT():void
        {
            var loc1:*=0;
            writeWord(65499);
            writeWord(132);
            writeByte(0);
            loc1 = 0;
            while (loc1 < 64) 
            {
                writeByte(YTable[loc1]);
                ++loc1;
            }
            writeByte(1);
            loc1 = 0;
            while (loc1 < 64) 
            {
                writeByte(UVTable[loc1]);
                ++loc1;
            }
            return;
        }

        internal function RGB2YUV(arg1:flash.display.BitmapData, arg2:int, arg3:int):void
        {
            var loc3:*=0;
            var loc4:*=0;
            var loc5:*=NaN;
            var loc6:*=NaN;
            var loc7:*=NaN;
            var loc1:*=0;
            var loc2:*=0;
            while (loc2 < 8) 
            {
                loc3 = 0;
                while (loc3 < 8) 
                {
                    loc4 = arg1.getPixel32(arg2 + loc3, arg3 + loc2);
                    loc5 = Number(loc4 >> 16 & 255);
                    loc6 = Number(loc4 >> 8 & 255);
                    loc7 = Number(loc4 & 255);
                    YDU[loc1] = 0.299 * loc5 + 0.587 * loc6 + 0.114 * loc7 - 128;
                    UDU[loc1] = -0.16874 * loc5 + -0.33126 * loc6 + 0.5 * loc7;
                    VDU[loc1] = 0.5 * loc5 + -0.41869 * loc6 + -0.08131 * loc7;
                    ++loc1;
                    ++loc3;
                }
                ++loc2;
            }
            return;
        }

        internal function writeBits(arg1:com.adobe.images.BitString):void
        {
            var loc1:*=arg1.val;
            var loc2:*=(arg1.len - 1);
            while (loc2 >= 0) 
            {
                if (loc1 & uint(1 << loc2)) 
                {
                    bytenew = bytenew | uint(1 << bytepos);
                }
                --loc2;
                var loc3:*;
                bytepos--;
                if (!(bytepos < 0)) 
                {
                    continue;
                }
                if (bytenew != 255) 
                {
                    writeByte(bytenew);
                }
                else 
                {
                    writeByte(255);
                    writeByte(0);
                }
                bytepos = 7;
                bytenew = 0;
            }
            return;
        }

        internal function computeHuffmanTbl(arg1:Array, arg2:Array):Array
        {
            var loc5:*=0;
            var loc1:*=0;
            var loc2:*=0;
            var loc3:*=new Array();
            var loc4:*=1;
            while (loc4 <= 16) 
            {
                loc5 = 1;
                while (loc5 <= arg1[loc4]) 
                {
                    loc3[arg2[loc2]] = new com.adobe.images.BitString();
                    loc3[arg2[loc2]].val = loc1;
                    loc3[arg2[loc2]].len = loc4;
                    ++loc2;
                    ++loc1;
                    ++loc5;
                }
                loc1 = loc1 * 2;
                ++loc4;
            }
            return loc3;
        }

        internal function fDCTQuant(arg1:Array, arg2:Array):Array
        {
            var loc1:*=NaN;
            var loc2:*=NaN;
            var loc3:*=NaN;
            var loc4:*=NaN;
            var loc5:*=NaN;
            var loc6:*=NaN;
            var loc7:*=NaN;
            var loc8:*=NaN;
            var loc9:*=NaN;
            var loc10:*=NaN;
            var loc11:*=NaN;
            var loc12:*=NaN;
            var loc13:*=NaN;
            var loc14:*=NaN;
            var loc15:*=NaN;
            var loc16:*=NaN;
            var loc17:*=NaN;
            var loc18:*=NaN;
            var loc19:*=NaN;
            var loc20:*=0;
            var loc21:*=0;
            loc20 = 0;
            while (loc20 < 8) 
            {
                loc1 = arg1[loc21 + 0] + arg1[loc21 + 7];
                loc8 = arg1[loc21 + 0] - arg1[loc21 + 7];
                loc2 = arg1[loc21 + 1] + arg1[loc21 + 6];
                loc7 = arg1[loc21 + 1] - arg1[loc21 + 6];
                loc3 = arg1[loc21 + 2] + arg1[loc21 + 5];
                loc6 = arg1[loc21 + 2] - arg1[loc21 + 5];
                loc4 = arg1[loc21 + 3] + arg1[loc21 + 4];
                loc5 = arg1[loc21 + 3] - arg1[loc21 + 4];
                loc9 = loc1 + loc4;
                loc12 = loc1 - loc4;
                loc10 = loc2 + loc3;
                loc11 = loc2 - loc3;
                arg1[loc21 + 0] = loc9 + loc10;
                arg1[loc21 + 4] = loc9 - loc10;
                loc13 = (loc11 + loc12) * 0.707106781;
                arg1[loc21 + 2] = loc12 + loc13;
                arg1[loc21 + 6] = loc12 - loc13;
                loc9 = loc5 + loc6;
                loc10 = loc6 + loc7;
                loc11 = loc7 + loc8;
                loc17 = (loc9 - loc11) * 0.382683433;
                loc14 = 0.5411961 * loc9 + loc17;
                loc16 = 1.306562965 * loc11 + loc17;
                loc15 = loc10 * 0.707106781;
                loc18 = loc8 + loc15;
                loc19 = loc8 - loc15;
                arg1[loc21 + 5] = loc19 + loc14;
                arg1[loc21 + 3] = loc19 - loc14;
                arg1[loc21 + 1] = loc18 + loc16;
                arg1[loc21 + 7] = loc18 - loc16;
                loc21 = loc21 + 8;
                ++loc20;
            }
            loc21 = 0;
            loc20 = 0;
            while (loc20 < 8) 
            {
                loc1 = arg1[loc21 + 0] + arg1[loc21 + 56];
                loc8 = arg1[loc21 + 0] - arg1[loc21 + 56];
                loc2 = arg1[loc21 + 8] + arg1[loc21 + 48];
                loc7 = arg1[loc21 + 8] - arg1[loc21 + 48];
                loc3 = arg1[loc21 + 16] + arg1[loc21 + 40];
                loc6 = arg1[loc21 + 16] - arg1[loc21 + 40];
                loc4 = arg1[loc21 + 24] + arg1[loc21 + 32];
                loc5 = arg1[loc21 + 24] - arg1[loc21 + 32];
                loc9 = loc1 + loc4;
                loc12 = loc1 - loc4;
                loc10 = loc2 + loc3;
                loc11 = loc2 - loc3;
                arg1[loc21 + 0] = loc9 + loc10;
                arg1[loc21 + 32] = loc9 - loc10;
                loc13 = (loc11 + loc12) * 0.707106781;
                arg1[loc21 + 16] = loc12 + loc13;
                arg1[loc21 + 48] = loc12 - loc13;
                loc9 = loc5 + loc6;
                loc10 = loc6 + loc7;
                loc11 = loc7 + loc8;
                loc17 = (loc9 - loc11) * 0.382683433;
                loc14 = 0.5411961 * loc9 + loc17;
                loc16 = 1.306562965 * loc11 + loc17;
                loc15 = loc10 * 0.707106781;
                loc18 = loc8 + loc15;
                loc19 = loc8 - loc15;
                arg1[loc21 + 40] = loc19 + loc14;
                arg1[loc21 + 24] = loc19 - loc14;
                arg1[loc21 + 8] = loc18 + loc16;
                arg1[loc21 + 56] = loc18 - loc16;
                ++loc21;
                ++loc20;
            }
            loc20 = 0;
            while (loc20 < 64) 
            {
                arg1[loc20] = Math.round(arg1[loc20] * arg2[loc20]);
                ++loc20;
            }
            return arg1;
        }

        internal function writeWord(arg1:int):void
        {
            writeByte(arg1 >> 8 & 255);
            writeByte(arg1 & 255);
            return;
        }

        internal function writeByte(arg1:int):void
        {
            byteout.writeByte(arg1);
            return;
        }

        internal function writeDHT():void
        {
            var loc1:*=0;
            writeWord(65476);
            writeWord(418);
            writeByte(0);
            loc1 = 0;
            while (loc1 < 16) 
            {
                writeByte(std_dc_luminance_nrcodes[loc1 + 1]);
                ++loc1;
            }
            loc1 = 0;
            while (loc1 <= 11) 
            {
                writeByte(std_dc_luminance_values[loc1]);
                ++loc1;
            }
            writeByte(16);
            loc1 = 0;
            while (loc1 < 16) 
            {
                writeByte(std_ac_luminance_nrcodes[loc1 + 1]);
                ++loc1;
            }
            loc1 = 0;
            while (loc1 <= 161) 
            {
                writeByte(std_ac_luminance_values[loc1]);
                ++loc1;
            }
            writeByte(1);
            loc1 = 0;
            while (loc1 < 16) 
            {
                writeByte(std_dc_chrominance_nrcodes[loc1 + 1]);
                ++loc1;
            }
            loc1 = 0;
            while (loc1 <= 11) 
            {
                writeByte(std_dc_chrominance_values[loc1]);
                ++loc1;
            }
            writeByte(17);
            loc1 = 0;
            while (loc1 < 16) 
            {
                writeByte(std_ac_chrominance_nrcodes[loc1 + 1]);
                ++loc1;
            }
            loc1 = 0;
            while (loc1 <= 161) 
            {
                writeByte(std_ac_chrominance_values[loc1]);
                ++loc1;
            }
            return;
        }

        internal function writeSOS():void
        {
            writeWord(65498);
            writeWord(12);
            writeByte(3);
            writeByte(1);
            writeByte(0);
            writeByte(2);
            writeByte(17);
            writeByte(3);
            writeByte(17);
            writeByte(0);
            writeByte(63);
            writeByte(0);
            return;
        }

        internal function writeAPP0():void
        {
            writeWord(65504);
            writeWord(16);
            writeByte(74);
            writeByte(70);
            writeByte(73);
            writeByte(70);
            writeByte(0);
            writeByte(1);
            writeByte(1);
            writeByte(0);
            writeWord(1);
            writeWord(1);
            writeByte(0);
            writeByte(0);
            return;
        }

        internal function processDU(arg1:Array, arg2:Array, arg3:Number, arg4:Array, arg5:Array):Number
        {
            var loc3:*=0;
            var loc7:*=0;
            var loc8:*=0;
            var loc9:*=0;
            var loc1:*=arg5[0];
            var loc2:*=arg5[240];
            var loc4:*=fDCTQuant(arg1, arg2);
            loc3 = 0;
            while (loc3 < 64) 
            {
                DU[ZigZag[loc3]] = loc4[loc3];
                ++loc3;
            }
            var loc5:*=DU[0] - arg3;
            arg3 = DU[0];
            if (loc5 != 0) 
            {
                writeBits(arg4[category[32767 + loc5]]);
                writeBits(bitcode[32767 + loc5]);
            }
            else 
            {
                writeBits(arg4[0]);
            }
            var loc6:*=63;
            while (loc6 > 0 && DU[loc6] == 0) 
            {
                --loc6;
            }
            if (loc6 == 0) 
            {
                writeBits(loc1);
                return arg3;
            }
            loc3 = 1;
            while (loc3 <= loc6) 
            {
                loc7 = loc3;
                while (DU[loc3] == 0 && loc3 <= loc6) 
                {
                    ++loc3;
                }
                if ((loc8 = loc3 - loc7) >= 16) 
                {
                    loc9 = 1;
                    while (loc9 <= loc8 / 16) 
                    {
                        writeBits(loc2);
                        ++loc9;
                    }
                    loc8 = int(loc8 & 15);
                }
                writeBits(arg5[loc8 * 16 + category[32767 + DU[loc3]]]);
                writeBits(bitcode[32767 + DU[loc3]]);
                ++loc3;
            }
            if (loc6 != 63) 
            {
                writeBits(loc1);
            }
            return arg3;
        }

        internal function initQuantTables(arg1:int):void
        {
            var loc1:*=0;
            var loc2:*=NaN;
            var loc7:*=0;
            var loc3:*=[16, 11, 10, 16, 24, 40, 51, 61, 12, 12, 14, 19, 26, 58, 60, 55, 14, 13, 16, 24, 40, 57, 69, 56, 14, 17, 22, 29, 51, 87, 80, 62, 18, 22, 37, 56, 68, 109, 103, 77, 24, 35, 55, 64, 81, 104, 113, 92, 49, 64, 78, 87, 103, 121, 120, 101, 72, 92, 95, 98, 112, 100, 103, 99];
            loc1 = 0;
            while (loc1 < 64) 
            {
                loc2 = Math.floor((loc3[loc1] * arg1 + 50) / 100);
                if (loc2 < 1) 
                {
                    loc2 = 1;
                }
                else if (loc2 > 255) 
                {
                    loc2 = 255;
                }
                YTable[ZigZag[loc1]] = loc2;
                ++loc1;
            }
            var loc4:*=[17, 18, 24, 47, 99, 99, 99, 99, 18, 21, 26, 66, 99, 99, 99, 99, 24, 26, 56, 99, 99, 99, 99, 99, 47, 66, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99];
            loc1 = 0;
            while (loc1 < 64) 
            {
                loc2 = Math.floor((loc4[loc1] * arg1 + 50) / 100);
                if (loc2 < 1) 
                {
                    loc2 = 1;
                }
                else if (loc2 > 255) 
                {
                    loc2 = 255;
                }
                UVTable[ZigZag[loc1]] = loc2;
                ++loc1;
            }
            var loc5:*=[1, 1.387039845, 1.306562965, 1.175875602, 1, 0.785694958, 0.5411961, 0.275899379];
            loc1 = 0;
            var loc6:*=0;
            while (loc6 < 8) 
            {
                loc7 = 0;
                while (loc7 < 8) 
                {
                    fdtbl_Y[loc1] = 1 / (YTable[ZigZag[loc1]] * loc5[loc6] * loc5[loc7] * 8);
                    fdtbl_UV[loc1] = 1 / (UVTable[ZigZag[loc1]] * loc5[loc6] * loc5[loc7] * 8);
                    ++loc1;
                    ++loc7;
                }
                ++loc6;
            }
            return;
        }

        public function encode(arg1:flash.display.BitmapData):flash.utils.ByteArray
        {
            var loc5:*=0;
            var loc6:*=null;
            byteout = new flash.utils.ByteArray();
            bytenew = 0;
            bytepos = 7;
            writeWord(65496);
            writeAPP0();
            writeDQT();
            writeSOF0(arg1.width, arg1.height);
            writeDHT();
            writeSOS();
            var loc1:*=0;
            var loc2:*=0;
            var loc3:*=0;
            bytenew = 0;
            bytepos = 7;
            var loc4:*=0;
            while (loc4 < arg1.height) 
            {
                loc5 = 0;
                while (loc5 < arg1.width) 
                {
                    RGB2YUV(arg1, loc5, loc4);
                    loc1 = processDU(YDU, fdtbl_Y, loc1, YDC_HT, YAC_HT);
                    loc2 = processDU(UDU, fdtbl_UV, loc2, UVDC_HT, UVAC_HT);
                    loc3 = processDU(VDU, fdtbl_UV, loc3, UVDC_HT, UVAC_HT);
                    loc5 = loc5 + 8;
                }
                loc4 = loc4 + 8;
            }
            if (bytepos >= 0) 
            {
                (loc6 = new com.adobe.images.BitString()).len = bytepos + 1;
                loc6.val = (1 << bytepos + 1 - 1);
                writeBits(loc6);
            }
            writeWord(65497);
            return byteout;
        }

        internal function initCategoryNumber():void
        {
            var loc3:*=0;
            var loc1:*=1;
            var loc2:*=2;
            var loc4:*=1;
            while (loc4 <= 15) 
            {
                loc3 = loc1;
                while (loc3 < loc2) 
                {
                    category[32767 + loc3] = loc4;
                    bitcode[32767 + loc3] = new com.adobe.images.BitString();
                    bitcode[32767 + loc3].len = loc4;
                    bitcode[32767 + loc3].val = loc3;
                    ++loc3;
                }
                loc3 = -(loc2 - 1);
                while (loc3 <= -loc1) 
                {
                    category[32767 + loc3] = loc4;
                    bitcode[32767 + loc3] = new com.adobe.images.BitString();
                    bitcode[32767 + loc3].len = loc4;
                    bitcode[32767 + loc3].val = (loc2 - 1) + loc3;
                    ++loc3;
                }
                loc1 = loc1 << 1;
                loc2 = loc2 << 1;
                ++loc4;
            }
            return;
        }

        internal var fdtbl_UV:Array;

        internal var std_ac_chrominance_values:Array;

        internal var std_dc_chrominance_values:Array;

        internal var ZigZag:Array;

        internal var YDC_HT:Array;

        internal var YAC_HT:Array;

        internal var bytenew:int=0;

        internal var fdtbl_Y:Array;

        internal var std_ac_chrominance_nrcodes:Array;

        internal var DU:Array;

        internal var std_ac_luminance_values:Array;

        internal var byteout:flash.utils.ByteArray;

        internal var UVAC_HT:Array;

        internal var UVDC_HT:Array;

        internal var bytepos:int=7;

        internal var YDU:Array;

        internal var UDU:Array;

        internal var VDU:Array;

        internal var std_dc_chrominance_nrcodes:Array;

        internal var std_ac_luminance_nrcodes:Array;

        internal var std_dc_luminance_values:Array;

        internal var YTable:Array;

        internal var std_dc_luminance_nrcodes:Array;

        internal var bitcode:Array;

        internal var UVTable:Array;

        internal var category:Array;
    }
}


