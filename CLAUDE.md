# ipsj-lualatex.cls 変換仕様書

このドキュメントは、`ipsj.cls` / `ipsjpref.sty` / `ipsjtech.sty`（pLaTeX前提）から `ipsj-lualatex.cls`（LuaLaTeX専用）への変換作業の仕様・決定根拠・落とし穴を記録したものである。利用者向けの説明は [README.md](README.md) を参照。本書は「再度この変換をやり直す/拡張する」ときに必要な情報を残すことを目的とする。

## 1. 対象範囲と方針

### 1.1 入力資料

| ファイル | バージョン | 行数 |
|---|---|---|
| `ipsj.cls` | v4.1 [2025/02/05] | 5945行 |
| `ipsjpref.sty` | v3.00 [2017/02/16]（序文 `preface` オプション用） | 約375行 |
| `ipsjtech.sty` | v3.00 [2012/06/01]（研究報告 `techrep` オプション用） | 約355行 |

`ipsj.cls` は `\ifDS@preface`/`\ifDS@techrep` が真のとき、ファイル末尾（5914〜5919行目）で `\input{ipsjpref.sty}` / `\input{ipsjtech.sty}` を行い、`\@maketitle`・`\authortitle`・ページスタイル等を**後から上書き**する構造だった。

### 1.2 方針（ユーザー指示）

- 後方互換性は不要。**現時点のLuaLaTeXのみ**を対象にする。
- 全文書種別（論文誌各分冊・研究報告・序文）を完全再現する。
- 縦組（`tate`）・トンボ（旧`mentuke`）も実装する。
- オプション名は整理し直してよい（旧名と一致させる必要はない）。
- 出力物は `ipsj-lualatex.cls` という単一ファイル。`ipsjpref-lualatex.sty` 等の分割は行わない。

## 2. アーキテクチャ上の決定

### 2.1 ベースクラス

`\LoadClass{article}` を使う。`ipsj.cls` は独立クラスとして書かれていたが、新クラスでは標準 `article` の上に被せる形にした。理由：

- `article` が提供する `\@startsection` 基盤、`\@float`/`\@dblfloat`、脚注機構などはIPSJクラスでも最終的にほぼ同じ意味で使われており、自前で再実装する必要がない。`itemize`/`enumerate`/`description`/`quote`/`quotation`/`verse` は `\list`/`\@trivlist` という共通の下位機構を使っているため土台は流用できるが、ラベル書式・字下げ幅・行間は原文が独自に上書きしているため、これらは結局`\renewenvironment`で個別に再実装している（§4.13参照）。
- `\maketitle`/`\@maketitle`/セクション見出し/キャプション/参考文献など、IPSJ固有の部分は全て `\renewcommand`/`\renewenvironment` で上書きするため、ベースが`article`であることは実害がない。

**`jlreq`を使わなかった理由**：和文クラスの選択肢として`jlreq`（基本版面を自動計算する高機能な現代的和文クラス）も検討対象になり得るが、以下の理由で採用しなかった。

1. **`ipsj.cls`自体が「固定版面」であり、`jlreq`の強み（基本版面の自動計算）を活かす場面が無い**：§2.3で確認した通り、`ipsj.cls`は紙サイズオプションに応じた版面計算ロジックを持ちながら、最終的にその結果を一切使わずA4・本文幅177mm等の数値をハードコードで無条件上書きしている（5230〜5269行目）。つまり移植対象そのものが「グリッドから計算する」発想ではなく「決まった数値を生の`\setlength`で叩き込む」発想で書かれている。`jlreq`を基底にしても自動計算機能は使わず全項目を生数値で上書きすることになるため強みを活かせず、むしろ`jlreq`が裏で管理しようとする`\baselineskip`等の値と衝突し、§4.11（`\AtBeginDocument`がクラス側の一度きりの上書きを後から無効化した問題）と同種の二重管理バグを増やすリスクが大きい。
2. **`ipsj.cls`自身のアーキテクチャが`jclasses.dtx`（=`article`系pLaTeXクラス）の慣用句で書かれている**：`\@startsection`/`\@float`/`\@dblfloat`/`\@maketitle`/`\@makecaption`といった`article`/`jclasses`系の標準フックをそのまま`\renewcommand`で上書きする構造になっている。新クラスでも同じフック名を持つ`article`を土台にすることで、原文の各行と新クラスの各行を1:1に対応させたまま移植できる。`jlreq`は同名フックを持っていても内部実装の前提（版面計算との結びつき方）が異なるため、全フックについて対応づけを再検討する手間とリスクが生じ、互換性再現という目的に対して何のメリットも生まない。
3. **縦組要件は`luatexja-core`の`\tate`だけで十分だった**：§1.2の縦組要件に対し、`jlreq`の縦組サポートは`jlreq`独自の版面モデル（コラムの流れ方向、脚注配置等）と一体になっている。`ipsj.cls`の縦組は単に「`\tate`に切り替えて、それ以外は同じ固定A4レイアウトを使う」という単純なものなので、`jlreq`の縦組エンジンを採用すると2つの前提を整合させる作業が新たに必要になり、要件を超えた複雑性を持ち込む。

公平な評価として、`jlreq`の方が日本語組版として工学的に「正しい」設計であり、§4.11や§4.15のような`\baselineskip`スコープ系のバグは`jlreq`ベースなら発生しなかった可能性もある。しかし今回のゴールは「より良い日本語組版を作る」ことではなく「`ipsj.cls`という特定の、既に固定された出力を再現する」ことであり、自前で値を計算しようとするエンジンを足すことは忠実な再現を難しくする方向に働くと判断した。

注意点：`article` が既に定義している名前（`\figurename`, `\tablename`, `\refname`, `\appendixname`, `\abovecaptionskip`, `figure`/`table`/`thebibliography` 環境, `\large`〜`\Huge` 等のサイズコマンド）を `\newcommand`/`\newenvironment`/`\newlength` で再定義すると `already defined` エラーになる。**すべて `\renewcommand`/`\renewenvironment` を使うこと。**

### 2.2 エンジン・フォント

```latex
\RequirePackage{luatexja}
\RequirePackage{luatexja-fontspec}
\setmainfont{TeX Gyre Termes}
\setsansfont{TeX Gyre Heros}
\setmainjfont{Harano Aji Mincho}
\setsansjfont{Harano Aji Gothic}
\renewcommand{\kanjifamilydefault}{\mcdefault}
```

- `luatexja-tate` という名前のアドオンパッケージは**存在しない**（TeX Live 2026時点）。`\tate`/`\yoko` は `luatexja-core.sty` が直接提供しており、`\RequirePackage{luatexja}` だけで使える。これは `ltjtarticle.cls`（LuaTeX-ja公式の縦組クラス）の実装を確認して判明した（`\DeclareOption{tate}{\tate ...}` を `\RequirePackage{luatexja}` のみで実行している）。
- フォントは `texlive/texlive:latest`（TeX Live 2026）に標準収録されているものを選定。`fc-list` で確認した結果：
  - `Harano Aji Mincho` / `Harano Aji Gothic` は **Regular/Bold の実ウェイトを両方持つ**（`haranoaji` パッケージ）。フェイクボールド処理は不要。
  - `TeX Gyre Termes` / `TeX Gyre Heros` も Regular/Bold/Italic/BoldItalic を完備。
- 旧クラスの `JY1`/`JT1` エンコーディングによる仮想フォント差し替え（太明朝=FutoMin, 太ゴシック=FutoGoth, `submit`オプション無指定時のタイトル用）は、対応する物理フォントのBoldウェイト（`\mcfamily\bfseries` / `\gtfamily\bfseries`）に単純化した。

**これらのフォントを選び、他を選ばなかった理由**：TeX Liveには和文・欧文ともに多数のフォントが収録されているが、以下の根拠で他の選択肢を排した。

和文（Mincho/Gothic）について：

- **原文`ipsj.cls`が前提としていた具体的なフォントの正体**：`ipsj.cls`を`grep`すると、`\usefont{JY1}{fmb}{m}{n}% FutoMin`（2767行目）等、JY1/JT1エンコーディングの仮想フォント名「FutoMin」「FutoGoth」が太字明朝・太字ゴシックとして使われている（605〜631行目）。森澤（モリサワ）配布の`morisawa`パッケージ（`morisawa.dtx`、CTAN/texjporg）を確認したところ、通常ウェイトの明朝・ゴシックは`Ryumin-Light-J`/`GothicBBB-Medium-J`（リュウミン/中ゴシックBBB相当）であり、太字側は同パッケージで`FutoMinA101-Bold-J`/`FutoGoB101-Bold-J`（「太ミンA101」「太ゴB101」、モリサワが別途販売する独立した太字専用書体）として定義されている。つまり`ipsj.cls`が前提とする和文書体の系統は、**リュウミン/中ゴシックBBBという伝統的な商用フォント**である（IPA系のような独自デザインの和文フォントではない）。なお、このFutoMin/FutoGoth仮想フォントの宣言（`\ifDS@english\else...\fi`内）は文書全体の`\bfseries`に効くものではなく、§2.2既述の通り`submit`オプション無指定時のタイトル表示という限られた箇所でのみ使われていた特殊なものであり、§4.16で発見した「`\bfseries`が和文明朝で太字ゴシックに自動代替される」という一般的な挙動とは別の仕組みである。
- **`Harano Aji Mincho`/`Harano Aji Gothic`を選んだ理由**：これらは「源ノ明朝」/「源ノ角ゴシック」（Source Han Serif/Sans、Adobe・Google共同開発のオープンソースCJKフォント。Googleからは"Noto Serif/Sans CJK"の名でも配布されている）を、**Adobe-Japan1（AJ1）字形順に組み替え直した派生フォント**である（ライセンスはSource Han同様SIL Open Font License 1.1で、自由に再配布できる）。AJ1字形順への組み替えは、`ipsj.cls`のようなpLaTeX系クラスが内部で前提とするCID-keyedフォントの字形順序（伝統的にdvipdfmx等がAJ1前提でCIDマッピングを行う）に合わせるための変換であり、**pTeX/pLaTeX系ツールチェーンとの互換性を確保することが主目的**である（後述するRyumin-Light/GothicBBB-Medium系の書体デザインそのものを継承しているわけではない）。TeX Live自体も2019年頃のライセンス事情の変化を受けて、和文の既定フォントをこの`haranoaji`パッケージに切り替えており（`jlreq`/`ltjsclasses`/`BXjscls`等、現代的な和文LuaLaTeXクラスの既定フォントでもある）、「TeX Live標準環境だけで追加インストール不要に動く」という本プロジェクトの要件（README §必要環境）に合致する、かつ**明朝・ゴシックの両方でRegular/Boldの実ウェイトが揃っている**（§2.2既述）という実務上の利点が決定的だった。
- **`IPAex明朝`/`IPAexゴシック`（旧TeX Live既定）を選ばなかった理由**：`fc-list`で確認したところ、いずれも**`style=Regular`の単一ウェイトしか持たず、太字（Bold）の実体が存在しない**。本クラスは§4.16で発見した「明朝には元々太字が無いのでゴシックで代用する」という原文の慣習を**ゴシック側の本物の太字**で再現する必要があり、IPAexではゴシック側もフェイクボールド（線を太らせるだけの疑似処理）になってしまい、太字が必要な見出し等の品質が原文より劣化する。なお字形デザインはSource Han系・Ryumin系のいずれとも異なる独立した設計（情報処理推進機構（IPA）による開発）である。
- **`Noto Sans/Serif CJK JP`を選ばなかった理由**：これは前述の通り`Harano Aji`と**同じ「源ノ」字形デザイン**を採用したフォントであり、見た目の差はほぼ無い。選ばなかった理由は字形デザインではなく実務上の理由のみ：標準的なTeX Live配布物には同梱されておらず、`luatexja-fontspec`から使うにはシステムへの別途インストールが必要になり、「追加インストール不要」という本プロジェクトの要件（README §必要環境）に反する。また、AJ1字形順への変換が施されていないため、伝統的なCID-keyed和文フォント周りの処理（dvipdfmx経由の出力等）との相性は`Harano Aji`の方が確実である。
- **いずれを選んでも、`ipsj.cls`本来が前提としていたRyumin-Light/GothicBBB-Medium（商用、森澤由来）の書体デザインそのものとは一致しない**：これは本プロジェクトが許容する既知の限界であり、フォントを変更した時点で避けられない差である（TeX Gyre Termes/HeroesとTimes/Helveticaの関係も同様、後述）。

欧文（Times/Helvetica相当）について：

- **原文`ipsj.cls`が前提としていた具体的なフォントの正体**：`ipsj.cls`を`grep`すると、ヘッダ・タイトル等のラテン文字部分で`\usefont{OT1}{ptm}{m}{n}%Times`（1441, 1455, 1899, 1905行目等）、`\usefont{OT1}{ptm}{b}{n}%Times-Bold`（2762, 2768行目）、`\usefont{OT1}{phv}{b}{n}`（1198, 2983, 3075行目）が多数使われている。`ptm`/`phv`はPSNFSS（dvips時代のPostScriptフォント切り替え機構）における**Times（Nimbus Roman系）/Helvetica（Nimbus Sans系）の標準識別子**であり、コメントにも明示的に「Times」と書かれている。さらに5236行目には`%%\AtBeginDocument{\RequirePackage{txfonts}}`という、Times/Helvetica互換のPostScriptフォントパッケージ`txfonts`を読み込む処理がコメントアウトで残っている。これらから、`ipsj.cls`の原作者はラテン文字部分に明確に**Times（本文）/Helvetica（見出し等のサンセリフ）**を意図していたことが分かる（Computer Modernではない）。
- **`TeX Gyre Termes`/`TeX Gyre Heros`を選んだ理由**：これらはGUST e-foundryプロジェクトによる、`txfonts`の基盤と同じ**URW Nimbus Roman/Nimbus Sans**（Times/Helvetica互換のPostScriptフォント）をOpenType化し、`fontspec`/`luatexja-fontspec`から直接使えるよう整備したものである。`txfonts`（Type1 PostScriptフォント）はLuaLaTeXの`fontspec`ベースのフォント選択とは相性が悪く直接使えないため、**同じ字形系列を保ったままOpenType・fontspec対応にした後継**として最適だった。Regular/Bold/Italic/BoldItalicを完備しており、§4.16のような「ウェイトが足りないことによる予期しない代替」のリスクも無い。
- **`Latin Modern`（LuaLaTeXの既定フォント）を選ばなかった理由**：何も指定しなければLuaLaTeXは`Latin Modern`（Computer Modernの後継）を使うが、これは原文`ipsj.cls`が前提とするTimes/Helvetica系の見た目とは明確に異なる「TeX標準書体」の外観であり、学術論文ヘッダー等の見た目が原文と大きく変わってしまうため採用しなかった。
- **`Liberation Serif/Sans`等の他のTimes/Helvetica互換クローンを選ばなかった理由**：TeX Gyreと同様にTimes/Helvetica互換だが、TeX LiveにおけるOpenType・`fontspec`対応の完成度・収録の安定性でTeX Gyreの方が標準的であり、`luatexja-fontspec`の公的なドキュメント・サンプルでも欧文側の組み合わせとして例示されているため、実績のあるTeX Gyreを選んだ。

### 2.3 ページジオメトリ：A4固定の根拠

`ipsj.cls` は `a4paper`/`a5paper`/`b4paper`/`b5paper`（および `a4j`/`a5j`/`b4j`/`b5j`、`a4p`等のp系亜種、`landscape`）オプションを宣言しているが、**これらは実際には出力に全く影響しない**。具体的には：

- 821〜1019行目に `\if@compatibility` で分岐する「紙サイズオプションに応じた `\textwidth`/`\textheight`/`\topmargin`/`\oddsidemargin` 計算」がある（jclasses.dtx由来の汎用ロジックの名残）。
- しかし5230〜5269行目で、**オプションの値を一切参照せずに**以下を無条件に実行している：

```latex
\setlength{\paperheight}{297mm}
\setlength{\paperwidth}{210mm}
\textwidth 177mm
\textheight 55\Cvs   % 英文; 和文は 47\Cvs
\advance\textheight\topskip
\advance\textheight.4mm
\@tempdima\paperwidth \advance\@tempdima-\textwidth
\@tempdima.5\@tempdima \advance\@tempdima-1in
\oddsidemargin\@tempdima \evensidemargin\@tempdima
\setlength{\topmargin}{-17mm}
\columnsep 8mm
```

つまり821〜1019行のロジックは**到達後に必ず上書きされる死んだコードパス**である。これが判明したため、新クラスでは紙サイズオプション自体を廃止し、上記の最終値だけを直接実装した（`ipsj-lualatex.cls` の「5. Page geometry」セクション）。

`\headheight`/`\headsep`/`\footskip` は別の場所（1022〜1024行目: `\headheight5mm` `\headsep9.5mm`、835行目: `\footskip11.7mm`）で設定されており、ここは上書きされないので確定値としてそのまま採用した。

### 2.4 寸法単位

- `\Q`（0.71144pt）, `\JQ`（0.7392507pt）, `\h`（0.25mm）はただのTeX寸法定数であり、エンジン非依存。`\newdimen` でそのまま移植。
- **`zw`/`zh` 単位の落とし穴**（最重要の発見の一つ）：
  - pLaTeXでは `zw`（全角幅）・`zh`（全角高さ）はエンジンが解釈するネイティブな寸法単位で、`\hskip1zw` のように**裸の文字列として**書ける。
  - LuaTeX-jaでは `zw`/`zh` はネイティブ単位ではなく、`luatexja-core.sty` 内で `\let\zw=\ltj@zw`（Luaコールバックで現在の和文フォントの幅を取得して返す寸法値マクロ）として提供される。つまり `\zw` は**寸法を保持するマクロ**であり、利用するときは必ず `1\zw` のように**バックスラッシュ付きで係数の後ろに置く**必要がある。`1zw`（裸の単位）と書くと `Illegal unit of measure` エラーになる。
  - 元の `ipsj.cls` 自身は `\ifDS@english\edef\zw{em}\else\edef\zw{zw}\fi`（5188〜5190行目）のように `\zw` を「展開すると `zw` という文字列になるマクロ」として定義し、`\hskip1\zw` という**マクロ越しの間接参照**で使っていた（直接 `1zw` と書いていたわけではない）。このため移植先でも同じ間接参照パターン（`\zw` というコマンド名）を維持しつつ、定義の実体だけをluatexja-core由来のものに差し替えればよい。和文モードでは何もせず（luatexja-coreの`\zw`をそのまま使う）、英文モードでは `\def\zw{em}` として「`1\zw`→`1em`」という文字列展開に切り替える。
  - **影響範囲**：原稿（`.tex`）側で `\makebox[9.47zw][l]{...}` のように `zw` を直接書いている箇所（情報処理学会公式サンプルにいくつか存在する）は、`\makebox[9.47\zw][l]{...}` のように機械的にバックスラッシュを補う必要がある。クラスファイル側の対応では解決しない。
- `\Cwd`/`\Cht`/`\Cdp`/`\Cvs`（全角文字1つの幅・高さ・深さ・行送り）：原文は `\setbox0\hbox{\char\euc"A1A1}`（pTeXのJISコード直接指定）で計測していた。移植版は `\mcfamily\normalsize` 選択後に Unicode の「全」を `\settowidth` 等で計測する方式に変更（エンジン非依存、フォントが変わっても自動追従する）。英文モードは元から実測ではなく固定値（`\ChtE`=7.19269pt 等）だったので、その数値をそのまま移植した。

### 2.5 トンボ（`tombow`）・校正ガイド（`proof`）

- `tombow`：`eso-pic` の `\AddToShipoutPictureBG` + `\AtPageLowerLeft` を使い、A4の四隅（0,0〜210,297mm、各10mm）に直線を描画。`picture` 環境の `\unitlength`/`\line` を使った素朴な実装。元クラスの `\tombowtrue`/`\maketombowbox` はpLaTeXカーネル（plcore）提供のプリミティブで、LuaLaTeXには存在しないため、ロジックは完全に新規実装。
- `proof`：元の `\if@Proof` 分岐（1027〜1038行目）をそのまま移植。`\@Ltop`/`\@Rtop`/`\@Lbot`/`\@Rbot` の4つのマクロが、ヘッダ・フッタの隅に短いL字のルールを描画する。これはpLaTeX固有プリミティブに依存しない素のTeXコードなので1:1で移植可能だった。

### 2.6 実装言語：`expl3`を使わなかった理由

本クラスのコードは全て古典的なLaTeX2eカーネルマクロのスタイル（`\def`/`\renewcommand`/`\@ifundefined`/`\csname...\endcsname`等）で書かれており、`expl3`（LaTeX3のプログラミング層、`\ExplSyntaxOn`/`\tl_set:Nn`等）は一切使用していない（`ipsj-lualatex.cls`を`ExplSyntax`で`grep`して0件であることを確認済み）。検討した上での判断であり、理由は以下の通り。

- **原文`ipsj.cls`自体、および本クラスが乗っている`luatexja-core.sty`/`luatexja.sty`自体も、いずれもexpl3を一切使っていない**（3ファイルとも`grep`で`ExplSyntax`系の記述が0件であることを確認済み）。`ipsj.cls`は`\@ifundefined`等の古典的なLaTeX2eカーネル慣用句で、`luatexja`本体もLua連携部分以外は同様の古典マクロスタイルで書かれている。つまり、移植対象（原文）も土台のエンジン（luatexja）もどちらもexpl3とは無縁の世界で書かれている。
- **原文とのコードの1:1対応が、忠実な移植における最大の安全策になっている**（§2.1の`jlreq`不採用と同じ論理）。本クラスは`ipsj.cls`のほぼ全てのマクロをそのまま`\renewcommand`/`\renewenvironment`で移植する方針を取っており、原文の各行と新クラスの各行を直接対応させられることが、出力の忠実性を検証する最も確実な手段になっている。expl3の関数ベース記法（`\tl_set:Nn`等）で書き直すと、原文との行単位の対応関係が失われ、「書き直したコードが原文と同じ振る舞いをするか」を独自に、しかも原文とは全く異なる記法のまま再検証する必要が生じる。
- **本プロジェクトで発見したバグの多くは、TeXプリミティブの低レベルな挙動に起因していた**：§4.4（`\@tempboxa`/`\@tempboxb`の再入問題）、§4.10（`\csname...\endcsname`直後の`\relax`欠落により数値スキャン中に後続の`\ifnum`が代入前の値で実行されてしまう問題）、§4.11（`\AtBeginDocument`フックによる`\normalsize`のトップレベル再実行）、§4.15（`\fontsize`の`\baselineskip`設定がグループスコープに閉じてしまう問題）。これらは展開順序・グルーピングスコープ・数値スキャン仕様といった、TeXエンジンの生の挙動を直接推論しないと見つからない種類のバグだった。expl3はまさにこの種の低レベルな挙動を意識させない設計（高位の関数・データ構造でTeXの足回りを隠蔽し、安全に使えるようにする）であり、これは新規開発では長所だが、「既存の低レベルな挙動を一字一句再現できているか」を検証する今回の作業には不向きだった。
- **新規ロジックがほとんど無く、expl3のデータ構造的な強みを活かす場面が無い**：実装の大半は原文の条件分岐（`\ifDS@english`等）・寸法演算（`\setlength`/`\advance`）・`\csname`によるレジスタアクセスを1:1で移植するだけであり、expl3が解決する「複雑なデータ構造（seq/clist/prop等）の安全な操作」「関数命名規則による名前空間汚染の回避」といった問題が、今回の作業ではそもそも発生しない。

なお、本クラス自身のコードはexpl3を使っていないが、`\RequirePackage{luatexja-fontspec}`経由で読み込まれる`fontspec.sty`は内部で`xparse`（expl3ベースのインターフェースパッケージ）を`\RequirePackage`しているため、実行時には依存関係を通じて間接的にexpl3が読み込まれる。これは依存先パッケージの実装詳細であり、本クラス自身の設計判断とは無関係である。

公平な評価として、expl3は新規開発であれば現代的で安全なLaTeX3公式推奨スタイルであり、§4.x節で見つかったバグの一部（特にカウンタ・文字列操作系）はexpl3で書けばそもそも発生しなかった可能性がある。しかし`jlreq`の場合と同様、今回のゴールは「より安全なコードを書く」ことではなく「`ipsj.cls`という既存の固定された出力を一字一句再現する」ことであり、原文と異なる記法・抽象化層を挟むことは、忠実な再現の検証を難しくする方向に働くと判断した。

## 3. オプション名対応表

| 旧（`ipsj.cls`） | 新（`ipsj-lualatex.cls`） | 変更理由 |
|---|---|---|
| `mentuke` | `tombow` | 意味が直接伝わる英語名に変更 |
| `Proof` | `proof` | 大文字小文字の統一 |
| `LAYOUT` | 廃止 | `\if@LAYOUT` は宣言のみで使用箇所が一つもなかった（grep で確認済み） |
| `OT` | 廃止 | `\ifDS@OT` も同様に未使用 |
| `a4paper`/`a5paper`/`b4paper`/`b5paper`/`a4j`/`a5j`/`b4j`/`b5j`/`a4p`/`a5p`/`b4p`/`b5p`/`landscape` | 廃止 | §2.3参照。常にA4のため意味がなかった |
| `tate`, `techrep`, `submit`, `noauthor`, `english`, `preface`, `preprint`, `draft`, `final`, `oneside`/`twoside`, `onecolumn`/`twocolumn`, `leqno`, `fleqn`, `openbib` | 変更なし | そのまま流用（`fleqn`は元から常時有効なので実質無効なオプションだが、警告抑制のため受理だけする。§4.18参照） |
| `alone`（`ipsjpref.sty`由来、`preface`専用） | 変更なし | `preface`モードでのみ意味を持つ。序文が単独で1ページに収まる場合、ヘッダのページ参照を範囲でなく単一ページにする（§4.18参照） |
| `PRO`/`ACS`/`TOD`/`TOM`/`CDS`/`DC`/`DCON`/`CVA`/`TBIO`/`SLDM`/`JIP`/`TCE` | 変更なし | 学会の公式略称なので変更しない方が良い |
| `technote`/`sigrecommended`/`invited`/`Data`/`Survey`/`Research`/`Short`/`systems`/`services`/`devices`/`Express`/`Practice`/`Content`/`system`/`abstract`/`invitedshort`/`recommendedshort`/`recommendedresearch`/`recommendedpractice`/`recommendedcontent`/`recommendeddevices` | 変更なし | 同上 |
| `DAM` | ユーザー向けオプションとして廃止 | 元々「特定の論文誌を指定しない」ことを表す内部の既定値（sentinel）であり、ユーザーが明示的に指定する意味のあるオプションではなかった。新クラスでは何も指定しない状態が自動的にこれに相当する |

内部実装名の対応（コードを読む人向け）：

| 旧の内部変数名 | 新の内部変数名 |
|---|---|
| `\@type`（論文誌種別） | `\@iptype` |
| `\@Mtype`（論文種別） | `\@ipMtype` |
| `\signame@XXX` | `\ipsj@signame@XXX` |
| `\SHUBETUname@XXX` | `\ipsj@shubetu@XXX` |
| `\Ediname@XXX` | `\ipsj@ediname@XXX` |

## 4. 不具合・落とし穴（発見した順）

実装中に発生し、原因調査と修正を行った問題を記録する。同種の作業をやり直す際に再発しやすいので必ず確認すること。

### 4.1 既存コマンドの再定義によるエラー

`\newcommand`/`\newenvironment`/`\newlength`/`\newcounter` で `article.cls` がすでに定義している名前を宣言すると `already defined` エラーになる。該当：`\small`/`\footnotesize`/`\scriptsize`/`\tiny`/`\large`/`\Large`/`\LARGE`/`\huge`/`\Huge`、`\figurename`/`\tablename`/`\refname`/`\appendixname`、`\abovecaptionskip`/`\belowcaptionskip`、`figure`/`figure*`/`table`/`table*`/`thebibliography` 環境、`\c@figure`/`\c@table` カウンタ。→ 全て `\renewcommand`/`\renewenvironment` に変更。

### 4.2 `zw` 単位エラー

§2.4参照。クラス内・サンプル文書内の「裸の `zw`」を全て `\zw` に置換した。

### 4.3 `\pdfpagewidth`/`\pdfpageheight` が未定義

元クラスは `\@ifundefined{pdfpagewidth}{\relax}{\pdfpagewidth=\paperwidth ...}` という分岐でpdfTeX系プリミティブを設定していたが、現行LuaTeXではこのプリミティブ名が直接使えない（`Undefined control sequence`）。LaTeXカーネルが `\paperwidth`/`\paperheight` から自動的にPDFメディアボックスを生成するため、**この処理ブロックは丸ごと削除**して問題ない（削除して確認済み）。

### 4.4 `\@tempboxa`/`\@tempboxb` の再入問題（重要）

**症状**：`\@makecaption` で

```latex
\setbox\@tempboxa\hbox{\footnotesize{\bfseries#1}\hskip1\zw{#2}}%
\setbox\@tempboxb\hbox{\footnotesize{\bfseries#1}\hskip1\zw}%
```

を実行すると、ドキュメント中で**初めて**太字明朝（Bold Mincho）の特定サイズが必要になったタイミングで2行目が `Undefined control sequence` で落ちる。1行目（`\@tempboxa` への代入）は成功するが、ほぼ同じ内容の2行目（`\@tempboxb` への代入）だけ失敗する。

**原因**：`\@tempboxa`/`\@tempboxb` はLaTeXカーネル全体で広く使われる汎用スクラッチレジスタである。`\bfseries` によって初めて要求される和文フォントシェイプ（このケースでは小さいサイズの太字明朝）を遅延ロードする際、NFSS／luatexjaの内部処理（フォント代替の判定等）が**同じ `\@tempboxa`/`\@tempboxb` を一時的に使用する**ため、自分が組み立てている最中の `\setbox\@tempboxb` が割り込まれて壊れる、という再入（reentrancy）の競合。

二分探索で確認した手順：
1. 同じ内容を `\setbox9\hbox{...}`（別レジスタ）に変えると問題が消える → レジスタ競合であることを確認。
2. `\setbox\@tempboxa\hbox{...}`（1回目）は常に成功する → 競合するのは「2回目以降、かつ新規フォントロードを伴う」呼び出し。
3. 最小再現：`\setbox\@tempboxa\hbox{\bfseries#1}` の直後に `\setbox\@tempboxb\hbox{\bfseries#1}` を書くだけで再現する。

**対処**：キャプション関連の処理（`\@makecaption`, `\ecaption`, `\@twocolcaption`, `\@twocolecaption`）専用に `\newbox\ipsj@boxa` `\newbox\ipsj@boxb` を新設し、`\@tempboxa`/`\@tempboxb` を一切使わないようにした。

**教訓**：このクラスのように「同じboxレジスタに複数回、かつフォント切り替えを伴う内容を書き込む」処理を新規に書く場合は、必ず専用のboxレジスタを用意すること。`\@tempboxa`/`\@tempboxb`はワンショットの使い捨てにしか使わない。

### 4.5 月の自動算出ロジックの欠落

`\setcounter{month}{...}` を指定しなかった場合、ヘッダの `(Jan. 2018)` のような表記が `(— 2018)` になってしまった。原文（2068〜2070行目）を再確認したところ、

```latex
\@tempcnta\ifDS@online\ipsj@olh@month \else
  \ifnum\c@month<\z@ \c@number \else \c@month \fi \fi \relax
```

という分岐があり、**`\c@month` が未設定（`-1`）のときは `\c@number`（号数）を月として使う**仕様だった（隔月刊・月刊誌では号数=月になることが多いため）。これを見落として `\c@month<0` のとき単に `---` を出す実装にしていたのが原因。`\ipsj@month` に `\c@number` フォールバックを追加して修正。

### 4.6 既定年のtypo

`\ipsj@year` のフォールバック基準年が `1958` になっていた（正しくは `1959`）。原文2090行目以降の `\newcounter{year} \c@year\m@ne` とAgent調査結果の転記ミス。`1959`に修正。

### 4.7 著者上付き文字のカンマ重複（off-by-one）

**症状**：`\author{処理 花子}{Hanako Shori}{IPSJ}`（メールアドレス無し）のような著者で、上付き文字が `1,`（カンマだけ残る）になってしまう。

**原因**：`\comma@or@relax@affilabel`/`\comma@or@relax@email`（著者の所属番号・メール記号の間にカンマを入れる補助マクロ）の実装が、ループの境界値 `\@tempcnta`（=要素数+1）と現在のインデックス `\@tempcntb` を単純に `\@tempcntb<\@tempcnta` で比較していた。この条件はループの**全ての**反復で真になってしまう（境界値が要素数+1なので、最後の要素でも必ず真）ため、最後の要素の後にも常にカンマが入っていた。

正しい判定は「次の要素が存在するか」＝ `\@tempcntb+1 < \@tempcnta` （`\numexpr` を使用）。これは原文の対応マクロの定義をAgentの抽出結果から見つけられず、独自に実装を起こした際のバグであり、原文に同種の不具合があったわけではない。

### 4.8 著者紹介（biography）の写真欄レイアウト

**症状**：`\profile{m,F}{...}{...}` の枠が左右の縦線だけになり上下の横線が無い／本文が枠の横に回り込まず枠の下に落ちる／会員種別の「（正会員）」表記が前のエントリの末尾に紛れ込む。

**原因**：最初の実装は `\pushtowall`（ゼロ幅オーバーレイ）の使い方を簡略化しすぎていた。原文（ipsj.cls 4636〜4858行目）を再度精読して判明した正しい構造は次の通り：

1. エントリ全体を `\begin{minipage}[t]{\columnwidth} ... \end{minipage}` で包む。
2. 写真／枠は `\raisebox{3mm}{\pushtowall{\begin{minipage}[t]{25mm}\hrule\@height.1mm \hbox to 25mm{\vrule...\hss\vrule...} \hrule\@height.1mm\end{minipage}}}`。**上下の `\hrule` が必須**（最初の実装では省略していた）。実画像がある場合（`\IfFileExists{<stem>.eps}` が真）は `\raisebox{-28mm}{\pushtowall{\resizebox{25mm}{31mm}{\includegraphics{...}}}}` に切り替える。
3. 氏名＋本文ブロックは、**写真とは別に独立して**もう一段 `\pushtowall{\begin{minipage}[t]{\columnwidth}\hangindent30mm\hangafter-7\relax ... \end{minipage}}` で包む。写真も本文ブロックも両方ゼロ幅化されているため、互いの横幅を消費せず同じ原点に重ねて配置でき、`\hangindent`/`\hangafter` によって本文が最初の数行だけ枠を避けて回り込む。
4. 氏名の直後・本文の前に会員種別の「（正会員）」等を出力し、その後 `\\[.5\Cvs]` で改行してから本文を続ける（本文の末尾に称号「フェロー」等が付く）。
5. 会員種別の判定マクロ `\@@member`/`\@title@member` は、**呼び出しごとに明示的に空へリセットしてから** `\@for` で再計算する必要がある（`\ipsj@setmember` ヘルパーを新設）。リセットを忘れると `\edef` の結果が前のエントリから引き継がれてしまう。

修正後は `jsample-lualatex.tex`／`esample-lualatex.tex` の著者紹介ページが参照PDFと同じレイアウトになることを確認した。**ただしこの時点では、エントリ単体の見た目しか検証しておらず、複数エントリ間の行間（`\vskip2\Cvs`）の移植漏れには気づいていなかった（後日§4.15で発覚・修正）。**

### 4.9 英文モードの `\author` でラベルが完全に失われるバグ（重要）

**症状**：`english`オプション使用時、`\author{Taro Joho}{IPSJ,PJU}[joho.taro@ipsj.or.jp]` のように所属ラベルとメールを指定しても、上付き文字の**所属番号が完全に消える**（メールの文字（`a)`等）はカンマを伴って正しく出るが、その前の数字が出ない）。複数著者がいる場合に発覚しやすい。

**原因**：`\ifDS@english` 分岐の `\author` 定義（ユーザー向けの2引数ラッパー）が

```latex
\def\author#1#2{\@ifnextchar[{\@author{#1}{#1}}{\@author{#1}{#1}[]}}
```

となっており、内部マクロ `\@author#1#2[#3]`（`#1`=所属ラベル一覧, `#2`=著者名, `#3`=メール）に対して**著者名（`#1`）を2回渡し、所属ラベル一覧（`#2`）を完全に捨てていた**。結果として所属ラベル一覧が常に「著者名そのもの」という1個のダミーラベルになり、`\affiliate@num@<著者名>` も `\paffiliate@num@<著者名>` も未定義（`\csname`の自動\relax化）になるため、該当する上付き文字が空文字列になる。

**対処**：引数の順序を入れ替えるだけで修正できる。

```latex
\def\author#1#2{\@ifnextchar[{\@author{#2}{#1}}{\@author{#2}{#1}[]}}
```

このバグは情報処理学会公式の英文サンプル（`esample.tex`）でも発生していた（3人の連名のうち全員の所属番号が消えていた）が、ページ数比較と1ページ目のざっとした目視確認だけでは見逃していた。SES（ソフトウェアエンジニアリングシンポジウム）用テンプレートの英文サンプルを検証する際に、上付き文字を高解像度で確認して初めて発覚した。**ページ数の一致だけでは不十分で、複数著者のいる英文ドキュメントでは著者欄を高解像度で目視確認する必要がある**という教訓。

なお、このバグの調査中に「最後の著者の上付き番号の後に余分なカンマがあるように見える」という疑いが生じ、その時点では`pdfcrop --bbox`で確認した結果カンマは存在しないと判断した。**しかしこれは誤った結論だった**。実際には本物のバグであり、後日（§4.10）の調査で再現条件（メールアドレスを持つ著者が直前にいない場合に限り発覚する）を誤って外していたために再現しなかっただけだったことが判明した。詳細はメールアドレスが存在しない著者の調査（§4.10）を参照。

### 4.10 メールアドレスを持たない著者の上付き文字に余分なカンマが付く根本バグ（TeXの数値スキャン仕様に起因、重要）

**症状**：`\author{name}{}{label}`（メールアドレス省略）のように**メールアドレスを持たない著者**がいる場合、その著者の上付き文字が `1,`（末尾に余分なカンマ）になる。`noauthor`かつ全著者がメールアドレス省略のSES論文（後述の5件の追加検証で発見）で初めて明確に視認できたが、実際には**メールアドレスの有無を問わずすべての著者で常に発生していた**バグであり、メールアドレスを1件以上持つ著者では「もともと出るべきカンマ」と偶然重なって見分けがつかなかっただけである。4.9節末尾で「誤りだった」と記載した調査時の結論はこれが原因の誤判定であり、本節の内容が正しい。

**原因**：`\authoroutput`内の以下の行（メールアドレス数の取得）

```latex
\expandafter\@tempcnta\csname authoremail@num@\the\count@\endcsname
\ifnum\@tempcnta=\z@\relax\else\textsuperscript{,}\fi
```

は、`\csname...\endcsname`が展開された結果（例：`\authoremail@num@3`の中身である数字`0`）をTeXの数値スキャナが`\count`レジスタへ代入する際、**後続に明示的な`\relax`等の終端トークンが無い**ため、数値スキャナが「もっと続く数字があるかもしれない」と先読みを続けてしまう。先読みの過程でTeXは次のトークンを展開可能であれば展開する（`get_x_token`相当の処理）が、その次のトークンが`\ifnum`のような**条件文プリミティブ**である場合、TeXは数値スキャン処理の最中にその条件文を**実際に実行してしまう**。この時点では`\@tempcnta`への代入（`0`への変更）は**まだ完了していない**ため、`\ifnum\@tempcnta=\z@`は**代入前の古い値**（直前の所属ラベルループで使われた`label数+1`、通常2以上）を見て判定することになり、ほぼ常に「ゼロでない」と誤判定して`\textsuperscript{,}`を実行してしまう。その後で本来の代入（`0`）が完了するため、最終的な値は正しいのに、**誤判定による副作用（カンマの出力）だけが既に発生済み**という状態になる。

メールアドレスを1件以上持つ著者の場合も同じ誤判定は起きているが、その場合は「本来カンマを出すべき」状況と偶然一致するため、出力上は区別できず正しく見える。メールアドレス0件の著者だけ、誤判定によるカンマが「余分」として可視化される。

**対処**：`\csname...\endcsname`による`\count`代入の直後に明示的な`\relax`を置き、数値スキャンを即座に終端させる。

```latex
\expandafter\ipsj@authcnta\csname authoremail@num@\the\count@\endcsname\relax
\ifnum\ipsj@authcnta=\z@\relax\else\textsuperscript{,}\fi
```

同種のパターン（`\expandafter<count>\csname...\endcsname`の直後に`\relax`が無いもの）をクラス全体から検索し、見つかった箇所（所属ラベル数の取得、著者紹介ページのメール脚注生成）にも同様に`\relax`を追加した。これらは直後が`\advance`（プリミティブだが条件文ではない）であったため**今回は実害が出ていなかった**が、将来このコードを編集して直後に条件文を追加すると同種の不具合が再発する危険があるため、予防的に修正した。

**発見の経緯**：当初（4.9節）の調査では英文3名連名サンプルで確認し、メールアドレスのない最後の著者（Jiro Gakkai）の上付き文字を高解像度で切り出して「カンマは無い」と判断した。これ自体は**その時点の確認としては正しかった**が、後にSES追加検証の5件目（全著者がメールアドレスを省略した和文4名連名の論文）で同じ位置に明確なカンマが再現し、`\message`による値の直接出力で`\authoremail@num@<n>`が確かに`0`であることを確認した上で、`\relax`や`\message`を該当行の直後に挿入すると症状が消えるという再現実験により、TeXの数値スキャン中の条件文先読み実行が原因であると断定した。同じ条件（英文3名連名、メールなし著者）を結果が変わるはずがない以上、4.9節時点の「カンマは無い」という判断は**誤り**だったことになる。低解像度はおろか高解像度での目視確認すら、TeXのマクロ展開タイミングに起因する間欠的な不具合の有無を判定する手段としては不十分であり、**疑わしい挙動は`\message`で実際の変数値を直接出力して検証する**のが唯一信頼できる方法である。

### 4.11 `itemize`/`enumerate`内に不自然な行間が空く（`\flushbottom`×フォント再選択の相互作用、重要）

**症状**：`jsample-lualatex.pdf`を元の`jsample.pdf`と見比べると、`itemize`/`enumerate`を使っている節（5.1節の「べからず集」チェックリスト等）だけ、項目間に不自然に大きい空白が不規則に入る。本文の段落や他の箇所は正常。

**原因**：本クラスは`\flushbottom`を使用しており（原文`ipsj.cls`も同様）、両カラムの高さを揃えるために必要な伸縮分を、ページ内で伸縮可能な空白（glue）に分配する。標準`article.cls`の`itemize`/`enumerate`のリスト間隔（`\@listI`系、`\topsep`/`\itemsep`/`\parsep`）には`plus`/`minus`の伸縮成分が大きく含まれており、他に伸縮できる箇所が少ないと、その伸縮分がリストの項目間に集中して押し込まれ、不自然な空白として可視化される。

原文`ipsj.cls`はこの現象を避けるため、`itemize`/`enumerate`のリスト間隔を全て**伸縮なしのゼロ**に固定している（5945行のファイル中、「ipsjpapers.styから流用」というコメント付きの一箇所で`\@listi`〜`\@listvi`を再定義）。本クラスでも同様の再定義を一度だけ追加して動作確認したが、**それだけでは直らなかった**：`fontspec`/`luatexja-fontspec`が`\AtBeginDocument`フック内で`\normalsize`を再度呼び出すため（pLaTeXには存在しない、LuaLaTeX特有のフォント設定の都合）、`\normalsize`の定義に含まれる`\let\@listi\@listI`（標準カーネルの慣用句で、`\@listI`は`article.cls`の伸縮ありデフォルトを保持している）が**グループの外側（トップレベル）で再実行され**、一度きりの修正を上書きしてしまう。原文`ipsj.cls`はpLaTeXのみを対象とし`fontspec`を一切使わないため、この再実行が起こらず、問題が表面化しなかった。

`\message`でクラス読み込みの各段階での`\meaning\@listi`を直接確認したところ、`\usepackage{...}`直後までは正しくゼロ伸縮だったが、`\begin{document}`の直後の時点でいつの間にか伸縮ありに戻っていることが判明し、原因を特定した。

**対処**：`\normalsize`自身の定義内で`\let\@listi\@listI`を使うのをやめ、`\small`/`\footnotesize`が既にそうしているのと同じパターンで、ゼロ伸縮の値を直接`\def`する。

```latex
\renewcommand{\normalsize}{%
  ...
  %% \let\@listi\@listI ではなく直接値を設定する（後述参照）
  \leftmargin\leftmargini \partopsep\z@ \parsep\z@ \topsep\z@ \itemsep\z@}
```

`\normalsize`は何度再実行されても毎回正しい値を設定するため、再実行元（`fontspec`のフックなど）を個別に特定・対処する必要がなく、頑健な解決になる。深い入れ子（`\@listii`〜`\@listvi`）は`\normalsize`からは再設定されないため、クラス読み込み時の一度きりの定義で十分。

修正後、`jsample-lualatex.pdf`は9ページ（修正前は11ページ、原文は10ページ）、`esample-lualatex.pdf`は8ページ（修正前は9ページ、原文も8ページで完全一致）に変化し、不自然な空白は全て解消された。

**教訓**：`\AtBeginDocument`でフックを使うパッケージ（`fontspec`系に限らず、`hyperref`等も同様の手法を使うことがある）は、クラス側が想定していないタイミングで`\normalsize`等のカーネルコマンドを**トップレベルで**再実行することがある。クラス内で「一度だけ`\@listi`等を上書きすれば十分」という設計は、こうした再実行で容易に無効化されるため、**繰り返し呼ばれる可能性のある命令（`\normalsize`/`\small`/`\footnotesize`等）の内部に直接組み込む**方が安全である。

### 4.12 既定（論文誌）モードの1ページ目で受付日・採録日が表示されない（重要）

**症状**：`jsample-lualatex.pdf`の1ページ目に、原文`jsample.pdf`にある「受付日2016年3月4日，再受付日2015年7月16日/2015年11月20日，採録日2016年8月1日」（英文では"Received: March 4, 2016, Accepted: August 1, 2016"等）の行が表示されない。`\受付`/`\再受付`/`\採録`（`\received`/`\rereceived`/`\accepted`）は原稿側で正しく呼んでいるにもかかわらず、出力に反映されない。

**原因**：受付・採録日を実際に画面へ出すのは`\@uketsuke`（和文）/`\@euketsuke`（英文）という出力用マクロで、`\authortitle`（タイトルページ組版）からこれを呼び出して初めて表示される。本クラスでは`\@uketsuke`/`\@euketsuke`を**`techrep`モードのフォントレジスタ（`\phantom{...}`で日付を完全に隠す版）でしか定義しておらず**、かつ`\authortitle`の**既定（論文誌）モード版**には`\@uketsuke`/`\@euketsuke`を呼び出す行自体が無かった（techrepモード版の`\authortitle`にのみ存在していた）。原文`ipsj.cls`を確認すると、`\@uketsuke`（実際の日付を組み立てて表示する本来の定義）は既定モードでも使われており、`\authortitle`内で著者欄の直後・概要欄の直前に`{\juketukefont{\@uketsuke}\par}`として呼ばれている。techrepモードは技術報告（採録前提のプレプリント）なので日付を見せない`\phantom`版に**後から上書き**する、という構造だったが、移植時にこの「既定モードでの本来の表示」の方を実装し忘れていた。

**対処**：

1. 本来の`\@uketsuke`/`\@euketsuke`（`\@received`/`\@rereceived`/`\@rerereceived`/`\@accepted`/`\@released`、英文では`\@ereceived`等を組み合わせて表示する版）を、`\received`/`\accepted`等の定義の直後（techrepの`\ifDS@techrep`分岐より前）に追加した。
2. 既定モードの`\authortitle`（和文・英文の両方）に、著者欄の直後・概要欄の直前へ`{\juketukefont{\@uketsuke}\par}`（英文は`{\Enguketukefont{\@uketsuke}\par}`）、英文著者欄がある場合はその直後にも`{\euketukefont{\@euketsuke}\par}`の呼び出しを追加した。フォントマクロ（`\juketukefont`等）とスキップ量（`\Jauthorjreceivesep`等）は元から定義済みで使われていなかっただけだったため、呼び出しを追加するだけで済んだ。

修正後、`jsample-lualatex.pdf`は10ページ（原文と完全一致）、`esample-lualatex.pdf`は8ページ（変化なし、原文と完全一致）になり、受付・採録日が画素単位で原文と一致する形で表示されることを確認した。`techrep`モード（`tech-jsample-lualatex.tex`）は元から`\phantom`版を使うため影響なし。

**教訓**：「`techrep`モードでは日付を隠す」という仕様だけに着目してphantom版の移植を優先し、**それより基本的な「既定モードでは日付を実際に表示する」という土台の実装を見落とした**。同じマクロ名（`\@uketsuke`）が複数モードで意味の異なる定義を持つ場合、各モードの`\authortitle`を1つずつ独立に全文比較する必要があり、「techrep版が動いているから大丈夫」という確認だけでは既定モードの欠落に気づけない。

### 4.13 `enumerate`/`itemize`/`description`/`quote`/`quotation`/`verse`/`\newtheorem`の「意図的な簡略化」を撤回（重要）

**経緯**：当初の実装では、`\Enumerate`/`\Itemize`/`\Description`/`\ENUMERATE`/`\ITEMIZE`/`\DESCRIPTION`/`enumerate*`/`itemize*`/`description*` を標準の `enumerate`/`itemize`/`description` への単純な `\let` 別名にとどめ、`quote`/`quotation`/`verse` の `\Cwd` ベースのインデント調整・IPSJ向け`\newtheorem`スタイル・`recommendation` 環境は未移植とし、「使用頻度が低い」「枝葉末節」と判断して優先度を下げていた。ところが`jsample-lualatex.pdf`と`jsample.pdf`を見比べたところ、2.1節の箇条書き（`\begin{Enumerate}`使用）の番号書式が「1.」（標準LaTeX）と「(1)」（原文）で異なっており、ユーザーから「簡略化はやりすぎだった、`enumerate`に限らず全て正しく実装し直してほしい」という指摘を受けた。

**原因（技術的詳細）**：原文`ipsj.cls`は次の2階層で `enumerate`/`itemize`/`description` をカスタマイズしている。

1. **基底の`enumerate`/`itemize`/`description`自体を再定義**：`\labelenumi`を`(\,\theenumi\,)`（標準は`\theenumi.`）に、ラベル幅を`2\Cwd`に変更するなど。これは`\Enumerate`等の大文字版とは無関係に、**プレーンな`enumerate`を使うだけで効果がある**変更であり、見落としていた部分。
2. **`\Enumerate`等の大文字版は、カーネルの`\@trivlist`（`\list`が内部で呼び出す、字下げ確定用のマクロ）を一時的に上書きして、`\leftmargin`/`\itemindent`をさらに調整する**：`\Enumerate`/`\Itemize`/`\Description`は字下げを詰め、`\ENUMERATE`等の全大文字版は`\Cwd`分広げ、`enumerate*`等のアスタリスク版は逆方向に`\Cwd`シフトする。3種とも実体は同じ`\lst@trivlist`に異なる引数を渡しただけ。

「`\Enumerate`を`enumerate`の別名にした」という簡略化だけに注目していたため、1.の基底レベルの再定義が必要なことに気づいておらず、`\Enumerate`を独自実装しても`(1)`書式には到達できなかった（`\Enumerate`は内部で結局`\enumerate`を呼ぶため、土台が標準のままでは番号書式は変わらない）。

**対処**：原文の該当箇所（`ipsj.cls`の「ipsjpapers.styから流用」コメント付き一帯）を以下の方針でそのまま移植した。

- `\labelenumi`〜`\labelenumiv`・`\theenumi`〜`\theenumiv`・`\p@enumii`〜`\p@enumiv`を`\renewcommand`で上書き（`(1)`形式）。
- `enumerate`/`itemize`/`description`環境自体を`\renewenvironment`で再定義（ラベル幅`2\Cwd`、行間ゼロ等）。
- `\lst@trivlist`/`\lst@Trivlist`/`\lst@TRIVLIST`/`\lst@strivlist`を移植し、`\Enumerate`/`\Itemize`/`\Description`/`\ENUMERATE`/`\ITEMIZE`/`\DESCRIPTION`/`enumerate*`/`itemize*`/`description*`を`\@trivlist`フック経由の実装に差し替え。
- `quote`/`quotation`/`verse`を`\renewenvironment`で再定義（`\Cwd`ベースの字下げ）。
- `\newtheorem`をカーネルの既定動作から完全に差し替え（`\@ifstar`で分岐し、`\theo@it`/`\theo@sp`を経由して`\DESCRIPTION`リストで定理見出しを組む。英文モードでは定理番号がイタリックになる）。
- `recommendation`環境（SLDM等の「推薦文」）を追加。

修正後、`jsample-lualatex.pdf`の2.1節は`(1)`〜`(11)`の番号付きリストとして原文と画素単位で一致し、`quote`環境（URL表示など、`jsample`/`esample`/`tech-jsample`/`ses-sample`/`ses-esample`で多用）を含むページも完全一致を確認した。`quotation`/`verse`/`\newtheorem`/`recommendation`は今回のテスト文書群では実際に使用されていないため出力比較はできていないが、原文のコードをそのまま移植してあるため、構造的には同一の挙動になるはずである。

**教訓**：「`X`を`Y`の別名にする」という簡略化を行う際は、**`Y`自体が標準から変更されていないかを必ず確認する**こと。`\Enumerate`が`enumerate`の単純な別名で済むという判断は、暗黙に「`enumerate`自体は標準のまま」という前提に依存していたが、実際には原文がその前提も崩していた。「大文字版だけ特別」という思い込みで調査を打ち切らず、関連する全レベルの定義を原文から再確認する必要がある。

### 4.14 手動の`\pagebreak`/`\newpage`がフォント差による改行位置のズレで巨大な空白を生む（クラス側では対処不可、原稿側の問題）

**症状**：`jsample-lualatex.pdf`の5.2節で、`itemize`の最初の項目の途中で強制的に改段され、その段の残り全体（7ページ目左段のほとんど）が空白になる。

**原因**：`jsample.tex`の該当箇所には、原文の組版に合わせて手動で挿入された`\pagebreak`がitem内の文中（「研究の動機，」の直後）にある。

```latex
\item[$\Box$] 在来研究との関連，研究の動機，\pagebreak%%%
              ねらい等が明確に説明されていないのは再考を要する．
```

`\pagebreak`はその場で即座に改ページするのではなく、**次の行末**に強制改ページ用のペナルティを挿入する仕組みである。元のpLaTeX版ではフォントメトリクスの結果「研究の動機，」がちょうど段の最後の行に来ており、`\pagebreak`は「すでにほぼ埋まっている段の直後」で発火するため目立った空白は生まれない。LuaLaTeX版ではフォント（TeX Gyre Termes/Harano Aji）が異なるため改行位置がわずかにずれ、「研究の動機，ねらい等が明確に説」までが1行に収まってしまう。その行末で同じ`\pagebreak`が発火するため、まだ段の上部にもかかわらず強制的に改段され、段の残り全体が空白になる。

文章の内容自体は壊れていない（次の段の先頭で正しく続く）。**これはクラス側の不具合ではなく、特定の行送り位置を前提にした`\pagebreak`/`\nopagebreak`/`\newpage`が、フォント差による改行位置のズレに対して構造的に脆いという、原稿（.tex）側の問題**である。フォントメトリクスが完全に一致しない限り、どのような実装をしてもこの種の手動改ページ位置だけは原文と完全に一致させることはできない。

**対処**：`jsample-lualatex.tex`からは該当`\pagebreak`を削除した（ユーザーの指示により、見た目を整えるため）。`itemize`/`enumerate`/`description`等の自前実装そのものに問題はなく、§6.2のページ数・他の全ページの目視比較は変更前から完全一致している。他の文書を移植する際も、手動の`\pagebreak`/`\nopagebreak`/`\newpage`がitemやparagraphの**途中**に置かれている箇所があれば、目視比較で不自然な空白が出ていないか確認し、出ていればその挿入位置を削除・調整する必要がある（§6.3の手順に追加済み）。

同じ文書の5.5節末尾（`\end{itemize}`の直後、5.6節の直前）にも `\newpage` がもう1箇所あり、同種の症状（7ページ目右段がほぼ空白）を引き起こしていた。これも削除した。`\newpage`は段の途中ではなく節の境界にあったため、削除した結果**ページ数自体が10ページから9ページに変わった**（原文`jsample.pdf`は10ページのまま）。これは「`\newpage`が指定された地点が、原文の組版ではちょうど次ページの先頭と一致していたが、フォント差で詰まった本クラスの組版ではまだページに余裕がある地点だった」ことを意味し、`\newpage`を削除して自然な流れに任せた方が、空白を残すよりも原文の体裁に近い。`\pagebreak`の場合（§4.14前半）と異なり、`\newpage`の削除はページ数自体を変化させる場合があることに注意。

**この節からの一般的な教訓**：`\pagebreak`/`\nopagebreak`/`\newpage`/`\enlargethispage`等、原稿中に直接書かれた**絶対位置依存の組版命令**は、フォントを変更すると全て疑わしいと考えるべきである。1箇所見つかったら、同じ文書に他にないか`grep`で網羅的に確認すること（本件では`\pagebreak`と`\newpage`の2箇所があり、片方を直してから初めてもう片方が次の症状として見えてきた）。

### 4.15 著者紹介（`\profile`）のエントリ間・本文行間が原文より詰まって見える（重要、2段階で発覚）

**症状（1段目）**：`jsample-lualatex.pdf`末尾の著者紹介（`biography`環境、`\profile`を複数回使用）が、原文`jsample.pdf`と比べてエントリ間の行間が詰まって見える。実際には1ページに収まる`\profile`エントリの数が原文より多く、全体的に窮屈な印象になる。

**原因（1段目）**：原文`ipsj.cls`の`\ip@eprofile`/`\no@eprofile`/`\n@eprofile`（`\profile`の内部実装、写真あり・なし・枠なしの3パターン）は、いずれも各エントリの組版を終えた直後に`\vskip2\Cvs`（全角2行分の行送り）を挿入しており、これがエントリ同士の間隔を作っている。本クラスでは§4.8で報告したとおり、写真欄と本文欄を独立した`\pushtowall`（ゼロ幅オーバーレイ）で重ねる方式に作り替えていたが、各エントリの末尾を`\end{minipage}\global\let\@BreakMember\relax\par}`で終えるだけで、原文にある**`\vskip2\Cvs`の移植を丸ごと落としていた**。§4.8の調査では枠線・写真配置・字下げ・会員種別表記の再現に注力し、「エントリ間の間隔」という一段階上のレイアウト要素を見落としていた。

**対処（1段目）**：`\ip@eprofile`/`\no@eprofile`/`\n@eprofile`の全6種（和文・英文 × 写真あり/なし/枠なし）の末尾を、`\par}` から `\par\vskip2\Cvs}` に統一して変更した（6箇所とも同一の変更だったため`replace_all`で一括修正）。

**症状（2段目）**：1段目の修正後も、ユーザーから「エントリ間ではなく、各著者の紹介文**本文の行間そのもの**がまだ詰まって見える」という指摘を受けた。

**原因（2段目）**：本文（紹介文）のフォント設定は原文・本クラスとも `\fontsize{13\JQ}{21\h}\selectfont` で一致しており、サイズ自体に差はなかった。差は**`\baselineskip`をどこで設定しているか**にあった。原文は

```latex
\baselineskip=21\h{\fontsize{13\JQ}{21\h}\selectfont #3\csname @title@member\endcsname}%
```

のように、`\baselineskip=21\h`を**`{...}`グループの外側**で明示的に代入してから、グループ内で`\fontsize`を適用している。一方、本クラスは

```latex
{\fontsize{13\JQ}{21\h}\selectfont#3\@title@member}%
```

と`\fontsize`だけをグループ内に置いていた。`\fontsize{size}{skip}\selectfont`は内部的に`\baselineskip`を`skip`相当の値に設定するが、これは**`{...}`グループに対してローカルな代入**になる。`biography`環境は冒頭で`\footnotesize`（行送り`18\h`）に切り替えているため、グループを閉じた瞬間に`\baselineskip`は`\footnotesize`の`18\h`へ巻き戻ってしまい、その後TeXが段落をライン分割する際に**本文用に意図した21\hではなく18\hの行送りが使われてしまう**。原文が`\baselineskip=21\h`をグループの**外側**に置いているのは、まさにこの巻き戻りを防ぐための意図的な配置だったが、移植時に見落として`\fontsize`の自動設定だけに頼っていた。

**対処（2段目）**：原文と同じ位置（`{...}`グループの外側）に`\baselineskip21\h`（英文モードは`\baselineskip18\h`）を明示的に追加した。対象は和文・英文 × 写真あり/なし/枠なしの全6箇所。

修正後、`jsample-lualatex.pdf`・`esample-lualatex.pdf`・`ses-esample-lualatex.pdf`を再コンパイルし、ページ数は変化なし（9/8/8）。`pdfcrop`で同一座標・同一スケールに切り出した「処理花子」エントリの本文行間を原文と直接比較したところ、行間のピクセル差はほぼゼロ（300dpiで63〜65px、原文も65px）まで一致した。

**教訓**：`\fontsize{size}{skip}\selectfont`は`\baselineskip`を**設定したと思っても、それがどのグループスコープで有効になるか**を常に意識する必要がある。原文が同じ値を二重に（グループ外の明示代入＋グループ内の`\fontsize`）書いているのは冗長に見えて実は必須であり、「同じ値を2回書いているから一方は削っても良い」という早合点は禁物。また、この種の「行間だけが違う」というユーザー指摘は、改めて`pdfcrop`で同一領域を同一スケールで切り出し、ピクセル単位で行送りを比較するまで確証が持てなかった——目視だけでは「詰まって見える」が原因（1段目のエントリ間隔か、2段目の本文行間か）の特定までは難しい。

### 4.16 「太字明朝」は原文では実は常に「ゴシック」で代用されている（クラス全域に影響、重要）

**症状**：`jsample-lualatex.pdf`の著者紹介で、著者名が原文`jsample.pdf`では明らかにゴシック体（サンセリフ・等画線）に見えるのに対し、新版では明朝体（セリフ風・はね/うろこ付き）に見える。

**原因の核心**：原文`ipsj.cls`が前提とする（pLaTeX/upLaTeXの）標準的な和文フォントセットアップでは、**Mincho（明朝）ファミリにBoldシェイプがそもそも宣言されていない**。そのため`\bfseries`を明朝ファミリの状態で呼ぶと、NFSSのフォント代替機構が自動的に**Gothic（ゴシック）ファミリのMediumシェイプ**を代用する。これは「明朝の太字が欲しければゴシックで代用する」という和文組版の古くからの慣習に基づくもので、`ipsj.cls`のコード自体は単に`\bfseries`としか書いていない（`\gtfamily`等の明示的な指定はしていない）。

これを実際に検証するため、`jsample.pdf`をGhostscriptで非圧縮化し`/BaseFont`を全て列挙したところ、**文書全体を通じて`HaranoAjiMincho-Regular`と`HaranoAjiGothic-Medium`の2つしか埋め込まれておらず、`HaranoAjiMincho-Bold`は一切存在しなかった**。つまり原文には太字明朝のグリフが文書中のどこにも無く、太字が必要な箇所は全てゴシックで描画されている。

一方、本クラスは`luatexja-fontspec`経由で`Harano Aji Mincho`を指定しており、このフォントファミリは**Regular/Boldの実ウェイトを両方持つ**（§2.2で確認済み）。そのため`\bfseries`は素直に本物の太字明朝を選択してしまい、原文が依存する「明朝に太字が無いのでゴシックが代用される」という暗黙の挙動が再現されない。`\section`等の見出しコマンドは既に`\gtfamily\bfseries`を明示していたため問題なかったが（おそらく見出しは原文を直接確認して移植したため）、それ以外の多くの箇所は単純に`\bfseries`だけを移植しており、本クラスでは（本物の太字明朝が使えてしまうがゆえに）原文と異なる結果になっていた。

**調査方法**：`ipsj.cls`全体を`\bfseries`で`grep`し（51件）、各箇所が英文（Latin文字、影響なし）か和文（影響あり）かを確認した上で、対応する本クラスの実装と比較した。

**対処**：和文かつ`\bfseries`を使う箇所に`\gtfamily`を追加した。具体的には以下（全て英文モードでは無変更、`\ifDS@english`で和文側のみに適用）：

- `\GAIYOU`（概要ラベル）／`\JKEYWORD`（キーワードラベル）
- `\paragraph`／`\subparagraph`（既存の`\section`〜`\subsubsection`は元々`\gtfamily`済みだった）
- `\@makecaption`／`\@twocolcaption`（図表番号「図1」「表1」のラベル部分。英文用の`\ecaption`／`\@twocolecaption`は元から`\rmfamily`系で太字明朝の問題自体が発生しないため無変更）
- `\figref`/`\tabref`系の初回参照強調（`\bf@or@normal`）：和文「図1」は`\gtfamily`、英文"Fig. 1"は元の`\bfseries`のまま（`\ifDS@english`で分岐）
- `recommendation`環境（「推薦文」）／`\acknowledgment`（「謝辞」）の和文側
- `description`環境の`\makelabel`（項目見出しの太字）
- `\profile`内部実装（`\ip@eprofile`/`\no@eprofile`/`\n@eprofile`の和文3種）の著者名（今回の発端）

**`\@makecaption`/`\@twocolcaption`は要注意**：これらは`\ifDS@english`の内側で分岐させているわけではなく、和文モードでも英文モードでも共通して呼ばれる（英文モードの`esample.tex`は`\ecaption`ではなく素の`\caption`を多用しているため）。そのため`\gtfamily`を無条件に追加すると、英文キャプション（"Fig. 1"等、漢字を含まない）にも適用されてしまう。漢字を含まないので**見た目には何の影響もない**はずだが、`\gtfamily`への切替自体がluatexjaの行送り計算にわずかな影響を与えるらしく、`esample-lualatex.pdf`のページ数が8→9に変化する副作用が実際に発生した。そのため`\ipsj@boldlabel`という小さいヘルパー（`\ifDS@english\bfseries\else\gtfamily\bfseries\fi`）を導入し、英文モードでは元の`\bfseries`のみに留めるよう修正した。

**追記（§4.17で根本原因が判明）**：本節作成時点では上記`\ipsj@boldlabel`分岐を入れても`esample-lualatex.pdf`が8→9ページのままで原因を特定できず、「フォントメトリクスの違いによる1ページ程度のズレ」と同種の許容範囲内の差として一旦受け入れた。実際には全く別の原因（`\section`見出しの組版機構が簡略化されていたこと）が真の原因であり、§4.17の修正によって`esample`は8ページに復帰し、原文と完全一致するようになった。「本物のバグが1つあるだけなのに、無関係な複数の変更を疑って個別に元に戻す」というbisectのやり方では、変更箇所自体ではなく**クラスの別の場所に潜む既存の不具合**が原因のケースを発見できないという教訓が残る。

**さらなる残存事項（無害と判断）**：修正後も`jsample-lualatex.pdf`の埋め込みフォントには依然`HaranoAjiMincho-Bold`が含まれている。ログを調査した結果、これは`\mathversion{bold}`（見出し等で使用）が`luatexja-fontspec`の数式シンボルフォント"mincho"の「bold」バージョンとして`HaranoAjiMincho`のBoldシェイプを自動的に宣言する副作用であると判明した（`LaTeX Font Info: Overwriting symbol font 'mincho' in version 'bold' ... JY3/HaranoAjiMincho(0)/m/n --> JY3/HaranoAjiMincho(0)/b/n`）。これは数式モード用のシンボルフォント宣言であり、文書中に実際に和文文字を含む数式中ボールド表記が無ければ、グリフが一切描画されないまま埋め込まれるだけの無害なフォントだと考えられる。全ページを目視確認した範囲では、可視のテキストとして太字明朝が現れている箇所は見つからなかった。原文がこの宣言自体を回避できている理由は、原文の和文フォント設定がそもそもmincho自体をgt系へのsubstitute宣言として組んでいるためと推測されるが、これを完全に同じ形で再現するには`luatexja-fontspec`のシンボルフォント宣言レベルでの変更が必要となり、リスクと労力に対して得られる効果（非表示のフォントが1つ減るだけ）が小さいため、今回は対応を見送った。

**教訓**：「`\bfseries`をそのまま移植すれば十分」という判断は、**原文の和文フォント環境にBoldシェイプが存在するかどうか**という前提を無意識に踏んでいた。本クラスのように実際にBoldウェイトを持つ物理フォント（Harano Aji）を採用する場合、原文が「フォントが無いから仕方なくゴシックで代用していた」だけの箇所が、移植先では「本物の太字明朝が描画できてしまう」という形で逆に視覚的な相違点として表面化する。**`\bfseries`の移植は、出力PDFの`/BaseFont`一覧を確認して「太字明朝が実在するか」を機械的に検証するまで、安全だとみなしてはならない**。

### 4.17 `\section`見出しが固定高さの`\vbox`で組まれる独自機構だったのに、単純な`\@startsection`に簡略化していた（重要、esampleの謎の1ページ差の真因でもあった）

**症状**：`jsample-lualatex.pdf`の1節「1. はじめに」見出しの下の空白が、原文`jsample.pdf`より明らかに狭い。4節「4. 論文の構成」でも見出しの前後の空白が原文と異なる。

**原因**：`ipsj.cls`の`\section`は、標準的な「前後スキップ＋見出し本文」という`\@startsection`の素朴なモデルでは組まれていない。`\@startsectionA`/`\@sectA`という専用マクロが、見出し（番号＋題名）が1行に収まる場合は**固定高さ`2.43\Cvs`の`\vbox`**（`\vfill`で見出し行を上下中央に配置）に、`\columnwidth`を超えて折り返す場合は`\addvspace{.65\Cvs}`/`{.74\Cvs}`という別の固定値に、見出しを組み込む。さらに前後では`\mbox{}\par\vspace{-\baselineskip}`（直前の段落が残す行送りグルーを打ち消す）、見出し直後では`\prevdepth=-1000pt`（次の段落が独自に行送りグルーを追加するのを防ぐ）という、通常の段落送り処理を明示的にキャンセルする処理が入っており、**見た目の空白は前後スキップの値ではなく、この固定高さのボックス自体が決めている**。

本クラスの実装は`\section`を含む見出し全レベルを単純な`\renewcommand{\section}{\@startsection{section}{1}{\z@}{.5\Cvs}{.00001\Cvs}{...}}`に簡略化していた。後スキップの値（`.00001\Cvs`）は原文の`\@sectA`に渡す値（同じく`.00001\Cvs`、ほぼゼロ）をそのまま転記していたため一見正しそうに見えるが、**原文ではこの値自体がほぼ無意味（実際の空白は`\vbox`の高さが生む）**ということに気づいておらず、単純な`\@startsection`モデルではこの後スキップがほぼゼロのまま機能してしまい、見出し下の空白が実質的に消えていた。前スキップも原文の`.00001\Cvs`ではなく`.5\Cvs`に変えてしまっており、これも不一致だった。

**対処**：原文の`\@startsectionA`/`\@sectA`/`\@ssectA`（和文・英文の両方）を`\section`専用に移植した。`\SECTwd`/`\@tempboxb`（原文の汎用スクラッチレジスタ）は§4.4の教訓に従い専用レジスタ`\ipsj@secboxa`/`\ipsj@secboxb`に置き換えた。`\@xsect`も（実際には使われない分岐の`\clubpenalty`が`article.cls`のカーネル版と異なるだけだが）安全のため移植した。`\@hangfrom`/`\@afterheading`等はカーネルの提供する同名マクロが原文の独自定義と機能的に同一であることを確認し、そのまま流用した（再定義不要）。`\subsection`〜`\subparagraph`（`\@startsectionC`/`\@sectC`系）は原文を確認した結果、標準カーネルの`\@startsection`/`\@sect`/`\@ssect`と**構造的にほぼ同一**（`\@hangfrom`を使う点も含めて）であり、固定高さボックスのような特殊機構を持たないことが分かったため、既存の単純な`\@startsection`実装のままで構わない。ただし前スキップの値に誤りがあった：`\subsubsection`/`\paragraph`/`\subparagraph`は原文では前スキップが`0.00001\Cvs`（ほぼゼロ）なのに対し本クラスは`.5\Cvs`になっていたため修正し、さらに`\paragraph`/`\subparagraph`の見出しレベル引数も原文同様`{3}`（`\subsubsection`と同じレベル）に修正した（本クラスは`{4}`/`{5}`になっていた。`\setcounter{secnumdepth}{3}`の既定値では、レベル引数が`{4}`/`{5}`だと`\paragraph`/`\subparagraph`が常に無番号になってしまうが、原文ではレベル`{3}`なので既定で番号が付く）。

**`\appendix`内の`\section*{\appendixname}`に関する副次的な発見**：上記の修正を施した直後、`jsample-lualatex.pdf`の付録見出し「付録」が原文の「付　　　録」（文字間が大きく開いた均等配置）と異なり詰まって表示され、さらに直後の「A.1 付録の書き方」が次ページに押し出される現象に気づいた。調査の結果、2つの独立した不具合が判明した。

1. **`\kintou`（均等配置マクロ）がLuaTeX-jaの`kanjiskip`機構に対応していなかった**：原文の`\kintou`は`\kanjiskip\z@ \@plus 1fill \@minus 1fill`によってpTeXの`\kanjiskip`レジスタ自体を伸縮可能にし、`\hbox to #1{...}`の余白を**文字と文字の間**に吸収させることで均等配置を実現している。本クラスの実装はこれを「`#2`の前後に`\hskip0pt plus1fill minus1fill`を置く」という簡略化に置き換えていたが、これは`#2`を箱の中央に**1つのブロックとして**寄せるだけで、文字間は一切広がらない（LuaTeX-jaの文字間グルーは有限次数なので、外側の無限次数`fill`グルーと同じリストに同居すると常に負ける）。`\ltjsetparameter{kanjiskip={0pt plus 1fill minus 1fill},xkanjiskip={...}}`（LuaTeX-jaにおける`\kanjiskip`の代替インターフェース）に置き換えて修正した。
2. **`\appendix`内で`\section*`が使う機構が原文と異なっていた**：原文は`\appendix`の内部で`\section`自体を`\@startsectionAPP`（`\@startsectionA`とほぼ同一だが、`*`付きの場合は`\@ssectA`ではなく`\@ssectC`——本クラスの文脈ではカーネルの`\@ssect`と同義——を呼ぶ）に再定義している。`\@sectAPP`（`*`無しの場合）は`\@sectA`と1バイトも違わない実装だったため、新たに複製はせず`\@sectA`を再利用した。本クラスは`\appendix`内で`\section`を再定義しておらず、`\section*{\appendixname}`が常に（より大きな空白を作る）`\@ssectA`を経由してしまっていたため、`\@startsectionAPP`を追加し`\appendix`からそれを使うよう修正した。

**検証方法**：`pdfcrop`で原文・新版の同一領域を同一スケールに切り出し、見出し下の空白・「付　　　録」の文字間隔を直接比較した。また`gs`でページごとにPNG化して目視確認した。

**結果**：修正後、`jsample-lualatex.pdf`は10ページ→9ページに変化したが、これは§6.2に既出の「フォントメトリクス差による1ページ程度のズレ」と同種の非構造的な差であり（最終ページの著者紹介が1件繰り越されるのみで、空白の異常等は無いことを確認済み）、見出し前後の空白自体は原文と画素単位で一致するようになった。`esample-lualatex.pdf`は9ページ→8ページに変化し、**§4.16で「原因不明だが許容範囲内」としていた1ページ差が完全に解消し、原文と完全一致するようになった**。すなわち、§4.16時点での差は太字明朝/ゴシック修正そのものが原因ではなく、本節で発見した`\section`見出し機構の欠落が真因だったことになる。他のテスト文書（`tech-jsample`/`ses-sample`/`ses-esample`）のページ数はこの修正で変化していない。

**教訓**：「前後スキップの値さえ原文と同じにすれば見出しの空白は再現できる」という前提は、`\@startsection`モデル（前後スキップ＋見出し本文）が常に成り立つという暗黙の仮定に基づいていたが、`ipsj.cls`の`\section`はそのモデル自体を採用していなかった。値だけを転記して「だいたい合っていそう」に見えるコードは、根本のレイアウトモデルそのものが違うケースを覆い隠してしまう。また、ある文書（`esample`）で原因不明のまま受け入れた1ページ差が、実は別の文書（`jsample`）の不具合修正によって解消されることがある——「許容範囲内のドリフト」と判断する前に、関連する他の変更を先に検討する余地がないか振り返る価値がある。

### 4.18 `ipsj.cls`を頭から全行読み直して発見した、その他の移植漏れ一式（重要）

`\section`の固定`\vbox`機構（§4.17）が「同じ名前のマクロが移植先にも存在するのに内容が簡略化されている」という、単純な名前ベースの差分検査では見つからない種類の欠落だったことを受け、`ipsj.cls`（5945行）を冒頭から終端まで全て読み直し、`ipsj-lualatex.cls`の対応箇所と1つずつ突き合わせる作業を行った。`\def`/`\newcommand`/`\renewcommand`/`\newenvironment`等で定義されている識別子をPowerShellの正規表現で全て抽出し（原文392個、移植先307個）、原文にあって移植先に同名で存在しない161個をリストアップし、1つずつ「本当に欠落しているか」「`\ipsj@`接頭辞等で改名されているだけか」「`article.cls`が代わりに提供しているので不要か」「原文自体で実質使われていない死んだコードか」を判定した。見つかった**本物の欠落**は以下の通り（無関係/死んだコードと判定したものは後述）。

1. **`\cite{a,b,c}`が引用番号を昇順に並べ替えない**：原文の`\@citex`/`\@cite`は、独自実装の連結リスト型ソートユーティリティ（`\@sort@list`系、約100行）を使って`\cite{ref5,ref1,ref3}`を`[1, 3, 5]`という昇順・重複除去済みの形に組み直してから出力する。移植先はこの再定義を一切行わず、`article.cls`標準の`\@citex`/`\@cite`（入力順をそのまま出力するだけ）に依存していた。`esample-lualatex.tex`の4.7.1節に「Cited labels are sorted automatically」という説明文があり、この機能が実際に使われる前提の文書であることを確認した上で、ソートユーティリティ一式をエンジン非依存のプレーンTeXコードとしてそのまま移植した。
2. **禁則処理（kinsoku）がLuaTeX-jaの既定値より弱い**：原文は`\prebreakpenalty`/`\postbreakpenalty`を直接代入して、括弧・引用符・小書きの仮名（ぁぃぅぇぉっゃゅょ等）・長音記号「ー」・波ダッシュ「〜」の前後で改行を禁止している。LuaTeX-jaは`luatexja-core`読み込み時に`ltj-kinsoku.tex`から既定の禁則テーブルを自動ロードするため、括弧・引用符類はすでに原文と同じ`\@M`（10000）で一致していることを`ltj-kinsoku.tex`を直接読んで確認したが、**小書きの仮名は既定で150しかなく**、原文の`\@M`より大幅に弱い。波ダッシュ「〜」には既定の禁則設定（`jaxspmode`はあるが`prebreakpenalty`は無い）が存在しない。両方を`\ltjsetparameter{prebreakpenalty=...}`（LuaTeX-jaにおける`\kanjiskip`同様、直接代入できないTeXレジスタの代替インターフェース）経由で原文と同じ強さに上書きした。ASCII引用符的な文字（コード34/92）に対する原文の弱め設定（1000）も同様に追加した。
3. **数式環境が常時フラッシュレフト（`fleqn`）であるべきなのに、`article.cls`の既定（中央揃え）のままだった**：原文の`equation`/`eqnarray`/`\[...\]`は、標準LaTeXの`fleqn.clo`（フラッシュレフト数式オプション）の内容をそのままファイル末尾に再掲し、`\mathindent`を`1\zw`、`\@eqnnum`（数式番号の直前の空白）を3mm追加した独自版に差し替えている。これは`fleqn`という**クラスオプションを指定した場合だけ効く**機能ではなく、`ipsj.cls`が常時無条件に適用している既定動作である。実際、`\DeclareOption{fleqn}{\input{fleqn.clo}}`というオプション自体も原文に存在するが、これは単に同じ`fleqn.clo`を**もう一度**読み込むだけで実質的な意味を持たない（後述の死んだコードの一種）。移植先は`fleqn`をオプション指定時のみ`article`に転送する作りになっており、無指定時は中央揃えの数式になっていた。`\LoadClass[fleqn]{article}`に変更して常時`fleqn.clo`を適用し、`\mathindent1\zw`と`\@eqnnum`の3mm補正を追加することで、原文と同じ挙動にした（カーネル標準の`fleqn.clo`を使う方が、原文の古い埋め込みコピーを再度手で写すより低リスクと判断）。`esample-lualatex.tex`4.4.2節の実際の数式（`\Delta_l = \sum...`）で、フラッシュレフト配置・数式番号の位置が原文と一致することを確認した。
4. **`\@listi`〜`\@listvi`に`\labelsep`/`\labelwidth`/`\rightmargin`/`\listparindent`/`\itemindent`の零詰め設定が抜けていた**：§4.11で行送りの伸縮（`\partopsep`等）はゼロ化済みだったが、原文の`\lst@listi`はそれに加えてこれら5つのパラメータも全レベル共通の値で固定していた。`enumerate`/`itemize`/`description`本体は別途自前の値を設定する（§4.13）ためこの抜けの影響を受けないが、それ以外の`\list`ベースの構成（特殊なネストしたリスト等）では影響がありうる。`\ipsj@listspacing`に追加した。なお、この値を`\normalsize`の本体からも参照する構成にしたため、`\normalsize`の最初の呼び出し（クラス読み込み中、文字グリッド計測のため）より前に`\ipsj@listspacing`自体の`\def`を定義し直す必要があった（参照する側と定義する側の順序関係には注意が必要だった）。
5. **`\inhibitglue`が`\relax`に潰されていて何もしない**：`luatexja-core`はpTeXの`\inhibitglue`プリミティブと同名・同機能のコマンドをすでに提供しているが、移植先には`\let\inhibitglue\relax`という行があり、これを完全に無効化していた。会員種別表記（「（正会員）」等）の直前で和文・ラテン文字間の字間グルーを抑制する目的の呼び出しが、いつの間にか`\@@member`直書きに簡略化されてしまっていたことと合わせて発覚した（§4.8で発見された不具合とは別物）。`\let`の行を削除し、3箇所の`\@@member`呼び出しに`\inhibitglue`を復元し、さらに和文モードの`\footnotemark`が字間を詰めるという別の仕様（原文の`footnotemarks@ve`）も追加した。
6. **小規模だが実際に使われうるユーティリティマクロが複数未移植**：`\ruby{base}{ふりがな}`（ルビ）、`\QED`（証明終わりの$\Box$マーク）、`\MARU{n}`（丸囲み数字）、`\contact{...}`（後方互換のため受理するだけで何も出力しない）、`\Hline`（`\noalign`用の太さ0.4mmの表組み用ルール）、`\ddash`/`\doubledash`（二重ダッシュ記号）、`\dummyfigure`/`\dummyfiguret`（紙への貼り込み原稿時代の余白確保用）。いずれもテスト文書群では使われていないが、§4.13の教訓（「テスト文書で使われていない＝不要、ではない」）に従い、原文のロジックをそのまま移植した（`\ruby`内部の`\kanjiskip=\fill`は`\kintou`（§4.17）と同じ理由で`\ltjsetparameter`に置き換えた）。
7. **`\Center`/`\@floatenv`が未移植で、`figure`/`table`内の`center`が標準の伸縮ありバージョンのままだった**：原文は`figure`/`figure*`/`table`/`table*`の冒頭で`\@floatenv`（`\let\center\Center`）を呼び、`\trivlist`ベースで伸縮ゼロの独自`center`に切り替える。移植先はこの呼び出し自体が無く、フロート内で`\begin{center}`を使った場合に標準カーネルの伸縮ありバージョンが使われてしまう状態だった。テスト文書群はフロート内で`center`を使っていないため影響は未確認だが、`\Center`/`\endCenter`/`\@floatenv`を移植し、4つの環境すべてから呼ぶようにした。
8. **既定年の自動算出に使う加算定数が、`DAM`以外の全ての論文誌種別で1ずつ小さい（重要、実害あり）**：§4.6で修正した「既定値1958→1959」は`DAM`（デフォルト）用の定数だけであり、その他の論文誌種別（JIP, ACS, PRO, TOD, TOM, TBIO, SLDM, CVA, CDS, DC, DCON, TCE）用の加算定数は別々に存在し、**全て**移植時に1小さい値になっていた（JIP: 1991→正1992、ACS/PRO/TOD/TOM/TBIO/SLDM: 2006→正2007、CVA: 2007→正2008、CDS: 2009→正2010、DC/DCON: 2011→正2012、TCE: 2013→正2014）。`esample-lualatex.tex`（`Vol.59`...ではなく実際は`Vol.26`, `JIP`）の見出しで実際に「(Jan. 2017)」と表示されており、原文`esample.pdf`の「(Jan. 2018)」と1年ズレていることをヘッダ部分の精密な`pdfcrop`比較で発見した。全12種別の定数を原文の値に修正した。また、原文には`english`オプション単体（特定の論文誌種別を指定しない英文原稿）の場合に`\ifDS@EEE`という専用フラグでJIPと同じ1992を使う分岐があり、これも移植先に欠けていたため、`\ifDS@english`で代替して追加した（`\ifDS@EEE`はJIP等の専用オプションでは強制的に偽になる設計のため、カスケード内でJIP等のチェックより後に置く限り`\ifDS@english`と等価）。
9. **既定モードのヘッダで、`No.`欄の非表示条件と`abstract`時の単一ページ参照が未移植**：原文の英文既定モードヘッダは、CVA/TBIO/SLDM/`preprint`/JIPの場合に号数（`No.X`）を表示しない（finding 8の調査で発見、上記のヘッダ比較で「No.1」が誤って表示されていたことを発見）。また`abstract`オプション指定時（PRO論文誌の研究会発表梗概）はページ参照が単一ページ（`\pageref{firstpage}`のみ）になり、和文モードでも同様の単一ページ化がある。いずれも移植先には無く、常に「号数を表示／ページ範囲で参照」という単純化された挙動になっていた。原文の条件分岐をそのまま追加した。
10. **序文（`preface`）モードが`\@maketitle`しか移植されておらず、タイトルページの大半が既定モードのまま漏れていた**：`ipsjpref.sty`は`\@maketitle`に加えて、(a) 概要・キーワード・受付日を一切表示しない簡略版の`\authortitle`、(b) `\ifDS@alone`（序文が単独で1ページに収まる場合、ページ参照を範囲でなく単一ページにする、`ipsjpref.sty`独自の新規オプション）に対応した専用の`\ps@IPSJTITLEheadings`、(c) 論文種別ラベル（`\SHUBETUname@Data`/`@Survey`/`@TBIOM`/`@Short`/`@DAM`）を全て非表示にする再定義、の3つを持つが、移植先は(a)(b)(c)のいずれも実装しておらず、`\@maketitle`だけが`\ifDS@preface`で分岐していた。このため序文モードでは（実際に使うとすれば）概要・キーワード・受付日欄が既定モードのまま残ってしまうという、本プロジェクトのテスト文書群では一度も検証されていなかった欠落だった。`alone`オプションを新設し、(a)(b)(c)を全て移植し、最小限の手作りテスト文書（`\documentclass[preface,submit]`、`\documentclass[preface,submit,alone]`の両方）でエラー無くコンパイルでき、タイトルページが概要・キーワード無しの簡潔な構成になることを確認した（参照PDFが存在しないため、原文との画素比較はできていない。§7「未検証事項」に追記）。

**今回あえて移植しなかった、確認済みの死んだコード**：`\zdash`/`\ndash`（コメントで「not use submit」と明記され、原文内のどこからも参照されていない）、`\titleddash`（後続のより後の`\ddash`定義で即座に上書きされ、実質到達しない）、`\rparen`（`)`という1文字の別名に過ぎず、移植先はすでに同じ箇所で素の`)`を直接書いているため出力に差が無い）、`\jtitle`/`\d@jtitle`/`\s@jtitle`/`\hd@title`/`\@jtitle`（定義されるが`ipsj.cls`/`ipsjpref.sty`/`ipsjtech.sty`のどこからも参照されない、独立した未使用の見出し設定インフラ）。

**調査方法**：PowerShellの正規表現で`\def`/`\newcommand`/`\renewcommand`/`\newenvironment`/`\renewenvironment`のパターンを抽出し名前リスト化、`Compare-Object`相当の集合差分で「原文にあって移植先に無い」名前を抽出した。この機械的な差分は`\ipsj@`改名や`article.cls`提供で不要になった項目を多数含む偽陽性を生んだため、1件ごとに`grep`で文脈を読み、本当に必要かどうかを判定した。この方法は**名前が一致しているが内容が簡略化されているケース**（§4.17の`\section`がまさにこれ）を検出できないため、名前ベースの差分は出発点に過ぎず、本節の各項目は結局原文の該当箇所をすべて目視で読み直して確認した。

**結果**：5つのテスト文書（`jsample`/`esample`/`tech-jsample`/`ses-sample`/`ses-esample`）すべてが2回パスでエラーなくコンパイルでき、ページ数は本節の修正前後で変化していない（9/8/6/6/8、§6.2参照）。`esample-lualatex.pdf`のヘッダは「No.1」の誤表示と「2017年」の誤表示の両方が解消し、原文と完全に一致するようになった。

**教訓**：これまでの不具合修正は「ユーザーが視認した症状から原因を逆引きする」という反応的な進め方だったが、今回は「原文を冒頭から終端まで全部読み、移植先と1つずつ突き合わせる」という網羅的な進め方に切り替えたことで、これまで一度も視認されていなかった実害のあるバグ（fleqn数式、ヘッダの号数表示、既定年の算出）が複数見つかった。これらは小さな文書や視認上目立たない箇所に隠れていたため、症状ベースの検査では発見されなかったと考えられる。「テスト文書群が全てパスしているから移植は完了している」という判断は、テスト文書群が原文の機能の一部しか使っていない場合には正しくない。

### 4.19 フロート内の文字が`\normalsize`のまま使われ、表が`\textwidth`を超えて右にはみ出す（重要）

**症状**：ユーザーが実在する研究論文7件＋SES論文5件（§6.4/§6.6参照）の出力を目視確認していた際、`higo_202308_ses-main`の表1（`table*`、`\verb`によるシグネチャ文字列を含む）が右マージンを大きく超えてはみ出し、`プリミティブ型のみ`列が紙面外に切れていることが判明した。ビルドログにも`Overfull \hbox (76.1661pt too wide)`が出ていた。

**原因**：原文`ipsj.cls`は標準LaTeXカーネルが提供する`\@floatboxreset`（`\@float`/`\@dblfloat`がフロート本体の組版前に必ず呼ぶフック）を

```latex
\def\@floatboxreset{%
\reset@font
\footnotesize\baselineskip16\h
\@setminipage
}
```

として上書きしており、**全ての`figure`/`table`/`figure*`/`table*`の内容を無条件に`\footnotesize`で組む**ようになっていた。移植先`ipsj-lualatex.cls`はこのフック自体を再定義しておらず、カーネルの既定（フォントサイズを変更しない）のままだったため、フロート内容が周囲の本文と同じ`\normalsize`で組まれ、`\verb`内の英数字シグネチャや見出し文字列がその分大きく、`tabular`の自然幅が`\textwidth`を超えていた。

**発見の経緯**：原文に`@floatboxreset`という名前自体が存在することは§4.18の網羅的な名前比較で一度は洗い出されていたはずだが、「`\@floatboxreset`」はカーネル提供のフック名であり一見「カーネルに任せれば良い」項目に見えたため、当時は見落とされていた。今回、`\settowidth`で表の自然幅を実測（579.17pt、`\textwidth`は503.0pt、差は76.17ptでビルドログの警告と一致）し、`\verb`文字列の幅を比較したところ、むしろ我々の等幅フォント（Latin Modern Mono）は原文のComputer Modern Typewriterより**狭い**ことが分かり、文字幅の差ではあり得ないと判明。原文を読み直して`\@floatboxreset`の差し替えを発見した。

**対処**：`ipsj-lualatex.cls`に同じ内容の`\@floatboxreset`再定義を追加した（`\@floatenv`の直後）。修正後、同じ表の`Overfull \hbox`は76.17pt→1.22ptまで縮小し、目視でも紙面内に収まるようになった。`jsample`/`esample`/`tech-jsample`/`ses-sample`/`ses-esample`の5文書はページ数に変化なし（9/8/6/6/8）。

**教訓**：カーネルが提供するフック名（`\@floatboxreset`/`\@floatenv`等）は「カーネルの既定動作で十分」と判断する前に、原文がそのフックを**上書きしているかどうか**を必ず確認すること。フック名がカーネル由来であることと、原文がそれを無変更で使っていることは別の話であり、§4.18の機械的な名前比較だけでは「原文にあって移植先にもある名前」（カーネル提供分）の内容差は検出できない。

### 4.20 本文の`\kanjiskip`に原文が与えていた伸縮（行末揃え用の字間ジャスティファイ）が移植先に存在しない（重要、ページ数に影響）

**症状**：ユーザーが`higo_202308_ses-main`の8ページ目「謝辞」を原文`draft.pdf`（pLaTeX）と見比べたところ、原文では「謝　辞　本　研　究　は　JSPS　科　研　費（...」のように全ての文字間が大きく均等に開いて1行を埋めているのに対し、移植先は「謝辞」を含め文字間が詰まったまま改行されており、明らかに異なる組まれ方をしていた。

**原因**：原文`ipsj.cls`は`\normalsize`/`\small`/`\footnotesize`（和文モード側の分岐）の中で必ず

```latex
\kanjiskip\z@ \@plus .1zw \@minus .05zw
```

を実行しており、和文文字間の通常グルー（`\kanjiskip`）に**伸縮（行ジャスティファイのための余白吸収能力）を持たせていた**。pTeXでは`\kanjiskip`は直接代入可能なレジスタだが、LuaTeX-jaではこれは`\ltjsetparameter{kanjiskip=...}`経由の設定値であり、移植先の`\normalsize`/`\small`/`\footnotesize`にはこの設定が一切無かったため、LuaTeX-ja側の既定値（伸縮の少ない値）がそのまま使われていた。その結果、ある行を行末まで埋めるために必要な伸縮量を、原文は字間（`\kanjiskip`）で広く吸収できたのに対し、移植先はその余地が無いまま行分割アルゴリズムが**より多くの文字を1行に詰め込む側**を選ぶようになり、本文全体の改行位置・ページ数が変化していた。

**発見の経緯**：「謝辞」の文字間が詰まっているという視覚的症状から、`\kintou`（§4.17で既知の、`kanjiskip`を`1fill`にして均等配置する別の仕掛け）との関連を疑ったが、`\acknowledgment`の定義自体は単に`{\bfseries{謝辞}}\hskip1\zw`であり`\kintou`を使っていなかった。原文の該当行を再確認し、`\normalsize`等の中に`\kanjiskip\z@ \@plus .1zw \@minus .05zw`という、フォントサイズ変更コマンドの中という一見目立たない位置に埋め込まれた設定を発見した。`\ltjgetparameter{kanjiskip}`で値を直接確認し、修正前は伸縮ゼロ、修正後は`0.0pt plus 0.92477pt minus 0.46239pt`（`\normalsize`時、`.1\Cwd`相当）になっていることを確認した。

**対処**：`\normalsize`/`\small`/`\footnotesize`の和文分岐に`\ltjsetparameter{kanjiskip={0pt plus .1\zw minus .05\zw}}`を追加した（フォントサイズ切替の直後、`\zw`が新しいサイズを反映した値になった後に評価されるよう注意）。

**結果**：5つの公式サンプル文書はページ数に変化なし（9/8/6/6/8）。一方、実論文での回帰確認では3件でページ数が変化し、**いずれも実機オリジナル（pLaTeXコンパイル済みPDF）のページ数と完全に一致する方向に修正された**：`s-onizuk_202407_ipsj-main`（14→13、原文13）、`ym-fujwr_202308_ses-main`（3→2、原文2）。原文PDFが手元に無い`tyngtmyn_202403_sigse-main`も9→8に変化したが、最終ページを目視確認した限りレイアウト崩れは無く、同種の改善と判断した。

**教訓**：`\kanjiskip`/`\xkanjiskip`はpTeXでは直接レジスタ代入、LuaTeX-jaでは`\ltjsetparameter`経由という違いがあるため、`grep`で`\kanjiskip`を検索しても**構文が違う移植先の対応箇所**が見つからず、§4.18のような機械的な名前比較では発見しにくい。さらに今回の設定は`\kintou`専用ではなく**本文ジャスティファイ全体に影響するグローバルな値**であり、症状（謝辞の文字間）から原因（フォントサイズコマンド内の地味な1行）を特定するまでに複数の仮説（`\kintou`絡みか、フォント幅の違いか）を経由した。「文字間が詰まっている/開いている」という症状は、その場所だけのローカルな問題とは限らず、`\normalsize`等の基盤設定が疑わしいことを示すシグナルとして扱うべきである。

### 4.21 ユーザー原稿が直接`\textbf{}`で和文を太字にすると本物の太字明朝になる（§4.16の対処漏れ、重要）

**症状**：`ry-inoue_202507_ipsj-main`で、原稿が表の見出しに`\textbf{訓練データ}`と直接書いている箇所が、ゴシックではなく太字の明朝体（セリフ・はね/うろこ付き）で表示されていた。

**原因**：§4.16で発見した「明朝に太字が無いので原文では常にゴシックで代用される」という現象に対し、当時の対処は**クラス内部が`\bfseries`を呼ぶ既知の呼び出し箇所**（`\GAIYOU`/`\paragraph`/`\@makecaption`等）にのみ`\gtfamily`を個別に追加するという、対症療法的な修正だった。原稿の著者が自分の本文や表の中で**直接`\textbf{和文}`や`\bfseries`を書いた場合**は、クラスが関知できないためこの個別パッチの対象外となり、`Harano Aji Mincho`が実際にBoldウェイトを持つ（§2.2）ことから、そのまま本物の太字明朝で出力されていた。これは「クラスの呼び出し箇所を1つずつ塞ぐ」というアプローチの構造的な限界であり、ユーザー原稿の全ての`\textbf`呼び出しを事前に列挙することは不可能である。

**対処**：個別パッチ方式をやめ、フォント宣言そのものを原文の挙動に合わせた。`\setmainjfont{Harano Aji Mincho}`に`[BoldFont={Harano Aji Gothic}]`オプションを追加し、**「Minchoの太字はGothicで代用する」という代替規則自体をfontspec/NFSSレベルで宣言**した。これにより、クラス内部の呼び出しか原稿側の直接呼び出しかを問わず、`\mcfamily`下での`\bfseries`/`\textbf`は全て自動的にGothic-Boldへ差し替わるようになった。§4.16で個別追加した`\gtfamily\bfseries`／`\ipsj@boldlabel`の呼び出しは、この大域的な代替により実質的に冗長になったが、二重適用しても無害なため削除はしていない。

**結果**：5つの公式サンプル文書、および全14件の実文書テストでページ数に変化なし、エラーなし。ビルドログの埋め込みフォント一覧から`HaranoAjiMincho-Bold.otf`が消え、該当箇所は`HaranoAjiGothic-Bold.otf`で描画されるようになったことを確認した。

**教訓**：「クラスがどこで`\bfseries`を呼んでいるか」を網羅するアプローチ（§4.16）は、**クラス自身の呼び出し**に対しては有効だが、**原稿側の直接呼び出し**には原理的に対応できない。フォント代替が必要な事象を見つけたら、個別の呼び出し箇所にパッチを当てる前に、「フォント宣言自体（`\setmainjfont`等のオプション）でその代替を表現できないか」を先に検討するべきだった。

### 4.22 `table*`の和文キャプションが原文では中央揃えなのに、移植先は左寄せになる（重要）

**症状**：`s-onizuk_202407_ipsj-main`の7ページ目、`table*`環境内の和文`\caption{Python Tutorialの各項目に対する...}`（2行に渡る長いキャプション）が左マージンに張り付いて表示され、直後の英語キャプション（`\ecaption`、同じ`table*`内）は正しく中央揃えになっていた。原文`ipsj_s_onizuk.pdf`では和文・英文とも中央揃えだった。

**原因**：`\@makecaption`（和文キャプション）のオーバーフロー分岐（キャプション文字列が`\capwidth`より長い場合に`\parbox`で折り返す処理）に、原文では

```latex
\hfil\parbox[t]{\capwidth}{...}
```

のように先頭に`\hfil`があるのに対し、移植先には

```latex
\parbox[t]{\capwidth}{...}\par
```

と**先頭の`\hfil`が欠落していた**。原文がこの1個の`\hfil`だけで中央揃えになっている理由は、段落終端で自動的に挿入される`\parfillskip`（既定値`0pt plus 1fil`）が**右側の伸縮を無料で供給する**ため、先頭の`\hfil`（左側の伸縮）と組み合わさることで実質`\hfil...\parfillskip`という両側`\hfil`相当になり中央揃えが成立する、という`\par`の暗黙動作に依存した書き方だったため。移植先で`\hfil`を書き忘れると、伸縮は`\parfillskip`の右側だけになり、ボックスが左に張り付く。原文と全く同じ構造を持つ`\ecaption`（§2.2参照）には正しく`\hfil`が移植されていたため、英文キャプションだけ症状が出なかった。

**対処**：`\@makecaption`のオーバーフロー分岐の先頭に`\hfil`を追加し、`\ecaption`/`\@twocolcaption`/`\@twocolecaption`と同じ構造に揃えた。

**結果**：5つの公式サンプル文書、全14件の実文書テストでページ数に変化なし、エラーなし。`s-onizuk_202407_ipsj-main`の表2キャプションが原文と同じ2行中央揃えになることを確認した。

**教訓**：`\hfil ... \par`という、片側の`\hfil`と段落終端の自動`\parfillskip`を組み合わせて中央揃えを実現する書き方は、移植時に「`\hfil`が1個しかないから単純に左寄せのつもりだろう」と誤読されやすい。同じパターンを使う複数の関連マクロ（`\@makecaption`/`\ecaption`/`\@twocolcaption`/`\@twocolecaption`）がある場合、1つが正しく移植されていても**他が見落とされている可能性がある**ため、同種のマクロ群は必ずセットで突き合わせる必要がある。

### 4.23 脚注の直後に`[b]`配置フロートが続く／見出しが列末で孤立する：LaTeXカーネル自体の不安定な挙動（クラスのバグではない、参考）

ユーザーから報告された以下の症状は、いずれも調査の結果**LaTeX2eカーネル自身の、`ipsj-lualatex.cls`や`ipsj.cls`に依存しない一般的な挙動**であることが確認できた（独立したテストとして、IPSJ固有のコードを一切使わない素の`article.cls`の`twocolumn`モードを`pdflatex`/`lualatex`の両方でコンパイルし、同じ現象が再現することを確認済み）。

- **脚注の直後に`[b]`配置フロート（`table`/`table*`）が続くと、最終的な列内での上下関係が脚注→フロートと「逆転」することがある**：`a-tabata_*`／`ry-inoue_202507_ipsj-main`で発生。標準の`\@makecol`は本来「本文→下部フロート→脚注」の順に列を構成するが、フォントメトリクスの違いで改行・改ページ位置がわずかに変わると、この順序決定が不安定になり逆転することがある。`ry-inoue_202507_ipsj-main`の原稿には実際に`% TODO footnoteの位置を調整`という、著者自身が原文の時点で既にこの不安定さに気付いていたコメントが残っていた。
- **列の末尾に空白を残したまま、見出し（`\section`/`\subsection`）が次の列の先頭に押し出される**：`a-tabata_202311_ipsj-main`の4.2/4.3節境界、`ryt-kbys_202307_sigse-main`の6節で発生。見出しが列の最後に「孤立」しないようにする標準のペナルティ機構（`\@secpenalty`、`\section`の固定高さ`\vbox`機構については§4.17）が働いた結果であり、原文と移植先でフォントメトリクスが異なるために、この機構が発動する分岐点（列に見出しがちょうど収まるかどうか）がページごとに微妙にずれる。

どちらも原稿側で該当箇所に明示的な`\pagebreak`/`\nopagebreak`やフロート配置指定の変更（`[b]`→`[t]`等）を行わない限り、クラス側だけでは確実に制御できない。修正を試みるよりも、§4.14と同種の「フォントメトリクス差由来の許容範囲内の差」として扱うのが適切と判断した。

### 4.24 `\topnumber`/`\bottomnumber`/`\totalnumber`の移植漏れにより、3つ目以降の`[tb]`フロートが上に積めず下に落ちる（重要）

**症状**：`tyngtmyn_202403_sigse-main`の2ページ目右段で、`\begin{figure}[tb]`が3つ連続する箇所（図1〜図3の依存関係図）のうち、原文`tyngtm_202403_sigse.pdf`では3つ全てが列の最上部にまとめて配置されていたのに対し、移植先では先頭2つ（図1・図2）だけが上に配置され、3つ目（図3）が脚注ブロックより下（列の最下部）に配置されていた。§4.23の「脚注とフロートの順序不安定性」と症状が似ていたため最初はそちらと同根を疑ったが、原文に同じ位置で参照PDFがあり「原文では3つとも上」という明確な差分が確認できたため、再調査した。

**原因**：原文`ipsj.cls`は

```latex
\setcounter{topnumber}{8}
\setcounter{bottomnumber}{8}
\setcounter{totalnumber}{16}
\setcounter{dbltopnumber}{2}
```

を設定しており、1列あたり最大8個までの「上部フロート」を積めるようにしていた。`\topfraction`/`\bottomfraction`等の**割合**設定（§2.1で既に移植済み）はこれとは独立したパラメータで、いくらフォント側の高さに余裕があっても、フロートの**個数**がLaTeXカーネルの既定値（`topnumber=2`/`bottomnumber=1`/`totalnumber=3`）を超えた時点で、超過分は強制的に次の配置先（`[tb]`なら列下部、それも溢れればさらに後続ページ）に回される。移植先は`\topfraction`等の割合設定だけを移植し、この個数カウンタ自体の`\setcounter`を移植し忘れていたため、カーネルの既定値（2個まで）が使われており、3個目のフロートが原文の意図通りに上へ積めなかった。

**発見の経緯**：`\topfraction{1}`等は完全に一致しているため、最初は「フォントメトリクス差で2つ目と3つ目の間の本文がわずかに増え、3つ目だけ収まらなくなった」という、§4.23と同種の偶発的な差を疑った。しかし原文の該当箇所のソースを確認すると、図1〜図3の間に意味のある本文はほぼ無く（`\begin{figure}`が連続している）、偶発的な詰まり方の違いだけでは3個目だけが落ちる理由として弱いと判断し、`ipsj.cls`を`\topnumber`で`grep`したところ§1065〜1068の`\setcounter`群が移植先に存在しないことが分かった。

**対処**：`\topfraction`等の直前に同じ4行の`\setcounter`を追加した。

**結果**：5つの公式サンプル文書、全14件の実文書テストでページ数に変化なし、エラーなし。`tyngtmyn_202403_sigse-main`の図1〜図3が原文と同様に列最上部にまとめて配置され、脚注がその後の本文と合わせて列最下部に収まることを確認した。

**教訓**：フロート配置を制御するパラメータは`\topfraction`系（割合）と`\topnumber`系（個数）の**2系統**があり、片方だけを移植すると「だいたい合っているが、フロートが3個以上並ぶ箇所でだけ症状が出る」という、テスト文書の内容に依存して再現条件が変わる類の不具合になる。§4.18の機械的な名前比較ではこの`\setcounter`群も本来検出できたはずだが、当時は`\topfraction`等の`\def`だけを見て「フロート関連は移植済み」と判断し、深掘りを止めてしまっていた可能性がある。同じ「フロート個数」のテーマに複数の独立したパラメータ系統が存在する場合、1つを見つけても兄弟パラメータの存在を疑って原文を読み直す必要がある。

### 4.25 2ページ目以降のページヘッダに`[DOI: ...]`が繰り返し表示される（重要）

**症状**：`esample-lualatex.pdf`（リポジトリ直下の公式サンプル、`tests/`配下ではない）で、本来1ページ目だけに表示されるべき`[DOI: 10.2197/ipsjjip.26.1]`の行が、2ページ目以降の全ページのヘッダにも繰り返し表示されていた。原文`esample.pdf`では1ページ目だけに表示される。

**原因**：原文`ipsj.cls`はタイトルページ専用の`\ps@IPSJTITLEheadings`（`\thispagestyle{IPSJTITLEheadings}`で1ページ目にのみ適用）の中でのみ実際に`[DOI: ...]`の文字列を組み込み、本文ページ用の`\ps@headings`（`\pagestyle{headings}`で2ページ目以降に適用される既定スタイル）では、同じ`{\DOIHeadfont ... }`という箱組みの構造だけを残しつつ**中身を空にしている**（`\rlap{{\DOIHeadfont}}`、間に何も書かない）。移植先`ipsj-lualatex.cls`の`\ps@headings`は、この箱の中身として`\ipsj@doi`（DOI文字列を実際に組み立てるマクロ）をそのまま呼んでしまっており、本文ページにも毎回DOIが印字されていた。一方、タイトルページ用の`\ps@IPSJTITLEheadings`（複数モード分定義されている）はいずれも正しく`\ipsj@doi`を呼んでおり、問題は`\ps@headings`という1箇所だけだった。

**対処**：`\ps@headings`内の`\smash{\raisebox{-6mm}{\rlap{\DOIHeadfont\ipsj@doi}}}`から`\ipsj@doi`を削除し、`\smash{\raisebox{-6mm}{\rlap{\DOIHeadfont}}}`という、原文と同じ「空の箱だけ残す」形に修正した（空box自体は撤去せず残している点も含めて原文の構造に合わせた）。

**結果**：5つの公式サンプル文書、全14件の実文書テストでページ数に変化なし、エラーなし。`esample-lualatex.pdf`の2ページ目以降でDOI行が表示されなくなり、1ページ目には引き続き正しく表示されることを確認した。

**教訓**：同一の`\DOIHeadfont`ボックス構造が、タイトルページ用と本文ページ用の**複数の`\ps@...`定義に分散して**現れる（`\ps@IPSJTITLEheadings`が複数モード分、`\ps@headings`が1つ）。`\ipsj@doi`という呼び出し自体の存在だけを`grep`で確認すると「ちゃんと呼ばれている」ように見えてしまうため、**呼ばれていてはいけない場所**（本文ページ用のスタイル）まで呼んでしまっていないかは、各`\ps@...`定義を個別に開いて確認する必要がある。

### 4.26 `equation`環境の数式前後の空白がわずかに少なく見える場合がある（クラスのバグではない、参考）

**調査内容**：`jsample-lualatex.pdf`の4.4.2節にある`equation`環境の数式（式(1)）について、原文`jsample.pdf`と比べて前後の空白が少なく見えるという報告があった。調査の結果、**原文・移植先のいずれも`equation`環境自体は無改造の標準`fleqn.clo`（フラッシュレフト数式）そのもの**であることを確認した：原文`ipsj.cls`内に「`%% from fleqn.clo`」という見出しコメント付きで標準`fleqn.clo`が verbatim 転記されており（5042行目に「End of file `fleqn.clo'」とまである）、その`equation`環境の定義は`\abovedisplayskip`等を一切触っていない（`eqnarray`環境だけは別途this4変数を全て同じ値に強制する特別な上書きがあるが、`equation`には無い）。移植先は§4.18 finding 3の通り`\LoadClass[fleqn]{article}`でカーネル付属の現行`fleqn.clo`を使っており、これも同様に`equation`では`\abovedisplayskip`等を触らない。両者の`\abovedisplayskip`/`\abovedisplayshortskip`/`\belowdisplayskip`/`\belowdisplayshortskip`の値自体（`\normalsize`内で設定）も完全に一致している。

つまり、`equation`の前後空白を実際に決めているのは、TeXエンジンが`$$...$$`（display math）の直前テキストの残り幅と数式自身の幅を比較して`\abovedisplayskip`（広い方）と`\abovedisplayshortskip`（ほぼ0）のどちらを採用するかを決める**エンジンプリミティブレベルの自動判定**であり、LaTeXのクラスファイルからは直接介入できない領域である。この判定はテキストフォント・数式フォントの字送り次第で結果が変わるため、フォントが異なれば（§1.2の通り本プロジェクトでは数式フォントも含め原文と同一にはできない）、同じソースでもどちらの skip が選ばれるかが変わることがある。

**結論**：クラス側に対応漏れは無いことを確認済み。§4.23と同種の「フォントメトリクス差に起因するTeXエンジンレベルの分岐結果の違い」であり、修正は見送った。

## 5. 当初のテスト文書では見つからなかった機能（後で追加したもの）

最初に用意したテスト文書（ユーザー提供の実論文1件を移植したもの、`techrep,submit,noauthor`）は機能を網羅していなかった。情報処理学会公式サンプル（`jsample.tex`/`esample.tex`/`tech-jsample.tex`）でテストして初めて、未実装または未検証だったことが分かった機能：

- `\figref`/`\Figref`/`\figsref`/`\Figsref`/`\tabref`/`\Tabref`/`\tabsref`/`\Tabsref`：図表参照。同じラベルへの**最初の参照だけ太字**になり、2回目以降は通常体になる仕様（`\@ifundefined{ipsj@used@<label>}` で初回判定）。
- `\Editor`／`\Ediname` テーブル（TOD/TBIO/CVA/SLDM固有の「担当編集委員」「Communicated by」表記）。
- `\urlj`/`\urle`/`\refdatej`/`\refdatee`/`\doi`（参考文献中のURL・DOI・アクセス日表記）。
- `\acknowledgment`（謝辞見出し）。`\end{acknowledgment}` に対応する `\endacknowledgment` は原文にも存在しないが、`\csname endacknowledgment\endcsname` が未定義のとき自動的に `\relax` として確定する（TeXの`\csname`の仕様）ため、これは欠落ではなく元々そういう仕様だった。
- `\Enumerate`/`\Itemize`/`\Description`/`\ENUMERATE`/`\ITEMIZE`/`\DESCRIPTION`/`enumerate*`/`itemize*`/`description*`。当初は標準の `enumerate`/`itemize`/`description` への単純な別名にとどめていたが、原文の`\@trivlist`フックを使った専用実装に差し替えた（§4.13参照）。
- `\CaptionType`（`figure`/`table`環境内で見出しの種類を切り替える）。
- `\<`（pTeX時代の字送り調整ヒント。LuaTeX-jaでは不要なので `\relax` の単純な空命令とした）。
- `\：`（全角コロンを1文字幅・改行禁止で出力するマクロ）。
- 和文カウンタ別名 `巻数`/`号数`/`月数`/`年数` → `\c@volume`/`\c@number`/`\c@month`/`\c@year`。`\setcounter{巻数}{59}` のような記法をサポートするために `\expandafter\let\csname c@巻数\endcsname\c@volume` のように対応させている。

## 6. 検証方法

### 6.1 環境

開発・検証を行ったWindows機にはネイティブのTeX処理系が入っていなかったため、Dockerの公式イメージ `texlive/texlive:latest`（検証時点でTeX Live 2026、LuaHBTeX 1.24.0）を使用した。

```sh
# Git Bash で実行する場合、-w /workdir のパスがMSYSに書き換えられてしまうため
# MSYS_NO_PATHCONV=1 を必ず付ける
MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd)":/workdir -w /workdir \
  texlive/texlive:latest lualatex -interaction=nonstopmode -halt-on-error jsample-lualatex.tex
```

フォントの存在確認は `fc-list` で行った：

```sh
docker run --rm texlive/texlive:latest bash -c "fc-list | grep -i 'haranoaji\|tex gyre termes\|tex gyre heros'"
```

PDFの目視比較には、`pdftoppm`/ImageMagickがイメージに入っていなかったため Ghostscript を使用した：

```sh
docker run --rm -v "$(pwd)":/workdir -w /workdir texlive/texlive:latest \
  gs -dNOPAUSE -dBATCH -sDEVICE=png16m -r150 -dFirstPage=1 -dLastPage=1 -sOutputFile=out.png in.pdf
```

ページ数の確認（`pdfinfo`が無いため）：

```sh
docker run --rm -v "$(pwd)":/workdir -w /workdir texlive/texlive:latest \
  gs -dNODISPLAY -dNOSAFER -dBATCH -q -c "(file.pdf) (r) file runpdfbegin pdfpagecount = quit"
```

### 6.2 テスト文書と結果

| テスト文書 | 元ファイル | モード | 新/元のページ数 | 結果 |
|---|---|---|---|---|
| `tech-jsample-lualatex.tex` | `tech-jsample.tex`（公式サンプル） | `submit,techrep,noauthor` | 6 / 6 | ほぼ画素単位で一致 |
| `jsample-lualatex.tex` | `jsample.tex`（公式サンプル） | 既定（論文誌・和文） | 9 / 10 | 構造は一致、1ページ差（§4.14, §4.17参照） |
| `esample-lualatex.tex` | `esample.tex`（公式サンプル） | `english,preprint,JIP` | 8 / 8 | 完全一致（§4.17参照） |

この数値は§4.11の`itemize`/`enumerate`行間バグ、§4.12の受付・採録日欠落バグ、§4.17の`\section`見出し機構の欠落（固定高さ`\vbox`を単純な`\@startsection`に簡略化していた問題）の修正後のもの（修正前は`jsample`が11ページ、`esample`が9ページで、いずれも実際より1ページ多かった）。§4.11/§4.12を修正した結果、いったんは`jsample`/`esample`とも原文とページ数完全一致（10/10、8/8）になったが、その後§4.14で`jsample.tex`中の手動`\pagebreak`/`\newpage`2箇所（フォント差由来の不自然な空白の原因だった）を削除したところ`jsample`は9ページに変化し（`esample`はこの種の手動改ページが無いため8ページのまま）、さらに§4.16のMincho/Gothic代替修正の後`esample`が9ページに変化した（原因不明のまま許容範囲内の差として一旦受け入れていた）。§4.17で`\section`見出し機構を正しく移植した結果、`esample`は8ページに戻り原文と完全一致するようになった（§4.16時点の1ページ差の真因はこの`\section`機構の欠落だったことが判明）。`jsample`の9/10という1ページ差は、手動改ページ命令を取り除いた結果として生じた差であり、§6.2冒頭の他の1ページ差（フォントメトリクスの違いによる行末・改ページ位置の累積的なズレ）と同種の、構造上の不具合ではない差である。

`techrep` モードの2文書がページ数完全一致なのは、研究報告の本文がdense vol/no/DOI表記を持たず、見出しの行間調整等の影響を受けにくいためと考えられる。

### 6.3 既存サンプルをLuaLaTeX用に移植する際の手順（再現可能な手順）

1. `\documentclass[...]{ipsj}` → `\documentclass[...]{ipsj-lualatex}`
2. `\usepackage[dvipdfmx]{graphicx}` / `\usepackage[dvips]{graphicx}` → `\usepackage{graphicx}`
3. `\usepackage[varg]{txfonts}` と続く `\makeatletter \input{ot1txtt.fd} \makeatother` を削除する
4. `\usepackage[dvipdfmx,...]{hyperref}` や `\usepackage[dvipdfmx]{xcolor}` など、`graphicx` 以外のパッケージに付いている `dvipdfmx`/`dvips` ドライバオプションも同様に削除する（§6.4参照）
5. `\usepackage{pxjahyper}` を使っている場合は削除する（§6.4参照）
6. ソース中の「`<数値>zw`」「`<数値>zh`」を全て「`<数値>\zw`」「`<数値>\zh`」に変換する（`grep -n '[0-9.]zw[]}]'` 等で検出できる）。`\lstset{...}` の `xleftmargin`/`xrightmargin`/`numbersep` 等の寸法キーも例外ではなく変換が必要（§6.6参照。`caption=`等の文字列系キーは無関係）
7. プロジェクトに `jlisting.sty` のローカルコピーが同梱されている場合、文字エンコーディングを確認する（§6.4参照）
8. `lualatex` で2回コンパイルし、`Undefined control sequence` 等が出ないか確認する
9. BibTeXを使っている場合は `upbibtex -kanji=utf8 <jobname>` で文献リストを生成する（§6.4参照）
10. 元のPDF（pLaTeXでビルド済みのもの）とページ数・レイアウトを目視比較する
11. `\pagebreak`/`\nopagebreak`/`\newpage` をitem・段落の途中に手動で挿入している箇所があれば、目視比較で不自然な空白が出ていないか確認する（§4.14参照）。出ていれば、その`\pagebreak`等を削除するかコメントアウトするのが基本対応（クラス側では直せない）

### 6.4 実在する研究論文7件での追加検証

ユーザーが実際に執筆した研究論文・研究報告7件（情報処理学会論文誌4件、研究会原稿3件。図表・BibTeX文献リスト・著者紹介・サードパーティパッケージを含む実戦的な原稿）を用いて、上記の移植手順がそのまま通用するかを検証した。検証後にzipファイルと展開先ディレクトリ（`verify-test/`）は削除済みのため、このセクションが唯一の記録である。

| # | 内容 | 使用パッケージ等 | 新/元のページ数 | 結果 |
|---|---|---|---|---|
| 1 | 論文誌（和文，4名連名，BibTeX） | 標準のみ | 13 / 13 | 完全一致 |
| 2 | 論文誌（和文，3名連名，BibTeX） | amsmath, colortbl, ascmac, subcaption | 9 / 9 | 完全一致 |
| 3 | 論文誌（technote，BibTeX） | hyperref+pxjahyper, subcaption, comment | 5 / 5 | 完全一致（pxjahyper削除後） |
| 4 | 論文誌（和文，自作 `sty/udline.sty` 同梱，BibTeX） | multirow, subcaption, udline（独自パッケージ） | 9 / 9 | 完全一致 |
| 5 | 研究報告（`jlisting.sty` 同梱，BibTeX） | listings+jlisting, cite, url | 9 / 8 | 構造一致，1ページ差（jlisting文字コード変換後） |
| 6 | 研究報告（BibTeX，謝辞あり） | hyperref+pxjahyper, inconsolata, algorithm2e, tcolorbox | 8 / 8 | 完全一致（pxjahyper削除後） |
| 7 | 研究報告（`jlisting.sty` 同梱，旧オプション `uplatex` 付き，BibTeX） | listings+jlisting, slashbox, algorithm, algpseudocode | 9 / 8 | 構造一致，1ページ差（jlisting文字コード変換後） |

この検証で新たに判明した、§6.3の手順に追加すべき注意点：

- **`pxjahyper` は削除する**：`hyperref` と組み合わせて和文PDFのしおり文字化けを防ぐためのpLaTeX/upLaTeX専用パッケージ。LuaTeXはネイティブにUnicodeを扱うためこの種の対策が不要であり、`pxjahyper` 自体もLuaTeXをサポートしていない。`\usepackage[dvipdfmx,hidelinks]{hyperref}\usepackage{pxjahyper}` は `\usepackage[hidelinks]{hyperref}` だけにする（7件中2件で遭遇）。
- **`jlisting.sty` の文字エンコーディングに注意**（7件中2件で遭遇、最重要の新規発見）：`listings` パッケージに和文対応を加える `jlisting.sty` のローカルコピーが、**ISO-2022-JP相当の旧エンコーディング**で保存されている場合がある。LuaLaTeXはソースファイルをUTF-8として読むため、このファイルを読み込んだ瞬間に次のような致命的エラーになる。

  ```text
  ! Text line contains an invalid character.
  l.138 \def\lstlistingname{^^[$B%=!<%9%3!<%I^^[(B}
  ```

  対処は、当該ファイルをUTF-8に変換するだけでよい（中身はただの `\def\lstlistingname{ソースコード}` 等で、pTeX固有の処理は含まれていなかった）。

  ```sh
  iconv -f ISO-2022-JP -t UTF-8 jlisting.sty > jlisting-utf8.sty
  mv jlisting.sty jlisting-original.sty.bak && mv jlisting-utf8.sty jlisting.sty
  ```

  事前にエンコーディングを確認するには、該当行をエディタで開くか、`grep -n 'lstlistingname'` の出力が文字化けしていないかを見るとよい。
- **BibTeXは `upbibtex -kanji=utf8` を使う**：プレーンな `bibtex` コマンドでは、和文を含む `.bib` ファイル＋ `ipsjsort.bst`/`ipsjunsrt.bst` の組み合わせで `"XXX" is a string literal, not an integer, for entry truncation` のような大量のエラーが出ることがある（バイト単位処理のためUTF-8マルチバイト文字の境界を誤認識する）。`upbibtex -kanji=utf8 <jobname>` を使えば問題なく `.bbl` が生成できる。リポジトリの `latexmkrc`（`$bibtex = 'pbibtex %O %B';`）をLuaLaTeX用に書き換える場合は `$bibtex = 'upbibtex -kanji=utf8 %O %B';` 等にするとよい。
- **`uplatex` のような未知のクラスオプションは無害**：`\documentclass[...,uplatex,...]{ipsj-lualatex}` のように、本クラスが宣言していないオプション名が紛れていても、`\ProcessOptions` はそれを無視し最後に "Unused global option(s)" という警告を出すだけで、コンパイルは止まらない（7件中1件で確認）。旧原稿のオプション指定をそのまま使い回しても実害はない。
- **その他、特に問題なく動作したサードパーティパッケージ**：`amsmath`, `colortbl`, `ascmac`, `subcaption`, `multirow`, `xcolor`, `tcolorbox`, `inconsolata`, `algorithm`/`algorithm2e`/`algpseudocode`, `slashbox`, `enumitem`, `cite`, `url`/`xurl`, `comment`, 自作の下線パッケージ（`udline.sty`、`\iftdir` 等汎用的なLaTeX2eの書き方のみを使用）。これらは`graphicx`系以外は元々ドライバオプションを取らないため変更不要だった。

**注記**：この7件検証の時点では§4.11の`itemize`/`enumerate`行間バグ、§4.12の受付・採録日欠落バグ（既定モードの文書のみ影響、`techrep`モードの文書には影響なし）はまだ発見されていなかった。元のzip/展開先は検証後に削除済みのため、修正後のページ数で再検証はできていないが、`itemize`/`enumerate`を使っている文書ではページ数がさらに減っている可能性があり（§4.11参照）、既定モード（`techrep`を指定していない論文誌投稿）の文書では1ページ目に受付・採録日が追加で表示されるようになっているはずである（§4.12参照）。

### 6.5 SES（ソフトウェアエンジニアリングシンポジウム）向け `ses` オプション

情報処理学会が配布する標準の `ipsj.cls`/`ipsjtech.sty` とは別に、SES（IPSJ/SIGSE ソフトウェアエンジニアリングシンポジウム）が独自に配布している、研究報告スタイルをベースに**ヘッダ（学会名表記）・DOI/補助ヘッダ行・footerの著作権表記・ページ番号をすべて非表示にした**亜種一式（`ipsj.cls`（`ses`オプション追加版）, `ses.sty`, `ses-sample.tex`, `ses-esample.tex`）が存在する。これをユーザーから提供を受けて検証し、`ipsj-lualatex.cls` 側にも `ses` オプションとして実装した。

実物の `ipsj.cls`（SES改変版）を `diff` した結果、本質的な変更は次の3点のみだった。

```latex
\newif\ifDS@ses \DS@sesfalse
\DeclareOption{ses}{\DS@sestrue}
...（ファイル末尾）...
\ifDS@ses\def\next{\input{ses.sty}\endinput}\else\let\next\relax\fi
\next
```

`ses.sty` 自身は `ipsjtech.sty`（techrep）の `\@maketitle`/`\authortitle`/`\biography` 等をほぼ丸ごと再定義しているだけで、実質的な差分は `\ps@IPSJTITLEheadings`（ページスタイル）の中だけにある。さらに重要な点として、**実際の `ses-sample.tex`/`ses-esample.tex` は `techrep` オプションを明示せず `\documentclass[submit,ses,noauthor]{ipsj}` のように `ses` 単独で使われている**（`ses.sty` が無条件に `\input` されるため、techrep相当の組版に自動的に切り替わる）。

この実態に合わせて、`ipsj-lualatex.cls` では `ses` を選択すると同時に内部で `techrep` も有効化し、既存のtechrepページスタイルをさらに上書きする形で実装した。

```latex
\newif\ifDS@ses      \DS@sesfalse
\DeclareOption{ses}{\DS@sestrue\DS@techreptrue}
...
\ifDS@ses
\def\ipsj@signame@DAM{\relax}
\def\ps@IPSJTITLEheadings{%
  \def\@oddhead{\@Ltop\rlap{\small
    \ifDS@english{\HeadfontE{\signame}}\else{\HeadfontJ{\signame}}\fi}%
    \hfil\@Rtop}%
  \let\@evenhead\@oddhead
  \def\@oddfoot{\@Lbot\hfil{\botnomble\relax}\@Rbot}%
  \let\@evenfoot\@oddfoot
  \let\@mkboth\@gobbletwo}
\let\ps@headings\ps@IPSJTITLEheadings
\fi
```

`\ipsj@signame@DAM`（`\signame`の実体）を`\relax`にすることで学会名表記自体を空にし、ページ番号は`\thepage`の代わりに`\relax`を置くことで非表示にしている（オリジナルの`ses.sty`と同じ仕掛け）。

検証結果（提供された `ses-sample.pdf`/`ses-esample.pdf` と比較）：

| テスト文書 | 元ファイル | モード | 新/元のページ数 | 結果 |
|---|---|---|---|---|
| `ses-sample-lualatex.tex` | `ses-sample.tex`（和文） | `submit,ses,noauthor` | 6 / 6 | 完全一致。ヘッダ・フッタ・ページ番号が全頁で正しく非表示 |
| `ses-esample-lualatex.tex` | `ses-esample.tex`（英文） | `submit,ses,english` | 8 / 7 | 構造は一致、1ページ分の行送り差（既知のフォントメトリクス差。§6.2参照） |

この検証の過程で、`ses-esample-lualatex.tex` の著者欄（3名連名）の上付き文字が崩れていることに気づき、§4.9に記載した**英文モード `\author` の実バグ**を発見・修正した（`ses`機能自体のバグではなく、既存の`esample-lualatex.tex`にも内在していた）。

### 6.6 `ses` オプションの実在する研究論文5件での追加検証

`ses`オプション実装後、ユーザーから「`ses`対応が正しく動作しているか追加で確認してほしい」という依頼を受け、実際にSES（ソフトウェアエンジニアリングシンポジウム）へ投稿された研究論文5件（いずれも各論文に同梱の`ses.sty`/SES改変版`ipsj.cls`を使用）で検証した。検証後にzipファイルと展開先ディレクトリ（`verify-ses-test/`）は削除済みのため、このセクションが唯一の記録である。

| # | 内容 | 使用パッケージ等 | 新/元のページ数 | 結果 |
|---|---|---|---|---|
| 1 | 論文（和文，3名連名，BibTeX） | hyperref+pxjahyper, subcaption, comment | 10 / 10 | 完全一致（pxjahyper削除後） |
| 2 | 論文（和文，単著，BibTeX） | xurl, subfig, multirow, amsmath[fleqn], dblfloatfix | 9 / 9 | 完全一致 |
| 3 | 論文（和文，3名連名，BibTeX，`listings`使用） | listings, xurl | 9 / 8 | 構造一致，1ページ差（既知のフォントメトリクス差） |
| 4 | 論文（和文，3名連名，`jlisting.sty`同梱，BibTeX） | listings+jlisting, amsmath, mathtools, ascmac, threeparttablex, hyperref+pxjahyper | 9 / 9 | 完全一致（jlisting文字コード変換・`\lstset`内`zw`修正・pxjahyper削除後） |
| 5 | 論文（和文，4名連名，BibTeX，`\input`で本文分割） | amsmath, algorithmic, xcolor, tabularx, multirow | 2 / 2 | 完全一致（§4.10のクラス側バグ修正後） |

この検証で新たに判明した、§6.4の手順に追加すべき注意点：

- **`\lstset{...}`内の`zw`は変換が必要な場合がある**：§6.4で「`\lstset`のキーバリュー内の`zw`（`xleftmargin=3zw`等）は`listings`側のパーサが処理するため変換不要」と記録したが、これは**誤り、または機種依存**だったことが判明した（4件目で`xleftmargin=0zw`/`xrightmargin=0zw`/`numbersep=1zw`が`! Illegal unit of measure (pt inserted).`で実際にエラーになった）。`xleftmargin`/`xrightmargin`/`numbersep`は`listings`内部でTeXの標準的な寸法スキャナに渡される本物の寸法キーであり、`zw`を特別扱いするわけではない。**`\lstset`内であっても`zw`/`zh`は機械的に`\zw`/`\zh`へ変換する**のが安全（§6.3の手順に統合済み）。
- **クラス側の本物のバグを発見・修正**（§4.10参照）：メールアドレスを持たない著者の上付き文字に余分なカンマが付くバグ。`\expandafter<count>\csname...\endcsname`形式の代入に`\relax`終端が無く、TeXの数値スキャン中に直後の`\ifnum`条件文が代入完了前の古い値で実行されてしまうことが原因。5件目（全著者がメールアドレス省略）で初めて可視化されたが、実際には全文書に潜在していた（メールアドレスのある著者では「出るべきカンマ」と重なって無症状だった）。
- それ以外（`pxjahyper`削除、`jlisting.sty`の文字コード変換、`upbibtex -kanji=utf8`の使用）は§6.4と同じ対応で問題なく解決した。
- **この5件検証のさらに後で§4.11の`itemize`/`enumerate`行間バグを発見**（`fontspec`が`\AtBeginDocument`で`\normalsize`を再実行し、一度きりのリスト間隔修正を無効化する問題）。この表のページ数はバグ修正**前**のものであり、元のzip/展開先は検証後に削除済みのため再検証はできていない。`itemize`を使っている文書（1〜4件目、特に「べからず集」的なチェックリストを含むもの）では、修正後さらにページ数が減っている可能性がある。
- §4.12の受付・採録日欠落バグは`ses`オプション（`techrep`を内部で有効化する）には影響しない。`ses`は元から`\@uketsuke`の`\phantom`版（日付を隠す版）を使うため、この5件はいずれも影響を受けない。

## 7. 未検証・未対応の既知事項

- **縦組（`tate`）**：エンジンレベルの切り替え（`\AtBeginDocument{\tate}`）のみ実装。複雑な2段組タイトルページが縦組で正しく組まれるかは未検証。
- **各論文誌種別固有の文字列**（ACS/PRO/TOD/TOM/CDS/DC/DCON/CVA/TBIO/SLDM/TCEのヘッダ文言・DOIプレフィクス）：原文からテキストとして移植したが、個別にコンパイル確認したのは `techrep`（既定/DAM相当）と `JIP` のみ。既定年算出式（§4.18 finding 8）は全12種別の定数を原文と照合済みだが、`JIP`以外の11種別は実際にその論文誌種別を指定した文書のヘッダを画素単位で比較したわけではない。
- **`\newtheorem`**・`quotation`/`verse`・`recommendation` 環境：§4.13でコード自体は原文から移植済みだが、テスト文書群のいずれも実際に使用していないため、出力比較による動作確認はまだできていない（`quote`環境と`enumerate`/`itemize`/`description`本体は全テスト文書で使用されており確認済み）。
- **著者紹介の写真**：`\IfFileExists{<stem>.eps}` で `.eps` のみを確認する（原文と同じ仕様）。PNG/JPEG/PDF画像を直接使いたい場合は、この判定部分を拡張する必要がある。
- **`tombow` のオフセット調整**：トンボの位置（紙端からの距離）は10mm固定。原文にあった `\@tombowwidth` 相当のカスタマイズ余地は設けていない。
- **序文（`preface`）モード**：§4.18 finding 10で`\authortitle`/`\ps@IPSJTITLEheadings`/`alone`オプション/論文種別ラベル非表示を実装したが、対応する`ipsjpref.sty`版の参照PDFが手元に無いため、原文との画素単位の比較による検証はできていない。手作りの最小限のテスト文書（`\documentclass[preface,submit]`、`\documentclass[preface,submit,alone]`）でエラー無くコンパイルでき、概要・キーワード無しの簡潔なタイトルページになることのみ確認済み。
- **`\ruby`/`\QED`/`\MARU`/`\Hline`/`\dummyfigure`/`\dummyfiguret`/`\Center`（§4.18 finding 6, 7）**：原文のロジックをそのまま移植したが、テスト文書群のいずれも使用していないため出力比較はできていない。
- **`\cite`の引用番号ソート（§4.18 finding 1）**：`esample-lualatex.tex`で実際に複数引用（`\cite{companion,latex}`）が使われ正しく動作することを視認したが、並べ替えが必要になる「番号が逆順または不連続な複数引用」のケースは5つのテスト文書のいずれにも無く、ソート自体の動作は未検証。

## 8. ファイル一覧（このリポジトリにおける位置づけ）

| ファイル | 説明 |
|---|---|
| `ipsj-lualatex.cls` | 本変換の成果物（このドキュメントが説明するクラスファイル） |
| `ipsj.cls`, `ipsjpref.sty`, `ipsjtech.sty`, `ipsjsort*.bst`, `ipsjunsrt*.bst` | 変換元（pLaTeX用、保持のため残置） |
| `jsample.tex`/`esample.tex`/`tech-jsample.tex` と各PDF | 情報処理学会公式サンプル（pLaTeX用）。追加検証で使用 |
| `jsample-lualatex.tex`/`esample-lualatex.tex`/`tech-jsample-lualatex.tex` と各PDF | 上記サンプルを `ipsj-lualatex.cls` 用に移植したもの |
| `ses-sample-lualatex.tex`/`ses-esample-lualatex.tex` と各PDF | SES（ソフトウェアエンジニアリングシンポジウム）向け `ses` オプションのサンプル（§6.5参照）。元になったpLaTeX版（`ses-sample.tex`/`ses-esample.tex`/`ses.sty`等）はユーザー提供の一時的な検証資料であり、検証後にこのリポジトリから削除済み |
| `README.md` | 利用者向けの使い方・相違点ドキュメント |
| `CLAUDE.md` | 本ドキュメント |
