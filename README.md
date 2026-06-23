# ipsj-lualatex.cls

情報処理学会（IPSJ）の論文・研究報告用スタイルファイル `ipsj.cls` / `ipsjpref.sty` / `ipsjtech.sty`（pLaTeX/upLaTeX前提）の機能を、**LuaLaTeX専用**に1ファイルへ再実装したクラスファイルです。IPSJ/SIGSE ソフトウェアエンジニアリングシンポジウム（SES）が別途配布している `ses.sty`（研究報告スタイルからヘッダ・フッタ・ページ番号を非表示にした亜種）の機能も `ses` オプションとして統合しています（詳細は後述）。

後方互換性（pLaTeX, upLaTeX, pdfLaTeX, XeLaTeXでの利用）は考慮していません。現在のLuaLaTeXのみを対象としています。

**変換元スタイルファイルのバージョン**：[ipsj.cls](./ipsj.cls) v4.1 [2025/02/05]、[ipsjpref.sty](./ipsjpref.sty) v3.00 [2017/02/16]、[ipsjtech.sty](./ipsjtech.sty) v3.00 [2012/06/01]（いずれも情報処理学会公式配布分）。[ses.sty](./ses.sty) はSES2025（2025年開催のソフトウェアエンジニアリングシンポジウム）への投稿用として配布されていたものを基にしています。これらのスタイルファイルは年度や版によって変更される可能性があるため、上記バージョンが配布元（[情報処理学会](http://www.ipsj.or.jp/journal/submit/style.html)、ソフトウェア工学研究会）の現行版と一致しているか、確認してください。

なお、BiBTeXスタイルファイル、具体的には[ipsjsort.bst](./ipsjsort.bst) / [ipsjsort-e.bst](./ipsjsort-e.bst) / [ipsjunsrt.bst](./ipsjunsrt.bst) / [ipsjunsrt-e.bst](./ipsjunsrt-e.bst) v3.00 [2010/10/28]はそのまま使えます。

## 作成したファイル

スタイルファイルとともに、すぐに試せるサンプルを用意しています（`ipsj-lualatex.cls` を使うように調整済み）。

| ファイル | 内容 |
|---|---|
|[ipsj-lualatex.cls](./ipsj-lualatex.cls)|LuaLaTeXで使える情報処理学会論文・研究報告用スタイルファイル|
| [jsample-lualatex.tex](./jsample-lualatex.tex) | 通常の論文誌投稿（和文、複数著者・現所属・著者紹介あり）の公式サンプル[jsample.tex](./jsample.tex)を移植したもの |
| [esample-lualatex.tex](./esample-lualatex.tex) | 英文論文誌（`JIP`, `preprint`, `english`）の公式サンプル[esample.tex](./esample.tex)を移植したもの |
| [tech-jsample-lualatex.tex](./tech-jsample-lualatex.tex) | 研究報告の公式サンプル[tech-jsample.tex](./tech-jsample.tex)を移植したもの |
| [ses-sample-lualatex.tex](./ses-sample-lualatex.tex) | SES（ソフトウェアエンジニアリングシンポジウム）向け `ses` オプションのサンプル（和文）[ses-sample.tex](./ses-sample.tex)を移植したもの |
| [ses-esample-lualatex.tex](./ses-esample-lualatex.tex) | SES（ソフトウェアエンジニアリングシンポジウム）向け `ses` オプションのサンプル（英文）[ses-esample.tex](./ses-esample.tex)を移植したもの |

## PDF出力サンプル

pLaTeX版は配布物そのまま、LuaLaTeX版は上記ファイルをTeX Live 2026でコンパイルして作成しています。

| pLaTeX版 | LuaLaTeX版 |
|---|---|
|[jsample.pdf](./jsample.pdf) |[jsample-lualatex.pdf](./jsample-lualatex.pdf) |
|[esample.pdf](./esample.pdf) |[esample-lualatex.pdf](./esample-lualatex.pdf) |
| [tech-jsample.pdf](./tech-jsample.pdf) | [tech-jsample-lualatex.pdf](./tech-jsample-lualatex.pdf) |
| [ses-sample.pdf](./ses-sample.pdf) | [ses-sample-lualatex.pdf](./ses-sample-lualatex.pdf) |
| [ses-esample.pdf](./ses-esample.pdf) | [ses-esample-lualatex.pdf](./ses-esample-lualatex.pdf) |

## 必要環境

- **LuaLaTeX**（LuaHBTeX）。比較的新しいTeX Liveを推奨します（開発・動作確認はTeX Live 2026で行っています）。
- 和文フォント: **Harano Aji Mincho** / **Harano Aji Gothic**（TeX Live 2020以降で標準収録）
- 欧文フォントをクラス側では特に指定しません。`fontspec`の既定どおり**Latin Modern**になります（後述「フォントの指定方法」参照）
- `luatexja`, `luatexja-fontspec`, `fontspec`（いずれもTeX Liveに標準収録。`luatexja-fontspec`は`luatexja`本体に同梱されており、`fontspec`を自動的に読み込みます）
- `tombow`オプションを使う場合のみ `eso-pic`（TeX Liveに標準収録）

これらは`scheme-full`（全パッケージ導入）のTeX Live環境であれば追加インストール不要です。`scheme-basic`等の最小構成からインストールした場合は、`collection-langjapanese`（和文フォント・`luatexja`等）を追加してください。

## 最小サンプル

```latex
\documentclass[submit,techrep,noauthor]{ipsj-lualatex}
\usepackage{graphicx}

\begin{document}
\title{タイトル}
\author{情報 太郎}{Taro Joho}{aff1}[joho@example.jp]
\affiliate{aff1}{なんとか大学}

\begin{abstract}
概要．
\end{abstract}
\begin{jkeyword}
キーワード
\end{jkeyword}

\maketitle

\section{はじめに}
本文．

\begin{thebibliography}{9}
\bibitem{ref1} 著者: タイトル (2024).
\end{thebibliography}
\end{document}
```

コンパイルは `lualatex` を直接呼ぶだけです（`platex`は使いません）。

```sh
lualatex main.tex
lualatex main.tex   # 相互参照・文献番号を確定させるため2回以上
```

`latexmk` を使う場合は latexmkrc にて `$pdf_mode = 4;`（LuaLaTeXの直接PDF生成）の設定にしてください。

BibTeXで文献リストを作る場合（`ipsjsort.bst`/`ipsjunsrt.bst`を使用）は、和文を含む`.bib`を正しく処理できる `upbibtex` を使ってください。プレーンな `bibtex` ではマルチバイト文字の扱いが原因でエラーになることがあります。

```sh
upbibtex -kanji=utf8 main
lualatex main.tex
lualatex main.tex
```

## ipsj.cls利用者向け：主な相違点

これまで `ipsj.cls` / `ipsjpref.sty` / `ipsjtech.sty` を使っていた方向けに、変更点をまとめます。

### 1. ファイルは1つだけ

旧来は `ipsj.cls` が `preface` / `techrep` オプションに応じて `ipsjpref.sty` / `ipsjtech.sty` を内部で `\input` していましたが、`ipsj-lualatex.cls` は**この1ファイルだけ**で全モードに対応します。`ipsjpref.sty` や `ipsjtech.sty` を別途配置する必要はありません。

### 2. エンジンはLuaLaTeX専用

`platex` / `uplatex` / `pdflatex` / `xelatex` では使えません（使えないことを厳密に確認したわけではありませんが、少なくとも考慮はしていません）。`\documentclass` 1行を変えるだけでは移行できないので、原稿ファイル側にも以下の対応が必要です（詳細は次項）。

### 3. `\documentclass` とプリアンブルの書き換え

| 旧 (`ipsj.cls`) | 新 (`ipsj-lualatex.cls`) |
|---|---|
| `\documentclass[submit,techrep]{ipsj}` | `\documentclass[submit,techrep]{ipsj-lualatex}` |
| `\usepackage[dvipdfmx]{graphicx}` | `\usepackage{graphicx}`（ドライバオプション不要） |
| `\usepackage[dvips]{graphicx}` | 同上 |
| `\usepackage[dvipdfmx,...]{hyperref}` / `\usepackage[dvipdfmx]{xcolor}` 等 | ドライバオプションを外す（`graphicx`以外でも同様） |
| `\usepackage{pxjahyper}` | 削除する（pLaTeX/upLaTeX専用。LuaTeXは和文PDFしおりをネイティブに扱えるため不要かつ非対応） |
| `\usepackage[varg]{txfonts}` 等のpdfTeX用Type1フォント差し替え | 削除し、代わりに`\setmainfont{TeX Gyre Termes}`/`\setsansfont{TeX Gyre Heros}`を追加してください（`txfonts`自体はLuaLaTeXと互換性がありませんが、それが与えていたTimes/Helvetica系の見た目は`ipsj-lualatex.cls`では再現されないため、見た目を保ちたい場合は明示的な指定が必要です。詳細は後述「フォントの指定方法」） |

`amsmath`／`subcaption`／`multirow`／`xcolor`／`tcolorbox`／`inconsolata`／`algorithm`系／`cite`／`url`・`xurl`／`listings`等、その他多くの汎用パッケージは無変更でそのまま動作しました。`listings`に和文対応を加える`jlisting.sty`をプロジェクトにローカル同梱している場合は、そのファイルが古い日本語エンコーディング（ISO-2022-JP相当）で保存されていることがあり、LuaLaTeX（UTF-8前提）ではエラーになります。`iconv -f ISO-2022-JP -t UTF-8 jlisting.sty > jlisting.sty.new` のように変換してから差し替えてください（差し替えて動作することは確認しています）。

### 4. 用紙サイズオプションの廃止（重要）

`a4paper` / `a5paper` / `b4paper` / `b5paper`（および `a4j` / `a5j` などのj/p系亜種）、`landscape` オプションは**削除**しました。

理由: 元の `ipsj.cls` は本文末尾でページジオメトリを無条件にA4・本文幅177mmへ上書きしており、これらのオプションは実際には**何の効果も持っていませんでした**（紙面オプションを変えても出力は変わらない）。実害のない死んだオプションだったため、新クラスでは最初からA4専用としています。

### 5. オプション名の変更・整理

| 旧オプション | 新オプション | 備考 |
|---|---|---|
| `mentuke` | `tombow` | トンボ（裁ち落としマーク）。意味の分かりやすい名前に変更 |
| `Proof` | `proof`（小文字） | 校正用の隅つきガイド線。小文字に統一 |
| `LAYOUT` | （廃止） | 元のクラスでも参照されていない未使用オプションでした |
| `OT` | （廃止） | 同上 |
| `a4paper` 等の用紙オプション全般 | （廃止） | 上記4節参照。常にA4 |

それ以外のオプション（`techrep`, `submit`, `noauthor`, `english`, `preface`, `preprint`, `draft`, `final`, `tate`, `oneside`/`twoside`, `onecolumn`/`twocolumn`, `leqno`, `fleqn`, `openbib`, 各論文誌略称 `PRO`/`ACS`/`TOD`/`TOM`/`CDS`/`DC`/`DCON`/`CVA`/`TBIO`/`SLDM`/`JIP`/`TCE`、各論文種別 `technote`/`sigrecommended`/`invited`/`Data`/`Survey`/`Research`/`Short`/`systems`/`services`/`devices`/`Express`/`Practice`/`Content`/`system`/`abstract`/`invitedshort`/`recommendedshort`/`recommendedresearch`/`recommendedpractice`/`recommendedcontent`/`recommendeddevices`）は**そのまま同じ名前で使えます**。`fleqn`は数式が常にフラッシュレフトになる原文の挙動が既定で常時有効なため、指定しても無効果です（警告を出さないために受理はします）。

`preface`（序文）モードでは、`ipsjpref.sty`由来の`alone`オプションも使えます。序文が単独で1ページに収まる場合に指定すると、ヘッダのページ参照が「先頭ページ–末尾ページ」の範囲表記ではなく単一ページ表記になります。

`ses`（IPSJ/SIGSE ソフトウェアエンジニアリングシンポジウム向け。研究報告スタイルがベースで、ヘッダの学会名表記・DOI行・footerの著作権表記・ページ番号をすべて非表示にする）にも対応しています。`ses` を指定すると自動的に `techrep` 相当の組版になるため、`\documentclass[submit,ses,noauthor]{ipsj-lualatex}` のように `techrep` を併記する必要はありません（オリジナルの `ses.sty` と同じ挙動です）。

### 6. コマンド・環境はほぼ全て互換

以下は旧クラスと同じ名前・同じ引数で使えます。原稿の本文（`\begin{document}` 以降）はほとんど書き換え不要です。

- `\title`, `\etitle`, `\author`, `\affiliate`, `\paffiliate`, `\maketitle`
- `\begin{abstract}`, `\begin{eabstract}`, `\begin{jkeyword}`, `\begin{ekeyword}`, `\begin{keyword}`
- `\section` 〜 `\subparagraph`, `\appendix`
- `\begin{figure}`, `\begin{table}`, `\caption`, `\ecaption`, `\CaptionType`
- `\twocolcaption`, `\twocolecaption`, `\twocolfig`
- `\figref`, `\Figref`, `\figsref`, `\Figsref`, `\tabref`, `\Tabref`, `\tabsref`, `\Tabsref`
- `\begin{thebibliography}`, `\cite`, `\Cite`（`\cite{a,b,c}`は引用番号を自動的に昇順ソート・重複除去してから`[...]`で出力）
- `\begin{acknowledgment}`
- `\begin{biography}`, `\profile`（`\profile*`含む）
- `\received`, `\accepted`, `\rereceived`, `\rerereceived`, `\released`, `\Presented`、および和文別名 `\受付`, `\採録`, `\再受付`, `\再再受付`, `\発表`
- `\Editor`（編集委員名挿入。TOD/TBIO/CVA/SLDM）
- `\urlj`, `\urle`, `\refdatej`, `\refdatee`, `\doi`
- `enumerate`, `itemize`, `description`（IPSJ仕様の番号書式・字下げ。`enumerate`は`(1)`形式）、`\Enumerate`, `\Itemize`, `\Description`, `\ENUMERATE`, `\ITEMIZE`, `\DESCRIPTION`, `enumerate*`, `itemize*`, `description*`（大文字・アスタリスク版は字下げ幅のみ異なる）
- `quote`, `quotation`, `verse`（IPSJ仕様の`\Cwd`ベースの字下げ）
- `\newtheorem`（IPSJ仕様の定理見出し書式）、`recommendation` 環境（推薦文）
- `equation`, `eqnarray`, `\[ \]`（数式は中央揃えではなく原文と同じ常時フラッシュレフト配置。`\mathindent`は`1\zw`）
- `\ruby`（ルビ）, `\QED`（証明終わりの$\Box$）, `\MARU{n}`（丸囲み数字）, `\contact`（後方互換のため受理するだけで何も出力しない）, `\Hline`（表組み用の太さ0.4mmルール）, `\ddash`, `\doubledash`, `\dummyfigure`, `\dummyfiguret`
- `\setcounter{巻数}{...}`, `\setcounter{号数}{...}`, `\setcounter{月数}{...}`（和文カウンタ名のエイリアス）

### 7. `\zw` を裸の単位として書いていた箇所は要修正

旧スタイルファイルのサンプル文書では、寸法指定にしばしば `\makebox[9.47zw][l]{...}` のように **`zw` を単位記号として直接書く**箇所があります。これはpLaTeXエンジンが `zw`/`zh` をネイティブな寸法単位として解釈していたためです。

LuaLaTeX（`luatexja`）では `zw`/`zh` はネイティブ単位ではなく、`\zw`/`\zh` という**寸法を返すマクロ**として提供されます。そのため、

```latex
\makebox[9.47zw][l]{...}   % 旧: エラーになる（Illegal unit of measure）
\makebox[9.47\zw][l]{...}  % 新: \zw に書き換える
```

のように、**裸の `zw`/`zh` の直前にバックスラッシュを足す**必要があります。`\hskip1zw` のような頻出パターンも同様に `\hskip1\zw` に直してください。これは新クラス側の対応ではなく、**原稿（.tex）側で機械的に直す**必要がある変更です。`\lstset{xleftmargin=3zw,...}` のように `listings` パッケージのオプションキー内に書かれている場合も例外なく変換が必要です。

### 8. フォントの指定方法

`\mcfamily`（明朝）/ `\gtfamily`（ゴシック）はそのまま使えます。和文の実際の物理フォントはクラス側で

```latex
\setmainjfont{Harano Aji Mincho}[BoldFont={Harano Aji Gothic Medium}]
\setsansjfont{Harano Aji Gothic Medium}[BoldFont={Harano Aji Gothic Medium}]
```

と指定しています。別のフォントに差し替えたい場合は、`\documentclass` の後で `\setmainjfont` 等を再度呼べば上書きできます（`luatexja-fontspec` の標準的な使い方です）。旧クラスにあった `JY1`/`JT1` エンコーディングや太明朝・太ゴシックの仮想フォント差し替え（`submit` オプション無指定時の「太ミン」「太ゴ」）は、上記の `BoldFont` 指定（次項参照）によって実現しています。

**欧文（ラテン文字）フォントをクラス側では一切指定していません**。`\setmainfont`/`\setsansfont`を呼んでいないため、`fontspec`の既定どおり**Latin Modern**（Computer Modernの直接の後継。見た目はほぼ同一）になります。これは手抜きではなく、原文`ipsj.cls`自体の挙動を調べた結果に基づく意図的な選択です。`ipsj.cls`は`\rmdefault`/`\sfdefault`を一切書き換えておらず（`platex`で実際に確認済み）、ラテン文字フォントの選択は完全にドキュメント側に委ねられています。情報処理学会公式サンプルのうち和文モードのもの（`jsample.tex`等）はラテン文字用フォントパッケージを何も読み込んでおらず、実際にComputer Modernで組まれています。一方、英文モードのサンプル（`esample.tex`/`ses-esample.tex`）がTimes/Helvetica系に見えるのは、**そのドキュメント自身**が`\usepackage[varg]{txfonts}`（pLaTeX/pdfTeX時代のPostScriptフォントパッケージ。LuaLaTeXでは使えません）を独自に読み込んでいるからです。

したがって、Times/Helvetica系の見た目が欲しい場合は、`txfonts`を読んでいた原稿だったときと同様に、**ご自身のプリアンブルで**`fontspec`経由で明示的に指定してください（本リポジトリの`esample-lualatex.tex`/`ses-esample-lualatex.tex`も、削除した`txfonts`の代わりにこの方法でTimes/Helvetica系を再現しています）。

```latex
\setmainfont{TeX Gyre Termes}  % Times相当
\setsansfont{TeX Gyre Heros}   % Helvetica相当
```

**太字明朝とゴシックの代用について**：原文`ipsj.cls`が前提としていた和文フォント環境には明朝の太字（Bold）シェイプが無く、`\bfseries`は自動的にゴシックで代用されていました（和文組版の古くからの慣習）。代用先は「太いゴシック」ではなく、当時のゴシック書体が標準として持っていた唯一のウェイトである**Medium**で、ゴシック自体をボールド化する処理は行われていませんでした。本クラスが採用する Harano Aji Mincho/Gothic はいずれも本物の Bold ウェイトを持つため、対策なしでは見出し・概要ラベル・図表番号や、原稿中で直接`\textbf{和文}`と書いた箇所などが原文と異なる太字明朝・太字ゴシックで出てしまいます。これを避けるため、`\setmainjfont`/`\setsansjfont`の`BoldFont`オプションで「明朝・ゴシックいずれの太字も`Harano Aji Gothic Medium`に切り替える」という代用規則自体をフォント宣言レベルで定義しています。この方式により、クラス内部の処理だけでなく、**原稿中で直接`\bfseries`や`\textbf{}`を使った場合も**自動的に原文と同じ見た目（太字ゴシック、ただしMediumウェイト）になります。

### 9. 縦組（`tate`）・トンボ（`tombow`）

- `tate` オプションは `luatexja` 本体が提供する `\tate` への切り替えのみを行います。タイトルページの複雑な段組みまで含めた縦組での見た目は十分に検証していません。本格的に縦組で使う場合は出力を必ず目視確認してください。
- `tombow` オプションは `eso-pic` を使ってA4四隅にトンボを描画します。旧クラスの `mentuke` 相当ですが、トンボ位置の微調整（オフセット）オプションは未実装です。

### 10. 著者紹介欄の写真

`\profile[<画像のベース名>]{...}{...}{...}` の形で画像を指定した場合、`<画像のベース名>.eps` の存在のみをチェックします（旧クラスと同じ挙動）。PNG/JPEG/PDF画像を使う場合は `.eps` という名前のファイルを別途用意するか、本クラスの `\IfFileExists` 判定部分を改造してください。

## 既知の制限

- 全ての論文誌種別オプション（`ACS`/`PRO`/`TOD`/`TOM`/`CDS`/`DC`/`DCON`/`CVA`/`TBIO`/`SLDM`/`TCE`）のヘッダ文字列・DOI表記・年度算出式は移植していますが、個別に組版確認をしたのは `techrep` と `JIP` のみです。
- `\newtheorem` のIPSJ向けカスタマイズ・`quotation`/`verse` のインデント調整・`recommendation` 環境・`\ruby`/`\QED`/`\MARU`/`\Hline`/`\dummyfigure`/`\dummyfiguret`/`eqnarray`/`\[ \]`・`\twocolcaption`/`\twocolecaption`/`\twocolfig` は原文のコードをそのまま移植していますが、検証用のテスト文書のいずれも実際に使用していないため、出力比較による動作確認は行っていません（`quote`環境、`enumerate`/`itemize`/`description`本体、`equation`環境はテスト文書の少なくとも1つで使用されており、組版確認をして問題がないと判断しています。
- `preface`（序文）モードは`\authortitle`・専用ページスタイル・`alone`オプションを移植していますが、対応する参照PDFが手元に無いため、出力比較による動作確認は行っていません。最小限の手作りテスト文書でエラー無くコンパイルできることのみ確認済みです。
- `\cite`の引用番号自動ソートは、`esample-lualatex.tex`の複数引用（`\cite{companion,latex}`）で動作することを確認しましたが、並べ替えが実際に発生するケース（番号が逆順または不連続な複数引用）はテスト文書に無く、ソート処理自体は未検証です。

## 開発・検証の方針

本クラスは、`ipsj.cls`/`ipsjpref.sty`/`ipsjtech.sty`/`ses.sty`のソースコードを直接読み比べながら実装し、情報処理学会公式サンプル（`jsample`/`esample`/`tech-jsample`）に加え、手元にあって利用可能な論文・研究報告を多数使い、pLaTeXでビルドした元のPDFと画素単位で比較する形で検証しています。和文フォントには情報処理学会公式サンプルのPDFも既に使用している `Harano Aji Mincho`/`Harano Aji Gothic` をそのまま採用しているため、和文部分の字体は原文とほぼ完全に一致します。

その一方で、LuaLaTeX（LuaTeX-ja）とpLaTeXでは行送り・改ページの計算が**エンジンレベルでわずかに異なる**ため、原稿によっては最終的なページ数が元のpLaTeX版と1ページ程度ずれることがあります（LuaLaTeXで処理すると、文書の内容に依存してページ数が増えたり減ったりします）。これは検証の過程で繰り返し確認していますが、これは`ipsj-lualatex.cls`の内容欠落・処理崩れではなく、ページ内の余白の配分がわずかに変わることによる差であって、無害かつ対応不能だと考えています。逆に、ページ数が大きくずれる・図表が消える・文字が異常な書体になるといった症状は、本クラス側の変換ミスである可能性が高いので、ぜひ[教えて](https://bsky.app/profile/matusita.bsky.social)ください。

## 謝辞

本クラスは、以下のソフトウェア・フォント・データなしには成立しませんでした。

- **`ipsj.cls` / `ipsjpref.sty` / `ipsjtech.sty`**：本クラスの変換元であり、移植作業の全てはこのコードを読み解くことから始まりました。原作者（Hiroshi Nakashima氏、Yasuki Saito氏ほか）と情報処理学会論文誌ジャーナル編集委員会に感謝します。
- **`ses.sty`／SES改変版`ipsj.cls`**：IPSJ/SIGSE ソフトウェアエンジニアリングシンポジウム（SES）が独自に配布・保守しているスタイルファイルです。情報処理学会ソフトウェア工学研究会ならびにSES運営委員会に感謝します。
- **TeX Live**：本クラスの開発・動作確認の基盤となったTeX配布環境です。TeX Users Groupに感謝します。
- **LuaTeX-ja**：`\tate`、和文/欧文フォントの分離管理、`\kanjiskip`/`\xkanjiskip`等、LuaTeXで日本語組版を実現するための基盤そのものです。LuaTeX-jaプロジェクトに感謝します。
- **fontspec**：本クラスのフォント選択は全て`fontspec`（および`luatexja-fontspec`によるその和文拡張）に依拠しています。原作者のWill Robertson氏ならびにThe LaTeX projectに感謝します。
- **Harano Aji Mincho / Harano Aji Gothic**（`haranoaji`パッケージ）：本クラスが採用する和文フォント。Adobe・Googleが共同開発した源ノ明朝・源ノ角ゴシック（Source Han Serif/Sans）をAdobe-Japan1字形順に組み替えたもので、情報処理学会公式サンプルのPDFも同じフォントで組まれています。作者のMasamichi Hosoda氏に感謝します。
- **TeX Gyre Termes / TeX Gyre Heros**：Times/Helvetica系の見た目が欲しい場合に使う欧文フォント。GUST e-foundryプロジェクトに感謝します。
- 検証作業では、`Ghostscript`・`ImageMagick`・`pdfminer.six`・`qpdf`・Dockerの`texlive/texlive`公式イメージにも大いに助けられました。原文との画素単位の比較や、埋め込みフォントの直接確認といった検証手法は、これらのツールなしには実行できませんでした。
- **Claude Code**：本ツールの開発全般にわたって利用しました。
