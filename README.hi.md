[English](README.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [日本語](README.ja.md) · [中文](README.zh.md) · **हिन्दी**

# Chordex ABNT

[monome norns](https://monome.org/docs/norns/) के लिए पैड, एंबिएंट, लीड और
टेक्सचर वाला कॉर्ड वाद्य। एक की से चार सुरों का कॉर्ड और बेस बजता है, एक
सबट्रैक्टिव इंजन से होकर: 4 परिवार × 8 प्रीसेट, कुल 32 ध्वनियाँ। इसमें
आर्पेजिएटर की जगह **मूवमेंट** है: कॉर्ड बजता रहता है और ध्वनि खुद बदलती
रहती है।

![Chordex ABNT](docs/sheet.png)

**स्क्रीन ही ध्वनि है, उसी तरीके से गणना की गई जिससे वह बजती है:**

- **बाएँ:** आवाज़। A (तीन डिट्यून सॉ वेव), B, SUB और AIRE (साँस जैसा शोर)
  गोले हैं जिनकी चमक उनका स्तर है; वे फ़िल्टर की ओर कण भेजते हैं। फ़िल्टर
  के अंदर का बिंदु कटऑफ़ है, छल्ला रेज़ोनेंस है, और फ़िल्टर LFO के साथ
  झूलता है। नीचे 10 फ़ेडर।
- **बीच में:** फूल, सुर की असली वेवफ़ॉर्म ध्रुवीय रूप में। परछाईं =
  डिट्यून, रोएँ = साँस का शोर, टूटन = ग्रेन, खुलते छल्ले = इको, चिंगारियाँ =
  शिमर। अंदर 12 सुरों के पहिये पर कॉर्ड।
- **दाएँ:** परिवार और प्रीसेट, ऑसिलोस्कोप, स्पेक्ट्रम और मूवमेंट का वक्र,
  जिस पर एक बिंदु चलता है।

## विशेषताएँ

- **4 परिवार × 8 प्रीसेट**
  - **PAD**: वॉर्म पैड, ग्लास पैड, स्ट्रिंग्स, कोरस, स्वीप पैड, डार्क पैड,
    ब्रास पैड, 80 के दशक का पॉली
  - **AMBIENT**: लंबे अटैक, बड़ा हॉल, इको और शिमर
  - **LEAD**: ग्लाइड के साथ मोनोफ़ोनिक (आख़िरी सुर को प्राथमिकता)
  - **TEXTURE**: दाने, बारिश, स्टैटिक, रेत, कीड़े, बर्फ़, मोटर, धुंध
- **आवाज़**: तीन डिट्यून VarSaw (सॉ → ट्रायंगल), चुने हुए अंतराल पर PWM वाला
  पल्स ऑसिलेटर, सब, फ़िल्टर किया हुआ साँस का शोर, यादृच्छिक ग्रेन, अपने
  एनवेलप और LFO वाला रेज़ोनेंट फ़िल्टर, ड्राइव, ग्लाइड
- **मूवमेंट** (K2), टेम्पो के साथ, 6 मोड:
  - **OLA** (लहर): फ़िल्टर ऊपर-नीचे जाता है
  - **DERIVA** (बहाव): कटऑफ़, आकार, डिट्यून और ऑसिलेटर B धीरे-धीरे
    यादृच्छिक रूप से बहते हैं
  - **RESPIRA** (साँस): कॉर्ड की हर आवाज़ अपने ढंग से उठती, गिरती और स्टीरियो
    में चलती है
  - **PULSO** (पल्स): वॉल्यूम का लयबद्ध गेट (इको और हॉल बजते रहते हैं)
  - **GIRO** (घूमना): ध्वनि स्टीरियो में घूमती है और कोरस खुलता है
  - **MAREA** (ज्वार): वॉल्यूम उठता और लौटता है; घटने पर हॉल बढ़ता है
  हर परिवार का अपना मोड है (PAD OLA, AMBIENT DERIVA, LEAD PULSO,
  TEXTURE RESPIRA)
- **इफ़ेक्ट**: कोरस, टेम्पो वाला पिंग-पोंग इको, शिमर, हॉल
- **10 कॉर्ड**: maj, min, dim, aug, 7, maj7, min7, m7b5, sus2, sus4
- **स्ट्रम** पैनल, **कॉर्ड मोड** चालू/बंद (बंद = एक साथ 8 की तक) और **होल्ड**
- आने वाली MIDI क्लॉक के साथ चलता है (मूवमेंट और इको का टेम्पो)
- सारी सेटिंग अपने-आप सेव होती हैं

<!-- u-ma:family -->
## Chordex परिवार

कंट्रोल वही, इंजन अलग। बाकी भी आज़माएँ:

| | |
|---|---|
| <a href="https://github.com/buenosairesfront/chordex80/blob/main/README.hi.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordex80/main/docs/1_d50.png" width="200" alt="Chordex 80"></a> | **[Chordex 80](https://github.com/buenosairesfront/chordex80/blob/main/README.hi.md)**<br>outrun सूर्यास्त वाला 80 के दशक का पॉलीसिंथ<br>`;install https://github.com/buenosairesfront/chordex80` |
| <a href="https://github.com/buenosairesfront/chordexfm/blob/main/README.hi.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexfm/main/docs/3_metal.png" width="200" alt="Chordex FM"></a> | **[Chordex FM](https://github.com/buenosairesfront/chordexfm/blob/main/README.hi.md)**<br>4-ऑपरेटर FM, फूल के रूप में<br>`;install https://github.com/buenosairesfront/chordexfm` |
| <a href="https://github.com/buenosairesfront/chordexstg/blob/main/README.hi.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexstg/main/docs/2_tutti.png" width="200" alt="ChordexSTG"></a> | **[ChordexSTG](https://github.com/buenosairesfront/chordexstg/blob/main/README.hi.md)**<br>गज़ से बजे तार की असली गति वाले ऑर्केस्ट्रा स्ट्रिंग्स<br>`;install https://github.com/buenosairesfront/chordexstg` |
| <a href="https://github.com/buenosairesfront/chordexwt/blob/main/README.hi.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexwt/main/docs/2_vocal.png" width="200" alt="Chordex WT"></a> | **[Chordex WT](https://github.com/buenosairesfront/chordexwt/blob/main/README.hi.md)**<br>वेवटेबल: 8 वेव वाले 8 बैंक, 3D टेबल के रूप में<br>`;install https://github.com/buenosairesfront/chordexwt` |
| <a href="https://github.com/buenosairesfront/chordexchip/blob/main/README.hi.md"><img src="https://raw.githubusercontent.com/buenosairesfront/chordexchip/main/docs/1_nes.png" width="200" alt="Chordex CHIP"></a> | **[Chordex CHIP](https://github.com/buenosairesfront/chordexchip/blob/main/README.hi.md)**<br>चिपट्यून: 8 कंसोल चिप × 8 प्रीसेट, ट्रैकर के रूप में<br>`;install https://github.com/buenosairesfront/chordexchip` |

**U-MA से और:** सभी वाद्य और टूल एक जगह → [U-MA शोकेस](https://github.com/buenosairesfront/U-ma/blob/main/README.hi.md)
<!-- /u-ma:family -->

## ज़रूरतें

- norns (shield, standard या fates)
- MIDI कीबोर्ड या कंट्रोलर

## इंस्टॉल

maiden से:

```
;install https://github.com/buenosairesfront/chordexabnt
```

फिर नया इंजन `ChordexABNT` कंपाइल करने के लिए **norns रीस्टार्ट करें**
(SYSTEM > RESTART), और SELECT से **chordexabnt** लोड करें।

## कंट्रोल

| कंट्रोल | काम |
|---|---|
| E1 | कटऑफ़ (चमक) |
| E2 | फ़ेडर चुनें |
| E3 | फ़ेडर समायोजित करें |
| K3 + E1 | प्रीसेट (सभी 32 एक कतार में: PAD 1–8, AMBIENT, LEAD, TEXTURE) |
| K3 + E2 | हॉल |
| K3 + E3 | कॉर्ड का प्रकार |
| K3 दबाए रखें (घुमाए बिना) | कॉर्ड मोड चालू/बंद |
| K2 (टैप) | मूवमेंट चालू/बंद |
| K2 + E1 | मूवमेंट की गहराई |
| K2 + E2 | मूवमेंट का मोड |
| K2 + E3 | मूवमेंट की गति (1/16 से 16 बार) |
| K2 + K3 | STRUM पैनल खोलता है: E3 = कॉर्ड के सुरों के बीच का समय, बीट के भागों में; + पहले सुर से आख़िरी तक, − आख़िरी से पहले तक |
| K1 दबाए रखें | होल्ड चालू/बंद (ऊपर दाईं ओर हीरा) |

**फ़ेडर:** अटैक, रिलीज़, रेज़ोनेंस, LFO मूवमेंट, डिट्यून, साँस का शोर, ग्रेन,
इको, शिमर, ग्लाइड।

**PARAMETERS मेनू:** MIDI चैनल (डिफ़ॉल्ट 1; 0 = सभी), MIDI क्लॉक डिवाइडर, मोनो,
आकार, ऑसिलेटर B और उसका अंतराल, सब, ऑक्टेव, बेस, डिके, सस्टेन, फ़िल्टर
एनवेलप, LFO की गति, ड्राइव, कोरस, इको की पुनरावृत्ति और समय, वॉल्यूम, और ऊपर
का सब कुछ।

## arc और crow

दोनों वैकल्पिक हैं: arc या crow जुड़ा न हो तो कुछ नहीं बदलता।

**arc** (4 रिंग, नॉब की तरह दिखते हैं): 1 कटऑफ़ · 2 मूवमेंट की गहराई · 3 मूवमेंट की गति · 4 हॉल

**crow**: IN1 = सुर (V/oct, 0 V = C4), IN2 = गेट (बजाना और छोड़ना) · OUT1 = कॉर्ड का मूल सुर (V/oct) · OUT2 = एनवेलप (0–8 V, ध्वनि के अटैक और रिलीज़ के साथ) · OUT3 = मूवमेंट, LFO के रूप में (जब चालू हो) · OUT4 = हर कॉर्ड पर एक पल्स। PARAMETERS > ARC / CROW में बंद किया जा सकता है।

**टेम्पो:** पहली बार चलाने पर आंतरिक टेम्पो 50 BPM होता है। आने वाली MIDI क्लॉक (किसी भी MIDI पोर्ट पर) मौजूद हो तो वही टेम्पो तय करती है।

## गैलरी

| | |
|---|---|
| ![PAD](docs/1_warm_pad.png) PAD · WARM PAD · maj7 · OLA | ![AMBIENT](docs/2_cristales.png) AMBIENT · CRISTALES · min7 · DERIVA |
| ![LEAD](docs/3_solo_saw.png) LEAD · SOLO SAW · ग्लाइड | ![TEXTURE](docs/4_lluvia.png) TEXTURE · LLUVIA · RESPIRA |
| ![AMBIENT](docs/5_marea.png) AMBIENT · NUBE · m7b5 · MAREA | ![preset](docs/6_preset.png) प्रीसेट चुनना (K3 + E1) |

## श्रेय

[Buenos Aires Front](https://github.com/buenosairesfront) / U-MA द्वारा बनाया
गया। MIT लाइसेंस के तहत जारी।
