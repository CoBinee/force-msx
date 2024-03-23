; PsShot.s : プレイヤショット
;


; モジュール宣言
;
    .module PsShot

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Enemy.inc"
    .include    "PsShot.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤショットを初期化する
;
_PsShotInitialize::
    
    ; レジスタの保存

    ; 初期値の設定
    ld      de, #_psshot
    ld      a, #PSSHOT_ENTRY
10$:
    ld      hl, #psshotDefault
    ld      bc, #PSSHOT_LENGTH
    ldir
    dec     a
    jr      nz, 10$
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤショットを更新する
;
_PsShotUpdate::
    
    ; レジスタの保存

    ; プレイヤショットの走査
    ld      ix, #_psshot
    ld      b, #PSSHOT_ENTRY
10$:
    push    bc

    ; ショットの更新
    ld      a, PSSHOT_TYPE(ix)
    or      a
    call    nz, PsShotMove

    ; 次のプレイヤショットへ
    ld      de, #PSSHOT_LENGTH
    add     ix, de
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤショットを描画する
;
_PsShotRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      hl, #(_sprite + GAME_SPRITE_PSSHOT)
    ld      ix, #_psshot
    ld      de, #PSSHOT_LENGTH
    ld      b, #PSSHOT_ENTRY
10$:
    ld      a, PSSHOT_TYPE(ix)
    or      a
    jr      z, 11$
    ld      a, PSSHOT_POSITION_Y(ix)
    sub     #(PSSHOT_SPRITE_R + 0x01)
    ld      (hl), a
    inc     hl
    ld      a, PSSHOT_POSITION_X(ix)
    sub     #PSSHOT_SPRITE_R
    ld      (hl), a
    inc     hl
    ld      a, PSSHOT_SPRITE(ix)
    ld      (hl), a
    inc     hl
    ld      (hl), #PSSHOT_COLOR
    inc     hl
11$:
    add     ix, de
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤショットを登録する
;
_PsShotEntry::

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
    ld      ix, #_psshot
    ld      de, #PSSHOT_LENGTH
    ld      b, #PSSHOT_ENTRY
10$:
    ld      a, PSSHOT_TYPE(ix)
    or      a
    jr      z, 11$
    add     ix, de
    djnz    10$
    jr      19$
11$:
    ld      PSSHOT_TYPE(ix), c
    ld      PSSHOT_POSITION_X(ix), l
    ld      PSSHOT_POSITION_Y(ix), h

    ; SE の再生
    ld      a, #GAME_SOUND_SE_SHOT
    call    _GamePlaySe
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret
    
; プレイヤショットを移動する
;
PsShotMove:

    ; レジスタの保存

    ; 移動
    ld      a, PSSHOT_POSITION_Y(ix)
    sub     #PSSHOT_SPEED
    ld      PSSHOT_POSITION_Y(ix), a
    cp      #PSSHOT_REGION_TOP
    jr      nc, 10$
    cp      #PSSHOT_REGION_BOTTOM
    jr      c, 10$
    xor     a
    ld      PSSHOT_TYPE(ix), a
10$:

    ; スプライトの更新
    ld      e, PSSHOT_TYPE(ix)
    ld      d, #0x00
    ld      hl, #psshotSprite
    add     hl, de
    ld      a, (hl)
    ld      PSSHOT_SPRITE(ix), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーとのヒットを判定する
;
_PsShotHitEnemy::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; ショットの走査
    ld      ix, #_psshot
    ld      b, #PSSHOT_ENTRY
100$:
    push    bc
    ld      a, PSSHOT_TYPE(ix)
    or      a
    jp      z, 190$
    cp      #PSSHOT_TYPE_SINGLE
    jr      nz, 120$

    ; シングルショットの判定
110$:
    ld      hl, #(psshotRect + PSSHOT_TYPE_SINGLE * 0x0008)
    ld      a, PSSHOT_POSITION_X(ix)
    add     a, (hl)
    ld      e, a
    inc     hl
    add     a, (hl)
    ld      c, a
    inc     hl
    ld      a, PSSHOT_POSITION_Y(ix)
    add     a, (hl)
    ld      d, a
    inc     hl
    add     a, (hl)
    ld      b, a
;   inc     hl
    call    _EnemyIsHit
    jr      nc, 119$
    xor     a
    ld      PSSHOT_TYPE(ix), a
119$:
    jp      190$

    ; ツインショットの判定
120$:
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #psshotRect
    add     hl, de
    ld      a, PSSHOT_POSITION_X(ix)
    add     a, (hl)
    ld      e, a
    inc     hl
    add     a, (hl)
    ld      c, a
    inc     hl
    ld      a, PSSHOT_POSITION_Y(ix)
    add     a, (hl)
    ld      d, a
    inc     hl
    add     a, (hl)
    ld      b, a
    inc     hl
   call    _EnemyIsHit
    jr      nc, 121$
    ld      a, #PSSHOT_TYPE_SINGLE
    ld      PSSHOT_TYPE(ix), a
121$:
    ld      a, PSSHOT_POSITION_X(ix)
    add     a, (hl)
    ld      e, a
    inc     hl
    add     a, (hl)
    ld      c, a
    inc     hl
    ld      a, PSSHOT_POSITION_Y(ix)
    add     a, (hl)
    ld      d, a
    inc     hl
    add     a, (hl)
    ld      b, a
    inc     hl
    call    _EnemyIsHit
    jr      nc, 123$
    ld      a, PSSHOT_TYPE(ix)
    cp      #PSSHOT_TYPE_SINGLE
    jr      nz, 122$
    xor     a
    ld      PSSHOT_TYPE(ix), a
    jr      129$
122$:
    ld      de, #-0x0008
    jr      124$
123$:
    ld      a, PSSHOT_TYPE(ix)
    cp      #PSSHOT_TYPE_SINGLE
    jr      nz, 129$
    ld      de, #-0x0004
124$:
    add     hl, de
    ld      a, PSSHOT_POSITION_X(ix)
    add     a, (hl)
    ld      PSSHOT_POSITION_X(ix), a
    inc     hl
    inc     hl
    ld      a, PSSHOT_POSITION_Y(ix)
    add     a, (hl)
    ld      PSSHOT_POSITION_Y(ix), a
    ld      a, #PSSHOT_TYPE_SINGLE
    ld      PSSHOT_TYPE(ix), a
;   jr      129$
129$:
;   jr      190$

    ; 次のショットへ
190$:
    ld      de, #PSSHOT_LENGTH
    add     ix, de
    pop     bc
    dec     b
    jp      nz, 100$

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; プレイヤショットの初期値
;
psshotDefault:

    .db     PSSHOT_TYPE_NULL
    .db     PSSHOT_POSITION_NULL
    .db     PSSHOT_POSITION_NULL
    .db     PSSHOT_SPRITE_NULL

; スプライト
;
psshotSprite:

    .db     0x00
    .db     0x10
    .db     0x14
    .db     0x18
    .db     0x1c

; 大きさ
;
psshotRect:

    .db      0x00, 0x00,  0x00, 0x00,  0x00, 0x00,  0x00, 0x00
    .db      0x00, 0x02, -0x0c, 0x18,  0x00, 0x00,  0x00, 0x00
    .db     -0x0c, 0x02, -0x0c, 0x18, +0x0a, 0x02, -0x0c, 0x18
    .db     -0x0a, 0x02, -0x0c, 0x18, +0x08, 0x02, -0x0c, 0x18
    .db     -0x08, 0x02, -0x0c, 0x18, +0x06, 0x02, -0x0c, 0x18


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤショット
;
_psshot::
    
    .ds     PSSHOT_LENGTH * PSSHOT_ENTRY
