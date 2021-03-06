# See LICENSE for license details.

#*****************************************************************************
# ma_utld.S
#-----------------------------------------------------------------------------
#
# Test misaligned ut ld trap.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64SV
RVTEST_CODE_BEGIN

  vsetcfg 32,0
  li a3,4
  vsetvl a3,a3

  la a3, dest+1
  vmsv vx1, a3
  lui a0,%hi(vtcode1)
  vf %lo(vtcode1)(a0)
  fence

vtcode1:
  lw x2, 0(x1)
  stop

vtcode2:
  add x2,x2,x3
  stop

stvec_handler:
  vxcptkill

  li TESTNUM,2

  # check cause
  csrr a3, scause
  li a4,HWACHA_CAUSE_MISALIGNED_LOAD
  bne a3,a4,fail

  # check vec irq aux
  csrr a3, sbadaddr
  la a4,dest+1
  bne a3,a4,fail

  # make sure vector unit has cleared out
  vsetcfg 32,0
  li a3,4
  vsetvl a3,a3

  la a3,src1
  la a4,src2
  vld vx2,a3
  vld vx3,a4
  lui a0,%hi(vtcode2)
  vf %lo(vtcode2)(a0)
  la a5,dest
  vsd vx2,a5
  fence

  ld a1,0(a5)
  li a2,5
  li TESTNUM,2
  bne a1,a2,fail
  ld a1,8(a5)
  li TESTNUM,3
  bne a1,a2,fail
  ld a1,16(a5)
  li TESTNUM,4
  bne a1,a2,fail
  ld a1,24(a5)
  li TESTNUM,5
  bne a1,a2,fail

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

src1:
  .dword 1
  .dword 2
  .dword 3
  .dword 4
src2:
  .dword 4
  .dword 3
  .dword 2
  .dword 1
dest:
  .dword 0xdeadbeefcafebabe
  .dword 0xdeadbeefcafebabe
  .dword 0xdeadbeefcafebabe
  .dword 0xdeadbeefcafebabe

RVTEST_DATA_END
