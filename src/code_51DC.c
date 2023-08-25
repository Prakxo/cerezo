#include "51DC.h"
#include "psx/libcd.h"

#include "unkf.h"
#include "unkv.h"

s32 D_800783E0 = 0;

void func_800149DC(){

    D_800783E0 = 1;
}

void func_800149EC(){

    D_800783E0 = 0;
}

s32 func_800149F8(){

    return D_800783E0;
}

void func_80014A04(){

}

void func_80014A0C(){

    func_80038A24();
    func_8001B984();
    D_800783E0 = 0;
    CdInit();
    func_80054E08(0);
    func_8005E170(1);
    func_8005E5A0();
    func_800615A0();
    func_800251F8();
    func_800163F4();
    func_8001788C();
    D_800788A8 = func_8001E6B4();
    if (D_800788A8 < 0) {
        D_800788A8 = 0;
    }
    D_8007884C = 1;
    func_800170D0(0x12345678);
    func_80014E6C();
}
