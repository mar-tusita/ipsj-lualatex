%%
%% ipsj-lualatex.cls
%%
%% IPSJ (情報処理学会) manuscript class, rewritten from scratch for LuaLaTeX.
%%
%% This class consolidates the functionality formerly spread across
%% ipsj.cls / ipsjpref.sty / ipsjtech.sty (which target pLaTeX/upLaTeX)
%% into a single, self-contained class for current LuaLaTeX only.
%% No pLaTeX/upLaTeX/XeLaTeX compatibility is provided or intended.
%%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ipsj-lualatex}[2026/06/20 v1.0 IPSJ class for LuaLaTeX]

\RequirePackage{iftex}
\RequireLuaTeX

%% =================================================================
%% 1. Class options
%% =================================================================

%% 1.1 Options forwarded verbatim to the article base class.
\DeclareOption{oneside}{\PassOptionsToClass{oneside}{article}}
\DeclareOption{twoside}{\PassOptionsToClass{twoside}{article}}
\DeclareOption{onecolumn}{\PassOptionsToClass{onecolumn}{article}}
\DeclareOption{twocolumn}{\PassOptionsToClass{twocolumn}{article}}
\DeclareOption{leqno}{\PassOptionsToClass{leqno}{article}}
\DeclareOption{fleqn}{\PassOptionsToClass{fleqn}{article}}
\DeclareOption{openbib}{\PassOptionsToClass{openbib}{article}}
\DeclareOption{draft}{\PassOptionsToClass{draft}{article}}
\DeclareOption{final}{\PassOptionsToClass{final}{article}}
\DeclareOption{10pt}{\PassOptionsToClass{10pt}{article}}
\DeclareOption{11pt}{\PassOptionsToClass{11pt}{article}}
\DeclareOption{12pt}{\PassOptionsToClass{12pt}{article}}

%% NOTE: IPSJ manuscripts are always typeset on A4 paper -- the original
%% ipsj.cls accepted a4paper/a5paper/b4paper/b5paper(/j/p) options, but its
%% page-geometry code unconditionally hard-codes A4 at the end of the file
%% regardless of which size was selected, so those options never actually
%% had any effect.  They are intentionally not reproduced here.

%% 1.2 Language / submission-mode switches.
\newif\ifDS@english  \DS@englishfalse
\DeclareOption{english}{\DS@englishtrue}
\newif\ifDS@submit   \DS@submitfalse
\DeclareOption{submit}{\DS@submittrue}
\newif\ifDS@noauthor \DS@noauthorfalse
\DeclareOption{noauthor}{\DS@noauthortrue}
\newif\ifDS@techrep  \DS@techrepfalse
\DeclareOption{techrep}{\DS@techreptrue}
\newif\ifDS@preface  \DS@prefacefalse
\DeclareOption{preface}{\DS@prefacetrue}
\newif\ifDS@preprint \DS@preprintfalse
\DeclareOption{preprint}{\DS@preprinttrue\DS@englishtrue}

%% 1.3 Printing-related switches.
\newif\ifDS@tate   \DS@tatefalse
\DeclareOption{tate}{\DS@tatetrue}
\newif\ifDS@tombow \DS@tombowfalse
\DeclareOption{tombow}{\DS@tombowtrue}
\newif\ifDS@proof  \DS@prooffalse
\DeclareOption{proof}{\DS@prooftrue}

%% 1.4 Journal designation (mutually exclusive; default is the plain
%%     Transactions/"DAM" submission carried in \@iptype).
\def\@iptype{DAM}
\newif\ifDS@PRO  \DS@PROfalse
\newif\ifDS@ACS  \DS@ACSfalse
\newif\ifDS@TOD  \DS@TODfalse
\newif\ifDS@TOM  \DS@TOMfalse
\newif\ifDS@CDS  \DS@CDSfalse
\newif\ifDS@DC   \DS@DCfalse
\newif\ifDS@DCON \DS@DCONfalse
\newif\ifDS@CVA  \DS@CVAfalse
\newif\ifDS@TBIO \DS@TBIOfalse
\newif\ifDS@SLDM \DS@SLDMfalse
\newif\ifDS@JIP  \DS@JIPfalse
\newif\ifDS@TCE  \DS@TCEfalse
\DeclareOption{PRO}{\DS@PROtrue\def\@iptype{PRO}}
\DeclareOption{ACS}{\DS@ACStrue\def\@iptype{ACS}}
\DeclareOption{TOD}{\DS@TODtrue\def\@iptype{TOD}}
\DeclareOption{TOM}{\DS@TOMtrue\def\@iptype{TOM}}
\DeclareOption{CDS}{\DS@CDStrue\def\@iptype{CDS}}
\DeclareOption{DC}{\DS@DCtrue\def\@iptype{DC}}
\DeclareOption{DCON}{\DS@DCONtrue\def\@iptype{DCON}}
\DeclareOption{CVA}{\DS@CVAtrue\DS@englishtrue\def\@iptype{CVA}}
\DeclareOption{TBIO}{\DS@TBIOtrue\DS@englishtrue\def\@iptype{TBIO}}
\DeclareOption{SLDM}{\DS@SLDMtrue\DS@englishtrue\def\@iptype{SLDM}}
\DeclareOption{JIP}{\DS@JIPtrue\DS@englishtrue\def\@iptype{JIP}}
\DeclareOption{TCE}{\DS@TCEtrue\def\@iptype{TCE}}

%% 1.5 Paper category (\@ipMtype selects the printed category label and,
%%     for technical reports, the section banner text).
\def\@ipMtype{DAM}
\DeclareOption{technote}{\def\@ipMtype{technote}}
\DeclareOption{sigrecommended}{\def\@ipMtype{sigrecommended}}
\DeclareOption{invited}{\def\@ipMtype{invited}}
\DeclareOption{Data}{\def\@ipMtype{Data}}
\DeclareOption{Survey}{\def\@ipMtype{Survey}}
\newif\ifDS@Research \DS@Researchfalse
\DeclareOption{Research}{\DS@Researchtrue\def\@ipMtype{Research}}
\DeclareOption{Short}{\def\@ipMtype{Short}}
\DeclareOption{systems}{\def\@ipMtype{systems}}
\DeclareOption{services}{\def\@ipMtype{services}}
\DeclareOption{devices}{\def\@ipMtype{devices}}
\newif\ifDS@Practice \DS@Practicefalse
\DeclareOption{Express}{\def\@ipMtype{Express}}
\DeclareOption{Practice}{\DS@Practicetrue\def\@ipMtype{Practice}}
\newif\ifDS@Content \DS@Contentfalse
\DeclareOption{Content}{\DS@Contenttrue\def\@ipMtype{Content}}
\DeclareOption{system}{\def\@ipMtype{system}}
\newif\ifDS@abstract \DS@abstractfalse
\DeclareOption{abstract}{\DS@abstracttrue\def\@ipMtype{abstract}}
\DeclareOption{invitedshort}{\def\@ipMtype{invitedshort}}
\DeclareOption{recommendedshort}{\def\@ipMtype{recommendedshort}}
\DeclareOption{recommendedresearch}{\def\@ipMtype{recommendedresearch}}
\newif\ifDS@recommendedpractice \DS@recommendedpracticefalse
\DeclareOption{recommendedpractice}{\DS@recommendedpracticetrue\def\@ipMtype{recommendedpractice}}
\newif\ifDS@recommendedcontent \DS@recommendedcontentfalse
\DeclareOption{recommendedcontent}{\DS@recommendedcontenttrue\def\@ipMtype{recommendedcontent}}
\DeclareOption{recommendeddevices}{\def\@ipMtype{recommendeddevices}}

\ExecuteOptions{twoside,twocolumn,final}
\ProcessOptions\relax
\LoadClass{article}

%% =================================================================
%% 2. Engine setup: LuaTeX-ja and fonts
%% =================================================================

\RequirePackage{luatexja}
\RequirePackage{luatexja-fontspec}
%% \tate / \yoko (vertical <-> horizontal writing mode) are provided by
%% the core luatexja package already loaded above; no separate add-on
%% package is needed.

\setmainfont{TeX Gyre Termes}
\setsansfont{TeX Gyre Heros}
\setmainjfont{Harano Aji Mincho}
\setsansjfont{Harano Aji Gothic}
\renewcommand{\kanjifamilydefault}{\mcdefault}

\ifDS@tate
  \AtBeginDocument{\tate}
\fi

%% =================================================================
%% 3. Custom dimensions (Q/JQ/H units, character-grid units)
%% =================================================================

%% \Q, \JQ and \h reproduce the original class's literal point values;
%% these are plain TeX dimensions and need no engine-specific handling.
\newdimen\Q   \Q=0.71144pt
\newdimen\JQ  \JQ=0.7392507pt
\newdimen\h   \h=0.25mm

%% \zw/\zh (full-width quad / height of the current Japanese font) are
%% already provided as dynamic internal dimensions by luatexja-core.
%% In English mode there is no meaningful Japanese quad, so both are
%% redefined to expand to the text "em", which lets "1\zw" parse as
%% the native TeX unit "1em" instead (matching the original class).
\ifDS@english
  \def\zw{em}
  \def\zh{em}
\fi

%% \Cwd/\Cht/\Cdp/\Cvs: width/height/depth/baselineskip of one full-width
%% Japanese character at \normalsize, used throughout as grid units for
%% margins, captions, lists, etc.  In English mode the original class
%% used fixed, hand-measured constants instead of a glyph box; we do
%% the same.
\newdimen\Cwd \newdimen\Cht \newdimen\Cdp \newdimen\Cvs
\ifDS@english
  \Cht=7.19269pt \Cdp=1.28441pt \Cwd=8.9005pt \Cvs=12.80592pt
\fi

%% =================================================================
%% 4. Font size scale (normalsize: 13Q x 21H Japanese / 13Q x 18H Eng.)
%% =================================================================

\renewcommand{\normalsize}{%
  \ifDS@english
    \@setfontsize\normalsize{9.25pt}{12.80592pt}%
  \else
    \@setfontsize\normalsize{13\JQ}{21\h}%
  \fi
  \abovedisplayskip 9\p@ \@plus 3\p@ \@minus 4\p@
  \abovedisplayshortskip \z@ \@plus 2.5\p@
  \belowdisplayshortskip 5\p@ \@plus 2\p@ \@minus 2\p@
  \belowdisplayskip \abovedisplayskip
  \let\@listi\@listI}

\renewcommand{\small}{%
  \ifDS@english
    \@setfontsize\small{8.53728pt}{9.960159pt}%
  \else
    \@setfontsize\small{12\JQ}{20\h}%
  \fi
  \abovedisplayskip 6\p@ \@plus2\p@ \@minus4\p@
  \abovedisplayshortskip \z@ \@plus\p@
  \belowdisplayshortskip 3\p@ \@plus\p@ \@minus2\p@
  \def\@listi{\leftmargin\leftmargini
              \topsep 3\p@ \@plus \p@ \@minus \p@
              \parsep 1\p@ \@plus \p@ \@minus \p@
              \itemsep \parsep}%
  \belowdisplayskip \abovedisplayskip}

\renewcommand{\footnotesize}{%
  \ifDS@english
    \@setfontsize\footnotesize{7.82584pt}{9.24872pt}%
  \else
    \@setfontsize\footnotesize{11\JQ}{18\h}%
  \fi
  \abovedisplayskip 5\p@ \@plus 1.5\p@ \@minus 3\p@
  \abovedisplayshortskip \z@ \@plus\p@
  \belowdisplayshortskip 2.5\p@ \@plus \p@ \@minus 1.5\p@
  \def\@listi{\leftmargin\leftmargini
              \topsep 2\p@ \@plus\p@ \@minus\p@
              \parsep 1\p@ \@plus\p@ \@minus\p@
              \itemsep \parsep}%
  \belowdisplayskip \abovedisplayskip}

\ifDS@english
  \renewcommand{\scriptsize}{\@setfontsize\scriptsize{10\Q}{12\h}}
\else
  \renewcommand{\scriptsize}{\@setfontsize\scriptsize{10\JQ}{16\h}}
\fi
\renewcommand{\tiny}{\@setfontsize\tiny\@vpt\@vipt}
\renewcommand{\large}{\@setfontsize\large\@xpt{22\JQ}}
\renewcommand{\Large}{\@setfontsize\Large\@xipt{27\JQ}}
\renewcommand{\LARGE}{\@setfontsize\LARGE\@xiipt{33\JQ}}
\renewcommand{\huge}{\@setfontsize\huge\@xivpt{25pt}}
\renewcommand{\Huge}{\@setfontsize\Huge\@xviipt{30pt}}
\normalsize

%% Measure the character-grid units now that fonts and \normalsize exist.
\ifDS@english\else
  \begingroup
    \mcfamily\normalfont\normalsize\selectfont
    \setbox0\hbox{全}%
    \global\Cwd=\wd0 \global\Cht=\ht0 \global\Cdp=\dp0
    \global\Cvs=\baselineskip
  \endgroup
\fi

\setlength\floatsep    {1\Cvs \@plus .75\Cvs \@minus .25\Cvs}
\setlength\textfloatsep{1\Cvs \@plus .75\Cvs \@minus .25\Cvs}
\setlength\intextsep   {1\Cvs \@plus .75\Cvs \@minus .25\Cvs}
\setlength\dblfloatsep    {12\p@ \@plus 2\p@ \@minus 2\p@}
\setlength\dbltextfloatsep{20\p@ \@plus 2\p@ \@minus 4\p@}

\def\topfraction{1}
\def\bottomfraction{1}
\def\textfraction{0}
\def\floatpagefraction{0}
\def\dbltopfraction{1}
\def\dblfloatpagefraction{0}

\setlength\lineskip{1\p@}
\setlength\normallineskip{1\p@}
\renewcommand{\baselinestretch}{}
\setlength\parskip{\z@}
\ifDS@english
  \setlength\parindent{1em}
\else
  \setlength\parindent{1\zw}
\fi
\setlength\leftmargini{2\Cwd}
\setlength\marginparsep{5mm}
\setlength\marginparpush{5\p@}

%% =================================================================
%% 5. Page geometry
%% =================================================================
%% IPSJ manuscripts are always A4, two columns; the original class
%% hard-codes this regardless of any paper-size option, and so do we.

\setlength\paperwidth{210mm}
\setlength\paperheight{297mm}
\setlength\headheight{5mm}
\setlength\headsep{9.5mm}
\setlength\footskip{11.7mm}
\setlength\textwidth{177mm}
\@settopoint\textwidth

\ifDS@english
  \setlength\textheight{55\Cvs}
\else
  \setlength\textheight{47\Cvs}
\fi
\addtolength\textheight{\topskip}
\addtolength\textheight{.4mm}
\@settopoint\textheight

\@tempdima=\paperwidth
\addtolength\@tempdima{-\textwidth}
\@tempdima=.5\@tempdima
\addtolength\@tempdima{-1in}
\setlength\oddsidemargin{\@tempdima}
\setlength\evensidemargin{\@tempdima}
\setlength\topmargin{-17mm}
\setlength\columnsep{8mm}

\setlength\maxdepth{.5\topskip}
\setlength\marginparwidth{48\p@}
\flushbottom
\sloppy

%% The LaTeX kernel derives the PDF media box from \paperwidth/\paperheight
%% automatically under LuaLaTeX; no separate driver call is needed here.

\setlength\arraycolsep{5pt}
\setlength\tabcolsep{6pt}
\setlength\arrayrulewidth{.4pt}
\setlength\doublerulesep{1pt}
\setlength\fboxsep{3pt}
\setlength\fboxrule{.4pt}
\skip\@mpfootins=\skip\footins

\def\onelineskip{\par\vspace{1\baselineskip}\par}
\def\halflineskip{\par\vspace{.5\baselineskip}\par}

%% kintou: justify text #2 to width #1 using inter-character glue only
%% (used for centering short headings such as the appendix banner).
\def\kintou#1#2{%
  \ifDS@english\relax\else
    \leavevmode\hbox to #1{\hskip0pt plus 1fill minus 1fill\relax#2\hskip0pt plus 1fill minus 1fill\relax}%
  \fi}

%% =================================================================
%% 6. Volume / number / year / month plumbing
%% =================================================================

\newcounter{volume} \setcounter{volume}{0}
\newcounter{number} \setcounter{number}{0}
\newcounter{month}  \setcounter{month}{-1}
\newcounter{year}   \setcounter{year}{-1}

\def\ipsj@year{%
  \ifnum\c@year<0
    \@tempcnta\c@volume
    \ifDS@JIP \advance\@tempcnta 1991
    \else\ifDS@ACS \advance\@tempcnta 2006
    \else\ifDS@PRO \advance\@tempcnta 2006
    \else\ifDS@TOD \advance\@tempcnta 2006
    \else\ifDS@TOM \advance\@tempcnta 2006
    \else\ifDS@TBIO \advance\@tempcnta 2006
    \else\ifDS@SLDM \advance\@tempcnta 2006
    \else\ifDS@CVA \advance\@tempcnta 2007
    \else\ifDS@CDS \advance\@tempcnta 2009
    \else\ifDS@DC \advance\@tempcnta 2011
    \else\ifDS@DCON \advance\@tempcnta 2011
    \else\ifDS@TCE \advance\@tempcnta 2013
    \else \advance\@tempcnta 1959
    \fi\fi\fi\fi\fi\fi\fi\fi\fi\fi\fi\fi
    \number\@tempcnta
  \else
    \number\c@year
  \fi}

\def\ipsj@month{%
  \ifcase\c@month
    \or Jan.\or Feb.\or Mar.\or Apr.\or May\or June%
    \or July\or Aug.\or Sep.\or Oct.\or Nov.\or Dec.%
  \else ---\fi}

\def\@monthyear{\ipsj@month\hskip.5\Cwd\ipsj@year}
\def\@footyear{\ipsj@year}

\AtBeginDocument{\label{ipsj@firstpage}}
\AtEndDocument{%
  \clearpage
  \addtocounter{page}{-1}%
  \immediate\write\@auxout{\string\newlabel{ipsj@lastpage}{{}{\thepage}}}%
}

%% =================================================================
%% 7. Per-journal-type strings (running head, category label, DOI)
%% =================================================================

\def\SIGHead{\ifDS@english IPSJ Transactions on\else 情報処理学会論文誌\fi}
\ifDS@english
  \newcommand{\COMS}{Consumer Devices \& Systems}
  \newcommand{\COMSYS}{Paper on Consumer Systems}
  \newcommand{\COMSER}{Paper on Consumer Services}
  \newcommand{\COMSDV}{Paper on Consumer Devices}
  \newcommand{\RECCOMSDV}{Paper on Consumer Devices}
  \newcommand{\COMSAN}{Practice Paper}
  \newcommand{\COMCON}{Content Paper}
\else
  \newcommand{\COMS}{コンシューマ・デバイス\,\&\,システム}
  \newcommand{\COMSYS}{コンシューマ・システム論文}
  \newcommand{\COMSER}{コンシューマ・サービス論文}
  \newcommand{\COMSDV}{コンシューマ・デバイス論文}
  \newcommand{\RECCOMSDV}{推薦コンシューマ・デバイス論文}
  \newcommand{\COMSAN}{産業論文}
  \newcommand{\COMCON}{作品論文}
\fi

\def\ipsj@signame@DAM{\ifDS@english
  Electronic Preprint for Journal of Information Processing%
  \else 情報処理学会論文誌\fi}
\def\ipsj@signame@ACS{\ifDS@english{\SIGHead} Advanced Computing Systems%
  \else{\SIGHead}\hskip12\JQ コンピューティングシステム\fi}
\def\ipsj@signame@PRO{\ifDS@english{\SIGHead} Programming%
  \else{\SIGHead}\hskip12\JQ プログラミング\fi}
\def\ipsj@signame@TOM{\ifDS@english{\SIGHead} Mathematical Modeling and Its Applications%
  \else{\SIGHead}\hskip12\JQ 数理モデル化と応用\fi}
\def\ipsj@signame@TOD{\ifDS@english{\SIGHead} Databases%
  \else{\SIGHead}\hskip12\JQ データベース\fi}
\def\ipsj@signame@CDS{\ifDS@english{\SIGHead} Consumer Devices \& Systems%
  \else{\SIGHead}\hskip12\JQ \COMS\fi}
\def\ipsj@signame@DC{\ifDS@english{\SIGHead} Digital Content%
  \else{\SIGHead}\hskip12\JQ デジタルコンテンツ\fi}
\def\ipsj@signame@DCON{\ifDS@english{\SIGHead} Digital Content%
  \else{\SIGHead}\hskip12\JQ デジタルコンテンツ\fi}
\def\ipsj@signame@CVA{{\SIGHead} Computer Vision and Applications}
\def\ipsj@signame@TBIO{{\SIGHead} Bioinformatics}
\def\ipsj@signame@SLDM{{\SIGHead} System LSI Design Methodology}
\def\ipsj@signame@JIP{Journal of Information Processing}
\def\ipsj@signame@TCE{\ifDS@english{\SIGHead} Computers and Education%
  \else{\SIGHead}\hskip12\JQ 教育とコンピュータ\fi}
\def\signame{\csname ipsj@signame@\@iptype\endcsname}

%% DOI prefixes are only assigned for the four journals that carried
%% them in the original class.
\def\ipsj@doi@TBIO{ipsjtbio}
\def\ipsj@doi@CVA{ipsjtcva}
\def\ipsj@doi@SLDM{ipsjtsldm}
\def\ipsj@doi@JIP{ipsjjip}
\def\ipsj@doi{%
  \@ifundefined{ipsj@doi@\@iptype}{}{%
    [DOI: 10.2197/\csname ipsj@doi@\@iptype\endcsname.\number\c@volume.\pageref{ipsj@firstpage}]}}

\def\ipsj@shubetu@DAM{\ifDS@english Regular Paper%
  \else\ifDS@TCE 論\hskip1\zw 文\fi\leavevmode\fi}
\def\ipsj@shubetu@invited{\ifDS@english Invited Paper\else 招待論文\fi}
\def\ipsj@shubetu@sigrecommended{\ifDS@english Recommended Paper%
  \else\ifDS@TCE 研究会\fi 推薦論文\fi}
\def\ipsj@shubetu@invitedshort{\ifDS@english Invited Short Paper\else 招待ショートペーパー\fi}
\def\ipsj@shubetu@recommendedshort{\ifDS@english Recommended Short Paper\else 研究会推薦ショートペーパー\fi}
\def\ipsj@shubetu@technote{\ifDS@english Technical Note\else テクニカルノート\fi}
\def\ipsj@shubetu@recommendedresearch{\ifDS@english Recommended Research Paper\else 推薦研究論文\fi}
\def\ipsj@shubetu@recommendedpractice{\ifDS@english Recommended Practice Paper\else 推薦産業論文\fi}
\def\ipsj@shubetu@recommendedcontent{\ifDS@english Recommended Content Paper\else 推薦作品論文\fi}
\def\ipsj@shubetu@abstract{\ifDS@english Presentation Abstract\else 発表概要\fi}
\def\ipsj@shubetu@Eabstract{Presentation Abstract}
\def\ipsj@shubetu@systems{\ifDS@english\ifDS@JIP Paper (Consumer Systems)\else Paper on Consumer Systems\fi\else\COMSYS\fi}
\def\ipsj@shubetu@services{\ifDS@english\ifDS@JIP Paper (Consumer Services)\else Paper on Consumer Services\fi\else\COMSER\fi}
\def\ipsj@shubetu@devices{\ifDS@english\ifDS@JIP Paper (Consumer Devices)\else Paper on Consumer Devices\fi\else\COMSDV\fi}
\def\ipsj@shubetu@Research{\ifDS@english\ifDS@JIP Regular Paper\else Research Paper\fi\else 研究論文\fi}
\def\ipsj@shubetu@Data{Database/Software Paper}
\def\ipsj@shubetu@Survey{Survey Paper}
\def\ipsj@shubetu@TBIOM{Original Paper}
\def\ipsj@shubetu@Short{\ifDS@english Short Paper\else ショートペーパー\fi}
\def\ipsj@shubetu@system{Systems Paper}
\def\ipsj@shubetu@Express{Express Paper}
\def\ipsj@shubetu@recommendeddevices{\ifDS@english\ifDS@JIP Paper (Consumer Devices)\else Paper on Consumer Devices\fi\else\RECCOMSDV\fi}
\def\ipsj@shubetu@Practice{\ifDS@english\ifDS@JIP Regular Paper\else Practice Paper\fi\else\COMSAN\fi}
\def\ipsj@shubetu@Content{\ifDS@english\ifDS@JIP Regular Paper\else Content Paper\fi\else\COMCON\fi}
\def\SHUBETUname{\csname ipsj@shubetu@\@ipMtype\endcsname}

%% =================================================================
%% 8. Title-page typography
%% =================================================================

\def\HeadfontE{\ifDS@english
    \fontsize{13\Q}{0\h}\sffamily\bfseries\selectfont%
  \else
    \fontsize{13\Q}{0\h}\sffamily\bfseries\selectfont%
  \fi}
\def\HeadfontJ{\fontsize{12\JQ}{0\h}\gtfamily\bfseries\selectfont}
\def\DOIHeadfont{\fontsize{11\Q}{0\h}\sffamily\selectfont}

\def\SHUBETUfontE{\fontsize{18\Q}{0\h}\bfseries\selectfont}
\def\SHUBETUfontJ{\fontsize{18\JQ}{0\h}\gtfamily\mdseries\selectfont}

\def\bothashira{\fontsize{10\Q}{0\h}\normalfont\selectfont}
\def\botnomble{\fontsize{13\Q}{0\h}\normalfont\selectfont}

\def\jtitlefont{\fontsize{26\JQ}{34\h}\gtfamily\bfseries\mathversion{bold}\selectfont}
\def\juketukefont{\fontsize{10\JQ}{12\h}\normalfont\selectfont}
\def\etitlefont{\fontsize{20\Q}{22\h}\mathversion{bold}\selectfont}
\def\euketukefont{\fontsize{10\JQ}{12\h}\normalfont\selectfont}
\def\labelfont{\rmfamily\selectfont}
\def\authorfont{\fontsize{16\JQ}{22\h}\selectfont}
\def\eauthorfont{\fontsize{14\JQ}{18\h}\scshape\selectfont}
\def\Engeauthorfont{\fontsize{17\JQ}{22\h}\scshape\selectfont}
\def\elabelfont{\normalfont}
\def\Engtitlefont{\fontsize{28\Q}{34\h}\bfseries\mathversion{bold}\selectfont}
\def\Enguketukefont{\fontsize{10\JQ}{12\h}\sffamily\selectfont}

%% Title-block separations (techrep/default mode); the techrep skip
%% lengths are slightly tighter, matching ipsjtech.sty's own values.
\newskip\shubetutitlesep \shubetutitlesep=6.2mm
\newskip\JEhonbunsep     \JEhonbunsep=13.7mm
\newskip\Etitleauthorsep \Etitleauthorsep=10mm
\newskip\Eauthorreceivesep \Eauthorreceivesep=5.5mm
\newskip\Ereceiveabstsep \Ereceiveabstsep=2.5mm
\newskip\Eabstkeywordsep \Eabstkeywordsep=4mm
\newskip\Jtitlejauthorsep \Jtitlejauthorsep=9mm
\newskip\Jauthorjreceivesep \Jauthorjreceivesep=6.5mm
\newskip\Jreceivejabstsep \Jreceivejabstsep=2.5mm
\newskip\Jabstsepjkeyword \Jabstsepjkeyword=5.5mm
\newskip\Jkeywordetitle \Jkeywordetitle=14.2mm
\newskip\Jetitleeauthor \Jetitleeauthor=5.5mm
\newskip\Jeauthorereceivesep \Jeauthorereceivesep=5.5mm
\newskip\Jereceiveeabstsep \Jereceiveeabstsep=1.5mm
\newskip\Jeabstekeywordsep \Jeabstekeywordsep=5mm

%% =================================================================
%% 9. \author, \affiliate, \etitle and the byline machinery
%% =================================================================
%% \title (storing into \@title) is provided by the LaTeX kernel itself
%% and is reused as-is.

\newif\if@ET
\def\etitle#1{\global\@ETtrue\gdef\@etitle{#1}}
\def\@etitle{}

\newcount\author@count
\newcount\label@count
\newcount\email@count
\newcount\affiliate@count
\newcount\offsetemail
\newcount\paffiliate@count

\ifDS@english
  \def\author#1#2{\@ifnextchar[{\@author{#1}{#1}}{\@author{#1}{#1}[]}}
\else
  \def\author#1#2#3{\@ifnextchar[{\@author{#1}{#2}{#3}}{\@author{#1}{#2}{#3}[]}}
\fi

%% \zap@space (comma-list space stripper) is provided by the LaTeX kernel.

\ifDS@english
\def\@author#1#2[#3]{%
  \advance\author@count\@ne
  \expandafter\def\csname authorname\the\author@count\endcsname{#2}
  \edef\@labellist{\zap@space#1 \@empty}
  \@for\@temp:=\@labellist\do{%
    \advance\label@count\@ne
    \expandafter\edef\csname authorlabel\the\author@count @\the\label@count\endcsname{\@temp}}%
  \expandafter\edef\csname authorlabel@num@\the\author@count\endcsname{\the\label@count}
  \label@count\z@
  \edef\@emaillist{\zap@space#3 \@empty}
  \@for\@temp:=\@emaillist\do{%
    \advance\email@count\@ne
    \expandafter\edef\csname authoremail\the\author@count @\the\email@count\endcsname{\@temp}}%
  \expandafter\edef\csname authoremail@num@\the\author@count\endcsname{\the\email@count}
  \email@count\z@
}
\else
\def\@author#1#2#3[#4]{%
  \advance\author@count\@ne
  \expandafter\def\csname authorname\the\author@count\endcsname{#1}
  \expandafter\def\csname eauthorname\the\author@count\endcsname{#2}
  \edef\@labellist{\zap@space#3 \@empty}
  \@for\@temp:=\@labellist\do{%
    \advance\label@count\@ne
    \expandafter\edef\csname authorlabel\the\author@count @\the\label@count\endcsname{\@temp}}%
  \expandafter\edef\csname authorlabel@num@\the\author@count\endcsname{\the\label@count}
  \label@count\z@
  \edef\@emaillist{\zap@space#4 \@empty}
  \@for\@temp:=\@emaillist\do{%
    \advance\email@count\@ne
    \expandafter\edef\csname authoremail\the\author@count @\the\email@count\endcsname{\@temp}}%
  \expandafter\edef\csname authoremail@num@\the\author@count\endcsname{\the\email@count}
  \email@count\z@
}
\fi

\def\affiliate#1#2{%
  \advance\affiliate@count\@ne
  \expandafter\edef\csname affiliate@num@#1\endcsname{\the\affiliate@count}%
  \expandafter\def\csname affiliate@\the\affiliate@count\endcsname{#2}}

\def\paffiliate#1#2{%
  \advance\paffiliate@count\@ne
  \expandafter\edef\csname paffiliate@num@#1\endcsname{$\dagger$\the\paffiliate@count}%
  \expandafter\def\csname paffiliate@\the\paffiliate@count\endcsname{#2}}

\let\@BreakAuthor@N\relax
\def\breakauthorline#1{\expandafter\def\csname breakauthor@\the\numexpr#1\endcsname{\\}}
\def\breakeauthorline#1{\expandafter\def\csname breakeauthor@\the\numexpr#1\endcsname{\\}}
\def\break@or@oneskip{%
  \@ifundefined{breakauthor@\the\count@}{\hskip1\zw}{\csname breakauthor@\the\count@\endcsname}}
\def\ebreak@or@oneskip{%
  \@ifundefined{breakeauthor@\the\count@}{\hskip1em}{\csname breakeauthor@\the\count@\endcsname}}
%% Both loops bound \@tempcntb by \@tempcnta = (item count + 1), so a
%% trailing separator is needed exactly when the NEXT index is still
%% inside that range, i.e. \@tempcntb+1 < \@tempcnta.
\def\comma@or@relax@affilabel{%
  \ifnum\numexpr\@tempcntb+1\relax<\@tempcnta ,\fi}
\def\comma@or@relax@email{%
  \ifnum\numexpr\@tempcntb+1\relax<\@tempcnta ,\fi}

\def\authoroutput#1{%
  \bgroup
  \offsetemail\z@
  \count@\@ne
  \advance\author@count\@ne
  \@whilenum{\count@<\author@count}\do{%
    \mbox{%
      \ifDS@english
        \csname authorname\the\count@\endcsname
      \else
        \csname #1authorname\the\count@\endcsname
      \fi
      \null{}%
      \expandafter\@tempcnta\csname authorlabel@num@\the\count@\endcsname
      \advance\@tempcnta\@ne
      \@tempcntb\@ne
      {\@whilenum{\@tempcntb<\@tempcnta}\do{%
        \edef\temp{\csname authorlabel\the\count@ @\the\@tempcntb\endcsname}%
        \textsuperscript{\csname #1labelfont\endcsname
          \expandafter\ifx\csname affiliate@num@\temp\endcsname\relax
            \csname paffiliate@num@\temp\endcsname
          \else
            \csname affiliate@num@\temp\endcsname
          \fi
          \comma@or@relax@affilabel}%
        \advance\@tempcntb\@ne}}%
      \expandafter\@tempcnta\csname authoremail@num@\the\count@\endcsname
      \ifnum\@tempcnta=\z@\relax\else\textsuperscript{,}\fi
      \advance\@tempcnta\@ne
      \@tempcntb\@ne
      \@whilenum{\@tempcntb<\@tempcnta}\do{%
        \bgroup
        \advance\@tempcntb\offsetemail
        \textsuperscript{\csname #1labelfont\endcsname\@alph{\@tempcntb})\comma@or@relax@email}%
        \egroup
        \advance\@tempcntb\@ne}%
      \advance\@tempcntb-1\relax
      \global\advance\offsetemail\@tempcntb
    }%
    \ifDS@english\ebreak@or@oneskip\else\csname #1break@or@oneskip\endcsname\fi
    \advance\count@\@ne}%
  \egroup}

%% =================================================================
%% 10. Abstract / keyword boxes
%% =================================================================

\def\GAIYOU{\ifDS@abstract{\hskip1\zw}\else\textbf{概要}：\fi}
\def\EGAIYOU{\itshape\bfseries\sffamily Abstract:\hskip.5em}
\def\JKEYWORD{\textbf{キーワード}：}
\def\EKEYWORD{\itshape\bfseries\sffamily Keywords:\hskip.5em}

\newbox\@abstractbox  \newbox\@eabstractbox
\newbox\@jkeywordbox  \newbox\@ekeywordbox \newbox\@keywordbox

\ifDS@english
\def\abstract{\global\setbox\@abstractbox\hbox\bgroup
  \begin{minipage}[t]{.8\textwidth}\fontsize{12\Q}{14\h}\selectfont
  \noindent{\EGAIYOU}\ignorespaces}
\else
\def\abstract{\global\setbox\@abstractbox\hbox\bgroup
  \begin{minipage}[t]{.8\textwidth}\fontsize{12\JQ}{18\h}\selectfont
  \noindent{\GAIYOU}\ignorespaces}
\fi
\def\endabstract{\par\end{minipage}\egroup\ignorespaces}

\newif\if@EAB
\def\eabstract{\global\@EABtrue\global\setbox\@eabstractbox\hbox\bgroup
  \begin{minipage}[t]{.8\textwidth}\fontsize{12\Q}{15\h}\selectfont
  \noindent{\EGAIYOU}\ignorespaces}
\def\endeabstract{\par\end{minipage}\egroup\ignorespaces}

\newif\if@JK
\def\jkeyword{\par
  \global\@JKtrue
  \global\setbox\@jkeywordbox\hbox\bgroup
  \begin{minipage}[t]{.8\textwidth}\fontsize{12\JQ}{15\h}\selectfont
  \noindent{\JKEYWORD}\ignorespaces}
\def\endjkeyword{\par\end{minipage}\egroup\ignorespaces}

\newif\if@EK
\def\ekeyword{\par
  \global\@EKtrue
  \global\setbox\@ekeywordbox\hbox\bgroup
  \begin{minipage}[t]{.8\textwidth}\fontsize{12\Q}{15\h}\selectfont
  \noindent{\EKEYWORD}\ignorespaces}
\def\endekeyword{\par\end{minipage}\egroup\ignorespaces}

\def\keyword{\par\global\setbox\@ekeywordbox\hbox\bgroup
  \begin{minipage}[t]{.8\textwidth}\fontsize{12\Q}{15\h}\selectfont
  \noindent{\EKEYWORD}\ignorespaces}
\def\endkeyword{\par\end{minipage}\egroup\ignorespaces}

%% =================================================================
%% 11. Received / accepted / presented date stamps
%% =================================================================

\def\TUKI#1{\ifcase#1 xx\or January\or February\or March\or April\or May%
  \or June\or July\or August\or September\or October\or November\or December\fi}

\ifDS@english
\def\received#1#2#3{\gdef\@received{Received: \TUKI{#2} #3, #1}}
\def\accepted#1#2#3{\gdef\@accepted{Accepted: \TUKI{#2} #3, #1}}
\def\rereceived#1#2#3{\gdef\@rereceived{, Revised: \TUKI{#2} #3, #1}}
\def\rerereceived#1#2#3{\gdef\@rerereceived{/\TUKI{#2} #3, #1,}}
\def\released#1#2#3{\gdef\@released{Released: \TUKI{#2} #3, #1}}
\def\Presented#1#2#3{\gdef\@Presented{Presented: \TUKI{#2} #3, #1}}
\else
\def\received#1#2#3{%
  \gdef\@received{受付日#1年#2月#3日}%
  \gdef\@ereceived{Received: \TUKI{#2} #3, #1}}
\def\accepted#1#2#3{%
  \gdef\@accepted{採録日#1年#2月#3日}%
  \gdef\@eaccepted{Accepted: \TUKI{#2} #3, #1}}
\def\rereceived#1#2#3{%
  \gdef\@rereceived{，再受付日#1年#2月#3日}%
  \gdef\@erereceived{, Revised: \TUKI{#2} #3, #1}}
\def\rerereceived#1#2#3{%
  \gdef\@rerereceived{\,/\,#1年#2月#3日，}%
  \gdef\@ererereceived{/\TUKI{#2} #3, #1,}}
\def\Presented#1#2#3{%
  \gdef\@Presented{#1年#2月#3日発表}%
  \gdef\@ePresented{Presented: \TUKI{#2} #3, #1}}
\fi
\def\@accepted{}
\received{xxxx}{0}{xx}
\accepted{xxxx}{0}{xx}
\Presented{xxxx}{0}{xx}
\ifDS@english\else
  \let\受付\received \let\採録\accepted
  \let\再受付\rereceived \let\再再受付\rerereceived
\fi

%% =================================================================
%% 12. \maketitle / \@maketitle / \authortitle
%% =================================================================

\def\maketitle{\par
  \begingroup
    \renewcommand{\thefootnote}{\fnsymbol{footnote}}%
    \if@twocolumn
      \ifnum\col@number=\@ne \@maketitle
      \else \twocolumn[\@maketitle]\fi
    \else
      \newpage
      \global\@topnum\z@
      \@maketitle
    \fi
    \thispagestyle{IPSJTITLEheadings}%
    \@thanks
  \endgroup
  \setcounter{footnote}{0}%
  \global\let\thanks\relax
  \global\let\maketitle\relax
  \global\let\@thanks\@empty
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\title\relax
  \global\let\@etitle\@empty
  \global\let\etitle\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
  %% affiliate footnotes
  \bgroup
  \setcounter{footnote}{0}
  \def\thefootnote{\@arabic{\c@footnote}\protect\hphantom{)}}
  \advance\affiliate@count\@ne
  \count@\@ne
  \@whilenum{\count@<\affiliate@count}\do{%
    \refstepcounter{footnote}
    \footnotetext{\csname affiliate@\the\count@\endcsname}%
    \advance\count@\@ne}
  \egroup
  %% paffiliate ("presently with") footnotes
  \bgroup
  \setcounter{footnote}{0}
  \def\thefootnote{$\dagger$\@arabic{\c@footnote}\protect\hphantom{)}}
  \advance\paffiliate@count\@ne
  \count@\@ne
  \@whilenum{\count@<\paffiliate@count}\do{%
    \refstepcounter{footnote}
    \ifDS@english
      \footnotetext{Presently with\ \csname paffiliate@\the\count@\endcsname}%
    \else
      \footnotetext{\def\\{\newline Presently with \ignorespaces}%
        現在，\csname paffiliate@\the\count@\endcsname}%
    \fi
    \advance\count@\@ne}
  \egroup
  %% email footnotes
  \bgroup
  \setcounter{footnote}{0}
  \def\thefootnote{\@alph{\c@footnote})}
  \count@\@ne
  \advance\author@count\@ne
  \@whilenum{\count@<\author@count}\do{%
    \expandafter\@tempcntb\csname authoremail@num@\the\count@\endcsname
    \advance\@tempcntb\@ne
    \@tempcnta\@ne
    \@whilenum{\@tempcnta<\@tempcntb}\do{%
      \refstepcounter{footnote}
      \footnotetext{\csname authoremail\the\count@ @\the\@tempcnta\endcsname}%
      \advance\@tempcnta\@ne}%
    \advance\count@\@ne}
  \egroup
  \setcounter{footnote}{0}}

\def\@maketitle{%
  \newpage\null
  \ifDS@english
    \vskip-1.3mm
    {\SHUBETUfontE{\SHUBETUname}}%
  \else
    {\SHUBETUfontJ{\SHUBETUname}}%
  \fi
  \vskip\shubetutitlesep
  \begin{center}
  \authortitle
  \end{center}}

\ifDS@english
\def\authortitle{%
  {\Engtitlefont{\@title}\par}%
  \vskip\Etitleauthorsep
  {\Engeauthorfont\authoroutput{e}\par}%
  \vskip\Eauthorreceivesep
  \mbox{\box\@abstractbox}\par
  \vskip\Eabstkeywordsep
  \mbox{\box\@ekeywordbox}\par
  \vskip\JEhonbunsep}
\else
\def\authortitle{%
  {\jtitlefont{\@title}\par}%
  \vskip\Jtitlejauthorsep
  {\authorfont\authoroutput{}\par}%
  \vskip\Jreceivejabstsep
  \mbox{\box\@abstractbox}\par
  \if@JK
    \vskip\Jabstsepjkeyword
    \mbox{\box\@jkeywordbox}\par
  \fi
  \if@ET
    \vskip\Jkeywordetitle
    {\etitlefont\bfseries{\@etitle}}\par
  \fi
  \ifDS@noauthor\else
    \vskip\Jetitleeauthor
    {\eauthorfont\authoroutput{e}\par}%
    \vskip\Jeauthorereceivesep
  \fi
  \if@EAB
    \vskip\Jereceiveeabstsep
    \mbox{\box\@eabstractbox}\par
  \fi
  \if@EK
    \vskip\Jeabstekeywordsep
    \mbox{\box\@ekeywordbox}\par
  \fi
  \vskip\JEhonbunsep}
\fi

%% --- preface mode overrides --------------------------------------
\ifDS@preface
\def\@maketitle{%
  \newpage\null
  \ifDS@english
    \vskip-1.3mm{\SHUBETUfontE{\SHUBETUname}}%
  \else
    {\SHUBETUfontJ{\SHUBETUname}}%
  \fi
  \vskip\shubetutitlesep
  \begin{center}\authortitle\end{center}}
\fi

%% --- techrep mode overrides (mirrors ipsjtech.sty) ----------------
\ifDS@techrep
\def\biography{\ipsjnobiography}
\def\endbiography{\ipsjendnobiography}
\def\ipsjnobiography{%
  \let\profile\@gobble
  \setbox0\vbox\bgroup
  \tolerance\@M \hbadness\@M \hfuzz\maxdimen}
\def\ipsjendnobiography{\egroup\setbox0\hbox{}}

\def\@uketsuke{\leavevmode
  \phantom{Received: x}%
  \phantom{Accepted: x}}

\def\@maketitle{%
  \newpage\null
  \ifDS@english
    \vskip-1.3mm\phantom{\SHUBETUfontE{\SHUBETUname}}%
  \else
    {\SHUBETUfontJ{\SHUBETUname}}%
  \fi
  \vskip\shubetutitlesep
  \begin{center}\authortitle\end{center}}

\ifDS@english
\def\authortitle{%
  {\Engtitlefont{\@title}\par}%
  \vskip\Etitleauthorsep
  {\Engeauthorfont\authoroutput{e}\par}%
  \vskip\Eauthorreceivesep
  {\Enguketukefont{\@uketsuke}\par}%
  \vskip\Ereceiveabstsep
  \mbox{\box\@abstractbox}\par
  \vskip\Eabstkeywordsep
  \mbox{\box\@ekeywordbox}\par
  \vskip\JEhonbunsep}
\else
\def\authortitle{%
  {\jtitlefont{\@title}\par}%
  \vskip\Jtitlejauthorsep
  {\authorfont\authoroutput{}\par}%
  \vskip\Jauthorjreceivesep
  {\juketukefont{\@uketsuke}\par}%
  \vskip\Jreceivejabstsep
  \mbox{\box\@abstractbox}\par
  \if@JK
    \vskip\Jabstsepjkeyword
    \mbox{\box\@jkeywordbox}\par
  \fi
  \if@ET
    \vskip\Jkeywordetitle
    {\etitlefont\bfseries{\@etitle}}\par
  \fi
  \ifDS@noauthor\else
    \vskip\Jetitleeauthor
    {\eauthorfont\authoroutput{e}\par}%
    \vskip\Jeauthorereceivesep
    {\euketukefont{\@euketsuke}\par}%
  \fi
  \if@EAB
    \vskip\Jereceiveeabstsep
    \mbox{\box\@eabstractbox}\par
  \fi
  \if@EK
    \vskip\Jeabstekeywordsep
    \mbox{\box\@ekeywordbox}\par
  \fi
  \vskip\JEhonbunsep}
\fi

\def\@euketsuke{\leavevmode\phantom{Received: x}\phantom{Accepted: x}}
\fi

%% =================================================================
%% 13. Headers and footers
%% =================================================================

\def\textcopyrighttx{\copyright}

\def\ps@plain{%
  \let\@mkboth\@gobbletwo
  \let\@oddhead\@empty
  \def\@oddfoot{\reset@font\hfil\thepage\hfil}%
  \let\@evenhead\@empty
  \let\@evenfoot\@oddfoot}

\def\@Rtop{\relax}\def\@Ltop{\relax}\def\@Rbot{\relax}\def\@Lbot{\relax}
\ifDS@proof
  \def\@Rtop{\rlap{\smash{\rule[-\headsep]{0.05mm}{10mm}%
    \rule[-\headsep]{10mm}{0.05mm}}}}
  \def\@Ltop{\llap{\smash{\rule[-\headsep]{10mm}{0.05mm}%
    \rule[-\headsep]{0.05mm}{10mm}}}}
  \def\@Rbot{\rlap{\smash{\raisebox{1\footskip}%
    {\rule[-10mm]{0.05mm}{10mm}\rule{10mm}{0.05mm}}}}}
  \def\@Lbot{\llap{\smash{\raisebox{1\footskip}%
    {\rule{10mm}{0.05mm}\rule[-10mm]{0.05mm}{10mm}}}}}
\fi

\def\ps@empty{%
  \def\@oddhead{\@Ltop\hfil\@Rtop}%
  \let\@evenhead\@oddhead
  \def\@oddfoot{\@Lbot\hfil\@Rbot}%
  \let\@evenfoot\@oddfoot
  \let\@mkboth\@gobbletwo}

%% --- Title-page pagestyle -----------------------------------------
\def\ps@IPSJTITLEheadings{%
  \def\@oddhead{\@Ltop\rlap{\small
    \ifDS@english{\HeadfontE{\signame}}\else{\HeadfontJ{\signame}}\fi
    \ifDS@english
      \hskip12\Q{\HeadfontE{Vol.\number\c@volume}}%
      \hskip1em{\HeadfontE{No.\number\c@number}}%
      \hskip12\Q{\HeadfontE{\pageref{ipsj@firstpage}--\pageref{ipsj@lastpage}}}\ %
      \HeadfontE{(\@monthyear)}%
    \else
      \hskip12\JQ{\HeadfontE{Vol.\number\c@volume}}%
      \hskip12\JQ{\HeadfontE{No.\number\c@number}}%
      \hskip12\JQ{\HeadfontE{\pageref{ipsj@firstpage}--\pageref{ipsj@lastpage}}}\ %
      \HeadfontE{(\@monthyear)}%
    \fi}%
    \smash{\raisebox{-6mm}{\rlap{\DOIHeadfont\ipsj@doi}}}%
    \hfil\@Rtop}%
  \let\@evenhead\@oddhead
  \def\@oddfoot{\@Lbot\rlap{\bothashira
      \copyright\ \@footyear\ Information Processing Society of Japan}%
    \hfil{\botnomble\thepage}\@Rbot}%
  \let\@evenfoot\@oddfoot
  \let\@mkboth\@gobbletwo}

%% ipsjtech.sty sets \pagestyle{IPSJTITLEheadings} for the whole
%% document (not just the title page), and shows the running head as
%% the (language-dependent) society/report name with a smaller fixed
%% English "IPSJ SIG Technical Report" line stacked underneath it.
\ifDS@techrep
\def\ipsj@signame@DAM{\ifDS@english IPSJ SIG Technical Report%
  \else 情報処理学会研究報告\fi}
\def\ps@IPSJTITLEheadings{%
  \def\@oddhead{\@Ltop\rlap{\small
    \ifDS@english{\HeadfontE{\signame}}\else{\HeadfontJ{\signame}}\fi}%
    \smash{\raisebox{-4mm}{\rlap{\DOIHeadfont IPSJ SIG Technical Report}}}%
    \hfil\@Rtop}%
  \let\@evenhead\@oddhead
  \def\@oddfoot{\@Lbot\rlap{\bothashira
      \copyright\ \@footyear\ Information Processing Society of Japan}%
    \hfil{\botnomble\thepage}\@Rbot}%
  \let\@evenfoot\@oddfoot
  \let\@mkboth\@gobbletwo}
\fi

%% --- Body-page running header/footer -------------------------------
\def\ps@headings{%
  \def\@oddhead{\@Ltop\rlap{\small
    \ifDS@english{\HeadfontE{\signame}}\else{\HeadfontJ{\signame}}\fi
    \ifDS@english
      \hskip12\Q{\HeadfontE{Vol.\number\c@volume}}%
      \hskip1em{\HeadfontE{No.\number\c@number}}%
      \hskip12\Q{\HeadfontE{\pageref{ipsj@firstpage}--\pageref{ipsj@lastpage}}}\ %
      \HeadfontE{(\@monthyear)}%
    \else
      \hskip12\JQ{\HeadfontE{Vol.\number\c@volume}}%
      \hskip12\JQ{\HeadfontE{No.\number\c@number}}%
      \hskip12\JQ{\HeadfontE{\pageref{ipsj@firstpage}--\pageref{ipsj@lastpage}}}\ %
      \HeadfontE{(\@monthyear)}%
    \fi}%
    \smash{\raisebox{-6mm}{\rlap{\DOIHeadfont\ipsj@doi}}}%
    \hfil\@Rtop}%
  \let\@evenhead\@oddhead
  \def\@oddfoot{\@Lbot\rlap{\bothashira
      \textcopyrighttx\ \@footyear\ Information Processing Society of Japan}%
    \hfil{\botnomble\thepage}\@Rbot}%
  \let\@evenfoot\@oddfoot
  \let\@mkboth\@gobbletwo}

%% ipsjtech.sty applies \ps@IPSJTITLEheadings to every page (not just
%% the title page), so the interior running head matches it exactly.
\ifDS@techrep
\let\ps@headings\ps@IPSJTITLEheadings
\fi

\pagestyle{headings}

%% =================================================================
%% 14. Sectioning
%% =================================================================

\setcounter{secnumdepth}{3}
\renewcommand\thesection{\@arabic\c@section}
\renewcommand\thesubsection{\thesection.\@arabic\c@subsection}
\renewcommand\thesubsubsection{\thesubsection.\@arabic\c@subsubsection}
\renewcommand\theparagraph{\thesubsubsection.\@arabic\c@paragraph}
\renewcommand\thesubparagraph{\theparagraph.\@arabic\c@subparagraph}

%% \section gets "N." before the heading text; subsection and deeper
%% levels already carry internal periods (e.g. "1.1") so no trailing
%% period is added.  \zw expands to "em" in English mode (see Sec. 3),
%% so a single definition covers both languages.
\def\@seccntformat#1{%
  \csname the#1\endcsname
  \@ifundefined{ipsj@nodot@#1}{.}{}%
  \hskip1\zw}
\@namedef{ipsj@nodot@subsection}{1}
\@namedef{ipsj@nodot@subsubsection}{1}
\@namedef{ipsj@nodot@paragraph}{1}
\@namedef{ipsj@nodot@subparagraph}{1}

\renewcommand{\section}{\@startsection{section}{1}{\z@}%
  {.5\Cvs}{.00001\Cvs}%
  {\reset@font\fontsize{16\JQ}{21\h}\gtfamily\bfseries\mathversion{bold}\selectfont}}
\renewcommand{\subsection}{\@startsection{subsection}{2}{\z@}%
  {\Cvs}{.00001\Cvs}%
  {\reset@font\normalsize\gtfamily\bfseries\mathversion{bold}\selectfont}}
\renewcommand{\subsubsection}{\@startsection{subsubsection}{3}{\z@}%
  {.5\Cvs}{.00001\Cvs}%
  {\reset@font\normalsize\gtfamily\bfseries\mathversion{bold}\selectfont}}
\renewcommand{\paragraph}{\@startsection{paragraph}{4}{\z@}%
  {.5\Cvs}{.00001\Cvs}%
  {\reset@font\normalsize\bfseries\selectfont}}
\renewcommand{\subparagraph}{\@startsection{subparagraph}{5}{\z@}%
  {.5\Cvs}{.00001\Cvs}%
  {\reset@font\normalsize\bfseries\selectfont}}

\renewcommand\appendixname{\ifDS@english Appendix\else\kintou{5\zw}{付録}\fi}
\renewcommand\appendix{\par
  \setcounter{section}{0}
  \setcounter{subsection}{0}
  \setcounter{equation}{0}
  \setcounter{figure}{0}
  \setcounter{table}{0}
  \renewcommand\thesection{A.\@arabic\c@section}
  \renewcommand\thesubsection{\thesection.\@arabic\c@subsection}
  \renewcommand\theequation{A.\@arabic\c@equation}
  \renewcommand\thefigure{A$\cdot$\@arabic\c@figure}
  \renewcommand\thetable{A$\cdot$\@arabic\c@table}
  \section*{\appendixname}}

%% =================================================================
%% 15. Figures, tables, captions
%% =================================================================

\ifDS@english
  \renewcommand{\figurename}{Fig.}
  \renewcommand{\tablename}{Table}
\else
  \renewcommand{\figurename}{図}
  \renewcommand{\tablename}{表}
\fi

%% \abovecaptionskip/\belowcaptionskip are already provided by article.cls.
\newdimen\capwidth
\newdimen\ecapwidth
\newdimen\twocolcapwidth  \twocolcapwidth=.66\textwidth
\newdimen\twocolecapwidth \twocolecapwidth=.66\textwidth
\def\TABLE{table}

\renewcommand{\thefigure}{\@arabic\c@figure}
\def\fps@figure{tbp}\def\ftype@figure{1}\def\ext@figure{lof}
\def\fnum@figure{\figurename~\thefigure}
\def\fnum@efigure{Fig.~\thefigure}
\renewenvironment{figure}
  {\capwidth\hsize\ecapwidth\hsize
   \abovecaptionskip1mm\belowcaptionskip\z@\@float{figure}}
  {\end@float}
\renewenvironment{figure*}
  {\capwidth.66\textwidth\ecapwidth.66\textwidth
   \abovecaptionskip1mm\belowcaptionskip\z@\@dblfloat{figure}}
  {\end@dblfloat}

\renewcommand{\thetable}{\@arabic\c@table}
\def\fps@table{tbp}\def\ftype@table{2}\def\ext@table{lot}
\def\fnum@table{\tablename~\thetable}
\def\fnum@etable{Table~\thetable}
\renewenvironment{table}
  {\capwidth\hsize\ecapwidth\hsize
   \abovecaptionskip\z@\belowcaptionskip1mm\@float{table}}
  {\end@float}
\renewenvironment{table*}
  {\capwidth.66\textwidth\ecapwidth.66\textwidth
   \abovecaptionskip\z@\belowcaptionskip1mm\@dblfloat{table}}
  {\end@dblfloat}

%% Dedicated scratch boxes for caption layout.  The kernel's shared
%% \@tempboxa/\@tempboxb must NOT be reused here: the first time a new
%% bold Japanese font shape is lazily loaded (e.g. bold Mincho at a
%% caption's reduced size), luatexja/NFSS's own font-substitution code
%% transiently uses those same registers as scratch space, corrupting
%% a \setbox\@tempboxb that is still being assembled around such a
%% font switch. Dedicated registers avoid that reentrancy hazard.
\newbox\ipsj@boxa
\newbox\ipsj@boxb

\long\def\@makecaption#1#2{%
  \setbox\ipsj@boxa\hbox{\footnotesize{\bfseries#1}\hskip1\zw{#2}}%
  \setbox\ipsj@boxb\hbox{\footnotesize{\bfseries#1}\hskip1\zw}%
  \ifdim\wd\ipsj@boxa>\capwidth
    \parbox[t]{\capwidth}{\hangindent\wd\ipsj@boxb
      {\bfseries#1}\hskip1\zw#2}\par
  \else
    \hbox to\hsize{\hfil\box\ipsj@boxa\hfil}%
  \fi
  \vskip\belowcaptionskip}

\long\def\ecaption#1{{\footnotesize
  \setbox\ipsj@boxa\hbox{\footnotesize{\bfseries\csname fnum@e\@captype\endcsname}%
    \hskip1\zw\shortstack[l]{#1}}%
  \setbox\ipsj@boxb\hbox{\footnotesize{\bfseries\csname fnum@e\@captype\endcsname}\hskip1\zw}%
  \ifdim\wd\ipsj@boxa>\ecapwidth
    \hfil\parbox[t]{\ecapwidth}{\hangindent\wd\ipsj@boxb
      {\bfseries\csname fnum@e\@captype\endcsname}\hskip1\zw#1}\par
  \else
    \hbox to\hsize{\hfil\box\ipsj@boxa\hfil}%
  \fi
  \vspace{2\belowcaptionskip}\par}}

%% Wide (full-textwidth) caption machinery for figures/tables that
%% visually span both columns.
\newbox\@dummyfigbox
\def\twocolcaption{\refstepcounter\@captype\@dblarg{\@twocolcaption\@captype}}
\long\def\@twocolcaption#1[#2]#3{\par
  \begingroup\footnotesize
  \setbox\ipsj@boxa\hbox{{\bfseries\csname fnum@#1\endcsname}\hskip1\zw#3}%
  \setbox\ipsj@boxb\hbox{{\bfseries\csname fnum@#1\endcsname}\hskip1\zw}%
  \ifdim\wd\ipsj@boxa>\twocolcapwidth
    \hbox to\textwidth{\hfil\parbox[t]{\twocolcapwidth}{\hangindent\wd\ipsj@boxb
      {\bfseries\csname fnum@#1\endcsname}\hskip1\zw#3}\hfil}\par
  \else
    \hbox to\textwidth{\hfil\box\ipsj@boxa\hfil}%
  \fi
  \endgroup}
\def\twocolecaption{\@dblarg{\@twocolecaption\@captype}}
\long\def\@twocolecaption#1[#2]#3{\par
  \begingroup\footnotesize
  \setbox\ipsj@boxa\hbox{{\bfseries\csname fnum@e#1\endcsname}\hskip1\zw#3}%
  \setbox\ipsj@boxb\hbox{{\bfseries\csname fnum@e#1\endcsname}\hskip1\zw}%
  \ifdim\wd\ipsj@boxa>\twocolecapwidth
    \hbox to\textwidth{\hfil\parbox[t]{\twocolecapwidth}{\hangindent\wd\ipsj@boxb
      {\bfseries\csname fnum@e#1\endcsname}\hskip1\zw#3}\hfil}\par
  \else
    \hbox to\textwidth{\hfil\box\ipsj@boxa\hfil}%
  \fi
  \endgroup}
\def\twocolfig#1{\hbox to\columnwidth{\hbox to\textwidth{\hss#1\hss}\hss}}

%% =================================================================
%% 16. Bibliography
%% =================================================================

\ifDS@english
  \renewcommand{\refname}{References}
\else
  \renewcommand{\refname}{参考文献}
\fi
\newdimen\bibindent \bibindent=1.5em
\def\@biblabel#1{[#1]}

\renewenvironment{thebibliography}[1]
 {\ifDS@english
    \footnotesize\setlength\baselineskip{12\h}
  \else
    \small\setlength\baselineskip{15\h}
  \fi
  \subsection*{\normalsize\refname}%
  \vspace*{2mm}%
  \def\@mklab##1{##1\hfil}%
  \list{\@biblabel{\@arabic\c@enumiv}}%
    {\settowidth\labelwidth{\@biblabel{#1}}%
     \leftmargin\labelwidth
     \advance\leftmargin\labelsep
     \@openbib@code
     \usecounter{enumiv}%
     \let\p@enumiv\@empty
     \renewcommand\theenumiv{\@arabic\c@enumiv}}%
  \parskip\z@ \topsep\z@ \partopsep\z@
  \itemsep1\h \parsep\z@
  \sloppy
  \clubpenalty\z@ \widowpenalty\z@
  \sfcode`\.\@m}
 {\def\@noitemerr{\@latex@warning{Empty `thebibliography' environment}}%
  \endlist}
\let\@openbib@code\@empty
\let\Cite\cite

%% =================================================================
%% 17. Footnotes
%% =================================================================

\setlength{\skip\footins}{9\p@ \@plus 4\p@ \@minus 2\p@}
\ifDS@english
  \setlength\footnotesep{6.65\p@}
  \renewcommand{\footnoterule}{\kern-3\p@\hrule width\columnwidth\kern2.6\p@}
\else
  \setlength\footnotesep{10\h}
  \renewcommand{\footnoterule}{\kern-4\p@\hrule width\columnwidth\kern1.6\p@}
\fi

\def\thefootnote{\ifnum\c@footnote>\z@\leavevmode\lower.5ex\hbox{*}\@arabic\c@footnote\fi}

\def\footfont{\ifDS@english
    \fontsize{11\Q}{13\h}\normalfont\selectfont
  \else
    \fontsize{11\JQ}{14\h}\normalfont\selectfont
  \fi}

\long\def\@makefntext#1{\footfont
  \ifDS@english
    \setbox\z@=\hbox{\makebox[1.61\Cwd][l]{\@makefnmark}}%
  \else
    \setbox\z@=\hbox{\makebox[1.58\Cwd][l]{\@makefnmark}}%
  \fi
  \@tempdima\columnwidth
  \advance\@tempdima-\wd\z@
  \parshape 1 \wd\z@ \@tempdima
  \parindent=1\zw
  \noindent\llap{\unhbox\z@}#1}

%% =================================================================
%% 18. Biography / profile box (default and preface modes only;
%%     suppressed in techrep mode, see Section 12 above)
%% =================================================================

\ifDS@english
  \newcommand{\profname}{\relax}
\else
  \newcommand{\profname}{著者紹介}
\fi

\let\@BreakMember\relax
\def\BreakMember{\def\@BreakMember{\\}}

\def\h@member{名誉会員}\def\m@member{正会員}
\def\s@member{学生会員}\def\j@member{ジュニア会員}
\def\F@title@member{本会フェロー}
\def\E@title@member{本会シニア会員}
\def\L@title@member{本会終身会員}

\newcommand{\pushtowall}[1]{%
  \setbox0\hbox{#1}\wd0\z@\box0}

\def\profile{\@ifstar{\n@eprofile}{\@eprofile}}
\def\@eprofile{\@ifnextchar[{\ip@eprofile}{\no@eprofile}}

\ifDS@techrep\else
\ifDS@english
\def\ip@eprofile[#1]#2#3{%
  \par\nobreak\vskip\baselineskip\penalty\@M
  \noindent
  \IfFileExists{#1.eps}{%
    \pushtowall{\raisebox{-28.19mm}{\resizebox{25mm}{31mm}{\includegraphics{#1.eps}}}}}{}%
  \hangindent30mm\hangafter-8\relax
  {\fontsize{13\Q}{18\h}\bfseries\selectfont#2}\@BreakMember\par
  {\fontsize{13\Q}{18\h}\selectfont#3}\par}
\def\no@eprofile#1#2{%
  \par\nobreak\vskip\baselineskip\penalty\@M
  \noindent
  \pushtowall{\hbox{\vrule\@width.1mm\@height31mm
    \hskip25mm\vrule\@width.1mm\@height31mm}}%
  \hangindent30mm\hangafter-8\relax
  {\fontsize{13\Q}{18\h}\bfseries\selectfont#1}\@BreakMember\par
  {\fontsize{13\Q}{18\h}\selectfont#2}\par}
\def\n@eprofile#1#2{%
  \par\nobreak\vskip\baselineskip\penalty\@M
  \noindent
  {\fontsize{13\Q}{18\h}\bfseries\selectfont#1}\@BreakMember\par
  {\fontsize{13\Q}{18\h}\selectfont#2}\par}
\else
\def\ip@eprofile[#1]#2#3#4{%
  \par\nobreak\vskip\baselineskip\penalty\@M
  \noindent
  \IfFileExists{#1.eps}{%
    \pushtowall{\raisebox{-28.19mm}{\resizebox{25mm}{31mm}{\includegraphics{#1.eps}}}}}{}%
  \@for\@temp:=#2\do{%
    \@ifundefined{\@temp @member}{}{\edef\@@member{（\csname\@temp @member\endcsname）}}%
    \@ifundefined{\@temp @title@member}{}{\edef\@title@member{\csname\@temp @title@member\endcsname．}}}%
  \hangindent30mm\hangafter-7\relax
  {\fontsize{15\JQ}{0\h}\bfseries\selectfont#3}\@BreakMember\\[.5\Cvs]
  {\fontsize{13\JQ}{21\h}\selectfont#4\csname @title@member\endcsname
   \normalsize\inhibitglue\@@member}\par}
\def\no@eprofile#1#2#3{%
  \par\nobreak\vskip\baselineskip\penalty\@M
  \noindent
  \pushtowall{\hbox{\vrule\@width.1mm\@height31mm
    \hskip25mm\vrule\@width.1mm\@height31mm}}%
  \@for\@temp:=#1\do{%
    \@ifundefined{\@temp @member}{}{\edef\@@member{（\csname\@temp @member\endcsname）}}%
    \@ifundefined{\@temp @title@member}{}{\edef\@title@member{\csname\@temp @title@member\endcsname．}}}%
  \hangindent30mm\hangafter-7\relax
  {\fontsize{15\JQ}{0\h}\bfseries\selectfont#2}\@BreakMember\\[.5\Cvs]
  {\fontsize{13\JQ}{21\h}\selectfont#3\csname @title@member\endcsname
   \normalsize\inhibitglue\@@member}\par}
\def\n@eprofile#1#2#3{%
  \par\nobreak\vskip\baselineskip\penalty\@M
  \noindent
  \@for\@temp:=#1\do{%
    \@ifundefined{\@temp @member}{}{\edef\@@member{（\csname\@temp @member\endcsname）}}%
    \@ifundefined{\@temp @title@member}{}{\edef\@title@member{\csname\@temp @title@member\endcsname．}}}%
  {\fontsize{15\JQ}{0\h}\bfseries\selectfont#2}\@BreakMember\\[.5\Cvs]
  {\fontsize{13\JQ}{21\h}\selectfont#3\csname @title@member\endcsname
   \normalsize\inhibitglue\@@member}\par}
\fi
\fi
\let\inhibitglue\relax
\def\@@member{}
\def\@title@member{}

%% This default \biography (with profile photo box) is only meaningful
%% outside techrep mode; Sec. 12 above already installed the no-op
%% gobbling version for \ifDS@techrep, so it must not be clobbered here.
\ifDS@techrep\else
\def\biography{%
  \vspace{2\baselineskip}\nobreak
  \footnotesize\normalfont\parindent\z@
  \vskip\baselineskip\penalty\@medpenalty\penalty\@M
  \ifDS@english\vskip.5\Cvs\else\vskip-.5\Cvs\fi}
\def\endbiography{\par}
\fi

%% =================================================================
%% 19. Crop marks (tombow) and editorial corner guides
%% =================================================================

\ifDS@tombow
  \RequirePackage{eso-pic}
  %% Corner trim marks at all four corners of the (fixed A4) page.
  \AddToShipoutPictureBG{%
    \AtPageLowerLeft{%
      \unitlength1mm
      \thinlines
      \put(0,0){\line(1,0){10}}\put(0,0){\line(0,1){10}}
      \put(210,0){\line(-1,0){10}}\put(210,0){\line(0,1){10}}
      \put(0,297){\line(1,0){10}}\put(0,297){\line(0,-1){10}}
      \put(210,297){\line(-1,0){10}}\put(210,297){\line(0,-1){10}}
    }%
  }
\fi

\endinput
