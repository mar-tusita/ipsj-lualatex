# ipsj-lualatex.cls

情報処理学会（IPSJ）の論文・研究報告用スタイルファイル `ipsj.cls` / `ipsjpref.sty` / `ipsjtech.sty`（pLaTeX/upLaTeX前提）の機能を、**LuaLaTeX専用**に1ファイルへ再実装したクラスファイルです。

後方互換性（pLaTeX, upLaTeX, pdfLaTeX, XeLaTeXでの利用）は考慮していません。現在のLuaLaTeXのみを対象としています。

## 必要環境

- **LuaLaTeX**（LuaHBTeX）。TeX Live 2023以降を推奨。
- 和文フォント: **Harano Aji Mincho** / **Harano Aji Gothic**（TeX Liveに標準収録）
- 欧文フォント: **TeX Gyre Termes** / **TeX Gyre Heros**（TeX Liveに標準収録）
- `luatexja`, `luatexja-fontspec`, `fontspec`（`luatexja-fontspec`が自動的に読み込みます）
- `tombow`オプションを使う場合のみ `eso-pic`

これらは標準的なTeX Live環境であれば追加インストール不要です。

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

`latexmk` を使う場合は `$pdf_mode = 1;`（LuaLaTeXの直接PDF生成）の設定にしてください。リポジトリ同梱の `latexmkrc` は旧来の `platex + dvipdfmx` 用なので、LuaLaTeXで使う際は変更が必要です。

## ipsj.cls利用者向け：主な相違点

これまで `ipsj.cls` / `ipsjpref.sty` / `ipsjtech.sty` を使っていた方向けに、変更点をまとめます。

### 1. ファイル構成が1つに統合

旧来は `ipsj.cls` が `preface` / `techrep` オプションに応じて `ipsjpref.sty` / `ipsjtech.sty` を内部で `\input` していましたが、`ipsj-lualatex.cls` は**この1ファイルだけ**で全モードに対応します。`ipsjpref.sty` や `ipsjtech.sty` を別途配置する必要はありません。

### 2. エンジンはLuaLaTeX専用

`platex` / `uplatex` / `pdflatex` / `xelatex` では使えません。`\documentclass` 1行を変えるだけでは移行できないので、原稿ファイル側にも以下の対応が必要です（詳細は次項）。

### 3. `\documentclass` とプリアンブルの書き換え

| 旧 (`ipsj.cls`) | 新 (`ipsj-lualatex.cls`) |
|---|---|
| `\documentclass[submit,techrep]{ipsj}` | `\documentclass[submit,techrep]{ipsj-lualatex}` |
| `\usepackage[dvipdfmx]{graphicx}` | `\usepackage{graphicx}`（ドライバオプション不要） |
| `\usepackage[dvips]{graphicx}` | 同上 |
| `\usepackage[varg]{txfonts}` 等のpdfTeX用Type1数式フォント差し替え | 削除してください（LuaLaTeXのデフォルト数式フォントで十分。互換性もありません） |

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

それ以外のオプション（`techrep`, `submit`, `noauthor`, `english`, `preface`, `preprint`, `draft`, `final`, `tate`, `oneside`/`twoside`, `onecolumn`/`twocolumn`, `leqno`, `fleqn`, `openbib`, 各論文誌略称 `PRO`/`ACS`/`TOD`/`TOM`/`CDS`/`DC`/`DCON`/`CVA`/`TBIO`/`SLDM`/`JIP`/`TCE`、各論文種別 `technote`/`sigrecommended`/`invited`/`Data`/`Survey`/`Research`/`Short`/`systems`/`services`/`devices`/`Express`/`Practice`/`Content`/`system`/`abstract`/`invitedshort`/`recommendedshort`/`recommendedresearch`/`recommendedpractice`/`recommendedcontent`/`recommendeddevices`）は**そのまま同じ名前で使えます**。

### 6. コマンド・環境はほぼ全て互換

以下は旧クラスと同じ名前・同じ引数で使えます。原稿の本文（`\begin{document}` 以降）はほとんど書き換え不要です。

- `\title`, `\etitle`, `\author`, `\affiliate`, `\paffiliate`, `\maketitle`
- `\begin{abstract}`, `\begin{eabstract}`, `\begin{jkeyword}`, `\begin{ekeyword}`, `\begin{keyword}`
- `\section` 〜 `\subparagraph`, `\appendix`
- `\begin{figure}`, `\begin{table}`, `\caption`, `\ecaption`, `\CaptionType`
- `\twocolcaption`, `\twocolecaption`, `\twocolfig`
- `\figref`, `\Figref`, `\figsref`, `\Figsref`, `\tabref`, `\Tabref`, `\tabsref`, `\Tabsref`
- `\begin{thebibliography}`, `\Cite`
- `\begin{acknowledgment}`
- `\begin{biography}`, `\profile`（`\profile*`含む）
- `\received`, `\accepted`, `\rereceived`, `\rerereceived`, `\released`, `\Presented`、および和文別名 `\受付`, `\採録`, `\再受付`, `\再再受付`, `\発表`
- `\Editor`（編集委員名挿入。TOD/TBIO/CVA/SLDM）
- `\urlj`, `\urle`, `\refdatej`, `\refdatee`, `\doi`
- `\Enumerate`, `\Itemize`, `\Description`, `\ENUMERATE`, `\ITEMIZE`, `\DESCRIPTION`, `enumerate*`, `itemize*`, `description*`
- `\setcounter{巻数}{...}`, `\setcounter{号数}{...}`, `\setcounter{月数}{...}`（和文カウンタ名のエイリアス）

### 7. `\zw` を裸の単位として書いていた箇所は要修正

旧スタイルファイルのサンプル文書では、寸法指定にしばしば `\makebox[9.47zw][l]{...}` のように **`zw` を単位記号として直接書く**箇所があります。これはpLaTeXエンジンが `zw`/`zh` をネイティブな寸法単位として解釈していたためです。

LuaLaTeX（`luatexja`）では `zw`/`zh` はネイティブ単位ではなく、`\zw`/`\zh` という**寸法を返すマクロ**として提供されます。そのため、

```latex
\makebox[9.47zw][l]{...}   % 旧: エラーになる（Illegal unit of measure）
\makebox[9.47\zw][l]{...}  % 新: \zw に書き換える
```

のように、**裸の `zw`/`zh` の直前にバックスラッシュを足す**必要があります。`\hskip1zw` のような頻出パターンも同様に `\hskip1\zw` に直してください。これは新クラス側の対応ではなく、**原稿（.tex）側で機械的に直す**必要がある変更です。

### 8. フォントの指定方法

`\mcfamily`（明朝）/ `\gtfamily`（ゴシック）はそのまま使えます。実際の物理フォントはクラス側で

```latex
\setmainfont{TeX Gyre Termes}
\setsansfont{TeX Gyre Heros}
\setmainjfont{Harano Aji Mincho}
\setsansjfont{Harano Aji Gothic}
```

と指定しています。別のフォントに差し替えたい場合は、`\documentclass` の後で `\setmainjfont` 等を再度呼べば上書きできます（`luatexja-fontspec` の標準的な使い方です）。旧クラスにあった `JY1`/`JT1` エンコーディングや太明朝・太ゴシックの仮想フォント差し替え（`submit` オプション無指定時の「太ミン」「太ゴ」）は、対応する物理フォントの Bold ウェイトに置き換えています。

### 9. 縦組（`tate`）・トンボ（`tombow`）

- `tate` オプションは `luatexja` 本体が提供する `\tate` への切り替えのみを行います。タイトルページの複雑な段組みまで含めた縦組での見た目は十分に検証していません。本格的に縦組で使う場合は出力を必ず目視確認してください。
- `tombow` オプションは `eso-pic` を使ってA4四隅にトンボを描画します。旧クラスの `mentuke` 相当ですが、トンボ位置の微調整（オフセット）オプションは未実装です。

### 10. 著者紹介欄の写真

`\profile[<画像のベース名>]{...}{...}{...}` の形で画像を指定した場合、`<画像のベース名>.eps` の存在のみをチェックします（旧クラスと同じ挙動）。PNG/JPEG/PDF画像を使う場合は `.eps` という名前のファイルを別途用意するか、本クラスの `\IfFileExists` 判定部分を改造してください。

## サンプルファイル

このリポジトリには検証用に以下のサンプルを用意しています（`ipsj-lualatex.cls` を使うように調整済み）。

| ファイル | 内容 |
|---|---|
| `main-lualatex.tex` | 研究報告（`techrep,submit,noauthor`）の実例 |
| `jsample-lualatex.tex` | 通常の論文誌投稿（和文、複数著者・現所属・著者紹介あり）の公式サンプルを移植したもの |
| `esample-lualatex.tex` | 英文論文誌（`JIP`, `preprint`, `english`）の公式サンプルを移植したもの |
| `tech-jsample-lualatex.tex` | 研究報告の公式サンプルを移植したもの |

対応する元の `*.tex`（pLaTeX用）と、両方のPDFも参考用に同梱しています。`ipsj.cls` → `ipsj-lualatex.cls` への移行作業の実例として差分を確認してください。

## 既知の制限

- 全ての論文誌種別オプション（`ACS`/`PRO`/`TOD`/`TOM`/`CDS`/`DC`/`DCON`/`CVA`/`TBIO`/`SLDM`/`TCE`）のヘッダ文字列・DOI表記・年度算出式は移植していますが、個別に組版確認をしたのは `techrep` と `JIP` のみです。
- `\newtheorem` のIPSJ向けカスタマイズ、`quote`/`quotation`/`verse` のインデント調整、`recommendation` 環境は移植していません（標準LaTeXの動作になります）。
- `\Enumerate` 系の大文字環境は、旧クラスが持っていた専用のインデント幅調整を省略し、標準の `enumerate`/`itemize`/`description` の別名として実装しています。

詳細な技術的決定の根拠・移植作業の詳細は [CLAUDE.md](CLAUDE.md) を参照してください。
