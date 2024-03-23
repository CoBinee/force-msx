; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Title.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

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

    ; サウンドの停止
    call    _SystemStopSound
    
    ; タイトルの設定
    ld      hl, #titleDefault
    ld      de, #_title
    ld      bc, #TITLE_LENGTH
    ldir

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存

    ; 初期化処理
    ld      a, (_title + TITLE_STATE)
    cp      #(TITLE_STATE_NULL + 0x00)
    jr      nz, 09$

    ; 画面のクリア
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0000)
    ld      bc, #(0x0300 - 0x0001)
    ld      (hl), #0x00
    ldir

    ; ロゴの描画
    ld      hl, #titlePatternNameLogo
    ld      de, #(_appPatternName + 0x0120)
    ld      bc, #0x0040
    ldir

    ; ハイスコアの表示
    ld      hl, #titlePatternNameTop
    ld      de, #(_appPatternName + 0x02a)
    ld      bc, #0x0003
    ldir
    ld      hl, #(_appPatternName + 0x02e)
    ld      de, #(_app + APP_SCORE_10000000)
    call    80$

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; スプライトのクリア
    call    _SystemClearSprite

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    inc     (hl)

    ; キー入力待ち
    ld      a, (_title + TITLE_STATE)
    cp      #(TITLE_STATE_NULL + 0x01)
    jr      nz, 49$

    ; SPACE キーの監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 41$

    ; サウンドの停止
    call    _SystemStopSound

    ; SE の再生
    ld      hl, #titleSoundStart
    ld      (_soundRequest + 0x0000), hl

    ; 状態の更新
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
    jr      49$

    ; ESC キーの監視
41$:
;   ld      a, (_input + INPUT_BUTTON_ESC)
;   dec     a
;   jr      nz, 49$

    ; 状態の更新
;   ld      a, #APP_STATE_DEBUG_INITIALIZE
;   ld      (_app + APP_STATE), a
;   jr      49$
49$:

    ; ゲームの開始
    ld      a, (_title + TITLE_STATE)
    cp      #(TITLE_STATE_NULL + 0x02)
    jr      nz, 59$

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    ld      a, (hl)
    add     a, #0x04
    ld      (hl), a

    ; サウンドの監視
    ld      hl, (_soundRequest + 0x0000)
    ld      a, h
    or      l
    jr      nz, 59$
    ld      hl, (_soundPlay + 0x0000)
    ld      a, h
    or      l
    jr      nz, 59$

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a
59$:    

    ; HIT SPACE BAR の描画
    ld      a, (_title + TITLE_FRAME)
    and     #0x10
    ld      e, a
    ld      d, #0x00
    ld      hl, #titlePatternNameHitSpaceBar
    add     hl, de
    ld      de, #(_appPatternName + 0x0228)
    ld      bc, #0x0010
    ldir
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

    ; 更新の完了
90$:

    ; パターンネームの転送
    call    _AppTransferPatternName

    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; タイトルの初期値
;
titleDefault:

    .db     TITLE_STATE_NULL
    .db     TITLE_FRAME_NULL

; パターンネーム
;
titlePatternNameLogo:

    .db     0x00, 0x00, 0x00, 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf, 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd, 0xde, 0xdf, 0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0x00, 0x00, 0x00

titlePatternNameHitSpaceBar:

    .db     0x00, 0x00, 0x28, 0x29, 0x34, 0x00, 0x33, 0x30, 0x21, 0x23, 0x25, 0x00, 0x22, 0x21, 0x32, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

titlePatternNameTop:

    .db     0x34, 0x2f, 0x30

; サウンド
;

; ゲームスタート
titleSoundStart:

    .ascii  "T1V15L3O6BO5BR9"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; タイトル
;
_title::
    
    .ds     TITLE_LENGTH
