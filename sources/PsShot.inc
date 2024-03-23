; PsShot.inc : プレイヤショット
;


; マクロの定義
;

; プレイヤショット
PSSHOT_TYPE                     =   0x00
PSSHOT_POSITION_X               =   0x01
PSSHOT_POSITION_Y               =   0x02
PSSHOT_SPRITE                   =   0x03
PSSHOT_LENGTH                   =   0x04
PSSHOT_ENTRY                    =   0x04

; 種類
PSSHOT_TYPE_NULL                =   0x00
PSSHOT_TYPE_SINGLE              =   0x01
PSSHOT_TYPE_TWIN_LONG           =   0x02
PSSHOT_TYPE_TWIN_MIDDLE         =   0x03
PSSHOT_TYPE_TWIN_SHORT          =   0x04

; 位置
PSSHOT_POSITION_NULL            =   0x00

; 大きさ
PSSHOT_SIZE_X                   =   0x02
PSSHOT_SIZE_Y                   =   0x18

; 領域
PSSHOT_REGION_TOP               =   0xf4
PSSHOT_REGION_BOTTOM            =   0xcc
PSSHOT_REGION_LEFT              =   0x00
PSSHOT_REGION_RIGHT             =   0xff

; 速度
PSSHOT_SPEED                    =   0x10

; スプライト
PSSHOT_SPRITE_NULL              =   0x10
PSSHOT_SPRITE_R                 =   0x10

; 色
PSSHOT_COLOR                    =   0x08

; 外部関数宣言
;

    .globl  _PsShotInitialize
    .globl  _PsShotUpdate
    .globl  _PsShotRender
    .globl  _PsShotEntry
    .globl  _PsShotHitEnemy

; 外部変数宣言
;

    .globl  _psshot

