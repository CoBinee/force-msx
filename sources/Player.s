; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Player.inc"
    .include    "PsShot.inc"
    .include    "Bomb.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存

    ; 初期値の設定
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; ヒット／描画の更新
    ld      hl, #(_player + PLAYER_FLAG)
    ld      de, #(_player + PLAYER_NOHIT)
    ld      a, (de)
    or      a
    jr      z, 20$
    dec     a
    ld      (de), a
    set     #PLAYER_FLAG_NOHIT_BIT, (hl)
    ld      de, #(_game + GAME_REQUEST)
    ex      de, hl
    set     #GAME_REQUEST_RATE_MINUS_1_0_BIT, (hl)
    ex      de, hl
    jr      21$
20$:
    res     #PLAYER_FLAG_NOHIT_BIT, (hl)
21$:
    and     #0x02
    jr      z, 22$
    set     #PLAYER_FLAG_NORENDER_BIT, (hl)
    jr      23$
22$:
    res     #PLAYER_FLAG_NORENDER_BIT, (hl)
23$:

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを描画する
;
_PlayerRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_NORENDER_BIT, a
    jr      nz, 19$
    ld      hl, #(_sprite + GAME_SPRITE_PLAYER)
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     #(PLAYER_SPRITE_R + 0x01)
    ld      (hl), a
    inc     hl
    ld      a, (_player + PLAYER_POSITION_X)
    sub     #PLAYER_SPRITE_R
    ld      (hl), a
    inc     hl
    ld      a, (_player + PLAYER_SPRITE)
    ld      (hl), a
    inc     hl
    ld      a, (_player + PLAYER_COLOR)
    ld      (hl), a
;   inc     hl
19$:

    ; レジスタの復帰

    ; 終了
    ret
    
; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが登場する
;
PlayerStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 速度の設定
    ld      a, #-0x08
    ld      (_player + PLAYER_SPEED_Y), a

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 移動
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      de, #(_player + PLAYER_SPEED_Y)
    ld      a, (de)
    cp      #0x80
    jr      nc, 10$
    ld      a, #0x01
10$:
    add     a, (hl)
    ld      (hl), a
    cp      #0xa0
    jr      nc, 19$
    ex      de, hl
    inc     (hl)
    ld      a, (hl)
    cp      #0x10
    jr      nz, 19$

    ; 移動の完了
    ld      a, #PLAYER_STATE_PLAY
    ld      (_player + PLAYER_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを操作する
;
PlayerPlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 速度の設定
    ld      a, #PLAYER_SPEED_MOVE
    ld      (_player + PLAYER_SPEED_X), a
    ld      (_player + PLAYER_SPEED_Y), a

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 上下の移動
    ld      a, (_player + PLAYER_SPEED_Y)
    ld      c, a
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 11$
    ld      a, (hl)
    sub     c
    cp      #PLAYER_REGION_TOP
    jr      nc, 10$
    ld      a, #PLAYER_REGION_TOP
10$:
    ld      (hl), a
    jr      19$
11$:
    ld      a, (_input + INPUT_KEY_DOWN)
    or      a
    jr      z, 19$
    ld      a, (hl)
    add     a, c
    cp      #(PLAYER_REGION_BOTTOM + 0x01)
    jr      c, 12$
    ld      a, #PLAYER_REGION_BOTTOM
12$:
    ld      (hl), a
;   jr      19$
19$:

    ; 左右の移動
    ld      a, (_player + PLAYER_SPEED_X)
    ld      c, a
    ld      hl, #(_player + PLAYER_POSITION_X)
    ld      de, #(_player + PLAYER_ROTATE)
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 21$
    ld      a, (hl)
    sub     c
    cp      #PLAYER_REGION_LEFT
    jr      nc, 20$
    ld      a, #PLAYER_REGION_LEFT
20$:
    ld      (hl), a
    ld      a, (de)
    or      a
    jr      z, 29$
    dec     a
    ld      (de), a
    jr      29$
21$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 23$
    ld      a, (hl)
    add     a, c
    cp      #(PLAYER_REGION_RIGHT + 0x01)
    jr      c, 22$
    ld      a, #PLAYER_REGION_RIGHT
22$:
    ld      (hl), a
    ld      a, (de)
    cp      #PLAYER_ROTATE_RIGHT
    jr      nc, 29$
    inc     a
    ld      (de), a
    jr      29$
23$:
    ld      a, (de)
    cp      #PLAYER_ROTATE_CENTER
    jr      z, 29$
    jr      nc, 24$
    inc     a
    ld      (de), a
    jr      29$
24$:
    dec     a
    ld      (de), a
;   jr      29$
29$:

    ; ショット
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 39$
    ld      a, (_player + PLAYER_POSITION_X)
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      d, a
    ld      a, (_player + PLAYER_ROTATE)
    ld      c, a
    ld      b, #0x00
    ld      hl, #playerShot
    add     hl, bc
    ld      a, (hl)
    call    _PsShotEntry
;   jr      39$
39$:

    ; スプライトの設定
    ld      a, (_player + PLAYER_ROTATE)
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerSprite
    add     hl, de
    ld      a, (hl)
    ld      (_player + PLAYER_SPRITE), a

    ; ゲームの監視
    ld      hl, #(_game + GAME_FLAG)
    bit     #GAME_FLAG_PLAY_BIT, (hl)
    jr      nz, 49$
;   bit     #GAME_FLAG_OVER_BIT, (hl)
;   jr      z, 49$
    ld      a, #PLAYER_STATE_OVER
    ld      (_player + PLAYER_STATE), a
49$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがミスする
;
PlayerMiss:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 無敵の設定
    ld      a, #PLAYER_NOHIT_LENGTH
    ld      (_player + PLAYER_NOHIT), a

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; X 位置の更新
    ld      hl, #(_player + PLAYER_POSITION_X)
    ld      de, #(_player + PLAYER_SPEED_X)
    ld      a, (de)
    add     a, (hl)
    cp      #PLAYER_REGION_LEFT
    jr      nc, 10$
    ld      a, #PLAYER_REGION_LEFT
    jr      11$
10$:
    cp      #(PLAYER_REGION_RIGHT + 0x01)
    jr      c, 11$
    ld      a, #PLAYER_REGION_RIGHT
;   jr      11$
11$:
    ld      (hl), a

    ; X 速度の更新
    ld      a, (de)
    or      a
    jr      z, 19$
    cp      #0x80
    jr      nc, 12$
    dec     a
    jr      13$
12$:
    inc     a
;   jr      13$
13$:
    ld      (de), a
19$:

    ; Y 位置の更新
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      de, #(_player + PLAYER_SPEED_Y)
    ld      a, (de)
    add     a, (hl)
    cp      #PLAYER_REGION_TOP
    jr      nc, 20$
    ld      a, #PLAYER_REGION_TOP
    jr      21$
20$:
    cp      #(PLAYER_REGION_BOTTOM + 0x01)
    jr      c, 21$
    ld      a, #PLAYER_REGION_BOTTOM
;   jr      21$
21$:
    ld      (hl), a

    ; X 速度の更新
    ld      a, (de)
    or      a
    jr      z, 29$
    cp      #0x80
    jr      nc, 22$
    dec     a
    jr      23$
22$:
    inc     a
;   jr      23$
23$:
    ld      (de), a
29$:

    ; ミスの完了
    ld      a, (_player + PLAYER_SPEED_X)
    ld      c, a
    ld      a, (_player + PLAYER_SPEED_Y)
    or      c
    jr      nz, 39$
    ld      a, #PLAYER_STATE_PLAY
    ld      (_player + PLAYER_STATE), a
39$:

    ; レジスタの復帰

    ; 終了
    ret    

; プレイヤが退場する
;
PlayerOver:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_NORENDER_BIT, (hl)

    ; 速度の設定
    xor     a
    ld      (_player + PLAYER_SPEED_X), a
    ld      a, #0x08
    ld      (_player + PLAYER_SPEED_Y), a

    ; スプライトの設定
    ld      a, #0x20
    ld      (_player + PLAYER_SPRITE), a

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 移動
;   ld      hl, #(_game + GAME_FLAG)
;   bit     #GAME_FLAG_OVER_BIT, (hl)
;   jr      z, 19$
    ld      hl, #(_player + PLAYER_SPEED_Y)
    ld      a, (hl)
    cp      #-0x08
    jr      z, 10$
    dec     a
    ld      (hl), a
10$:
    ld      hl, #(_player + PLAYER_POSITION_Y)
    add     a, (hl)
    ld      (hl), a
    cp      #0xf4
    jr      nc, 19$
    cp      #0xe0
    jr      c, 19$

    ; 移動の完了
    xor     a
    ld      (_player + PLAYER_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤにヒットしたかどうかを判定する
;
_PlayerIsHit::

    ; レジスタの保存
    push    bc
    push    de

    ; de < 判定する矩形の左上
    ; bc < 判定する矩形の右下
    ; cf > ヒットした

    ; プレイヤの存在
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_NOHIT_BIT, a
    jr      nz, 190$

    ; X 座標の判定
    ld      a, (_player + PLAYER_POSITION_X)
    sub     #PLAYER_R
    cp      c
    jr      nc, 190$
    add     a, #(PLAYER_R * 0x02)
    cp      e
    jr      c, 190$

    ; Y 座標の判定
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     #PLAYER_R
    cp      b
    jr      nc, 190$
    add     a, #(PLAYER_R * 0x02)
    cp      d
    jr      c, 190$

    ; ヒットした
180$:

    ; 相手の中心の取得
    ld      a, e
    add     a, c
    rra
    ld      e, a
    ld      a, d
    add     a, b
    rra
    ld      d, a

    ; ミスの設定
    ld      a, (_player + PLAYER_POSITION_X)
    sub     e
    jr      nc, 181$
    neg
181$:
    ld      c, a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     d
    jr      nc, 182$
    neg
182$:
    cp      c
    jr      nc, 185$
    ld      a, (_player + PLAYER_POSITION_X)
    sub     e
    jr      z, 184$
    jr      nc, 183$
    ld      a, #-PLAYER_SPEED_MISS
    jr      184$
183$:
    ld      a, #PLAYER_SPEED_MISS
;   jr      184$
184$:
    ld      (_player + PLAYER_SPEED_X), a
    xor     a
    ld      (_player + PLAYER_SPEED_Y), a
    jr      188$
185$:
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     d
    jr      z, 187$
    jr      nc, 186$
    ld      a, #-PLAYER_SPEED_MISS
    jr      187$
186$:
    ld      a, #PLAYER_SPEED_MISS
;   jr      187$
187$:
    ld      (_player + PLAYER_SPEED_Y), a
    xor     a
    ld      (_player + PLAYER_SPEED_X), a
;   jr      188$
188$:
    ld      a, #PLAYER_STATE_MISS
    ld      (_player + PLAYER_STATE), a

    ; 爆発の設定
    ld      a, (_player + PLAYER_POSITION_X)
    add     a, e
    rra
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, d
    rra
    ld      d, a
    ld      c, #0x06
    ld      b, #0x00
    call    _BombEntry

    ; フラグのセット
    scf
    jr      90$

    ; ヒットしない
190$:
    or      a
;   jr      90$

    ; 判定の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; プレイヤの存在を確認する
;
_PlayerIsAlive::

    ; レジスタの保存

    ; cf > 存在する

    ; 存在の確認
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      z, 10$
    scf
10$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
playerProc:
    
    .dw     PlayerNull
    .dw     PlayerStart
    .dw     PlayerPlay
    .dw     PlayerMiss
    .dw     PlayerOver

; プレイヤの初期値
;
playerDefault:

    .db     PLAYER_STATE_START
    .db     PLAYER_FLAG_NULL
    .db     0x80
    .db     0xcc
    .db     PLAYER_SPEED_NULL
    .db     PLAYER_SPEED_NULL
    .db     PLAYER_ROTATE_CENTER
    .db     0x20
    .db     0x0f
    .db     PLAYER_NOHIT_NULL

; ショット
;
playerShot:

    .db     PSSHOT_TYPE_TWIN_SHORT
    .db     PSSHOT_TYPE_TWIN_MIDDLE, PSSHOT_TYPE_TWIN_MIDDLE, PSSHOT_TYPE_TWIN_MIDDLE
    .db     PSSHOT_TYPE_TWIN_LONG
    .db     PSSHOT_TYPE_TWIN_MIDDLE, PSSHOT_TYPE_TWIN_MIDDLE, PSSHOT_TYPE_TWIN_MIDDLE
    .db     PSSHOT_TYPE_TWIN_SHORT

; スプライト
;
playerSprite:

    .db     0x28
    .db     0x24, 0x24, 0x24
    .db     0x20
    .db     0x2c, 0x2c, 0x2c
    .db     0x30


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH
