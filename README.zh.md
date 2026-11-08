[English](README.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [日本語](README.ja.md) · **中文** · [हिन्दी](README.hi.md)

# Chordex ABNT

用于 [monome norns](https://monome.org/docs/norns/) 的和弦乐器，专为铺底、
氛围、主奏和音色纹理而做。一个键演奏四音和弦加低音，经过减法合成引擎：4 个系列 ×
8 个预设，共 32 种声音。它没有琶音器，而是 **运动**：和弦持续发声，变化的是
声音本身。

![Chordex ABNT](docs/sheet.png)

**屏幕就是声音，用与发声相同的方法计算：**

- **左：** 声部。A（三个失谐锯齿波）、B、SUB 和 AIRE（气声噪声）是圆圈，亮度
  就是它们的电平，并把粒子送进滤波器。滤波器里的点是截止频率，外环是共振，
  滤波器随 LFO 摆动。下方是 10 个推子。
- **中：** 花。音符的真实波形以极坐标画出。虚影 = 失谐，绒毛 = 气声，断口 =
  颗粒，扩散的圆环 = 回声，火花 = shimmer。中间是 12 音轮上的和弦。
- **右：** 系列和预设、示波器、频谱，以及有一个点在上面移动的运动曲线。

## 功能

- **4 个系列 × 8 个预设**
  - **PAD**：温暖铺底、玻璃铺底、弦乐、合唱、扫频铺底、暗色铺底、铜管铺底、
    80 年代复音
  - **AMBIENT**：长起音、大混响、回声和 shimmer
  - **LEAD**：带滑音的单音（后按优先）
  - **TEXTURE**：颗粒、雨、静电、沙、昆虫、冰、马达、薄雾
- **声部**：三个失谐 VarSaw（锯齿波 → 三角波）、按所选音程发声并带 PWM 的脉冲
  振荡器、副低音、滤波气声噪声、随机颗粒、拥有独立包络和 LFO 的共振滤波器、
  失真、滑音
- **运动**（K2），与速度同步，6 种模式：
  - **OLA**（波浪）：滤波器上下扫动
  - **DERIVA**（漂移）：截止频率、波形、失谐和振荡器 B 缓慢随机漂移
  - **RESPIRA**（呼吸）：和弦的每个声部各自起伏，并在立体声中移动
  - **PULSO**（脉冲）：有节奏的音量门（回声和混响继续发声）
  - **GIRO**（旋转）：声音在立体声中旋转，合唱效果展开
  - **MAREA**（潮汐）：音量涨起又退去；音量下降时混响变大
  每个系列都有默认模式（PAD OLA、AMBIENT DERIVA、LEAD PULSO、
  TEXTURE RESPIRA）
- **效果**：合唱、与速度同步的乒乓回声、shimmer、混响
- **10 种和弦**：maj、min、dim、aug、7、maj7、min7、m7b5、sus2、sus4
- **扫弦**面板、**和弦模式**开/关（关 = 最多 8 个键同时发声）和 **保持**
- 跟随外部 MIDI 时钟（运动和回声的速度）
- 所有设置自动保存

<!-- u-ma:family -->
## Chordex 系列

操作相同，引擎不同。也来试试其他几款：

| | |
|---|---|
| <a href="https://github.com/buenosairesfront/chordex80/blob/main/README.zh.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordex80/main/docs/1_d50.png" width="200" alt="Chordex 80"></a> | **[Chordex 80](https://github.com/buenosairesfront/chordex80/blob/main/README.zh.md)**<br>80 年代复音合成器，配 outrun 日落画面<br>`;install https://github.com/buenosairesfront/chordex80` |
| <a href="https://github.com/buenosairesfront/chordexfm/blob/main/README.zh.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexfm/main/docs/3_metal.png" width="200" alt="Chordex FM"></a> | **[Chordex FM](https://github.com/buenosairesfront/chordexfm/blob/main/README.zh.md)**<br>4 算子 FM，画成一朵花<br>`;install https://github.com/buenosairesfront/chordexfm` |
| <a href="https://github.com/buenosairesfront/chordexstg/blob/main/README.zh.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexstg/main/docs/2_tutti.png" width="200" alt="ChordexSTG"></a> | **[ChordexSTG](https://github.com/buenosairesfront/chordexstg/blob/main/README.zh.md)**<br>管弦乐弦乐，呈现真实的拉弦运动<br>`;install https://github.com/buenosairesfront/chordexstg` |
| <a href="https://github.com/buenosairesfront/chordexwt/blob/main/README.zh.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexwt/main/docs/2_vocal.png" width="200" alt="Chordex WT"></a> | **[Chordex WT](https://github.com/buenosairesfront/chordexwt/blob/main/README.zh.md)**<br>波表：8 个库、每库 8 个波形，画成 3D 波表<br>`;install https://github.com/buenosairesfront/chordexwt` |
| <a href="https://github.com/buenosairesfront/chordexchip/blob/main/README.zh.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexchip/main/docs/1_nes.png" width="200" alt="Chordex CHIP"></a> | **[Chordex CHIP](https://github.com/buenosairesfront/chordexchip/blob/main/README.zh.md)**<br>芯片音乐：8 种游戏机芯片 × 8 个预设，画成 tracker<br>`;install https://github.com/buenosairesfront/chordexchip` |

**更多 U-MA 作品：** 所有乐器和工具汇集一处 → [U-MA 作品集](https://github.com/buenosairesfront/U-ma/blob/main/README.zh.md)
<!-- /u-ma:family -->

## 需求

- norns（shield、standard 或 fates）
- MIDI 键盘或控制器

## 安装

在 maiden 中：

```
;install https://github.com/buenosairesfront/chordexabnt
```

然后 **重启 norns**（SYSTEM > RESTART）以编译新引擎 `ChordexABNT`，再从 SELECT
载入 **chordexabnt**。

## 操作

| 操作 | 功能 |
|---|---|
| E1 | 截止频率（亮度） |
| E2 | 选择推子 |
| E3 | 调节推子 |
| K3 + E1 | 预设（32 个排成一列：PAD 1–8、AMBIENT、LEAD、TEXTURE） |
| K3 + E2 | 混响 |
| K3 + E3 | 和弦类型 |
| 按住 K3（不旋转） | 和弦模式开/关 |
| K2（轻按） | 运动开/关 |
| K2 + E1 | 运动深度 |
| K2 + E2 | 运动模式 |
| K2 + E3 | 运动速度（1/16 到 16 小节） |
| K2 + K3 | 打开 STRUM 面板：E3 = 和弦各音之间的时间（按拍子细分）；+ 从第一个音弹到最后一个，− 从最后一个弹到第一个 |
| 按住 K1 | 保持开/关（右上角的菱形） |

**推子：** 起音、释放、共振、LFO 运动、失谐、气声、颗粒、回声、shimmer、
滑音。

**PARAMETERS 菜单：** MIDI 通道（默认 1；0 = 全部）、MIDI 时钟分频、单音、波形、
振荡器 B 及其音程、副低音、八度、低音、衰减、延音、滤波包络、LFO 速度、失真、
合唱、回声次数和时间、音量，以及上面所有内容。

## arc 和 crow

两者都是可选的：不连接 arc 或 crow 时一切照旧。

**arc**（4 个圆环，显示为旋钮）：1 截止频率 · 2 运动深度 · 3 运动速度 · 4 混响

**crow**：IN1 = 音高（V/oct，0 V = C4），IN2 = 门（触发与释放） · OUT1 = 和弦根音（V/oct） · OUT2 = 包络（0–8 V，跟随声音的起音和释放） · OUT3 = 运动，作为 LFO（开启时） · OUT4 = 每个和弦一个脉冲。可在 PARAMETERS > ARC / CROW 中关闭。

**速度：** 首次启动时内部速度为 50 BPM。只要有 MIDI 时钟输入（任意 MIDI 端口），就以它为准。

## 图库

| | |
|---|---|
| ![PAD](docs/1_warm_pad.png) PAD · WARM PAD · maj7 · OLA | ![AMBIENT](docs/2_cristales.png) AMBIENT · CRISTALES · min7 · DERIVA |
| ![LEAD](docs/3_solo_saw.png) LEAD · SOLO SAW · 滑音 | ![TEXTURE](docs/4_lluvia.png) TEXTURE · LLUVIA · RESPIRA |
| ![AMBIENT](docs/5_marea.png) AMBIENT · NUBE · m7b5 · MAREA | ![preset](docs/6_preset.png) 选择预设（K3 + E1） |

## 致谢

由 [Buenos Aires Front](https://github.com/buenosairesfront) / U-MA 制作。
以 MIT 许可证发布。
