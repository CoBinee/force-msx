; Bomb.s : 爆発
;


; モジュール宣言
;
    .module Bomb

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Bomb.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 爆発を初期化する
;
_BombInitialize::
    
    ; レジスタの保存

    ; 初期値の設定
    ld      a, #BOMB_ENTRY
    ld      de, #_bomb
10$:
    ld      hl, #bombDefault
    ld      bc, #BOMB_LENGTH
    ldir
    dec     a
    jr      nz, 10$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 爆発を更新する
;
_BombUpdate::
    
    ; レジスタの保存

    ; 爆発の走査
    ld      ix, #_bomb
    ld      b, #BOMB_ENTRY
10$:
    push    bc

    ; 爆発の処理
    ld      a, BOMB_STATE(ix)
    or      a
    call    nz, BombLoop

    ; 次の爆発へ
    ld      de, #BOMB_LENGTH
    add     ix, de
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; 爆発を描画する
;
_BombRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      hl, #(_sprite + GAME_SPRITE_BOMB)
    ld      ix, #_bomb
    ld      de, #BOMB_LENGTH
    ld      b, #BOMB_ENTRY
10$:
    ld      a, BOMB_STATE(ix)
    or      a
    jr      z, 11$
    ld      a, BOMB_POSITION_Y(ix)
    sub     #(BOMB_SPRITE_R + 0x01)
    ld      (hl), a
    inc     hl
    ld      a, BOMB_POSITION_X(ix)
    sub     #BOMB_SPRITE_R
    ld      (hl), a
    inc     hl
    ld      a, BOMB_SPRITE(ix)
    ld      (hl), a
    inc     hl
    ld      a, BOMB_COLOR(ix)
    ld      (hl), a
    inc     hl
11$:
    add     ix, de
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; 爆発を登録する
;
_BombEntry::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; de < 位置
    ; c  < 色
    ; b  < 速度

    ; 空きの取得
    ld      ix, #_bomb
    ld      h, #BOMB_ENTRY
10$:
    ld      a, BOMB_STATE(ix)
    or      a
    jr      z, 11$
    push    de
    ld      de, #BOMB_LENGTH
    add     ix, de
    pop     de
    dec     h
    jr      nz, 10$
    jr      19$
11$:
    ld      BOMB_STATE(ix), #BOMB_STATE_LOOP
    ld      BOMB_POSITION_X(ix), e
    ld      BOMB_POSITION_Y(ix), d
    ld      BOMB_SPEED(ix), b
    ld      BOMB_COLOR(ix), c
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret
    
; 爆発する
;
BombLoop:

    ; レジスタの保存

    ; 初期化
    ld      a, BOMB_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    ld      a, #(0x03 * 0x02)
    ld      BOMB_FRAME(ix), a

    ; SE の再生
    ld      a, #GAME_SOUND_SE_BOMB
    call    _GamePlaySe

    ; 初期化の完了
    inc     BOMB_STATE(ix)
09$:

    ; 移動
    ld      a, BOMB_POSITION_Y(ix)
    add     a, BOMB_SPEED(ix)
    ld      BOMB_POSITION_Y(ix), a

    ; フレームの更新
    dec     BOMB_FRAME(ix)
    jr      nz, 10$

    ; 爆発の削除
    xor     a
    ld      BOMB_STATE(ix), a
    jr      19$

    ; スプライトの設定
10$:
    ld      a, BOMB_FRAME(ix)
    and     #0xfe
    add     a, a
    add     a, #0x34
    ld      BOMB_SPRITE(ix), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 爆発の初期値
;
bombDefault:

    .db     BOMB_STATE_NULL
    .db     BOMB_POSITION_NULL
    .db     BOMB_POSITION_NULL
    .db     BOMB_SPEED_NULL
    .db     BOMB_SPRITE_NULL
    .db     BOMB_COLOR_NULL
    .db     BOMB_FRAME_NULL


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 爆発
;
_bomb::
    
    .ds     BOMB_LENGTH * BOMB_ENTRY
