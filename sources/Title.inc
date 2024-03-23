; Title.inc : タイトル
;


; マクロの定義
;

; タイトル
TITLE_STATE                     =   0x00
TITLE_FRAME                     =   0x01
TITLE_LENGTH                    =   0x02

; 状態
TITLE_STATE_NULL                =   0x00

; フレーム
TITLE_FRAME_NULL                =   0x00

; 外部関数宣言
;

    .globl  _TitleInitialize
    .globl  _TitleUpdate

; 外部変数宣言
;

    .globl  _title
