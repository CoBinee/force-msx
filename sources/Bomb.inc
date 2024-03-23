; Bomb.inc : 爆発
;


; マクロの定義
;

; 爆発
BOMB_STATE                      =   0x00
BOMB_POSITION_X                 =   0x01
BOMB_POSITION_Y                 =   0x02
BOMB_SPEED                      =   0x03
BOMB_SPRITE                     =   0x04
BOMB_COLOR                      =   0x05
BOMB_FRAME                      =   0x06
BOMB_LENGTH                     =   0x07
BOMB_ENTRY                      =   0x02

; 状態
BOMB_STATE_NULL                 =   0x00
BOMB_STATE_LOOP                 =   0x10

; 位置
BOMB_POSITION_NULL              =   0x00

; 速度
BOMB_SPEED_NULL                 =   0x00

; スプライト
BOMB_SPRITE_NULL                =   0x3c
BOMB_SPRITE_R                   =   0x10

; 色
BOMB_COLOR_NULL                 =   0x0d

; フレーム
BOMB_FRAME_NULL                 =   0x00

; 外部関数宣言
;

    .globl  _BombInitialize
    .globl  _BombUpdate
    .globl  _BombRender
    .globl  _BombEntry

; 外部変数宣言
;

    .globl  _bomb

