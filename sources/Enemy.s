; Enemy.s : エネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "EsShot.inc"
    .include    "Bomb.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存

    ; 初期値の設定
    ld      de, #_enemy
    ld      a, #ENEMY_ENTRY
10$:
    ld      hl, #enemyDefaultNull
    ld      bc, #ENEMY_LENGTH
    ldir
    dec     a
    jr      nz, 10$

    ; 残りの数の初期化
    ld      a, #ENEMY_ENTRY
    ld      (enemyRest), a

    ; 出現数の初期化
    call    EnemyNext

    ; スプライトの初期化
    xor     a
    ld      (enemySprite), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存
    
    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    push    bc

    ; 種類別の処理
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$
    ld      hl, #19$
    push    hl
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
19$:

    ; 次のエネミーへ
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      ix, #_enemy
    ld      a, (_game + GAME_SPRITE_ENEMY)
    ld      e, a
    add     a, #ENEMY_SPRITE_LENGTH
    ld      c, a
    ld      a, (enemySprite)
    add     a, e
    ld      e, a
    ld      b, #ENEMY_ENTRY
10$:
    push    bc
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$
    bit     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)
    jr      nz, 19$
    ld      hl,  #_sprite
    ld      d, #0x00
    add     hl, de
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #(ENEMY_SPRITE_R + 0x01)
    ld      (hl), a
    inc     hl
    ld      a, ENEMY_POSITION_X(ix)
    cp      #0x20
    jr      nc, 11$
    add     a, #0x20
    ld      d, #0x80
11$:
    sub     #ENEMY_SPRITE_R
    ld      (hl), a
    inc     hl
    ld      a, ENEMY_SPRITE(ix)
    ld      (hl), a
    inc     hl
    ld      a, ENEMY_COLOR(ix)
    or      d
    ld      (hl), a
;   inc     hl
    ld      a, e
    add     a, #0x04
    cp      c
    jr      c, 12$
    ld      a, (_game + GAME_SPRITE_ENEMY)
12$:
    ld      e, a
19$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; スプライトの更新
    ld      hl, #enemySprite
    ld      a, (hl)
    add     a, #0x04
    cp      #ENEMY_SPRITE_LENGTH
    jr      c, 91$
    xor     a
91$:
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを登録する
;
_EnemyEntry::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; 種類別の処理
    ld      a, (_game + GAME_REQUEST)
    bit     #GAME_REQUEST_ENEMY_PORT_BIT, a
    jp      nz, 300$
    bit     #GAME_REQUEST_ENEMY_ADVANCED_BIT, a
    jp      nz, 200$

    ; FIGHTER の登録
100$:
    ld      a, (enemyNext)
    ld      b, a
    ld      a, (enemyRest)
    cp      b
    jp      c, 190$
    call    EnemyNext

    ; 登録数の保存
    push    bc

    ; 初期値の取得
    ld      hl, #enemyDefaultFighter
    ld      de, #enemyDefault
    ld      bc, #ENEMY_LENGTH
    ldir

    ; 出現位置の取得
    call    _SystemGetRandom
    and     #0x38
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyLocationFighter
    add     hl, de

    ; 位置の取得
    call    _SystemGetRandom
    and     (hl)
    inc     hl
    add     a, (hl)
    inc     hl
    ld      (enemyDefault + ENEMY_POSITION_X), a
    call    _SystemGetRandom
    and     (hl)
    inc     hl
    add     a, (hl)
    inc     hl
    ld      (enemyDefault + ENEMY_POSITION_Y), a

    ; 速度の取得
    ld      a, (hl)
    inc     hl
    ld      (enemyDefault + ENEMY_SPEED_X), a
    ld      a, (hl)
    inc     hl
    ld      (enemyDefault + ENEMY_SPEED_Y), a

    ; 向きの取得
    ld      a, (hl)
    inc     hl
    ld      (enemyDefault + ENEMY_DIRECTION_X), a
    ld      a, (hl)
;   inc     hl
    ld      (enemyDefault + ENEMY_DIRECTION_Y), a

    ; 移動の取得
    ld      hl, #(enemyDefault + ENEMY_MOVE_X_PARAM_0)
    ld      b, #ENEMY_MOVE_PARAM_LENGTH
110$:
    call    _SystemGetRandom
    and     #0x03
    add     a, #0x03
    ld      (hl), a
    inc     hl
    djnz    110$
    ld      hl, #(enemyDefault + ENEMY_MOVE_Y_PARAM_0)
    ld      b, #ENEMY_MOVE_PARAM_LENGTH
111$:
    call    _SystemGetRandom
    and     #0x03
    add     a, #0x03
    ld      (hl), a
    inc     hl
    djnz    111$

    ; 最初は直進させる
    ld      b, #0x0c
    ld      a, (enemyDefault + ENEMY_MOVE_X_PARAM_0)
    add     a, b
    ld      (enemyDefault + ENEMY_MOVE_X_COUNT), a
    ld      a, (enemyDefault + ENEMY_MOVE_Y_PARAM_0)
    add     a, b
    ld      (enemyDefault + ENEMY_MOVE_Y_COUNT), a

    ; 登録数の復帰
    pop     bc

    ; FIGHTER の設定
    ld      ix, #_enemy
    call    _SystemGetRandom
    and     #0x18
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyColor
    add     hl, de
    ld      c, #0x01
130$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 131$
    ld      de, #ENEMY_LENGTH
    add     ix, de
    jr      130$
131$:
    push    hl
    push    bc
    ld      hl, #enemyDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     bc
    pop     hl
    ld      a, (hl)
    ld      ENEMY_COLOR(ix), a
    inc     hl
    ld      ENEMY_FRAME(ix), c
    ld      a, c
    add     a, #0x06
    ld      c, a
    ld      a, (enemyRest)
    dec     a
    ld      (enemyRest), a
    ld      de, #ENEMY_LENGTH
    add     ix, de
    djnz    130$
;   jr      190$

    ; FIGHTER の登録の完了
190$:
    jr      90$

    ; ADVANCED の登録
200$:
    ld      a, (enemyRest)
    or      a
    jr      z, 290$

    ; ADVANCED の設定
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
210$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 211$
    add     ix, de
    djnz    210$
    jr      219$
211$:
    ld      hl, #enemyDefaultAdvanced
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    ld      hl, #enemyRest
    dec     (hl)
    ld      hl, #(_game + GAME_REQUEST)
    res     #GAME_REQUEST_ENEMY_ADVANCED_BIT, (hl)
    ld      hl, #(_game + GAME_FLAG)
    set     #GAME_FLAG_ADVANCED_BIT, (hl)
219$:
;   jr      290$
290$:
    jr      90$

    ; PORT の登録
300$:
    ld      a, (enemyRest)
    or      a
    jr      z, 390$

    ; PORT の設定
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
310$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 311$
    add     ix, de
    djnz    310$
    jr      319$
311$:
    ld      hl, #enemyDefaultPort
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    ld      hl, #enemyRest
    dec     (hl)
    ld      hl, #(_game + GAME_REQUEST)
    res     #GAME_REQUEST_ENEMY_PORT_BIT, (hl)
319$:
;   jr      390$
390$:
;   jr      90$

    ; 登録の完了
90$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 何もしない
;
EnemyNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; FIGHTER が行動する
;
EnemyFighter:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; フレームの更新
    dec     ENEMY_FRAME(ix)
    jp      nz, 90$

    ; フレームの設定
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x1f
    ld      ENEMY_FRAME(ix), a

    ; ヒットの設定
    res     #ENEMY_FLAG_NOHIT_BIT, ENEMY_FLAG(ix)

    ; 描画の設定
    res     #ENEMY_FLAG_NORENDER_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; X 方向の移動
    dec     ENEMY_MOVE_X_COUNT(ix)
    jr      nz, 103$
    ld      a, ENEMY_SPEED_X(ix)
    cp      #-ENEMY_SPEED_FIGHTER
    jr      z, 100$
    cp      #ENEMY_SPEED_FIGHTER
    jr      z, 100$
    or      a
    jr      z, 101$
    jr      102$
100$:
    ld      a, ENEMY_DIRECTION_X(ix)
    neg
    ld      ENEMY_DIRECTION_X(ix), a
101$:
    ld      a, ENEMY_MOVE_X_INDEX(ix)
    inc     a
    and     #(ENEMY_MOVE_PARAM_LENGTH - 0x01)
    ld      ENEMY_MOVE_X_INDEX(ix), a
102$:
    ld      a, ENEMY_SPEED_X(ix)
    add     a, ENEMY_DIRECTION_X(ix)
    ld      ENEMY_SPEED_X(ix), a
    push    ix
    pop     hl
    ld      a, ENEMY_MOVE_X_INDEX(ix)
    add     a, #ENEMY_MOVE_X_PARAM_0
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      a, (hl)
    ld      ENEMY_MOVE_X_COUNT(ix), a
103$:
    ld      a, ENEMY_POSITION_X(ix)
    add     a, ENEMY_SPEED_X(ix)
    ld      ENEMY_POSITION_X(ix), a
109$:

    ; Y 方向の移動
    dec     ENEMY_MOVE_Y_COUNT(ix)
    jr      nz, 113$
    ld      a, ENEMY_SPEED_Y(ix)
    cp      #-ENEMY_SPEED_FIGHTER
    jr      z, 110$
    cp      #ENEMY_SPEED_FIGHTER
    jr      z, 110$
    or      a
    jr      z, 111$
    jr      112$
110$:
    ld      a, ENEMY_DIRECTION_Y(ix)
    neg
    ld      ENEMY_DIRECTION_Y(ix), a
111$:
    ld      a, ENEMY_MOVE_Y_INDEX(ix)
    inc     a
    and     #(ENEMY_MOVE_PARAM_LENGTH - 0x01)
    ld      ENEMY_MOVE_Y_INDEX(ix), a
112$:
    ld      a, ENEMY_SPEED_Y(ix)
    add     a, ENEMY_DIRECTION_Y(ix)
    ld      ENEMY_SPEED_Y(ix), a
    push    ix
    pop     hl
    ld      a, ENEMY_MOVE_Y_INDEX(ix)
    add     a, #ENEMY_MOVE_Y_PARAM_0
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      a, (hl)
    ld      ENEMY_MOVE_Y_COUNT(ix), a
113$:
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, ENEMY_SPEED_Y(ix)
    ld      ENEMY_POSITION_Y(ix), a
119$:

    ; 画面外の判定
    ld      a, ENEMY_POSITION_X(ix)
    cp      #ENEMY_REGION_FIGHTER_LEFT
    jr      c, 120$
    cp      #(ENEMY_REGION_FIGHTER_RIGHT + 0x01)
    jr      nc, 120$
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #(ENEMY_REGION_FIGHTER_BOTTOM + 0x01)
    jr      c, 129$
    cp      #ENEMY_REGION_FIGHTER_TOP
    jr      nc, 129$
120$:
    call    EnemyKill
    jr      190$
129$:

    ; ショット
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     #(ENEMY_R * 2)
    cp      ENEMY_POSITION_Y(ix)
    jr      c, 139$
    dec     ENEMY_FRAME(ix)
    jr      nz, 139$
    ld      a, #ESSHOT_TYPE_FIGHTER
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    call    _EsShotEntry
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x1f
    ld      ENEMY_FRAME(ix), a
139$:

    ; スプライトの設定
    ld      a, ENEMY_SPEED_X(ix)
    add     a, #ENEMY_SPEED_FIGHTER
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemySpriteFighter
    add     hl, de
    ld      a, (hl)
    ld      ENEMY_SPRITE(ix), a

    ; 移動の完了
190$:

    ; 行動の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; ADVANCED が行動する
;
EnemyAdvanced:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x0f
    ld      ENEMY_FRAME(ix), a

    ; BGM の再生
    ld      a, #GAME_SOUND_BGM_ADVANCED
    call    _GamePlayBgm

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; X 方向の移動
    ld      a, ENEMY_POSITION_X(ix)
    add     a, ENEMY_SPEED_X(ix)
    cp      #ENEMY_REGION_ADVANCED_LEFT
    jr      nc, 100$
    ld      ENEMY_SPEED_X(ix), #ENEMY_SPEED_ADVANCED_X
    ld      a, #ENEMY_REGION_ADVANCED_LEFT
    jr      101$
100$:
    cp      #(ENEMY_REGION_ADVANCED_RIGHT + 0x01)
    jr      c, 101$
    ld      ENEMY_SPEED_X(ix), #-ENEMY_SPEED_ADVANCED_X
    ld      a, #ENEMY_REGION_ADVANCED_RIGHT
;   jr      101$
101$:
    ld      ENEMY_POSITION_X(ix), a

    ; Y 方向の移動
    ld      a, ENEMY_MOVE_Y_INDEX(ix)
    or      a
    jr      z, 110$
    dec     ENEMY_MOVE_Y_INDEX(ix)
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #0x01
    ld      ENEMY_POSITION_Y(ix), a
110$:
    dec     ENEMY_MOVE_Y_COUNT(ix)
    jr      nz, 119$
    ld      a, ENEMY_SPEED_Y(ix)
    cp      #-ENEMY_SPEED_ADVANCED_Y
    jr      z, 111$
    cp      #ENEMY_SPEED_ADVANCED_Y
    jr      nz, 112$
111$:
    ld      a, ENEMY_DIRECTION_Y(ix)
    neg
    ld      ENEMY_DIRECTION_Y(ix), a
112$:
    ld      a, ENEMY_SPEED_Y(ix)
    add     a, ENEMY_DIRECTION_Y(ix)
    ld      ENEMY_SPEED_Y(ix), a
    ld      a, ENEMY_MOVE_Y_PARAM_0(ix)
    ld      ENEMY_MOVE_Y_COUNT(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, ENEMY_SPEED_Y(ix)
    ld      ENEMY_POSITION_Y(ix), a
119$:

    ; ショット
    dec     ENEMY_FRAME(ix)
    jr      nz, 139$
    ld      a, #ESSHOT_TYPE_ADVANCED
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    call    _EsShotEntry
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x0f
    ld      ENEMY_FRAME(ix), a
139$:

    ; レジスタの復帰

    ; 終了
    ret

; PORT が行動する
;
EnemyPort::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, #ENEMY_SPEED_PORT
    ld      ENEMY_POSITION_Y(ix), a
    cp      #ENEMY_REGION_PORT_TOP
    jr      nc, 10$
    cp      #ENEMY_REGION_PORT_BOTTOM
    jr      c, 10$
    xor     a
    ld      ENEMY_TYPE(ix), a

    ; リクエスト
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_OVER_BIT, (hl)
    bit     #ENEMY_FLAG_BOMB_BIT, ENEMY_FLAG(ix)
    jr      z, 19$
    set     #GAME_REQUEST_BONUS_BIT, (hl)
    jr      19$

    ; パラメータの更新
10$:
    inc     ENEMY_MOVE_Y_COUNT(ix)
    ld      a, ENEMY_MOVE_Y_COUNT(ix)
    cpl
    and     #0x01
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      c, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      l, ENEMY_MOVE_Y_PARAM_0(ix)
    ld      h, ENEMY_MOVE_Y_PARAM_1(ix)
    add     hl, de
    ld      ENEMY_MOVE_Y_PARAM_0(ix), l
    ld      ENEMY_MOVE_Y_PARAM_1(ix), h
    ex      de, hl
    ld      a, #0x90
    sub     c
    ld      c, a
    ld      b, #0x04
11$:
    ld      a, d
    cp      #0x03
    jr      nc, 12$
    ld      hl, #_appPatternName
    add     hl, de
    ld      (hl), c
    inc     hl
    inc     c
    ld      (hl), c
    inc     hl
    inc     c
    ld      (hl), c
    inc     hl
    inc     c
    jr      13$
12$:
    ld      a, c
    add     a, #0x03
    ld      c, a
;   jr      13$
13$:
    ld      hl, #0x0020
    add     hl, de
    ex      de, hl
    djnz    11$

    ; 移動の完了
19$:

    ; 爆発する
    bit     #ENEMY_FLAG_BOMB_BIT, ENEMY_FLAG(ix)
    jr      z, 29$
    ld      a, ENEMY_FRAME(ix)
    or      a
    jr      nz, 20$
    call    _SystemGetRandom
    and     #0x0f
    sub     #0x08
    add     a, ENEMY_POSITION_X(ix)
    ld      e, a
    call    _SystemGetRandom
    and     #0x0f
    sub     #0x08
    add     a, ENEMY_POSITION_Y(ix)
    ld      d, a
    ld      c, #0x0b
    ld      b, #0x04
    call    _BombEntry
    ld      a, #0x04
    ld      ENEMY_FRAME(ix), a
    jr      29$
20$:
    dec     ENEMY_FRAME(ix)
29$:

    ; レジスタの復帰

    ; 終了
    ret

; 爆発する
;
EnemyBomb:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    ld      a, #(0x03 * 0x02)
    ld      ENEMY_FRAME(ix), a

    ; SE の再生
    ld      a, #GAME_SOUND_SE_BOMB
    call    _GamePlaySe

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; フレームの更新
    dec     ENEMY_FRAME(ix)
    jr      nz, 10$

    ; エネミーの削除
    call    EnemyKill
    jr      19$

    ; スプライトの設定
10$:
    ld      a, ENEMY_FRAME(ix)
    and     #0xfe
    add     a, a
    add     a, #0x34
    ld      ENEMY_SPRITE(ix), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 次に出現するエネミーの数を取得する
;
EnemyNext:

    ; レジスタの保存

    ; 出現数の取得
    call    _SystemGetRandom
    and     #0x03
    add     a, #0x03
    ld      (enemyNext), a

    ; レジスタの復帰

    ; 終了
    ret

; 指定されたエネミーを爆発させる
;
EnemySetBomb:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; ix < 爆発させるエネミー

    ; スコアの更新
    call    _GameAddScoreRate

    ; 爆発の設定
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    push    de
    ld      hl, #enemyDefaultBomb
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    ld      ENEMY_POSITION_X(ix), e
    ld      ENEMY_POSITION_Y(ix), d

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 指定された種類のエネミーを爆発させる
;
_EnemySetBombType::

    ; レジスタの保存
    push    bc
    push    de
    push    ix

    ; a < 種類

    ; FIGHTER の爆発
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      c, a
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_TYPE(ix)
    cp      c
    call    z, EnemySetBomb
    add     ix, de
    djnz    10$

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc

    ; 終了
    ret

; エネミーを削除する
;
EnemyKill:

    ; レジスタの保存
    push    hl

    ; ix < 削除するエネミー

    ; エネミーの削除
    xor     a
    ld      ENEMY_TYPE(ix), a

    ; エネミーの残りの数の更新
    ld      hl, #enemyRest
    inc     (hl)

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; すべてのエネミーを削除する
;
_EnemyKillAll::

    ; レジスタの保存
    push    bc
    push    de
    push    ix

    ; エネミーの削除
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    xor     a
    ld      b, #ENEMY_ENTRY
10$:
    ld      ENEMY_TYPE(ix), a
    add     ix, de
    djnz    10$

    ; エネミーの残りの数の更新
    xor     a
    ld      (enemyRest), a

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc

    ; 終了
    ret

; 指定された種類のエネミーの位置を取得する
;
_EnemyGetPosition::

    ; レジスタの保存
    push    bc
    push    ix

    ; a  < 種類
    ; de > 位置

    ; 位置の取得
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
10$:
    cp      ENEMY_TYPE(ix)
    jr      z, 11$
    add     ix, de
    djnz    10$
    jr      19$
11$:
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     bc

    ; 終了
    ret

; エネミーにヒットしたかどうかを判定する
;
_EnemyIsHit::

    ; レジスタの保存
    push    hl
    push    bc
    push    ix

    ; de < 判定する矩形の左上
    ; bc < 判定する矩形の右下
    ; cf > ヒットした

    ; エネミーの走査
    ld      ix, #_enemy
    ld      h, #ENEMY_ENTRY
100$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 190$
    bit     #ENEMY_FLAG_NOHIT_BIT, ENEMY_FLAG(ix)
    jr      nz, 190$

    ; X 座標の判定
    ld      a, ENEMY_POSITION_X(ix)
    sub     #ENEMY_R
    cp      c
    jr      nc, 190$
    add     a, #(ENEMY_R * 0x02)
    cp      e
    jr      c, 190$

    ; Y 座標の判定
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #ENEMY_R
    cp      b
    jr      nc, 190$
    add     a, #(ENEMY_R * 0x02)
    cp      d
    jr      c, 190$

    ; ヒットした
180$:

    ; 爆発の設定
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_ADVANCED
    call    nz, EnemySetBomb

    ; フラグのセット
    scf
    jr      90$

    ; 次のエネミーへ
190$:
    push    de
    ld      de, #ENEMY_LENGTH
    add     ix, de
    pop     de
    dec     h
    jr      nz, 100$

    ; ヒットしない
    or      a
;   jr      90$

    ; 判定の完了
90$:

    ; レジスタの復帰
    pop     ix
    pop     bc
    pop     hl

    ; 終了
    ret

; 特定のエネミーにヒットしたかどうかを判定する
;
_EnemyIsHitType::

    ; レジスタの保存
    push    hl
    push    bc
    push    ix

    ; a  < 種類
    ; de < 判定する矩形の左上
    ; bc < 判定する矩形の右下
    ; cf > ヒットした

    ; エネミーの走査
    ld      ix, #_enemy
    ld      h, #ENEMY_ENTRY
10$:
    cp      ENEMY_TYPE(ix)
    jr      z, 11$
    push    bc
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    dec     h
    jr      nz, 10$
    jr      19$

    ; ヒットの判定
11$:

    ; X 座標の判定
    ld      a, ENEMY_POSITION_X(ix)
    sub     #ENEMY_R
    cp      c
    jr      nc, 19$
    add     a, #(ENEMY_R * 0x02)
    cp      e
    jr      c, 19$

    ; Y 座標の判定
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #ENEMY_R
    cp      b
    jr      nc, 19$
    add     a, #(ENEMY_R * 0x02)
    cp      d
    jr      c, 19$

    ; ヒットした

    ; 爆発の設定
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_PORT
    call    nz, EnemySetBomb
    set     #ENEMY_FLAG_BOMB_BIT, ENEMY_FLAG(ix)

    ; フラグのセット
    scf
    jr      90$

    ; ヒットしない
19$:
    or      a
;   jr      90$

    ; 判定の完了
90$:

    ; レジスタの復帰
    pop     ix
    pop     bc
    pop     hl

    ; 終了
    ret

; プレイヤとのヒットを判定する
;
_EnemyHitPlayer::

    ; レジスタの保存
    push    bc
    push    de
    push    ix

    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    push    bc
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$
    bit     #ENEMY_FLAG_NOHIT_BIT, ENEMY_FLAG(ix)
    jr      nz, 19$

    ; ヒットの判定
    ld      a, ENEMY_POSITION_X(ix)
    sub     #ENEMY_R
    ld      e, a
    add     a, #(ENEMY_R * 0x02)
    ld      c, a
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #ENEMY_R
    ld      d, a
    add     a, #(ENEMY_R * 0x02)
    ld      b, a
    call    _PlayerIsHit
    jr      nc, 19$
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_ADVANCED
    call    nz, EnemySetBomb

    ; 次のエネミーへ
19$:
    ld      de, #ENEMY_LENGTH
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

; 種類別の処理
;
enemyProc:
    
    .dw     EnemyNull
    .dw     EnemyFighter
    .dw     EnemyAdvanced
    .dw     EnemyPort
    .dw     EnemyBomb

; エネミーの初期値
;
enemyDefaultNull:

    .db     ENEMY_TYPE_NULL
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_DIRECTION_NULL
    .db     ENEMY_DIRECTION_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_COLOR_NULL
    .db     ENEMY_FRAME_NULL
    .db     ENEMY_MOVE_INDEX_NULL
    .db     ENEMY_MOVE_COUNT_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_INDEX_NULL
    .db     ENEMY_MOVE_COUNT_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    
enemyDefaultFighter:

    .db     ENEMY_TYPE_FIGHTER
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NORENDER | ENEMY_FLAG_NOHIT
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_DIRECTION_NULL
    .db     ENEMY_DIRECTION_NULL
    .db     0x40
    .db     0x07
    .db     ENEMY_FRAME_NULL
    .db     ENEMY_MOVE_INDEX_NULL
    .db     ENEMY_MOVE_COUNT_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_INDEX_NULL
    .db     ENEMY_MOVE_COUNT_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    
enemyDefaultAdvanced:

    .db     ENEMY_TYPE_ADVANCED
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .db     0x80
    .db     0xcc
    .db     ENEMY_SPEED_ADVANCED_X
    .db     -ENEMY_SPEED_ADVANCED_Y
    .db     ENEMY_DIRECTION_PLUS
    .db     ENEMY_DIRECTION_MINUS
    .db     0x50
    .db     0x01
    .db     ENEMY_FRAME_NULL
    .db     ENEMY_MOVE_INDEX_NULL
    .db     ENEMY_MOVE_COUNT_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     0x28
    .db     0x02
    .db     0x02
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL

enemyDefaultPort:

    .db     ENEMY_TYPE_PORT
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NOHIT | ENEMY_FLAG_NORENDER
    .db     0x8c
    .db     0xf4
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_DIRECTION_NULL
    .db     ENEMY_DIRECTION_NULL
    .db     0x4c ; ENEMY_SPRITE_NULL
    .db     0x0e ; ENEMY_COLOR_NULL
    .db     ENEMY_FRAME_NULL
    .db     ENEMY_MOVE_INDEX_NULL
    .db     ENEMY_MOVE_COUNT_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_INDEX_NULL
    .db     0x00
    .db     0xb0
    .db     0xff
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL

enemyDefaultBomb:

    .db     ENEMY_TYPE_BOMB
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NOHIT
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_DIRECTION_NULL
    .db     ENEMY_DIRECTION_NULL
    .db     0x34
    .db     0x0b
    .db     ENEMY_FRAME_NULL
    .db     ENEMY_MOVE_INDEX_NULL
    .db     ENEMY_MOVE_COUNT_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_INDEX_NULL
    .db     ENEMY_MOVE_COUNT_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL
    .db     ENEMY_MOVE_PARAM_NULL

; 出現位置
;
enemyLocationFighter:

    .db     0x3f, 0x20, 0x00, 0xf4,  ENEMY_SPEED_NULL,     ENEMY_SPEED_FIGHTER, ENEMY_DIRECTION_PLUS,  ENEMY_DIRECTION_PLUS
    .db     0x3f, 0xa0, 0x00, 0xf4,  ENEMY_SPEED_NULL,     ENEMY_SPEED_FIGHTER, ENEMY_DIRECTION_MINUS, ENEMY_DIRECTION_PLUS
    .db     0x3f, 0x20, 0x00, 0xcb,  ENEMY_SPEED_NULL,    -ENEMY_SPEED_FIGHTER, ENEMY_DIRECTION_PLUS,  ENEMY_DIRECTION_MINUS
    .db     0x3f, 0xa0, 0x00, 0xcb,  ENEMY_SPEED_NULL,    -ENEMY_SPEED_FIGHTER, ENEMY_DIRECTION_MINUS, ENEMY_DIRECTION_MINUS
    .db     0x00, 0x06, 0x3f, 0x10,  ENEMY_SPEED_FIGHTER,  ENEMY_SPEED_NULL,    ENEMY_DIRECTION_PLUS,  ENEMY_DIRECTION_PLUS
    .db     0x00, 0x06, 0x3f, 0x50,  ENEMY_SPEED_FIGHTER,  ENEMY_SPEED_NULL,    ENEMY_DIRECTION_PLUS,  ENEMY_DIRECTION_MINUS
    .db     0x00, 0xf9, 0x3f, 0x10, -ENEMY_SPEED_FIGHTER,  ENEMY_SPEED_NULL,    ENEMY_DIRECTION_MINUS, ENEMY_DIRECTION_PLUS
    .db     0x00, 0xf9, 0x3f, 0x50, -ENEMY_SPEED_FIGHTER,  ENEMY_SPEED_NULL,    ENEMY_DIRECTION_MINUS, ENEMY_DIRECTION_MINUS

; スプライト
;
enemySpriteFighter:

    .db     0x44, 0x44, 0x44, 0x44, 0x40, 0x40, 0x40, 0x40, 0x40, 0x48, 0x48, 0x48, 0x48

enemySpriteAdvanced:

    .db     0x54, 0x54, 0x54, 0x54, 0x50, 0x50, 0x50, 0x50, 0x50, 0x58, 0x58, 0x58, 0x58

; 色
;
enemyColor:

    .db     0x0c, 0x0c, 0x02, 0x02, 0x03, 0x03, 0x03, 0x03
    .db     0x06, 0x06, 0x08, 0x08, 0x09, 0x09, 0x09, 0x09
    .db     0x04, 0x04, 0x05, 0x05, 0x07, 0x07, 0x07, 0x07
    .db     0x0a, 0x0a, 0x0b, 0x0b, 0x0f, 0x0f, 0x0f, 0x0f


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
_enemy::
    
    .ds     ENEMY_LENGTH * ENEMY_ENTRY

; エネミーの残りの数
;
enemyRest:

    .ds     0x01

; 次に出現するエネミーの数
;
enemyNext:

    .ds     0x01

; エネミーの初期値
;
enemyDefault:

    .ds     ENEMY_LENGTH

; スプライト
;
enemySprite:

    .ds     0x01
