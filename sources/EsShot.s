; EsShot.s : エネミーショット
;


; モジュール宣言
;
    .module EsShot

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Player.inc"
    .include    "EsShot.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; エネミーショットを初期化する
;
_EsShotInitialize::
    
    ; レジスタの保存

    ; 初期値の設定
    ld      de, #_esshot
    ld      a, #ESSHOT_ENTRY
10$:
    ld      hl, #esshotDefault
    ld      bc, #ESSHOT_LENGTH
    ldir
    dec     a
    jr      nz, 10$
    
    ; スプライトの初期化
    xor     a
    ld      (esshotSprite), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーショットを更新する
;
_EsShotUpdate::
    
    ; レジスタの保存

    ; エネミーショットの走査
    ld      ix, #_esshot
    ld      b, #ESSHOT_ENTRY
10$:
    push    bc

    ; 種類別の処理
    ld      a, ESSHOT_TYPE(ix)
    or      a
    call    nz, EsShotMove

    ; 次のエネミーショットへ
    ld      de, #ESSHOT_LENGTH
    add     ix, de
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーショットを描画する
;
_EsShotRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      a, (_game + GAME_SPRITE_ESSHOT)
    ld      e, a
    add     a, #ESSHOT_SPRITE_LENGTH
    ld      c, a
    ld      a, (esshotSprite)
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      ix, #_esshot
    ld      b, #ESSHOT_ENTRY
10$:
    push    bc
    ld      a, ESSHOT_TYPE(ix)
    or      a
    jr      z, 19$
    ld      hl, #_sprite
    add     hl, de
    ld      a, ESSHOT_POSITION_Y(ix)
    sub     #(ESSHOT_SPRITE_R + 0x01)
    ld      (hl), a
    inc     hl
    ld      a, ESSHOT_POSITION_X(ix)
    sub     #ESSHOT_SPRITE_R
    ld      (hl), a
    inc     hl
    ld      (hl), #ESSHOT_SPRITE
    inc     hl
    ld      (hl), #ESSHOT_COLOR
;   inc     hl
    ld      a, e
    add     a, #0x04
    cp      c
    jr      c, 11$
    ld      a, #(_game + GAME_SPRITE_ESSHOT)
11$:
    ld      e, a
19$:
    ld      bc, #ESSHOT_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; スプライトの更新
    ld      hl, #esshotSprite
    ld      a, (hl)
    add     a, #0x04
    cp      #ESSHOT_SPRITE_LENGTH
    jr      c, 91$
    xor     a
91$:
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーショットを登録する
;
_EsShotEntry::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; a  < 種類
    ; de < 位置

    ; 引数の保存
    ex      de, hl
    ld      c, a

    ; 空きの取得
    ld      ix, #_esshot
    ld      de, #ESSHOT_LENGTH
    ld      b, #ESSHOT_ENTRY
10$:
    ld      a, ESSHOT_TYPE(ix)
    or      a
    jr      z, 11$
    add     ix, de
    djnz    10$
    jr      19$
11$:
    ld      ESSHOT_TYPE(ix), c
    ld      ESSHOT_POSITION_X(ix), l
    ld      ESSHOT_POSITION_Y(ix), h
    ld      b, #0x00
    ld      hl, #esshotSpeed
    add     hl, bc
    ld      a, (hl)
    ld      ESSHOT_SPEED(ix), a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret
    
; 何もしない
;
EsShotNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; エネミーショットを移動する
;
EsShotMove:

    ; レジスタの保存

    ; 移動
    ld      a, ESSHOT_POSITION_Y(ix)
    add     a, ESSHOT_SPEED(ix)
    ld      ESSHOT_POSITION_Y(ix), a
    cp      #ESSHOT_REGION_TOP
    jr      nc, 10$
    cp      #ESSHOT_REGION_BOTTOM
    jr      c, 10$
    xor     a
    ld      ESSHOT_TYPE(ix), a
10$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤとのヒットを判定する
;
_EsShotHitPlayer::

    ; レジスタの保存
    push    bc
    push    de
    push    ix

    ; ショットの走査
    ld      ix, #_esshot
    ld      b, #ESSHOT_ENTRY
10$:
    push    bc
    ld      a, ESSHOT_TYPE(ix)
    or      a
    jr      z, 19$

    ; ヒットの判定
    ld      a, ESSHOT_POSITION_X(ix)
    add     a, #ESSHOT_RECT_X
    ld      e, a
    add     a, #ESSHOT_RECT_WIDTH
    ld      c, a
    ld      a, ESSHOT_POSITION_Y(ix)
    add     a, #ESSHOT_RECT_Y
    ld      d, a
    add     a, #ESSHOT_RECT_HEIGHT
    ld      b, a
    call    _PlayerIsHit
    jr      nc, 19$
    xor     a
    ld      ESSHOT_TYPE(ix), a

    ; 次のショットへ
19$:
    ld      de, #ESSHOT_LENGTH
    add     ix, de
    pop     bc
    djnz    10$

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc

    ; 終了
    ret

; 定数の定義
;

; エネミーショットの初期値
;
esshotDefault:

    .db     ESSHOT_TYPE_NULL
    .db     ESSHOT_POSITION_NULL
    .db     ESSHOT_POSITION_NULL
    .db     ESSHOT_SPEED_NULL

; 速度
;
esshotSpeed:

    .db     ESSHOT_SPEED_NULL
    .db     ESSHOT_SPEED_FIGHTER
    .db     ESSHOT_SPEED_ADVANCED


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミーショット
;
_esshot::
    
    .ds     ESSHOT_LENGTH * ESSHOT_ENTRY

; スプライト
;
esshotSprite:

    .ds     0x01
