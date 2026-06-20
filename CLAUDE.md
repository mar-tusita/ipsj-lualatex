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

- `article` が提供する `\@startsection` 基盤、`itemize`/`enumerate`/`description`/`quote`/`quotation`/`verse`、`\@float`/`\@dblfloat`、脚注機構などはIPSJクラスでも最終的にほぼ同じ意味で使われており、自前で再実装する必要がない。
- `\maketitle`/`\@maketitle`/セクション見出し/キャプション/参考文献など、IPSJ固有の部分は全て `\renewcommand`/`\renewenvironment` で上書きするため、ベースが`article`であることは実害がない。

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

## 3. オプション名対応表

| 旧（`ipsj.cls`） | 新（`ipsj-lualatex.cls`） | 変更理由 |
|---|---|---|
| `mentuke` | `tombow` | 意味が直接伝わる英語名に変更 |
| `Proof` | `proof` | 大文字小文字の統一 |
| `LAYOUT` | 廃止 | `\if@LAYOUT` は宣言のみで使用箇所が一つもなかった（grep で確認済み） |
| `OT` | 廃止 | `\ifDS@OT` も同様に未使用 |
| `a4paper`/`a5paper`/`b4paper`/`b5paper`/`a4j`/`a5j`/`b4j`/`b5j`/`a4p`/`a5p`/`b4p`/`b5p`/`landscape` | 廃止 | §2.3参照。常にA4のため意味がなかった |
| `tate`, `techrep`, `submit`, `noauthor`, `english`, `preface`, `preprint`, `draft`, `final`, `oneside`/`twoside`, `onecolumn`/`twocolumn`, `leqno`, `fleqn`, `openbib` | 変更なし | そのまま流用 |
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

修正後は `jsample-lualatex.tex`／`esample-lualatex.tex` の著者紹介ページが参照PDFと同じレイアウトになることを確認した。

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

## 5. 当初の `main.tex` 検証では見つからなかった機能（後で追加したもの）

最初に用意したテスト文書 `main-lualatex.tex`（`main.tex` を移植、`techrep,submit,noauthor`）は機能を網羅していなかった。情報処理学会公式サンプル（`jsample.tex`/`esample.tex`/`tech-jsample.tex`）でテストして初めて、未実装または未検証だったことが分かった機能：

- `\figref`/`\Figref`/`\figsref`/`\Figsref`/`\tabref`/`\Tabref`/`\tabsref`/`\Tabsref`：図表参照。同じラベルへの**最初の参照だけ太字**になり、2回目以降は通常体になる仕様（`\@ifundefined{ipsj@used@<label>}` で初回判定）。
- `\Editor`／`\Ediname` テーブル（TOD/TBIO/CVA/SLDM固有の「担当編集委員」「Communicated by」表記）。
- `\urlj`/`\urle`/`\refdatej`/`\refdatee`/`\doi`（参考文献中のURL・DOI・アクセス日表記）。
- `\acknowledgment`（謝辞見出し）。`\end{acknowledgment}` に対応する `\endacknowledgment` は原文にも存在しないが、`\csname endacknowledgment\endcsname` が未定義のとき自動的に `\relax` として確定する（TeXの`\csname`の仕様）ため、これは欠落ではなく元々そういう仕様だった。
- `\Enumerate`/`\Itemize`/`\Description`/`\ENUMERATE`/`\ITEMIZE`/`\DESCRIPTION`/`enumerate*`/`itemize*`/`description*`。原文は `\@trivlist` を使った専用のインデント幅調整を行っていたが、新クラスでは標準の `enumerate`/`itemize`/`description` への単純な別名にとどめている（意図的な簡略化）。
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
  texlive/texlive:latest lualatex -interaction=nonstopmode -halt-on-error main-lualatex.tex
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
| `main-lualatex.tex` | `main.tex`（実論文） | `submit,techrep,noauthor` | 8 / 8 | ほぼ画素単位で一致 |
| `tech-jsample-lualatex.tex` | `tech-jsample.tex`（公式サンプル） | `submit,techrep,noauthor` | 6 / 6 | ほぼ画素単位で一致 |
| `jsample-lualatex.tex` | `jsample.tex`（公式サンプル） | 既定（論文誌・和文） | 11 / 10 | 構造は一致、1ページ分の行送り差 |
| `esample-lualatex.tex` | `esample.tex`（公式サンプル） | `english,preprint,JIP` | 9 / 8 | 同上 |

`jsample`/`esample` の1ページ差は、フォントメトリクスの違い（原文はTimes/Helvetica系+和文ベクタフォント、新版はTeX Gyre Termes/Heros + Harano Aji）による行末・改ページ位置の累積的なズレであり、構造上の不具合ではない（見出し・図表・著者紹介・参考文献など全要素は正しく再現されている）。

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

## 7. 未検証・未対応の既知事項

- **縦組（`tate`）**：エンジンレベルの切り替え（`\AtBeginDocument{\tate}`）のみ実装。複雑な2段組タイトルページが縦組で正しく組まれるかは未検証。
- **各論文誌種別固有の文字列**（ACS/PRO/TOD/TOM/CDS/DC/DCON/CVA/TBIO/SLDM/TCEのヘッダ文言・DOIプレフィクス・既定年算出式）：原文からテキストとして移植したが、個別にコンパイル確認したのは `techrep`（既定/DAM相当）と `JIP` のみ。
- **`\newtheorem` のIPSJ向けスタイル**、`quote`/`quotation`/`verse` の `\Cwd` ベースのインデント調整、`recommendation` 環境：未移植（標準LaTeXの挙動になる）。実際の使用頻度が低いため優先度を下げた。
- **著者紹介の写真**：`\IfFileExists{<stem>.eps}` で `.eps` のみを確認する（原文と同じ仕様）。PNG/JPEG/PDF画像を直接使いたい場合は、この判定部分を拡張する必要がある。
- **`tombow` のオフセット調整**：トンボの位置（紙端からの距離）は10mm固定。原文にあった `\@tombowwidth` 相当のカスタマイズ余地は設けていない。

## 8. ファイル一覧（このリポジトリにおける位置づけ）

| ファイル | 説明 |
|---|---|
| `ipsj-lualatex.cls` | 本変換の成果物（このドキュメントが説明するクラスファイル） |
| `ipsj.cls`, `ipsjpref.sty`, `ipsjtech.sty`, `ipsjsort*.bst`, `ipsjunsrt*.bst` | 変換元（pLaTeX用、保持のため残置） |
| `main.tex` / `main.pdf` | 実論文（pLaTeXでビルド済み）。変換の正解参照として使用 |
| `main-lualatex.tex` / `main-lualatex.pdf` | `main.tex` を `ipsj-lualatex.cls` 用に移植したもの |
| `jsample.tex`/`esample.tex`/`tech-jsample.tex` と各PDF | 情報処理学会公式サンプル（pLaTeX用）。追加検証で使用 |
| `jsample-lualatex.tex`/`esample-lualatex.tex`/`tech-jsample-lualatex.tex` と各PDF | 上記サンプルを `ipsj-lualatex.cls` 用に移植したもの |
| `ses-sample-lualatex.tex`/`ses-esample-lualatex.tex` と各PDF | SES（ソフトウェアエンジニアリングシンポジウム）向け `ses` オプションのサンプル（§6.5参照）。元になったpLaTeX版（`ses-sample.tex`/`ses-esample.tex`/`ses.sty`等）はユーザー提供の一時的な検証資料であり、検証後にこのリポジトリから削除済み |
| `README.md` | 利用者向けの使い方・相違点ドキュメント |
| `CLAUDE.md` | 本ドキュメント |
