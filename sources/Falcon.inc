; Falcon.inc : ファルコン
;


; マクロの定義
;

; ファルコン
FALCON_TYPE                     =   0x00
FALCON_STATE                    =   0x01
FALCON_POSITION_X               =   0x02
FALCON_POSITION_Y               =   0x03
FALCON_SPRITE                   =   0x04
FALCON_COLOR                    =   0x05
FALCON_FRAME                    =   0x06
FALCON_PARAM                    =   0x07
FALCON_LENGTH                   =   0x08
FALCON_ENTRY                    =   0x04

; 種類
FALCON_TYPE_NULL                =   0x00
FALCON_TYPE_SHIP                =   0x01
FALCON_TYPE_SHOT                =   0x02

; 状態
FALCON_STATE_NULL               =   0x00

; 位置
FALCON_POSITION_NULL            =   0x00

; 大きさ
FALCON_RECT_X                   =   0x00
FALCON_RECT_Y                   =   -0x0c
FALCON_RECT_WIDTH               =   0x02
FALCON_RECT_HEIGHT              =   0x18

; 範囲
FALCON_REGION_TOP               =   0xf0
FALCON_REGION_BOTTOM            =   0xd4
FALCON_REGION_LEFT              =   0x00
FALCON_REGION_RIGHT             =   0xff

; 速度
FALCON_SPEED_SHIP               =   0x04
FALCON_SPEED_SHOT               =   0x0a

; スプライト
FALCON_SPRITE_NULL              =   0x00
FALCON_SPRITE_R                 =   0x10

; 色
FALCON_COLOR_NULL               =   0x00

; フレーム
FALCON_FRAME_NULL               =   0x00

; パラメータ
FALCON_PARAM_NULL               =   0x00

; 外部関数宣言
;

    .globl  _FalconInitialize
    .globl  _FalconUpdate
    .globl  _FalconRender
    .globl  _FalconEntry

; 外部変数宣言
;

    .globl  _falcon
