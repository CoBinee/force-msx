; Back.inc : 背景
;


; マクロの定義
;

; 背景
BACK_STATE                      =   0x00
BACK_SCROLL_GROUND              =   0x01
BACK_SCROLL_WALL                =   0x02
BACK_FADE                       =   0x03
BACK_LENGTH                     =   0x04

; 状態
BACK_STATE_NULL                 =   0x00

; スクロール
BACK_SCROLL_NULL                =   0x00

; フェード
BACK_FADE_NULL                  =   0x00

; 外部関数宣言
;

    .globl  _BackInitialize
    .globl  _BackUpdate
    .globl  _BackRender
    .globl  _BackIsAlive
    .globl  _BackIsFade

; 外部変数宣言
;

    .globl  _back
