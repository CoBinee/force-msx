; Game.inc : ゲーム
;


; マクロの定義
;

; ゲーム
GAME_STATE                      =   0x00
GAME_FLAG                       =   0x01
GAME_REQUEST                    =   0x02
GAME_SPRITE_ENEMY               =   0x03
GAME_SPRITE_ESSHOT              =   0x04
GAME_SOUND                      =   0x05
GAME_FRAME                      =   0x06
GAME_SCORE_10000000             =   0x07
GAME_SCORE_01000000             =   0x08
GAME_SCORE_00100000             =   0x09
GAME_SCORE_00010000             =   0x0a
GAME_SCORE_00001000             =   0x0b
GAME_SCORE_00000100             =   0x0c
GAME_SCORE_00000010             =   0x0d
GAME_SCORE_00000001             =   0x0e
GAME_RATE_10_0                  =   0x0f
GAME_RATE_01_0                  =   0x10
GAME_RATE_00_1                  =   0x11
GAME_RATE_BCD_L                 =   0x12
GAME_RATE_BCD_H                 =   0x13
GAME_TIME_1000                  =   0x14
GAME_TIME_0100                  =   0x15
GAME_TIME_0010                  =   0x16
GAME_TIME_0001                  =   0x17
GAME_TIME_BCD_L                 =   0x18
GAME_TIME_BCD_H                 =   0x19
GAME_LENGTH                     =   0x1a

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_START                =   0x10
GAME_STATE_PLAY                 =   0x20
GAME_STATE_OVER                 =   0x30
GAME_STATE_RESULT               =   0x40
GAME_STATE_END                  =   0x50

; フラグ
GAME_FLAG_NULL                  =   0x00
GAME_FLAG_ADVANCED_BIT          =   0x00
GAME_FLAG_ADVANCED              =   (1 << GAME_FLAG_ADVANCED_BIT)
GAME_FLAG_FALCON_BIT            =   0x01
GAME_FLAG_FALCON                =   (1 << GAME_FLAG_FALCON_BIT)
GAME_FLAG_PROTON_BIT            =   0x01
GAME_FLAG_PROTON                =   (1 << GAME_FLAG_PROTON_BIT)
GAME_FLAG_PLAY_BIT              =   0x06
GAME_FLAG_PLAY                  =   (1 << GAME_FLAG_PLAY_BIT)
GAME_FLAG_OVER_BIT              =   0x07
GAME_FLAG_OVER                  =   (1 << GAME_FLAG_OVER_BIT)

; リクエスト
GAME_REQUEST_NULL               =   0x00
GAME_REQUEST_RATE_PLUS_1_0_BIT  =   0x00
GAME_REQUEST_RATE_PLUS_1_0      =   (1 << GAME_REQUEST_RATE_PLUS_1_0_BIT)
GAME_REQUEST_RATE_MINUS_1_0_BIT =   0x01
GAME_REQUEST_RATE_MINUS_1_0     =   (1 << GAME_REQUEST_RATE_MINUS_1_0_BIT)
GAME_REQUEST_RATE_MINUS_0_1_BIT =   0x02
GAME_REQUEST_RATE_MINUS_0_1     =   (1 << GAME_REQUEST_RATE_MINUS_0_1_BIT)
GAME_REQUEST_ENEMY_ADVANCED_BIT =   0x03
GAME_REQUEST_ENEMY_ADVANCED     =   (1 << GAME_REQUEST_ENEMY_ADVANCED_BIT)
GAME_REQUEST_ENEMY_PORT_BIT     =   0x04
GAME_REQUEST_ENEMY_PORT         =   (1 << GAME_REQUEST_ENEMY_PORT_BIT)
GAME_REQUEST_USE_THE_FORCE_BIT  =   0x05
GAME_REQUEST_USE_THE_FORCE      =   (1 << GAME_REQUEST_USE_THE_FORCE_BIT)
GAME_REQUEST_BONUS_BIT          =   0x06
GAME_REQUEST_BONUS              =   (1 << GAME_REQUEST_BONUS_BIT)
GAME_REQUEST_OVER_BIT           =   0x07
GAME_REQUEST_OVER               =   (1 << GAME_REQUEST_OVER_BIT)

; フレーム
GAME_FRAME_NULL                 =   0x00

; スプライト
GAME_SPRITE_FALCON              =   0x00
GAME_SPRITE_BOMB                =   0x10
GAME_SPRITE_PLAYER              =   0x18
GAME_SPRITE_PROTON              =   0x1c
GAME_SPRITE_ENEMY_0             =   0x20
GAME_SPRITE_ENEMY_1             =   0x40
GAME_SPRITE_ESSHOT_0            =   0x50
GAME_SPRITE_ESSHOT_1            =   0x20
GAME_SPRITE_PSSHOT              =   0x70

; サウンド
GAME_SOUND_NULL                 =   0x00
GAME_SOUND_BGM_FIGHTER          =   0x01
GAME_SOUND_BGM_ADVANCED         =   0x02
GAME_SOUND_BGM_RESULT           =   0x03
GAME_SOUND_SE_CLICK             =   0x01
GAME_SOUND_SE_SHOT              =   0x02
GAME_SOUND_SE_BOMB              =   0x03

; スコア

; 倍率
GAME_RATE_LENGTH                =   0x03

; 時間
GAME_TIME_LENGTH                =   0x04

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate
    .globl  _GameAddScoreRate
    .globl  _GamePlayBgm
    .globl  _GamePlaySe

; 外部変数宣言
;

    .globl  _game
