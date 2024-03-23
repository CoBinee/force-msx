; Proton.inc : プロトン
;


; マクロの定義
;

; プロトン
PROTON_STATE                    =   0x00
PROTON_FLAG                     =   0x01
PROTON_POSITION_X               =   0x02
PROTON_POSITION_Y               =   0x03
PROTON_SPRITE                   =   0x04
PROTON_COLOR                    =   0x05
PROTON_FRAME                    =   0x06
PROTON_LENGTH                   =   0x07

; 状態
PROTON_STATE_NULL               =   0x00
PROTON_STATE_SIGHT              =   0x10
PROTON_STATE_MISSILE            =   0x20
PROTON_STATE_BOMB               =   0x30

; フラグ
PROTON_FLAG_NULL                =   0x00
PROTON_FLAG_ENABLE_BIT          =   0x00
PROTON_FLAG_ENABLE              =   (1 << PROTON_FLAG_ENABLE_BIT)

; 位置
PROTON_POSITION_NULL            =   0x00

; 大きさ
PROTON_RECT_X                   =   -0x04
PROTON_RECT_Y                   =   -0x04
PROTON_RECT_WIDTH               =   0x08
PROTON_RECT_HEIGHT              =   0x08

; 領域
PROTON_REGION_TOP               =   0xb8
PROTON_REGION_BOTTOM            =   0x78
PROTON_REGION_LEFT              =   0x00
PROTON_REGION_RIGHT             =   0xff

; 距離
PROTON_DISTANCE                 =   0x60

; 速度
PROTON_SPEED_MISSILE            =   0x04
PROTON_SPEED_BOMB               =   0x04

; スプライト
PROTON_SPRITE_NULL              =   0x00
PROTON_SPRITE_R                 =   0x10

; 色
PROTON_COLOR_NULL               =   0x00

; フレーム
PROTON_FRAME_NULL               =   0x00

; 外部関数宣言
;

    .globl  _ProtonInitialize
    .globl  _ProtonUpdate
    .globl  _ProtonRender
    .globl  _ProtonEntry

; 外部変数宣言
;

    .globl  _proton

