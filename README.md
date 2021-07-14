# AIC2021 Project1 - TPU
contributed by < `E94079029 施丞宥` >

## Project Description
Design a Tensor Processing Unit(TPU) which has **4x4** Processing elements(PEs) that is capable to calculate ```(4*K)*(K*4)``` 8-bit integer matrix muplication. (Where is ```K``` is limited by the size of input global buffer)

**Project Constraints**
1. Your designs should be written in verilog language.
2. Your PEs shouldn't more than **4x4**, where a 2D systolic array architecture is **strictly required** in this project.
3. An 8-bit data length design.
4. 3KiBytes in total of global buffer size.

## Systolic array
<img src="/img/systolic.png" height="60%" width="60%"/>

## Architecture

### TOP
<img src="/img/arc1.jpg" height="60%" width="60%"/>

### Data Loader
<img src="/img/dataloader.jpg" height="60%" width="60%"/>

* 藉由遞增的暫存器來對DATA做pipeline的動作，達到systolic array的效果。

### MAC Unit
<img src="/img/MAC.jpg" height="60%" width="60%"/>

### FSM
<img src="/img/fsm.png" height="40%" width="40%"/>

* IDLE : 當 ```start=1``` 時，會進到BUZY開始做MAC運算。
* BUZY : 每當一次```4*4```的systolic array算完時，會進到OUTP。
* OUTP : 將運算完的結果存進output global buffer。
* DONE : 所有運算都做完後進到DONE表示運算結束。

## Goal
- [x] Pass atleast test1~3
- [x] Support ```(M*K)*(K*N)```
- [x] Synthesis

## Test Result

### Test1
<img src="/img/test1.png" height="60%" width="60%"/>

### Test2
<img src="/img/test2.png" height="60%" width="60%"/>

### Test3
<img src="/img/test3.png" height="60%" width="60%"/>

### Monster
<img src="/img/monster.png" height="60%" width="60%"/>

## Synthesis Result
* Area report

<img src="/img/area.png" height="40%" width="40%"/>
  
* Timing report

<img src="/img/timing.png" height="40%" width="40%"/>

* Cell library
  * tsmc13_neg
