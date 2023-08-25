#include "mainproc.h"
#include "psx/libetc.h"
#include "unkf.h"

void mainproc(){

    func_80053BD8();
    ResetCallback();
    func_8005A5A4(0);

    do{

        func_80014A0C();
        func_80014B04();
        func_80014AB4();

    }while(1);

}