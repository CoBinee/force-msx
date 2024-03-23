; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "PsShot.inc"
    .include    "EsShot.inc"
    .include    "Proton.inc"
    .include    "Bomb.inc"
    .include    "Falcon.inc"
    .include    "Back.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; サウンドの停止
    call    _SystemStopSound

    ; ゲームの初期化
    ld      hl, #gameDefault
    ld      de, #_game
    ld      bc, #GAME_LENGTH
    ldir
    
    ; 背景の初期化
    call    _BackInitialize

    ; プレイヤの初期化
    call    _PlayerInitialize

    ; エネミーの初期化
    call    _EnemyInitialize

    ; プレイヤショットの初期化
    call    _PsShotInitialize

    ; エネミーショットの初期化
    call    _EsShotInitialize

    ; プロトンの初期化
    call    _ProtonInitialize

    ; 爆発の初期化
    call    _BombInitialize

    ; ファルコンの初期化
    call    _FalconInitialize
    
    ; パターンネームのクリア
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0001)
    ld      bc, #0x02ff
    ld      (hl), #0x00
    ldir

    ; パターンネームの転送
    ld      hl, #_appPatternName
    ld      de, #APP_PATTERN_NAME_TABLE
    ld      bc, #0x0300
    call    LDIRVM

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)

    ; 状態の設定
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_game + GAME_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; スプライトの更新
    ld      a, (_game + GAME_SPRITE_ENEMY)
    cp      #GAME_SPRITE_ENEMY_0
    ld      a, #GAME_SPRITE_ENEMY_0
    jr      nz, 20$
    ld      a, #GAME_SPRITE_ENEMY_1
20$:
    ld      (_game + GAME_SPRITE_ENEMY), a
    ld      a, (_game + GAME_SPRITE_ESSHOT)
    cp      #GAME_SPRITE_ESSHOT_0
    ld      a, #GAME_SPRITE_ESSHOT_0
    jr      nz, 21$
    ld      a, #GAME_SPRITE_ESSHOT_1
21$:
    ld      (_game + GAME_SPRITE_ESSHOT), a

    ; パターンネームの転送
    call    _AppTransferPatternName

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret
    
; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_game + GAME_FLAG)
    set     #GAME_FLAG_PLAY_BIT, (hl)

    ; フレームの設定
    ld      a, #0x60
    ld      (_game + GAME_FRAME), a

    ; BGM の再生
    ld      a, #GAME_SOUND_BGM_FIGHTER
    call    _GamePlayBgm

    ; 初期化の完了
    ld      hl, #_game + GAME_STATE
    inc     (hl)
09$:

    ; 1 フレームの更新
    call    GameUpdateFrame

    ; 1 フレームの描画
    call    GameRenderFrame

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_PLAY
    ld      (_game + GAME_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret
    
; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ゲームを監視する
    call    GameControl

    ; プレイヤショットとエネミーのヒット判定
    call    _PsShotHitEnemy

    ; エネミーショットとプレイヤのヒット判定
    call    _EsShotHitPlayer

    ; エネミーとプレイヤのヒット判定
    call    _EnemyHitPlayer

    ; 1 フレームの更新
    call    GameUpdateFrame

    ; 倍率の更新
    call    GameUpdateRate

    ; 時間の更新
    call    GameUpdateTime

    ; 1 フレームの描画
    call    GameRenderFrame

    ; プレイの完了
    ld      hl, #(_game + GAME_REQUEST)
    bit     #GAME_REQUEST_OVER_BIT, (hl)
    jr      z, 19$
    ld      a, #GAME_STATE_OVER
    ld      (_game + GAME_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret
    
; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    ld      a, #0x60
    ld      (_game + GAME_FRAME), a
    
    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ボーナスの加算
    ld      hl, #(_game + GAME_REQUEST)
    bit     #GAME_REQUEST_BONUS_BIT, (hl)
    jr      z, 10$
    call    GameAddScoreBonus
    jr      c, 19$
10$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 19$
    dec     (hl)
    jr      nz, 19$

    ; フラグの設定
    ld      hl, #(_game + GAME_FLAG)
    res     #GAME_FLAG_PLAY_BIT, (hl)
19$:

    ; 1 フレームの更新
    call    GameUpdateFrame

    ; 1 フレームの描画
    call    GameRenderFrame

    ; ゲームオーバーの監視
    ld      hl, #(_game + GAME_FLAG)
    bit     #GAME_FLAG_OVER_BIT, (hl)
    jr      nz, 20$

    ; プレイヤの監視
    call    _PlayerIsAlive
    jr      c, 29$

    ; フラグの設定
    ld      hl, #(_game + GAME_FLAG)
    set     #GAME_FLAG_OVER_BIT, (hl)
    jr      29$

    ; 背景の監視
20$:
    call    _BackIsAlive
    jr      c, 29$

    ; 状態の更新
    ld      a, #GAME_STATE_RESULT
    ld      (_game + GAME_STATE), a
29$: 

    ; レジスタの復帰

    ; 終了
    ret

; ゲームの結果を表示する
;
GameResult:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 画面のクリア
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0000)
    ld      bc, #(0x0300 - 0x0001)
    ld      (hl), #0x00
    ldir

    ; RESULT の描画
    ld      hl, #gamePatternNameResult
    ld      de, #(_appPatternName + 0x00ed)
    ld      bc, #0x0006
    ldir

    ; SCORE の描画
    ld      hl, #gamePatternNameScore
    ld      de, #(_appPatternName + 0x0149)
    ld      bc, #0x0005
    ldir
    ld      hl, #(_appPatternName + 0x014f)
    ld      de, #(_game + GAME_SCORE_10000000)
    call    80$

    ; ハイスコアの比較
    ld      hl, #(_game + GAME_SCORE_10000000)
    ld      de, #(_app + APP_SCORE_10000000)
    ld      b, #APP_SCORE_LENGTH
00$:
    ld      a, (de)
    cp      (hl)
    jr      c, 01$
    jr      nz, 02$
    inc     hl
    inc     de
    djnz    00$

    ; TOP SCORE! の描画
01$:
    ld      hl, #(_game + GAME_SCORE_10000000)
    ld      de, #(_app + APP_SCORE_10000000)
    ld      bc, #APP_SCORE_LENGTH
    ldir
    ld      hl, #gamePatternNameUpdate
    ld      de, #(_appPatternName + 0x01ab)
    ld      bc, #0x000a
    ldir
    jr      08$

    ; TOP の描画
02$:
    ld      hl, #gamePatternNameTop
    ld      de, #(_appPatternName + 0x0189)
    ld      bc, #0x0003
    ldir
    ld      hl, #(_appPatternName + 0x018f)
    ld      de, #(_app + APP_SCORE_10000000)
    call    80$
;   jr      08$

    ; BGM の再生
08$:
    ld      a, #GAME_SOUND_BGM_RESULT
    call    _GamePlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; キー入力の監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; SE の再生
    ld      a, #GAME_SOUND_SE_CLICK
    call    _GamePlaySe

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
19$:
    jr      90$

    ; スコアの描画
80$:
    ld      c, #0x00
    ld      b, #(APP_SCORE_LENGTH - 0x01)
81$:
    ld      a, (de)
    or      a
    jr      z, 82$
    ld      c, #0x10
82$:
    add     a, c
    ld      (hl), a
    inc     hl
    inc     de
    djnz    81$
    ld      a, (de)
    add     a, #0x10
    ld      (hl), a
    ret

    ; 結果の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを終了する
;
GameEnd:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 画面のクリア
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0000)
    ld      bc, #(0x0300 - 0x0001)
    ld      (hl), #0x00
    ldir

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを監視する
;
GameControl:

    ; レジスタの保存

    ; ADVANCED のリクエスト
    ld      hl, (_game + GAME_TIME_BCD_L)
    ld      de, #0x1000
    or      a
    sbc     hl, de
    jr      nz, 19$
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_ENEMY_ADVANCED_BIT, (hl)
19$:

    ; エネミーの登録
    ld      hl, (_game + GAME_TIME_BCD_L)
    ld      de, #0x0250
    or      a
    sbc     hl, de
    jr      c, 29$
    jr      z, 20$
    call    _EnemyEntry

    ; 倍率減少のリクエスト
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_RATE_MINUS_0_1_BIT, (hl)
    jr      29$

    ; FIGHTER の削除
20$:
    ld      a, #ENEMY_TYPE_FIGHTER
    call    _EnemySetBombType

    ; プロトンの登録
    ld      hl, #(_game + GAME_FLAG)
    set     #GAME_FLAG_PROTON_BIT, (hl)
    call    _ProtonEntry
;   jr      29$
29$:

    ; ファルコンの登録
    ld      hl, (_game + GAME_TIME_BCD_L)
    ld      de, #0x0500
    or      a
    sbc     hl, de
    jr      nc, 39$
    ld      hl, #(_game + GAME_FLAG)
    bit     #GAME_FLAG_FALCON_BIT, (hl)
    jr      nz, 39$
    bit     #GAME_FLAG_ADVANCED_BIT, (hl)
    jr      z, 39$
    call    _FalconEntry
39$:

    ; USE THE FORCE のリクエスト
    ld      hl, (_game + GAME_TIME_BCD_L)
    ld      de, #0x0250
    or      a
    sbc     hl, de
    jr      nc, 49$
    ld      hl, (_game + GAME_TIME_BCD_L)
    ld      de, #0x0100
    or      a
    sbc     hl, de
    jr      c, 49$
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_USE_THE_FORCE_BIT, (hl)
49$:

    ; PORT の登録
    ld      hl, (_game + GAME_TIME_BCD_L)
    ld      de, #0x0001
    or      a
    sbc     hl, de
    jr      nz, 59$
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_ENEMY_PORT_BIT, (hl)
    call    _EnemyEntry
59$:

    ; レジスタの復帰

    ; 終了
    ret

; 1 フレーム更新する
;
GameUpdateFrame:

    ; レジスタの保存

    ; 背景の更新
    call    _BackUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; プレイヤショットの更新
    call    _PsShotUpdate

    ; エネミーショットの更新
    call    _EsShotUpdate

    ; プロトンの更新
    call    _ProtonUpdate

    ; 爆発の更新
    call    _BombUpdate

    ; ファルコンの更新
    call    _FalconUpdate

    ; レジスタの復帰

    ; 終了
    ret

; 1 フレーム描画する
;
GameRenderFrame:

    ; レジスタの保存

    ; 背景の描画
    call    _BackRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; プレイヤショットの描画
    call    _PsShotRender

    ; エネミーショットの描画
    call    _EsShotRender

    ; プロトンの描画
    call    _ProtonRender

    ; 爆発の描画
    call    _BombRender

    ; ファルコンの描画
    call    _FalconRender

    ; ステータスの描画
    call    _BackIsFade
    call    nc, GamePrintStatus

    ; レジスタの復帰

    ; 終了
    ret

; 倍率スコアを加算する
;
_GameAddScoreRate::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; スコアの加算
    ld      hl, #(_game + GAME_SCORE_00000010)
    ld      de, #(_game + GAME_RATE_00_1)
    ld      bc, #(((APP_SCORE_LENGTH - 0x01) << 8) | GAME_RATE_LENGTH)
10$:
    ld      a, (de)
    call    30$
    jr      c, 11$
    dec     hl
    dec     de
    dec     b
    dec     c
    jr      nz, 10$
    jr      19$
11$:
    ld      hl, #(_game + GAME_SCORE_10000000 + 0x0000)
    ld      de, #(_game + GAME_SCORE_10000000 + 0x0001)
    ld      bc, #(APP_SCORE_LENGTH - 0x0001)
    ld      (hl), #0x09
    ldir
19$:

    ; 倍率上昇のリクエスト
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_RATE_PLUS_1_0_BIT, (hl)
    jr      90$

    ; 一桁の加算
30$:
    push    hl
    push    bc
    add     a, (hl)
    ld      (hl), a
    sub     #0x0a
    jr      c, 32$
31$:
    ld      (hl), a
    dec     hl
    dec     b
    jr      z, 33$
    ld      a, (hl)
    inc     a
    ld      (hl), a
    sub     #0x0a
    jr      nc, 31$
32$:
    or      a
    jr      39$
33$:
    scf
;   jr      39$
39$:
    pop     bc
    pop     hl
    ret

    ; 加算の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; ボーナススコアを加算する
;
GameAddScoreBonus:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; cf > 加算中

    ; スコアの加算
    ld      hl, #(_game + GAME_SCORE_00010000)
    ld      de, #(_game + GAME_RATE_00_1)
    ld      bc, #((((APP_SCORE_LENGTH - 0x04) << 8)) | GAME_RATE_LENGTH)
10$:
    ld      a, (de)
    or      a
    jr      nz, 11$
    dec     hl
    dec     de
    dec     b
    dec     c
    jr      nz, 10$
    or      a
    jr      19$
11$:
    dec     a
    ld      (de), a
12$:
    inc     (hl)
    ld      a, (hl)
    sub     #0x0a
    jr      c, 13$
    ld      (hl), a
    dec     hl
    dec     b
    jr      nz, 12$
    ld      hl, #(_game + GAME_SCORE_10000000 + 0x0000)
    ld      de, #(_game + GAME_SCORE_10000000 + 0x0001)
    ld      bc, #(APP_SCORE_LENGTH - 0x0001)
    ld      (hl), #0x09
    ldir
13$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 倍率を更新する
;
GameUpdateRate:

    ; レジスタの保存
    push    hl
    push    bc

    ; リクエストの取得
    ld      hl, #(_game + GAME_REQUEST)

    ; 倍率を 1.0 上げる
    bit     #GAME_REQUEST_RATE_PLUS_1_0_BIT, (hl)
    jr      z, 19$
    res     #GAME_REQUEST_RATE_PLUS_1_0_BIT, (hl)
    ld      hl, #(_game + GAME_RATE_01_0)
    inc     (hl)
    ld      a, (hl)
    sub     #0x0a
    jr      c, 10$
    ld      (hl), a
    dec     hl
    inc     (hl)
    ld      a, (hl)
    sub     #0x0a
    jr      c, 10$
    ld      a, #0x09
    ld      (hl), a
    inc     hl
    ld      (hl), a
    inc     hl
    ld      (hl), a
;   inc     hl
10$:
    jr      90$
19$:

    ; 倍率を 1.0 下げる
    bit     #GAME_REQUEST_RATE_MINUS_1_0_BIT, (hl)
    jr      z, 29$
    res     #GAME_REQUEST_RATE_MINUS_1_0_BIT, (hl)
    ld      hl, #(_game + GAME_RATE_01_0)
    ld      a, (hl)
    or      a
    jr      nz, 20$
    ld      (hl), #0x09
    dec     hl
20$:
    dec     (hl)
    jr      90$
29$:

    ; 倍率を 0.1 下げる
    bit     #GAME_REQUEST_RATE_MINUS_0_1_BIT, (hl)
    jr      z, 39$
    res     #GAME_REQUEST_RATE_MINUS_0_1_BIT, (hl)
    ld      hl, #(_game + GAME_RATE_00_1)
    ld      b, #GAME_RATE_LENGTH
30$:
    ld      a, (hl)
    or      a
    jr      nz, 31$
    ld      (hl), #0x09
    dec     hl
    djnz    30$
31$:
    dec     (hl)
;   jr      90$
39$:

    ; 倍率更新の完了
90$:

    ; BCD 値の更新
    ld      hl, #(_game + GAME_RATE_10_0)
    ld      b, (hl)
    inc     hl
    ld      a, (hl)
    inc     hl
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, (hl)
;   inc     hl
    ld      c, a
    ld      (_game + GAME_RATE_BCD_L), bc

    ; 倍率を 1.0 以上に保つ
    ld      hl, (_game + GAME_RATE_BCD_L)
    ld      bc, #0x0010
    or      a
    sbc     hl, bc
    jr      nc, 91$
    xor     a
    ld      (_game + GAME_RATE_10_0), a
    ld      (_game + GAME_RATE_00_1), a
    inc     a
    ld      (_game + GAME_RATE_01_0), a
    ld      hl, #0x0010
    ld      (_game + GAME_RATE_BCD_L), hl
91$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; 時間を更新する
;
GameUpdateTime:

    ; レジスタの保存
    push    hl
    push    bc

    ; 時間の減少
    ld      hl, #(_game + GAME_TIME_1000)
    xor     a
    ld      b, #GAME_TIME_LENGTH
10$:
    add     a, (hl)
    inc     hl
    djnz    10$
    or      a
    jr      z, 19$
    ld      b, #GAME_TIME_LENGTH
11$:
    dec     hl
    ld      a, (hl)
    or      a
    jr      nz, 12$
    ld      (hl), #0x09
    djnz    11$
    jr      19$
12$:
    dec     (hl)
19$:

    ; BCD 値の更新
    ld      hl, #(_game + GAME_TIME_1000)
    ld      a, (hl)
    inc     hl
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, (hl)
    inc     hl
    ld      b, a
    ld      a, (hl)
    inc     hl
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, (hl)
;   inc     hl
    ld      c, a
    ld      (_game + GAME_TIME_BCD_L), bc

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; ステータスを描画する
;
GamePrintStatus:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; スコアの描画
    ld      c, #0xa0
    ld      hl, #(_appPatternName + 0x0020)
    ld      de, #(_game + GAME_SCORE_10000000)
    ld      (hl), #0xa0
    inc     hl
    ld      b, #(APP_SCORE_LENGTH - 0x01)
10$:
    ld      a, (de)
    or      a
    jr      z, 11$
    ld      c, #0xa1
11$:
    add     a, c
    ld      (hl), a
    inc     hl
    inc     de
    djnz    10$
    ld      a, (de)
    add     a, #0xa1
    ld      (hl), a
    inc     hl
    ld      (hl), #0xa0
    inc     hl
    ld      (hl), #0xad
    ld      hl, #(_appPatternName + 0x0020)
    ld      de, #(_appPatternName + 0x0040)
    ld      bc, #(((APP_SCORE_LENGTH + 0x03) << 8) | 0x0010)
12$:
    ld      a, (hl)
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    djnz    12$

    ; 倍率の描画
    ld      hl, #(_appPatternName + 0x0039)
    ld      de, #(_game + GAME_RATE_10_0)
    ld      (hl), #0xae
    inc     hl
    ld      (hl), #0xab
    inc     hl
    ld      a, (de)
    or      a
    jr      nz, 20$
    dec     a
20$:
    add     a, #0xa1
    ld      (hl), a
    inc     hl
    inc     de
    ld      a, (de)
    add     a, #0xa1
    ld      (hl), a
    inc     hl
    inc     de
    ld      (hl), #0xac
    inc     hl
    ld      a, (de)
    add     a, #0xa1
    ld      (hl), a
    inc     hl
    inc     de
    ld      (hl), #0xa0
    ld      hl, #(_appPatternName + 0x0039)
    ld      de, #(_appPatternName + 0x0059)
    ld      bc, #(((GAME_RATE_LENGTH + 0x04) << 8) | 0x0010)
21$:
    ld      a, (hl)
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    djnz    21$

    ; 時間の描画
    ld      c, #0xa0
    ld      hl, #(_appPatternName + 0x02b9)
    ld      de, #(_game + GAME_TIME_1000)
    ld      (hl), #0xaf
    inc     hl
    ld      (hl), #0xa0
    inc     hl
    ld      b, #(GAME_TIME_LENGTH - 0x01)
30$:
    ld      a, (de)
    or      a
    jr      z, 31$
    ld      c, #0xa1
31$:
    add     a, c
    ld      (hl), a
    inc     hl
    inc     de
    djnz    30$
    ld      a, (de)
    add     a, #0xa1
    ld      (hl), a
    inc     hl
    ld      (hl), #0xa0
    ld      hl, #(_appPatternName + 0x02b9)
    ld      de, #(_appPatternName + 0x02d9)
    ld      bc, #(((GAME_TIME_LENGTH + 0x03) << 8) | 0x0010)
32$:
    ld      a, (hl)
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    djnz    32$

    ; USE THE FORCE の表示
    ld      hl, #(_game + GAME_REQUEST)
    bit     #GAME_REQUEST_USE_THE_FORCE_BIT, (hl)
    jr      z, 40$
    res     #GAME_REQUEST_USE_THE_FORCE_BIT, (hl)
    ld      hl, #gamePatternNameUseTheForce
    ld      de, #(_appPatternName + 0x00c6)
    ld      bc, #0x0016
    ldir
40$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; BGM を再生する
;
_GamePlayBgm::

    ; レジスタの保存
    push    hl
    push    de

    ; a = 再生する音

    ; サウンドの再生
    ld      hl, #(_game + GAME_SOUND)
    cp      (hl)
    jr      z, 19$
    ld      (hl), a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameSoundBgm
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      (_soundRequest + 0x0000), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      (_soundRequest + 0x0002), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundRequest + 0x0004), de
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; SE を再生する
;
_GamePlaySe::

    ; レジスタの保存
    push    hl
    push    de

    ; a = 再生する音
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameSoundSe
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (_soundRequest + 0x0006), de

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
gameProc:
    
    .dw     GameNull
    .dw     GameStart
    .dw     GamePlay
    .dw     GameOver
    .dw     GameResult
    .dw     GameEnd

; ゲームの初期値
;
gameDefault:

    .db     GAME_STATE_START
    .db     GAME_FLAG_NULL
    .db     GAME_REQUEST_NULL
    .db     GAME_SPRITE_ENEMY_0
    .db     GAME_SPRITE_ESSHOT_0
    .db     GAME_SOUND_NULL
    .db     GAME_FRAME_NULL
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x01, 0x00
    .dw     0x0010
    .db     0x02, 0x00, 0x00, 0x00
    .dw     0x2000
;   .db     0x00, 0x03, 0x00, 0x00
;   .dw     0x0300


; パターンネーム
;
gamePatternNameUseTheForce:

    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x35, 0x33, 0x25, 0x00, 0x34, 0x28, 0x25, 0x00, 0x26, 0x2f, 0x32, 0x23, 0x25, 0x00, 0x00, 0x00, 0x00

gamePatternNameResult:

    .db     0x32, 0x25, 0x33, 0x35, 0x2c, 0x34

gamePatternNameScore:

    .db     0x33, 0x23, 0x2f, 0x32, 0x25

gamePatternNameTop:

    .db     0x34, 0x2f, 0x30

gamePatternNameUpdate:

    .db     0x34, 0x2f, 0x30, 0x00, 0x33, 0x23, 0x2f, 0x32, 0x25, 0x01

; サウンド
;
gameSoundBgm:

    .dw     gameSoundNull
    .dw     gameSoundNull
    .dw     gameSoundNull
    .dw     gameSoundNull
    .dw     gameSoundBgmFighter0
    .dw     gameSoundBgmFighter1
    .dw     gameSoundBgmFighter2
    .dw     gameSoundNull
    .dw     gameSoundBgmAdvanced0
    .dw     gameSoundBgmAdvanced1
    .dw     gameSoundBgmAdvanced2
    .dw     gameSoundNull
    .dw     gameSoundBgmOver0
    .dw     gameSoundBgmOver1
    .dw     gameSoundBgmOver2
    .dw     gameSoundNull
    
gameSoundSe:

    .dw     gameSoundNull
    .dw     gameSoundSeClick
    .dw     gameSoundSeShot
    .dw     gameSoundSeBomb

gameSoundNull:

    .ascii  "T1L0R"
    .db     0x00

gameSoundBgmFighter0:

    .ascii  "T2V15-3L5"
    .ascii  "O4F1"
    .ascii  "O4F7D5R4F1"
    .ascii  "O4F7D5R4A-1"
    .ascii  "O4A-8G4A-0G0"
    .ascii  "O4F3D8R3"
    .ascii  "R8R3R1"
    .db     0xff

gameSoundBgmFighter1:

    .ascii  "T2V15-3L5"
    .ascii  "O4D1"
    .ascii  "O3D5B-1A1G1F1G5B-1A1G1F1"
    .ascii  "O3D5B-1A1G1F1G5B-1A1G1F1"
    .ascii  "O3R5B-1A1G1F1A-1G1F1E1R5"
    .ascii  "O3R5G1F+1E1D1G1F+1E1D1O4C1O3B1A1G1"
    .ascii  "O3G1F+1E1D1O4C1O3B1A1G1O4D1C1O3B1A1O4G1F+1E1"
    .db     0xff

gameSoundBgmFighter2:

    .ascii  "T2V15-3L5"
    .ascii  "O3B-1"
    .ascii  "O3B-7G5R4B-1"
    .ascii  "O3B-7G5R4O4D-1"
    .ascii  "O4D-8C4A-0G0"
    .ascii  "O3B-3G8R3"
    .ascii  "R8R3R1"
    .db     0xff

gameSoundBgmAdvanced0:

    .ascii  "T2V15-3L3"
    .ascii  "O3G4R1G3G1G0G0G3G1G0G0E-3E-1E-0E-0"
    .db     0xff

gameSoundBgmAdvanced1:

    .ascii  "T2V15-3L3"
    .ascii  "O2G4R1G3G1G0G0G3G1G0G0E-3E-1E-0E-0"
    .db     0xff

gameSoundBgmAdvanced2:

    .ascii  "T2V15-3L3"
    .ascii  "O3G4R1G3G1G0G0G3G1G0G0O2B-3B-1B-0B-0"
    .db     0xff

gameSoundBgmOver0:

    .ascii  "T2V15-3L3"
    .ascii  "O4F6F1F1F6F1F1"
    .ascii  "O4F5F5F3F3F2F2F1"
    .ascii  "O4A6A1A1A6A1A1"
    .ascii  "O4A5A5A3A3A2A2A1"
;   .ascii  "O5C5C5C3C3C2C2C1"
    .db     0xff

gameSoundBgmOver1:

    .ascii  "T2V15-3L3"
    .ascii  "O3F6F1F1F6F1F1"
    .ascii  "O3F5F5F3F3F2F2F1"
    .ascii  "O3A6A1A1A6A1A1"
    .ascii  "O3A5A5A3A3A2A2A1"
;   .ascii  "O4F5F5E-3E-3E-2E-2E-1"
    .db     0xff

gameSoundBgmOver2:

    .ascii  "T2V15-3L3"
    .ascii  "O4F6F1F1F6F1F1"
    .ascii  "O4F5F5F3F3F2F2F1"
    .ascii  "O3F6F1F1F6F1F1"
    .ascii  "O3F5F5F3F3F2F2F1"
;   .ascii  "O4A5A5G-3G-3G-2G-2G-1"
    .db     0xff

gameSoundSeClick:

    .ascii  "T1V15L1O6B"
    .db     0x00

gameSoundSeShot:

    .ascii  "T1V15L0"
    .ascii  "O5C+RO4BAGFC+O3G+"
    .db     0x00

gameSoundSeBomb:

    .ascii  "T1V15L0"
    .ascii  "O4AGFEDC" ; "AGFEDCCDEFGABO5CDEFGABO6CO5AFEDEF"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ゲーム
;
_game::
    
    .ds     GAME_LENGTH
