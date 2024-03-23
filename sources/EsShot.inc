; EsShot.inc : エネミーショット
;


; マクロの定義
;

; エネミーショット
ESSHOT_TYPE                     =   0x00
ESSHOT_POSITION_X               =   0x01
ESSHOT_POSITION_Y               =   0x02
ESSHOT_SPEED                    =   0x03
ESSHOT_LENGTH                   =   0x04
ESSHOT_ENTRY                    =   0x08

; 種類
ESSHOT_TYPE_NULL                =   0x00
ESSHOT_TYPE_FIGHTER             =   0x01
ESSHOT_TYPE_ADVANCED            =   0x02

; 位置
ESSHOT_POSITION_NULL            =   0x00

; 大きさ
ESSHOT_RECT_X                   =   0x00
ESSHOT_RECT_Y                   =   -0x0c
ESSHOT_RECT_WIDTH               =   0x02
ESSHOT_RECT_HEIGHT              =   0x18

; 領域
ESSHOT_REGION_TOP               =   0xf4
ESSHOT_REGION_BOTTOM            =   0xcc
ESSHOT_REGION_LEFT              =   0x00
ESSHOT_REGION_RIGHT             =   0xff

; 速度
ESSHOT_SPEED_NULL               =   0x00
ESSHOT_SPEED_FIGHTER            =   0x06
ESSHOT_SPEED_ADVANCED           =   -0x06

; スプライト
ESSHOT_SPRITE                   =   0x10
ESSHOT_SPRITE_R                 =   0x10
ESSHOT_SPRITE_LENGTH            =   (ESSHOT_ENTRY * 0x04)

; 色
ESSHOT_COLOR                    =   0x03

; 外部関数宣言
;

    .globl  _EsShotInitialize
    .globl  _EsShotUpdate
    .globl  _EsShotRender
    .globl  _EsShotEntry
    .globl  _EsShotHitPlayer

; 外部変数宣言
;

    .globl  _esshot

