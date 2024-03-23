; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_STATE                    =   0x00
PLAYER_FLAG                     =   0x01
PLAYER_POSITION_X               =   0x02
PLAYER_POSITION_Y               =   0x03
PLAYER_SPEED_X                  =   0x04
PLAYER_SPEED_Y                  =   0x05
PLAYER_ROTATE                   =   0x06
PLAYER_SPRITE                   =   0x07
PLAYER_COLOR                    =   0x08
PLAYER_NOHIT                    =   0x09
PLAYER_LENGTH                   =   0x0a

; 状態
PLAYER_STATE_NULL               =   0x00
PLAYER_STATE_START              =   0x10
PLAYER_STATE_PLAY               =   0x20
PLAYER_STATE_MISS               =   0x30
PLAYER_STATE_OVER               =   0x40

; フラグ
PLAYER_FLAG_NULL                =   0x00
PLAYER_FLAG_NORENDER_BIT        =   0x00
PLAYER_FLAG_NORENDER            =   (1 << PLAYER_FLAG_NORENDER_BIT)
PLAYER_FLAG_NOHIT_BIT           =   0x01
PLAYER_FLAG_NOHIT               =   (1 << PLAYER_FLAG_NOHIT_BIT)

; 位置
PLAYER_POSITION_NULL            =   0x00

; 大きさ
PLAYER_R                        =   0x04

; 範囲
PLAYER_REGION_TOP               =   0x0c
PLAYER_REGION_BOTTOM            =   0xb4
PLAYER_REGION_LEFT              =   0x24
PLAYER_REGION_RIGHT             =   0xdc

; 速度
PLAYER_SPEED_NULL               =   0x00
PLAYER_SPEED_MOVE               =   0x02
PLAYER_SPEED_MISS               =   0x04

; 傾き
PLAYER_ROTATE_LEFT              =   0x00
PLAYER_ROTATE_CENTER            =   0x04
PLAYER_ROTATE_RIGHT             =   0x08

; スプライト
PLAYER_SPRITE_NULL              =   0x00
PLAYER_SPRITE_R                 =   0x10

; 色
PLAYER_COLOR_NULL               =   0x00

; 無敵
PLAYER_NOHIT_NULL               =   0x00
PLAYER_NOHIT_LENGTH             =   0x2d

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerIsHit
    .globl  _PlayerIsAlive

; 外部変数宣言
;

    .globl  _player

