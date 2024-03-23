; Falcon.s : ファルコン
;


; モジュール宣言
;
    .module Falcon

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Enemy.inc"
    .include    "Falcon.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ファルコンを初期化する
;
_FalconInitialize::
    
    ; レジスタの保存

    ; 初期値の設定
    ld      a, #FALCON_ENTRY
    ld      de, #_falcon
10$:
    ld      hl, #falconDefault
    ld      bc, #FALCON_LENGTH
    ldir
    dec     a
    jr      nz, 10$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ファルコンを更新する
;
_FalconUpdate::
    
    ; レジスタの保存

    ; ファルコンの走査
    ld      ix, #_falcon
    ld      b, #FALCON_ENTRY
10$:
    push    bc

    ; 種類別の処理
    ld      a, FALCON_TYPE(ix)
    or      a
    jr      z, 11$
    ld      hl, #11$
    push    hl
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #falconProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
11$:

    ; 次のファルコンへ
    ld      de, #FALCON_LENGTH
    add     ix, de
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; ファルコンを描画する
;
_FalconRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      hl, #(_sprite + GAME_SPRITE_FALCON)
    ld      ix, #_falcon
    ld      de, #FALCON_LENGTH
    ld      b, #FALCON_ENTRY
10$:
    ld      a, FALCON_TYPE(ix)
    or      a
    jr      z, 11$
    ld      a, FALCON_POSITION_Y(ix)
    sub     #(FALCON_SPRITE_R + 0x01)
    ld      (hl), a
    inc     hl
    ld      a, FALCON_POSITION_X(ix)
    sub     #FALCON_SPRITE_R
    ld      (hl), a
    inc     hl
    ld      a, FALCON_SPRITE(ix)
    ld      (hl), a
    inc     hl
    ld      a, FALCON_COLOR(ix)
    ld      (hl), a
    inc     hl
11$:
    add     ix, de
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; ファルコンを登録する
;
_FalconEntry::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; ファルコンの設定
    ld      hl, #falconDefaultShot
    ld      de, #_falcon
    ld      bc, #FALCON_LENGTH
    ldir
    ld      hl, #(_game + GAME_FLAG)
    set     #GAME_FLAG_FALCON_BIT, (hl)

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret
    
; 何もしない
;
FalconNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; 船が行動する
;
FalconShip:

    ; レジスタの保存

    ; 初期化
    ld      a, FALCON_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; フレームの更新
    dec     FALCON_FRAME(ix)
    jr      nz, 90$

    ; 初期化の完了
    inc     FALCON_STATE(ix)
09$:

    ; 移動
    ld      a, FALCON_POSITION_Y(ix)
    sub     #FALCON_SPEED_SHIP
    ld      FALCON_POSITION_Y(ix), a
    cp      #FALCON_REGION_TOP
    jr      nc, 19$
    cp      #FALCON_REGION_BOTTOM
    jr      c, 19$

    ; 移動の完了
    xor     a
    ld      FALCON_TYPE(ix), a

    ; BGM の再生
    ld      a, #GAME_SOUND_BGM_FIGHTER
    call    _GamePlayBgm
19$:

    ; 行動の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; ショットが行動する
;
FalconShot:

    ; レジスタの保存

    ; 初期化
    ld      a, FALCON_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 位置の設定
    ld      a, FALCON_PARAM(ix)
    or      a
    jr      z, 00$
    call    _SystemGetRandom
    and     #0x7f
    add     #0x40
    jr      01$
00$:
    ld      a, #ENEMY_TYPE_ADVANCED
    call    _EnemyGetPosition
    ld      a, e
;   jr      01$
01$:
    ld      FALCON_POSITION_X(ix), a
    ld      FALCON_POSITION_Y(ix), #0xcc

    ; カウンタの更新
    ld      a, FALCON_PARAM(ix)
    or      a
    jr      z, 02$
    dec     FALCON_PARAM(ix)
02$:

    ; 初期化の完了
    inc     FALCON_STATE(ix)
09$:

    ; 移動
    ld      a, FALCON_POSITION_Y(ix)
    sub     #FALCON_SPEED_SHOT
    ld      FALCON_POSITION_Y(ix), a
    cp      #FALCON_REGION_TOP
    jr      nc, 10$
    cp      #FALCON_REGION_BOTTOM
    jr      c, 10$

    ; ショットの再設定
    xor     a
    ld      FALCON_STATE(ix), a
    jr      19$

    ; ヒット判定
10$:
    ld      a, FALCON_PARAM(ix)
    or      a
    jr      nz, 19$
    ld      a, FALCON_POSITION_X(ix)
    add     a, #FALCON_RECT_X
    ld      e, a
    add     a, #FALCON_RECT_WIDTH
    ld      c, a
    ld      a, FALCON_POSITION_Y(ix)
    add     a, #FALCON_RECT_Y
    ld      d, a
    add     a, #FALCON_RECT_HEIGHT
    ld      b, a
    ld      a, #ENEMY_TYPE_ADVANCED
    call    _EnemyIsHitType
    jr      nc, 19$

    ; 船の設定
    ld      hl, #falconDefaultShip
    ld      de, #_falcon
    ld      bc, #(FALCON_LENGTH * FALCON_ENTRY)
    ldir
;   jr      19$

    ; 移動の完了
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 種類別の処理
;
falconProc:
    
    .dw     FalconNull
    .dw     FalconShip
    .dw     FalconShot

; ファルコンの初期値
;
falconDefault:

    .db     FALCON_TYPE_NULL
    .db     FALCON_STATE_NULL
    .db     FALCON_POSITION_NULL
    .db     FALCON_POSITION_NULL
    .db     FALCON_SPRITE_NULL
    .db     FALCON_COLOR_NULL
    .db     FALCON_FRAME_NULL
    .db     FALCON_PARAM_NULL

falconDefaultShip:

    .db     FALCON_TYPE_SHIP
    .db     FALCON_STATE_NULL
    .db     0xa0
    .db     0xd0
    .db     0x60
    .db     0x0f
    .db     0x30 - 0x01
    .db     FALCON_PARAM_NULL

    .db     FALCON_TYPE_SHIP
    .db     FALCON_STATE_NULL
    .db     0xc0
    .db     0xd0
    .db     0x64
    .db     0x0f
    .db     0x30
    .db     FALCON_PARAM_NULL

    .db     FALCON_TYPE_SHIP
    .db     FALCON_STATE_NULL
    .db     0xa0
    .db     0xd0
    .db     0x68
    .db     0x0f
    .db     0x30 + (0x20 / FALCON_SPEED_SHIP)
    .db     FALCON_PARAM_NULL

    .db     FALCON_TYPE_SHIP
    .db     FALCON_STATE_NULL
    .db     0xc0
    .db     0xd0
    .db     0x6c
    .db     0x0f
    .db     0x30 + (0x20 / FALCON_SPEED_SHIP)
    .db     FALCON_PARAM_NULL


falconDefaultShot:

    .db     FALCON_TYPE_SHOT
    .db     FALCON_STATE_NULL
    .db     FALCON_POSITION_NULL
    .db     FALCON_POSITION_NULL
    .db     0x10
    .db     0x0a
    .db     FALCON_FRAME_NULL
    .db     0x04


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ファルコン
;
_falcon::
    
    .ds     FALCON_LENGTH * FALCON_ENTRY
