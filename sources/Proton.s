; Proton.s : プロトン
;


; モジュール宣言
;
    .module Proton

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "Proton.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プロトンを初期化する
;
_ProtonInitialize::
    
    ; レジスタの保存

    ; 初期値の設定
    ld      hl, #protonDefault
    ld      de, #_proton
    ld      bc, #PROTON_LENGTH
    ldir
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プロトンを更新する
;
_ProtonUpdate::
    
    ; レジスタの保存

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_proton + PROTON_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #protonProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; プロトンを描画する
;
_ProtonRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      a, (_proton + PROTON_STATE)
    or      a
    jr      z, 10$
    ld      hl, #(_proton + PROTON_FLAG)
    bit     #PROTON_FLAG_ENABLE_BIT, (hl)
    jr      z, 10$
    ld      hl, #(_sprite + GAME_SPRITE_PROTON)
    ld      a, (_proton + PROTON_POSITION_Y)
    sub     #(PROTON_SPRITE_R + 0x01)
    ld      (hl), a
    inc     hl
    ld      a, (_proton + PROTON_POSITION_X)
    sub     #PROTON_SPRITE_R
    ld      (hl), a
    inc     hl
    ld      a, (_proton + PROTON_SPRITE)
    ld      (hl), a
    inc     hl
    ld      a, (_proton + PROTON_COLOR)
    ld      (hl), a
;   inc     hl
10$:

    ; レジスタの復帰

    ; 終了
    ret

; プロトンを登録する
;
_ProtonEntry::

    ; レジスタの保存

    ; 状態の設定
    ld      a, #PROTON_STATE_SIGHT
    ld      (_proton + PROTON_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
ProtonNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret
    
; 照準で狙う
;
ProtonSight:

    ; レジスタの保存

    ; 初期化
    ld      a, (_proton + PROTON_STATE)
    and     #0x0f
    jr      nz, 09$

    ; スプライトの設定
    ld      a, #0x70
    ld      (_proton + PROTON_SPRITE), a

    ; 色の設定
    ld      a, #0x06
    ld      (_proton + PROTON_COLOR), a

    ; 状態の更新
    ld      hl, #(_proton + PROTON_STATE)
    inc     (hl)
09$:

    ; キー入力
    ld      hl, #(_proton + PROTON_FLAG)
    bit     #PROTON_FLAG_ENABLE_BIT, (hl)
    jr      z, 19$
    ld      a, (_input + INPUT_BUTTON_F)
    dec     a
    jr      nz, 19$
    ld      a, #PROTON_STATE_MISSILE
    ld      (_proton + PROTON_STATE), a
    jr      90$
19$:

    ; 位置の更新
    ld      hl, #(_proton + PROTON_FLAG)
    ld      a, (_player + PLAYER_POSITION_X)
    ld      (_proton + PROTON_POSITION_X), a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     #PROTON_DISTANCE
    ld      (_proton + PROTON_POSITION_Y), a
    jr      c, 20$
    set     #PROTON_FLAG_ENABLE_BIT, (hl)
    jr      29$
20$:
    res     #PROTON_FLAG_ENABLE_BIT, (hl)
;   jr      29$
29$:

    ; 照準の完了
90$:

    ; ゲームの監視
    ld      hl, #(_game + GAME_FLAG)
    bit     #GAME_FLAG_PLAY_BIT, (hl)
    jr      nz, 91$
    xor     a
    ld      (_proton + PROTON_STATE), a
91$:

    ; レジスタの復帰

    ; 終了
    ret

; ミサイルが発射される
;
ProtonMissile::

    ; レジスタの保存

    ; 初期化
    ld      a, (_proton + PROTON_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 位置の設定
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      (_proton + PROTON_POSITION_Y), a

    ; 色の設定
    ld      a, #0x06
    ld      (_proton + PROTON_COLOR), a

    ; フレームの設定
    ld      a, #0x0c
    ld      (_proton + PROTON_FRAME), a

    ; 状態の更新
    ld      hl, #(_proton + PROTON_STATE)
    inc     (hl)
09$:

    ; 位置の更新
    ld      a, (_proton + PROTON_POSITION_Y)
    sub     #PROTON_SPEED_MISSILE
    ld      (_proton + PROTON_POSITION_Y), a

    ; フレームの更新
    ld      hl, #(_proton + PROTON_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; PORT のヒット
    ld      a, (_proton + PROTON_POSITION_X)
    add     a, #PROTON_RECT_X
    ld      e, a
    add     a, #PROTON_RECT_WIDTH
    ld      c, a
    ld      a, (_proton + PROTON_POSITION_Y)
    add     a, #PROTON_RECT_Y
    ld      d, a
    add     a, #PROTON_RECT_HEIGHT
    ld      b, a
    ld      a, #ENEMY_TYPE_PORT
    call    _EnemyIsHitType
    ld      a, #PROTON_STATE_BOMB
    ld      (_proton + PROTON_STATE), a
19$:

    ; スプライトの設定
    ld      a, (_proton + PROTON_FRAME)
    and     #0x0c
    add     a, #0x74
    ld      (_proton + PROTON_SPRITE), a

    ; レジスタの復帰

    ; 終了
    ret
    
; 爆発する
;
ProtonBomb:

    ; レジスタの保存

    ; 初期化
    ld      a, (_proton + PROTON_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 色の設定
    ld      a, #0x06
    ld      (_proton + PROTON_COLOR), a

    ; フレームの設定
    ld      a, #(0x30 / 0x04)
    ld      (_proton + PROTON_FRAME), a

    ; SE の再生
    ld      a, #GAME_SOUND_SE_BOMB
    call    _GamePlaySe

    ; 状態の更新
    ld      hl, #(_proton + PROTON_STATE)
    inc     (hl)
09$:

    ; 位置の更新
    ld      a, (_proton + PROTON_POSITION_Y)
    add     a, #PROTON_SPEED_BOMB
    ld      (_proton + PROTON_POSITION_Y), a

    ; フレームの更新
    ld      hl, #(_proton + PROTON_FRAME)
    dec     (hl)
    jr      nz, 19$
    xor     a
    ld      (_proton + PROTON_STATE), a
19$:

    ; スプライトの設定
    ld      a, (_proton + PROTON_FRAME)
    and     #0x0c
    add     a, #0x34
    ld      (_proton + PROTON_SPRITE), a

    ; レジスタの復帰

    ; 終了
    ret
    
; 定数の定義
;

; 状態別の処理
;
protonProc:

    .dw     ProtonNull
    .dw     ProtonSight
    .dw     ProtonMissile
    .dw     ProtonBomb

; プロトンの初期値
;
protonDefault:

    .db     PROTON_STATE_NULL
    .db     PROTON_FLAG_NULL
    .db     PROTON_POSITION_NULL
    .db     PROTON_POSITION_NULL
    .db     PROTON_SPRITE_NULL
    .db     PROTON_COLOR_NULL
    .db     PROTON_FRAME_NULL


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プロトン
;
_proton::
    
    .ds     PROTON_LENGTH
