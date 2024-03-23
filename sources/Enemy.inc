; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_TYPE                      =   0x00
ENEMY_STATE                     =   0x01
ENEMY_FLAG                      =   0x02
ENEMY_POSITION_X                =   0x03
ENEMY_POSITION_Y                =   0x04
ENEMY_SPEED_X                   =   0x05
ENEMY_SPEED_Y                   =   0x06
ENEMY_DIRECTION_X               =   0x07
ENEMY_DIRECTION_Y               =   0x08
ENEMY_SPRITE                    =   0x09
ENEMY_COLOR                     =   0x0a
ENEMY_FRAME                     =   0x0b
ENEMY_MOVE_X_INDEX              =   0x0c
ENEMY_MOVE_X_COUNT              =   0x0d
ENEMY_MOVE_X_PARAM_0            =   0x0e
ENEMY_MOVE_X_PARAM_1            =   0x0f
ENEMY_MOVE_X_PARAM_2            =   0x10
ENEMY_MOVE_X_PARAM_3            =   0x11
ENEMY_MOVE_X_PARAM_4            =   0x12
ENEMY_MOVE_X_PARAM_5            =   0x13
ENEMY_MOVE_X_PARAM_6            =   0x14
ENEMY_MOVE_X_PARAM_7            =   0x15
ENEMY_MOVE_Y_INDEX              =   0x16
ENEMY_MOVE_Y_COUNT              =   0x17
ENEMY_MOVE_Y_PARAM_0            =   0x18
ENEMY_MOVE_Y_PARAM_1            =   0x19
ENEMY_MOVE_Y_PARAM_2            =   0x1a
ENEMY_MOVE_Y_PARAM_3            =   0x1b
ENEMY_MOVE_Y_PARAM_4            =   0x1c
ENEMY_MOVE_Y_PARAM_5            =   0x1d
ENEMY_MOVE_Y_PARAM_6            =   0x1e
ENEMY_MOVE_Y_PARAM_7            =   0x1f
ENEMY_LENGTH                    =   0x20
ENEMY_ENTRY                     =   0x0c

; 種類
ENEMY_TYPE_NULL                 =   0x00
ENEMY_TYPE_FIGHTER              =   0x01
ENEMY_TYPE_ADVANCED             =   0x02
ENEMY_TYPE_PORT                 =   0x03
ENEMY_TYPE_BOMB                 =   0x04

; 状態
ENEMY_STATE_NULL                =   0x00

; フラグ
ENEMY_FLAG_NULL                 =   0x00
ENEMY_FLAG_NORENDER_BIT         =   0x00
ENEMY_FLAG_NORENDER             =   (1 << ENEMY_FLAG_NORENDER_BIT)
ENEMY_FLAG_NOHIT_BIT            =   0x01
ENEMY_FLAG_NOHIT                =   (1 << ENEMY_FLAG_NOHIT_BIT)
ENEMY_FLAG_BOMB_BIT             =   0x02
ENEMY_FLAG_BOMB                 =   (1 << ENEMY_FLAG_BOMB_BIT)

; 位置
ENEMY_POSITION_NULL             =   0x00

; 範囲
ENEMY_REGION_FIGHTER_TOP        =   0xf4
ENEMY_REGION_FIGHTER_BOTTOM     =   0xcb
ENEMY_REGION_FIGHTER_LEFT       =   0x06
ENEMY_REGION_FIGHTER_RIGHT      =   0xf9
ENEMY_REGION_ADVANCED_TOP       =   0xf4
ENEMY_REGION_ADVANCED_BOTTOM    =   0xcb
ENEMY_REGION_ADVANCED_LEFT      =   0x2c
ENEMY_REGION_ADVANCED_RIGHT     =   0xd4
ENEMY_REGION_PORT_TOP           =   0xf4
ENEMY_REGION_PORT_BOTTOM        =   0xcb
ENEMY_REGION_PORT_LEFT          =   0x00
ENEMY_REGION_PORT_RIGHT         =   0xff

; 向き
ENEMY_DIRECTION_NULL            =   0x00
ENEMY_DIRECTION_MINUS           =   0xff
ENEMY_DIRECTION_PLUS            =   0x01

; 速度
ENEMY_SPEED_NULL                =   0x00
ENEMY_SPEED_FIGHTER             =   0x06
ENEMY_SPEED_ADVANCED_X          =   0x01
ENEMY_SPEED_ADVANCED_Y          =   0x05
ENEMY_SPEED_PORT                =   0x04

; 大きさ
ENEMY_R                         =   0x0c

; スプライト
ENEMY_SPRITE_NULL               =   0x00
ENEMY_SPRITE_R                  =   0x10
ENEMY_SPRITE_LENGTH             =   (ENEMY_ENTRY * 0x04)

; 色
ENEMY_COLOR_NULL                =   0x00

; フレーム
ENEMY_FRAME_NULL                =   0x00

; 移動
ENEMY_MOVE_INDEX_NULL           =   0x00
ENEMY_MOVE_COUNT_NULL           =   0x00
ENEMY_MOVE_PARAM_NULL           =   0x00
ENEMY_MOVE_PARAM_LENGTH         =   0x08

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyEntry
    .globl  _EnemySetBombType
    .globl  _EnemyKillAll
    .globl  _EnemyGetPosition
    .globl  _EnemyIsHit
    .globl  _EnemyIsHitType
    .globl  _EnemyHitPlayer

; 外部変数宣言
;

    .globl  _enemy

