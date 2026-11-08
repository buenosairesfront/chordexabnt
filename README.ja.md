[English](README.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · **日本語** · [中文](README.zh.md) · [हिन्दी](README.hi.md)

# Chordex ABNT

[monome norns](https://monome.org/docs/norns/) 用の、パッド・アンビエント・
リード・テクスチャーのためのコード楽器です。1 つの鍵盤で 4 音のコードとベース
が鳴り、4 ファミリー × 8 プリセット（全 32 音色）の減算合成エンジンを通ります。
アルペジエーターの代わりに **ムーブメント** があり、コードは鳴り続けたまま
音色そのものが変化していきます。

![Chordex ABNT](docs/sheet.png)

**画面は音そのもの。鳴っている音と同じレシピで計算しています：**

- **左：** ボイス。A（デチューンした 3 本のノコギリ波）、B、SUB、AIRE（息の
  ノイズ）の円はレベルに応じて光り、フィルターへ粒子を送ります。フィルター内の
  点がカットオフ、輪がレゾナンスで、フィルターは LFO で揺れます。下に 10 本の
  フェーダー。
- **中央：** 花。ノートの実際の波形を極座標で描きます。ゴースト＝デチューン、
  毛羽＝息のノイズ、切れ目＝グレイン、広がる輪＝エコー、火花＝シマー。
  中には 12 音ホイール上のコード。
- **右：** ファミリーとプリセット、オシロスコープ、スペクトラム、点が走る
  ムーブメントのカーブ。

## 機能

- **4 ファミリー × 8 プリセット**
  - **PAD**：ウォームパッド、グラスパッド、ストリングス、クワイア、
    スウィープパッド、ダークパッド、ブラスパッド、80 年代ポリ
  - **AMBIENT**：長いアタック、大きなホール、エコーとシマー
  - **LEAD**：グライド付きモノフォニック（後着優先）
  - **TEXTURE**：粒、雨、ノイズ、砂、虫、氷、モーター、霧
- **ボイス**：デチューンした 3 本の VarSaw（ノコギリ波 → 三角波）、選んだ音程
  で鳴る PWM 付きパルスオシレーター、サブ、フィルターした息のノイズ、ランダムな
  グレイン、専用エンベロープと LFO を持つレゾナントフィルター、ドライブ、
  グライド
- **ムーブメント**（K2）、テンポ同期、6 モード：
  - **OLA**（波）：フィルターが上下する
  - **DERIVA**（漂流）：カットオフ、波形、デチューン、オシレーター B が
    ゆっくりランダムに漂う
  - **RESPIRA**（呼吸）：コードの各ボイスがそれぞれ大きくなり、小さくなり、
    ステレオの中を動く
  - **PULSO**（パルス）：リズミックな音量ゲート（エコーとホールは鳴り続ける）
  - **GIRO**（回転）：音がステレオで回り、コーラスが広がる
  - **MAREA**（潮）：音量が満ちて引き、下がるとホールが大きくなる
  各ファミリーに既定のモードあり（PAD OLA、AMBIENT DERIVA、LEAD PULSO、
  TEXTURE RESPIRA）
- **エフェクト**：コーラス、テンポ同期ピンポン・エコー、シマー、ホール
- **10 種のコード**：maj、min、dim、aug、7、maj7、min7、m7b5、sus2、sus4
- **ストラム**パネル、**コードモード** オン/オフ（オフ＝最大 8 鍵同時）、
  **ホールド**
- 外部 MIDI クロックに追従（ムーブメントとエコーのテンポ）
- 設定はすべて自動保存

<!-- u-ma:family -->
## Chordex ファミリー

操作は同じ、エンジンは別。ほかの楽器もどうぞ：

| | |
|---|---|
| <a href="https://github.com/buenosairesfront/chordex80/blob/main/README.ja.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordex80/main/docs/1_d50.png" width="200" alt="Chordex 80"></a> | **[Chordex 80](https://github.com/buenosairesfront/chordex80/blob/main/README.ja.md)**<br>アウトランの夕焼けを描く 80 年代ポリシンセ<br>`;install https://github.com/buenosairesfront/chordex80` |
| <a href="https://github.com/buenosairesfront/chordexfm/blob/main/README.ja.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexfm/main/docs/3_metal.png" width="200" alt="Chordex FM"></a> | **[Chordex FM](https://github.com/buenosairesfront/chordexfm/blob/main/README.ja.md)**<br>花として描かれる 4 オペレーター FM<br>`;install https://github.com/buenosairesfront/chordexfm` |
| <a href="https://github.com/buenosairesfront/chordexstg/blob/main/README.ja.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexstg/main/docs/2_tutti.png" width="200" alt="ChordexSTG"></a> | **[ChordexSTG](https://github.com/buenosairesfront/chordexstg/blob/main/README.ja.md)**<br>弓で擦った弦の実際の動きを描くオーケストラ弦楽<br>`;install https://github.com/buenosairesfront/chordexstg` |
| <a href="https://github.com/buenosairesfront/chordexwt/blob/main/README.ja.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexwt/main/docs/2_vocal.png" width="200" alt="Chordex WT"></a> | **[Chordex WT](https://github.com/buenosairesfront/chordexwt/blob/main/README.ja.md)**<br>8 波形 × 8 バンクのウェーブテーブル。3D テーブルとして描画<br>`;install https://github.com/buenosairesfront/chordexwt` |
| <a href="https://github.com/buenosairesfront/chordexchip/blob/main/README.ja.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexchip/main/docs/1_nes.png" width="200" alt="Chordex CHIP"></a> | **[Chordex CHIP](https://github.com/buenosairesfront/chordexchip/blob/main/README.ja.md)**<br>チップチューン：ゲーム機チップ 8 種 × 8 プリセット、トラッカーとして描画<br>`;install https://github.com/buenosairesfront/chordexchip` |

**U-MA のほかの作品：** すべての楽器とツールをひとつに → [U-MA ショーケース](https://github.com/buenosairesfront/U-ma/blob/main/README.ja.md)
<!-- /u-ma:family -->

## 必要なもの

- norns（shield、standard、fates）
- MIDI キーボードまたはコントローラー

## インストール

maiden から：

```
;install https://github.com/buenosairesfront/chordexabnt
```

その後 **norns を再起動**（SYSTEM > RESTART）して新しいエンジン `ChordexABNT`
をコンパイルし、SELECT から **chordexabnt** を読み込みます。

## 操作

| 操作 | 機能 |
|---|---|
| E1 | カットオフ（明るさ） |
| E2 | フェーダー選択 |
| E3 | フェーダー調整 |
| K3 + E1 | プリセット（32 個が一列：PAD 1–8、AMBIENT、LEAD、TEXTURE） |
| K3 + E2 | ホール |
| K3 + E3 | コードの種類 |
| K3 長押し（回さずに） | コードモード オン/オフ |
| K2（タップ） | ムーブメント オン/オフ |
| K2 + E1 | ムーブメントの深さ |
| K2 + E2 | ムーブメントのモード |
| K2 + E3 | ムーブメントの速さ（1/16 〜 16 小節） |
| K2 + K3 | STRUM パネルを開く：E3 ＝ コード音の間隔（拍の分割）。＋は最初の音から最後へ、−は最後から最初へ |
| K1 長押し | ホールド オン/オフ（右上のひし形） |

**フェーダー：** アタック、リリース、レゾナンス、LFO の動き、デチューン、
息のノイズ、グレイン、エコー、シマー、グライド。

**PARAMETERS メニュー：** MIDI チャンネル（既定 1、0 ＝ 全チャンネル）、MIDI
クロック分周、モノ、波形、オシレーター B と音程、サブ、オクターブ、ベース、
ディケイ、サステイン、フィルター・エンベロープ、LFO の速さ、ドライブ、
コーラス、エコーの回数と時間、音量、および上記すべて。

## arc と crow

どちらも任意です。arc や crow をつながなければ何も変わりません。

**arc**（4 つのリング、ノブとして表示）：1 カットオフ · 2 ムーブメントの深さ · 3 ムーブメントの速さ · 4 ホール

**crow**：IN1 = 音程（V/oct、0 V = C4）、IN2 = ゲート（鳴らす／離す） · OUT1 = コードのルート（V/oct） · OUT2 = エンベロープ（0〜8 V、音のアタックとリリース） · OUT3 = ムーブメントを LFO として（オンのとき） · OUT4 = コードごとにパルス。PARAMETERS > ARC / CROW でオフにできます。

**テンポ：** 初回起動時の内部テンポは 50 BPM。MIDI クロックが（どの MIDI ポートからでも）入っていれば、それに従います。

## ギャラリー

| | |
|---|---|
| ![PAD](docs/1_warm_pad.png) PAD · WARM PAD · maj7 · OLA | ![AMBIENT](docs/2_cristales.png) AMBIENT · CRISTALES · min7 · DERIVA |
| ![LEAD](docs/3_solo_saw.png) LEAD · SOLO SAW · グライド | ![TEXTURE](docs/4_lluvia.png) TEXTURE · LLUVIA · RESPIRA |
| ![AMBIENT](docs/5_marea.png) AMBIENT · NUBE · m7b5 · MAREA | ![preset](docs/6_preset.png) プリセット選択（K3 + E1） |

## クレジット

[Buenos Aires Front](https://github.com/buenosairesfront) / U-MA 制作。
MIT ライセンスで公開。
