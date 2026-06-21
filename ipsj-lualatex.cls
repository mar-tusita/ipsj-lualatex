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
%% fleqn is always on regardless of this option (see the \LoadClass call
%% below): the original unconditionally re-embeds a copy of the kernel's
%% own fleqn.clo at the end of ipsj.cls, so its OWN "fleqn" class option
%% (which would just \input the same file again) never had any effect.
%% Declaring it here as a no-op only avoids an "unused option" warning
%% for old documents that still pass it.
\DeclareOption{fleqn}{}
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
%% "alone" (preface mode only): the preface's own page range is a
%% single page rather than a span, so the running head shows just the
%% first-page reference instead of "first--last".
\newif\ifDS@alone    \DS@alonefalse
\DeclareOption{alone}{\DS@alonetrue}
%% SES (IPSJ/SIGSE Software Engineering Symposium) is a techrep variant
%% with the running head, DOI line, copyright notice and page number all
%% suppressed; selecting it implies techrep, matching the original
%% ses.sty/ipsj.cls combination (real-world usage never adds "techrep"
%% explicitly alongside "ses").
\newif\ifDS@ses      \DS@sesfalse
\DeclareOption{ses}{\DS@sestrue\DS@techreptrue}
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
%% Always load article.cls's own fleqn.clo: the original unconditionally
%% re-embeds a copy of that same kernel file at the end of ipsj.cls (see
%% the "Equation environments" subsection below), so flush-left
%% equations are baked-in default IPSJ behaviour, not something only
%% "fleqn" requests.
\LoadClass[fleqn]{article}

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
%% The original's Mincho has no genuine bold shape (see CLAUDE.md): NFSS
%% there falls back to Gothic whenever \bfseries is requested on Mincho
%% text. Harano Aji Mincho ships a real Bold weight, so without this
%% override \bfseries/\textbf on Japanese text would render in bold
%% Mincho instead, which looks wrong for any user-authored \textbf{...}
%% that isn't covered by the class's own \gtfamily\bfseries call sites.
%%
%% Crucially, the weight that substitutes in is "Harano Aji Gothic
%% Medium" -- NOT Gothic's own Bold face. Checking the original's PDF
%% output confirms it only ever embeds HaranoAjiGothic-Medium, never
%% HaranoAjiGothic-Bold, anywhere (see CLAUDE.md): the historical
%% commercial font this traces back to ("GothicBBB-Medium") only ever
%% had the one weight, called Medium for commercial-naming reasons, not
%% because it sits between a lighter and a bolder relative. So \bfseries
%% on Mincho -- and \gtfamily\bfseries, used throughout this class for
%% the same substitution (titles, section heads, captions, labels) --
%% must resolve to that same Medium face, not to genuine bold Gothic, or
%% headings come out visibly heavier than the original.
\setmainjfont{Harano Aji Mincho}[BoldFont={Harano Aji Gothic Medium}]
\setsansjfont{Harano Aji Gothic Medium}[BoldFont={Harano Aji Gothic Medium}]
\renewcommand{\kanjifamilydefault}{\mcdefault}

\ifDS@tate
  \AtBeginDocument{\tate}
\fi

%% Kinsoku (line-breaking prohibition) refinements beyond LuaTeX-ja's own
%% defaults (loaded automatically as part of \RequirePackage{luatexja},
%% from ltj-kinsoku.tex). That default table already matches the
%% original's bracket/quote-pair penalties exactly (both use \@M), so
%% those are not repeated here. Two genuine differences remain: small
%% kana get only a weak default penalty (150) where the original used
%% \@M, and the wave dash has no default prebreakpenalty at all.
\ifDS@english\else
  \ltjsetparameter{prebreakpenalty={`ぁ,\@M},prebreakpenalty={`ぃ,\@M},
    prebreakpenalty={`ぅ,\@M},prebreakpenalty={`ぇ,\@M},
    prebreakpenalty={`ぉ,\@M},prebreakpenalty={`っ,\@M},
    prebreakpenalty={`ゃ,\@M},prebreakpenalty={`ゅ,\@M},
    prebreakpenalty={`ょ,\@M},prebreakpenalty={`ゎ,\@M},
    prebreakpenalty={`ァ,\@M},prebreakpenalty={`ィ,\@M},
    prebreakpenalty={`ゥ,\@M},prebreakpenalty={`ェ,\@M},
    prebreakpenalty={`ォ,\@M},prebreakpenalty={`ッ,\@M},
    prebreakpenalty={`ャ,\@M},prebreakpenalty={`ュ,\@M},
    prebreakpenalty={`ョ,\@M},prebreakpenalty={`ヮ,\@M},
    prebreakpenalty={`ヵ,\@M},prebreakpenalty={`ヶ,\@M},
    prebreakpenalty={`ー,\@M},prebreakpenalty={`〜,\@M}}
  %% ASCII quote-like characters: not part of LuaTeX-ja's Japanese
  %% kinsoku table at all, so the original's two explicit settings
  %% (weaker than typical kinsoku penalties, hence the literal values
  %% rather than \@M) are reproduced verbatim.
  \ltjsetparameter{prebreakpenalty={34,1000},postbreakpenalty={92,1000}}
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

%% \[...\], equation and eqnarray are already in their IPSJ "flush left"
%% form via \LoadClass[fleqn]{article} above; \mathindent there defaults
%% to fleqn.clo's own value, which the original overrides to 1\zw, and
%% \@eqnnum gets an extra 3mm gap before the equation number.
\mathindent1\zw
\def\@eqnnum{{\normalfont\normalcolor(\theequation)\hspace*{3mm}}}

%% \Cwd/\Cht/\Cdp/\Cvs: width/height/depth/baselineskip of one full-width
%% Japanese character at \normalsize, used throughout as grid units for
%% margins, captions, lists, etc.  In English mode the original class
%% used fixed, hand-measured constants instead of a glyph box; we do
%% the same.
\newdimen\Cwd \newdimen\Cht \newdimen\Cdp \newdimen\Cvs
\ifDS@english
  \Cht=7.19269pt \Cdp=1.28441pt \Cwd=8.9005pt \Cvs=12.80592pt
\fi

%% itemize/enumerate/description spacing: make it perfectly rigid (no
%% plus/minus stretch) at every nesting depth, matching the original
%% class. Without this, \flushbottom's column-height balancing dumps
%% all of its needed stretch into whichever list happens to share a
%% column with a taller one, producing huge unnatural gaps between
%% list items that the original never had (standard article.cls's
%% \@listI etc. all carry generous plus/minus stretch). Depth 1
%% (\@listi) is also pinned directly inside \normalsize below, since
%% that is the one that gets re-invoked (and would otherwise be
%% clobbered) via fontspec's \AtBeginDocument hook; \@listii-vi are
%% never re-invoked elsewhere, so a one-time fix here is enough.
%% The original (\lst@listi) also pins \labelsep/\labelwidth/
%% \rightmargin/\listparindent/\itemindent the same way at every depth;
%% \enumerate/\itemize/\description set their own values later (see
%% Sec.14 below) which take precedence, so this only affects other
%% \list-based constructs (e.g. nested nonstandard list levels).
%% Defined here (ahead of \normalsize, which references it) rather
%% than alongside \leftmargini etc. below, purely so the forward
%% reference from \normalsize's body resolves; the dimensions it
%% actually uses (\Cwd, \leftmargini) only need to hold their final
%% values once \@listi etc. are invoked, not at \def time.
\def\ipsj@listspacing{%
  \labelsep\Cwd \labelwidth.25\Cwd
  \rightmargin\z@ \listparindent\z@ \itemindent\z@
  \partopsep\z@ \parsep\z@ \topsep\z@ \itemsep\z@}

%% =================================================================
%% 4. Font size scale (normalsize: 13Q x 21H Japanese / 13Q x 18H Eng.)
%% =================================================================

\renewcommand{\normalsize}{%
  \ifDS@english
    \@setfontsize\normalsize{9.25pt}{12.80592pt}%
  \else
    \@setfontsize\normalsize{13\JQ}{21\h}%
    \ltjsetparameter{kanjiskip={0pt plus .1\zw minus .05\zw}}%
  \fi
  \abovedisplayskip 9\p@ \@plus 3\p@ \@minus 4\p@
  \abovedisplayshortskip \z@ \@plus 2.5\p@
  \belowdisplayshortskip 5\p@ \@plus 2\p@ \@minus 2\p@
  \belowdisplayskip \abovedisplayskip
  %% Deliberately not \let\@listi\@listI (article.cls's stretchy
  %% default): fontspec/luatexja-fontspec re-invoke \normalsize from an
  %% \AtBeginDocument hook that runs at the top level (no group), so
  %% any reset to a stretchy \@listi here would permanently undo the
  %% rigid list spacing set up below (see CLAUDE.md for the full
  %% writeup of the resulting \flushbottom column-balancing bug).
  \leftmargin\leftmargini \ipsj@listspacing}

\renewcommand{\small}{%
  \ifDS@english
    \@setfontsize\small{8.53728pt}{9.960159pt}%
  \else
    \@setfontsize\small{12\JQ}{20\h}%
    \ltjsetparameter{kanjiskip={0pt plus .1\zw minus .05\zw}}%
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
    \ltjsetparameter{kanjiskip={0pt plus .1\zw minus .05\zw}}%
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

%% The kernel's default topnumber/bottomnumber/totalnumber (2/1/3) cap how
%% many floats may stack at the top/bottom of a single column, regardless
%% of \topfraction etc. having room. With 3+ floats placed close together
%% in a row (\begin{figure}[tb] with little or no intervening text), this
%% kernel default silently bumps the 3rd+ float from "top" to "bottom"
%% placement (or to a later page) well before the fraction limits below
%% ever come into play, which displaced a figure relative to a footnote
%% built from the original's intended top-stacking.
\setcounter{topnumber}{8}
\setcounter{bottomnumber}{8}
\setcounter{totalnumber}{16}
\setcounter{dbltopnumber}{2}

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

%% \ipsj@listspacing is defined in Sec.3 above (ahead of \normalsize,
%% which references it). \@listii-vi are never re-invoked elsewhere
%% after this, so defining them once here is enough.
\def\@listi{\leftmargin\leftmargini \ipsj@listspacing}
\def\@listii{\leftmargin\leftmarginii \ipsj@listspacing}
\def\@listiii{\leftmargin\leftmarginiii \ipsj@listspacing}
\def\@listiv{\leftmargin\leftmarginiv \ipsj@listspacing}
\def\@listv{\leftmargin\leftmarginv \ipsj@listspacing}
\def\@listvi{\leftmargin\leftmarginvi \ipsj@listspacing}
\@listi

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

%% kintou: spread text #2 evenly to width #1 (used for the "付　録"
%% appendix banner). The original makes \kanjiskip itself stretchable
%% (0pt plus 1fill minus 1fill) so the box's extra width is absorbed
%% BETWEEN #2's characters rather than around them; a plain bookend
%% \hskip (the previous implementation here) instead centers #2 as a
%% solid block, since LuaTeX-ja's own inter-character glue is finite
%% and never competes with an outer infinite-order \hskip in the same
%% list. \ltjsetparameter{kanjiskip=...} is LuaTeX-ja's equivalent of
%% pTeX's directly-assignable \kanjiskip register.
\def\kintou#1#2{%
  \ifDS@english\relax\else
    \leavevmode\hbox to #1{%
      \ltjsetparameter{kanjiskip={0pt plus 1fill minus 1fill},%
        xkanjiskip={0pt plus 1fill minus 1fill}}%
      #2}%
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
    \ifDS@JIP \advance\@tempcnta 1992
    \else\ifDS@ACS \advance\@tempcnta 2007
    \else\ifDS@PRO \advance\@tempcnta 2007
    \else\ifDS@TOD \advance\@tempcnta 2007
    \else\ifDS@TOM \advance\@tempcnta 2007
    \else\ifDS@TBIO \advance\@tempcnta 2007
    \else\ifDS@SLDM \advance\@tempcnta 2007
    \else\ifDS@CVA \advance\@tempcnta 2008
    \else\ifDS@CDS \advance\@tempcnta 2010
    \else\ifDS@DC \advance\@tempcnta 2012
    \else\ifDS@DCON \advance\@tempcnta 2012
    \else\ifDS@TCE \advance\@tempcnta 2014
    %% No specific journal type selected: "english" alone (with none of
    %% the journal-type options above, which would already have matched
    %% by this point) used the same fallback as JIP in the original.
    \else\ifDS@english \advance\@tempcnta 1992
    \else \advance\@tempcnta 1959
    \fi\fi\fi\fi\fi\fi\fi\fi\fi\fi\fi\fi\fi
    \number\@tempcnta
  \else
    \number\c@year
  \fi}

\def\ipsj@month{{%
  \@tempcnta\ifnum\c@month<\z@ \c@number\else\c@month\fi\relax
  \ifcase\@tempcnta ???%
    \or Jan.\or Feb.\or Mar.\or Apr.\or May\or June%
    \or July\or Aug.\or Sep.\or Oct.\or Nov.\or Dec.%
  \else ???\fi}}

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
%% Dedicated scratch registers for \authoroutput: \@tempcnta/\@tempcntb are
%% reused by NFSS font-substitution machinery, which can fire mid-loop the
%% first time a given superscript font/size is loaded and silently clobber
%% them (same reentrancy hazard as \@tempboxa/\@tempboxb; see CLAUDE.md 4.4).
\newcount\ipsj@authcnta
\newcount\ipsj@authcntb

\ifDS@english
  \def\author#1#2{\@ifnextchar[{\@author{#2}{#1}}{\@author{#2}{#1}[]}}
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
%% Both loops bound \ipsj@authcntb by \ipsj@authcnta = (item count + 1), so a
%% trailing separator is needed exactly when the NEXT index is still
%% inside that range, i.e. \ipsj@authcntb+1 < \ipsj@authcnta.
\def\comma@or@relax@affilabel{%
  \ifnum\numexpr\ipsj@authcntb+1\relax<\ipsj@authcnta ,\fi}
\def\comma@or@relax@email{%
  \ifnum\numexpr\ipsj@authcntb+1\relax<\ipsj@authcnta ,\fi}

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
      \expandafter\ipsj@authcnta\csname authorlabel@num@\the\count@\endcsname\relax
      \advance\ipsj@authcnta\@ne
      \ipsj@authcntb\@ne
      {\@whilenum{\ipsj@authcntb<\ipsj@authcnta}\do{%
        \edef\temp{\csname authorlabel\the\count@ @\the\ipsj@authcntb\endcsname}%
        \textsuperscript{\csname #1labelfont\endcsname
          \expandafter\ifx\csname affiliate@num@\temp\endcsname\relax
            \csname paffiliate@num@\temp\endcsname
          \else
            \csname affiliate@num@\temp\endcsname
          \fi
          \comma@or@relax@affilabel}%
        \advance\ipsj@authcntb\@ne}}%
      \expandafter\ipsj@authcnta\csname authoremail@num@\the\count@\endcsname\relax
      \ifnum\ipsj@authcnta=\z@\relax\else\textsuperscript{,}\fi
      \advance\ipsj@authcnta\@ne
      \ipsj@authcntb\@ne
      \@whilenum{\ipsj@authcntb<\ipsj@authcnta}\do{%
        \bgroup
        \advance\ipsj@authcntb\offsetemail
        \textsuperscript{\csname #1labelfont\endcsname\@alph{\ipsj@authcntb})\comma@or@relax@email}%
        \egroup
        \advance\ipsj@authcntb\@ne}%
      \advance\ipsj@authcntb-1\relax
      \global\advance\offsetemail\ipsj@authcntb
    }%
    \ifDS@english\ebreak@or@oneskip\else\csname #1break@or@oneskip\endcsname\fi
    \advance\count@\@ne}%
  \egroup}

%% =================================================================
%% 10. Abstract / keyword boxes
%% =================================================================

%% Bold Japanese text has no genuine Mincho-Bold shape in the original
%% toolchain, so the original always renders it via Gothic instead (see
%% CLAUDE.md for the full writeup); \gtfamily makes that explicit here
%% since Harano Aji Mincho *does* have a real bold weight and would
%% otherwise render true bold Mincho instead.
\def\GAIYOU{\ifDS@abstract{\hskip1\zw}\else{\gtfamily\bfseries 概要}：\fi}
\def\EGAIYOU{\itshape\bfseries\sffamily Abstract:\hskip.5em}
\def\JKEYWORD{{\gtfamily\bfseries キーワード}：}
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
  \let\発表\Presented
\fi

%% Default (journal) title page: actual received/revised/accepted
%% dates, shown between the author line and the abstract. techrep
%% mode overrides these with blank phantoms further below, since
%% submitted (not yet accepted) technical reports omit real dates.
\def\@uketsuke{%
  \@received
  \@ifundefined{@rereceived}{, }{%
    \@rereceived
    \@ifundefined{@rerereceived}{, }{\@rerereceived}%
    \par}%
  {\@accepted}%
  \@ifundefined{@released}{}{, \@released}}
\def\@euketsuke{%
  \@ereceived
  \@ifundefined{@erereceived}{, }{%
    \@erereceived
    \@ifundefined{@ererereceived}{, }{\@ererereceived}%
    \par}%
  \@eaccepted}

%% Japanese-named aliases of the volume/number/month counters, so that
%% \setcounter{巻数}{...} etc. (as used by the official sample documents)
%% directly manipulate \c@volume/\c@number/\c@month.
\expandafter\let\csname c@巻数\endcsname\c@volume
\expandafter\let\csname c@号数\endcsname\c@number
\expandafter\let\csname c@月数\endcsname\c@month
\expandafter\let\csname c@年数\endcsname\c@year

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
    \expandafter\@tempcntb\csname authoremail@num@\the\count@\endcsname\relax
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

%% A preface has no abstract/keywords/reception dates, unlike the
%% default and techrep \authortitle: just title, author and body.
\ifDS@english
\def\authortitle{%
  {\Engtitlefont{\@title}\par}%
  \vskip\Etitleauthorsep
  {\Engeauthorfont\authoroutput{e}\par}%
  \vskip\Eauthorreceivesep
  \vskip\JEhonbunsep}
\else
\def\authortitle{%
  {\jtitlefont{\@title}\par}%
  \vskip\Jtitlejauthorsep
  {\authorfont\authoroutput{}\par}%
  \vskip\Jauthorjreceivesep
  \vskip\JEhonbunsep}
\fi

%% Preface category labels are never printed (matches ipsjpref.sty,
%% which redefines these to invisible placeholders).
\def\ipsj@shubetu@DAM{\leavevmode}
\def\ipsj@shubetu@Data{\leavevmode\phantom{Database/Software Paper}}
\def\ipsj@shubetu@Survey{\leavevmode\phantom{Survey Paper}}
\def\ipsj@shubetu@TBIOM{\leavevmode\phantom{Original Paper}}
\def\ipsj@shubetu@Short{\leavevmode\phantom{Short Paper}}

%% Preface running head: same Vol./DOI scaffolding as the default
%% mode's \ps@IPSJTITLEheadings, except the page reference collapses
%% to a single page under "alone", and a preface's "No.X" is always
%% shown (unlike the default mode's CVA/TBIO/SLDM/JIP suppression,
%% which only matters for journal types a preface is never tagged
%% with in practice).
\ifDS@english
\def\ps@IPSJTITLEheadings{%
  \def\@oddhead{\@Ltop\rlap{\small{\HeadfontE{\signame}}%
    \hskip12\Q{\HeadfontE{Vol.\number\c@volume}}%
    \ifDS@alone
      \hskip12\Q{\HeadfontE{\pageref{ipsj@firstpage}}}\ %
    \else
      \hskip12\Q{\HeadfontE{\pageref{ipsj@firstpage}--\pageref{ipsj@lastpage}}}\ %
    \fi
    \HeadfontE{(\@monthyear)}}%
    \smash{\raisebox{-6mm}{\rlap{\DOIHeadfont\ipsj@doi}}}%
    \hfil\@Rtop}%
  \let\@evenhead\@oddhead
  \def\@oddfoot{\@Lbot\rlap{\bothashira
      \copyright\ \@footyear\ Information Processing Society of Japan}%
    \hfil{\botnomble\thepage}\@Rbot}%
  \let\@evenfoot\@oddfoot
  \let\@mkboth\@gobbletwo}
\else
\def\ps@IPSJTITLEheadings{%
  \def\@oddhead{\@Ltop\rlap{\small{\HeadfontJ{\signame}}%
    \hskip12\JQ{\HeadfontE{Vol.\number\c@volume}}%
    \ifDS@alone
      \hskip12\JQ{\HeadfontE{\pageref{ipsj@firstpage}}}\ %
    \else
      \hskip12\JQ{\HeadfontE{\pageref{ipsj@firstpage}--\pageref{ipsj@lastpage}}}\ %
    \fi
    \HeadfontE{(\@monthyear)}}%
    \hfil\@Rtop}%
  \let\@evenhead\@oddhead
  \def\@oddfoot{\@Lbot\rlap{\bothashira
      \textcopyrighttx\ \@footyear\ Information Processing Society of Japan}%
    \hfil{\botnomble\thepage}\@Rbot}%
  \let\@evenfoot\@oddfoot
  \let\@mkboth\@gobbletwo}
\fi
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
      %% "No.X" is omitted for journal types whose issues aren't
      %% numbered the same way (and for "preprint", which has no
      %% issue number to print yet).
      \ifDS@CVA\else\ifDS@TBIO\else\ifDS@SLDM\else
      \ifDS@preprint\else\ifDS@JIP\else
        \hskip1em{\HeadfontE{No.\number\c@number}}%
      \fi\fi\fi\fi\fi
      \ifDS@abstract
        \hskip12\Q{\HeadfontE{\pageref{ipsj@firstpage}}}\ %
      \else
        \hskip12\Q{\HeadfontE{\pageref{ipsj@firstpage}--\pageref{ipsj@lastpage}}}\ %
      \fi
      \HeadfontE{(\@monthyear)}%
    \else
      \hskip12\JQ{\HeadfontE{Vol.\number\c@volume}}%
      \hskip12\JQ{\HeadfontE{No.\number\c@number}}%
      \ifDS@abstract
        \hskip12\Q{\HeadfontE{\pageref{ipsj@firstpage}}}\ %
      \else
        \hskip12\JQ{\HeadfontE{\pageref{ipsj@firstpage}--\pageref{ipsj@lastpage}}}\ %
      \fi
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
    %% Unlike \ps@IPSJTITLEheadings (title page), the original only
    %% keeps an empty \DOIHeadfont box here on continuation pages --
    %% it never repeats the actual [DOI: ...] text past page 1.
    \smash{\raisebox{-6mm}{\rlap{\DOIHeadfont}}}%
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

%% ses.sty blanks the society-name running head, drops the DOI/secondary
%% header line and the copyright footer text, and replaces the page
%% number with nothing at all (symposium proceedings paginate the
%% volume themselves).
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

%% \section is NOT a plain before/after-skip heading in the original:
%% it is set inside a box of fixed height (2.43\Cvs when the number+
%% title fit on one line; a slightly different padding when they
%% overflow \columnwidth) with the normal interline glue around it
%% explicitly cancelled (\vspace{-\baselineskip} before this box,
%% \prevdepth=-1000pt after it) so the box height alone determines the
%% visible gap.  A plain \@startsection (the previous implementation
%% here) leaves almost no gap below the heading, because its "after"
%% skip argument is genuinely near-zero in the original too -- the
%% real gap always came from the box, never from that skip.  See
%% CLAUDE.md Sec.4.17.  \@startsectionA/\@sectA/\@ssectA below port the
%% original's \@startsectionA/\@sectA/\@ssectA verbatim, with
%% \ipsj@secboxa/\ipsj@secboxb standing in for the original's
%% \SECTwd/\@tempboxb (dedicated registers, per the Sec.4.4 box-
%% reentrancy lesson). \@xsect is also ported verbatim even though the
%% one line where it differs from the article.cls kernel's own copy
%% (\clubpenalty\z@ vs \@M) is a branch nothing in this class reaches,
%% since every heading level's "after" skip is a strictly positive
%% \Cvs-based value; porting it anyway costs nothing and removes a
%% spot where a future edit could silently reintroduce the kernel's
%% behaviour. \@hangfrom/\@afterheading are reused unchanged from the
%% kernel: the original's own copies are functionally identical.
\newbox\ipsj@secboxa
\newbox\ipsj@secboxb
\newlength\section@height
\section@height\lineskip
\advance\section@height-\topskip
\advance\section@height\baselineskip

\def\@startsectionA#1#2#3#4#5#6{%
  \if@noskipsec \leavevmode \fi
  \par
  \@tempskipa #4\relax
  \@afterindenttrue
  \ifdim \@tempskipa <\z@
    \@tempskipa -\@tempskipa \@afterindentfalse
  \fi
  \if@nobreak
    \everypar{}%
  \else
    \addpenalty\@secpenalty\addvspace\@tempskipa
  \fi
  \@ifstar
    {\@ssectA{#3}{#4}{#5}{#6}}%
    {\@dblarg{\@sectA{#1}{#2}{#3}{#4}{#5}{#6}}}}

\ifDS@english
\def\@sectA#1#2#3#4#5#6[#7]#8{%
  \ifnum #2>\c@secnumdepth
    \let\@svsec\@empty
  \else
    \refstepcounter{#1}%
    \protected@edef\@svsec{\@seccntformat{#1}\relax}%
  \fi
  \@tempskipa #5\relax
  \ifdim \@tempskipa>\z@
    \setbox\ipsj@secboxa\hbox{%
      \begingroup
      \noindent
      #6{\@hangfrom{\hskip #3\relax\@svsec}}%
      \interlinepenalty \@M {{#8}}%
      \endgroup}%
    \setbox\ipsj@secboxb\hbox{#6{%
      {\hskip #3\relax{\csname #2@font\endcsname \@svsec}}}}%
    \ifdim \wd\ipsj@secboxa > \columnwidth
      \@tempdima\columnwidth
      \advance\@tempdima-\wd\ipsj@secboxb
      \begingroup
      \mbox{}\par%
      \vspace{-\baselineskip}%%
      \addvspace{\section@height}%
      \addvspace{-.9mm}%
      \noindent%
      #6{\@hangfrom{\hskip #3\relax\@svsec}%
        \interlinepenalty \@M
        \hangindent\wd\ipsj@secboxb\hangafter=1
        #8\@@par}\nobreak%
      \vspace{-.7mm}%
      \addvspace{\section@height}%
      \endgroup
    \else
      \begingroup
      \mbox{}\par%
      \vspace{-\baselineskip}%%
      \noindent
      {\vbox to 8.65mm
        {\vfill%
         \addvspace{.54\Cvs}
         #6{\@hangfrom{\hskip #3\relax\@svsec}%
           \interlinepenalty \@M {#8}\@@par%
         }\nobreak%
         \vfill
        }%
       }
      \endgroup
    \fi
    \par
    \csname #1mark\endcsname{#7}%
    \addcontentsline{toc}{#1}{%
      \ifnum #2>\c@secnumdepth \else%
        \protect\numberline{\csname the#1\endcsname}\hskip1em%
      \fi%
      {#7}}%
  \else
    \def\@svsechd{%
      #6{\hskip #3\relax
      \@svsec #8}%
      \csname #1mark\endcsname{#7}%
      \addcontentsline{toc}{#1}{%
        \ifnum #2>\c@secnumdepth \else%
         \protect\numberline{\csname the#1\endcsname}%
        \fi%
        #7}}%
  \fi
  \@xsect{#5}}
\else
\def\@sectA#1#2#3#4#5#6[#7]#8{%
  \ifnum #2>\c@secnumdepth
    \let\@svsec\@empty
  \else
    \refstepcounter{#1}%
    \protected@edef\@svsec{\@seccntformat{#1}\relax}%
  \fi
  \@tempskipa #5\relax
  \ifdim \@tempskipa>\z@
    \setbox\ipsj@secboxa\hbox{%
      \begingroup
      \noindent
      #6{\@hangfrom{\hskip #3\relax\@svsec}}%
      \interlinepenalty \@M {{#8}}%
      \endgroup}%
    \setbox\ipsj@secboxb\hbox{#6{%
      {\hskip #3\relax{\csname #2@font\endcsname \@svsec}}}}%
    \ifdim \wd\ipsj@secboxa > \columnwidth
      \@tempdima\columnwidth
      \advance\@tempdima-\wd\ipsj@secboxb
      \begingroup
      \mbox{}\par%
      \vspace{-\baselineskip}%%
      \addvspace{.65\Cvs}%
      \noindent%
      #6{\@hangfrom{\hskip #3\relax\@svsec}%
        \interlinepenalty \@M
        \hangindent\wd\ipsj@secboxb\hangafter=1
        #8\@@par}\nobreak{\par}%
      \addvspace{.74\Cvs}%
      \endgroup
    \else
      \begingroup
      \mbox{}\par%
      \vspace{-\baselineskip}%%
      \noindent
      {\vbox to 2.43\Cvs{\vfill%
        #6{\@hangfrom{\hskip #3\relax\@svsec}%
          \interlinepenalty \@M {#8}\@@par}%
        \vfill}%
       }\@@par%
      \endgroup
    \fi
    \par\prevdepth=-1000pt%
    \csname #1mark\endcsname{#7}%
    \addcontentsline{toc}{#1}{%
      \ifnum #2>\c@secnumdepth \else%
        \protect\numberline{\csname the#1\endcsname}\hskip1\zw%
      \fi%
      {#7}}%
  \else
    \def\@svsechd{%
      #6{\hskip #3\relax
      \@svsec #8}%
      \csname #1mark\endcsname{#7}%
      \addcontentsline{toc}{#1}{%
        \ifnum #2>\c@secnumdepth \else%
         \protect\numberline{\csname the#1\endcsname}%
        \fi%
        #7}}%
  \fi
  \@xsect{#5}}
\fi

\def\@xsect#1{%
  \@tempskipa #1\relax
  \ifdim \@tempskipa>\z@
    \par \nobreak
    \vskip \@tempskipa
    \@afterheading
  \else
    \@nobreakfalse
    \global\@noskipsectrue
    \everypar{%
      \if@noskipsec
        \global\@noskipsecfalse
       {\setbox\z@\lastbox}%
        \clubpenalty\z@
        \begingroup \@svsechd \endgroup
        \unskip
        \@tempskipa #1\relax
        \hskip -\@tempskipa
      \else
        \clubpenalty \@clubpenalty
        \everypar{}%
      \fi}%
  \fi
  \ignorespaces}

\def\@ssectA#1#2#3#4#5{%
  \@tempskipa #3\relax
  \ifdim \@tempskipa>\z@
    \begingroup
    \mbox{}\par%
    \vspace{-\baselineskip}%%
    \addvspace{.5\Cvs}%
    \noindent%
    #4{%
      \@hangfrom{\hskip #1}%
        \interlinepenalty \@M #5\@@par}%
    \addvspace{.5\Cvs}%
    \endgroup
  \else
    \def\@svsechd{#4{\hskip #1\relax #5}}%
  \fi
  \@xsect{#3}}

%% Inside \appendix, a starred \section* (used once, internally, for
%% the "付録"/"Appendix" banner) reverts to the kernel's plain \@ssect
%% instead of \@ssectA: the original swaps in \@startsectionAPP there,
%% whose starred branch calls \@ssectC (itself equivalent to the
%% kernel's \@ssect, see CLAUDE.md Sec.4.17) rather than its own
%% \@sectA-style mechanism. Its non-starred branch (\@sectAPP in the
%% original) is otherwise byte-for-byte identical to \@sectA, so it is
%% reused here rather than duplicated.
\def\@startsectionAPP#1#2#3#4#5#6{%
  \if@noskipsec \leavevmode \fi
  \par
  \@tempskipa #4\relax
  \@afterindenttrue
  \ifdim \@tempskipa <\z@
    \@tempskipa -\@tempskipa \@afterindentfalse
  \fi
  \if@nobreak
    \everypar{}%
  \else
    \addpenalty\@secpenalty\addvspace\@tempskipa
  \fi
  \@ifstar
    {\@ssect{#3}{#4}{#5}{#6}}%
    {\@dblarg{\@sectA{#1}{#2}{#3}{#4}{#5}{#6}}}}

\renewcommand{\section}{\@startsectionA{section}{1}{\z@}%
  {.00001\Cvs}{.00001\Cvs}%
  {\reset@font\fontsize{16\JQ}{21\h}\gtfamily\bfseries\mathversion{bold}\selectfont}}
\renewcommand{\subsection}{\@startsection{subsection}{2}{\z@}%
  {\Cvs}{.00001\Cvs}%
  {\reset@font\normalsize\gtfamily\bfseries\mathversion{bold}\selectfont}}
\renewcommand{\subsubsection}{\@startsection{subsubsection}{3}{\z@}%
  {0.00001\Cvs}{0.00001\Cvs}%
  {\reset@font\normalsize\gtfamily\bfseries\mathversion{bold}\selectfont}}
\renewcommand{\paragraph}{\@startsection{paragraph}{3}{\z@}%
  {0.00001\Cvs}{0.00001\Cvs}%
  {\reset@font\normalsize\gtfamily\bfseries\selectfont}}
\renewcommand{\subparagraph}{\@startsection{subparagraph}{3}{\z@}%
  {0.00001\Cvs}{0.00001\Cvs}%
  {\reset@font\normalsize\gtfamily\bfseries\selectfont}}

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
  \renewcommand{\section}{\@startsectionAPP{section}{1}{\z@}%
    {.00001\Cvs}{.00001\Cvs}%
    {\reset@font\fontsize{16\JQ}{21\h}\gtfamily\bfseries\mathversion{bold}\selectfont}}%
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

%% Inside figure/table, \center is redirected to this \trivlist-based
%% version (rigid, no plus/minus stretch), not the kernel's \list-based
%% center environment, matching the original's \@floatenv.
\def\Center{\topsep\z@\parsep\z@\partopsep\z@\itemsep\z@
  \trivlist\centering\item\relax}
\def\endCenter{\endtrivlist}
\def\@floatenv{\let\center\Center}

%% The kernel's \@floatboxreset (called by \@float/\@dblfloat at the start
%% of every figure/table) does not change the font size; the original
%% overrides it to switch all float content to \footnotesize. Without this,
%% float content inherits \normalsize from the surrounding text, which is
%% wide enough to make tables overflow \hsize/\textwidth (observed with
%% \tabular content that fits only at \footnotesize).
\def\@floatboxreset{%
  \reset@font
  \footnotesize\baselineskip16\h
  \@setminipage
}

\renewcommand{\thefigure}{\@arabic\c@figure}
\def\fps@figure{tbp}\def\ftype@figure{1}\def\ext@figure{lof}
\def\fnum@figure{\figurename~\thefigure}
\def\fnum@efigure{Fig.~\thefigure}
\renewenvironment{figure}
  {\@floatenv\capwidth\hsize\ecapwidth\hsize
   \abovecaptionskip1mm\belowcaptionskip\z@\@float{figure}}
  {\end@float}
\renewenvironment{figure*}
  {\@floatenv\capwidth.66\textwidth\ecapwidth.66\textwidth
   \abovecaptionskip1mm\belowcaptionskip\z@\@dblfloat{figure}}
  {\end@dblfloat}

\renewcommand{\thetable}{\@arabic\c@table}
\def\fps@table{tbp}\def\ftype@table{2}\def\ext@table{lot}
\def\fnum@table{\tablename~\thetable}
\def\fnum@etable{Table~\thetable}
\renewenvironment{table}
  {\@floatenv\capwidth\hsize\ecapwidth\hsize
   \abovecaptionskip\z@\belowcaptionskip1mm\@float{table}}
  {\end@float}
\renewenvironment{table*}
  {\@floatenv\capwidth.66\textwidth\ecapwidth.66\textwidth
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

%% Bold Japanese text has no genuine Mincho-Bold shape in the original
%% toolchain, so the original always renders it via Gothic instead (see
%% CLAUDE.md); \gtfamily makes that explicit for the "図1"/"表1" label.
%% Guarded by \ifDS@english since \@makecaption/\@twocolcaption are also
%% used for plain-English \caption calls in english-mode documents (see
%% esample.tex), where there is no kanji and \gtfamily would be a no-op
%% at best -- but switching the (unused) kanji family still perturbs
%% luatexja's line-height bookkeeping enough to shift pagination by a
%% line, so it must not be applied there.
\def\ipsj@boldlabel{\ifDS@english\bfseries\else\gtfamily\bfseries\fi}

\long\def\@makecaption#1#2{%
  \setbox\ipsj@boxa\hbox{\footnotesize{\ipsj@boldlabel#1}\hskip1\zw{#2}}%
  \setbox\ipsj@boxb\hbox{\footnotesize{\ipsj@boldlabel#1}\hskip1\zw}%
  \ifdim\wd\ipsj@boxa>\capwidth
    \hfil\parbox[t]{\capwidth}{\hangindent\wd\ipsj@boxb
      {\ipsj@boldlabel#1}\hskip1\zw#2}\par
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
  \setbox\ipsj@boxa\hbox{{\ipsj@boldlabel\csname fnum@#1\endcsname}\hskip1\zw#3}%
  \setbox\ipsj@boxb\hbox{{\ipsj@boldlabel\csname fnum@#1\endcsname}\hskip1\zw}%
  \ifdim\wd\ipsj@boxa>\twocolcapwidth
    \hbox to\textwidth{\hfil\parbox[t]{\twocolcapwidth}{\hangindent\wd\ipsj@boxb
      {\ipsj@boldlabel\csname fnum@#1\endcsname}\hskip1\zw#3}\hfil}\par
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
%% 15b. \figref/\tabref, \Editor, \urlj/\urle/\doi, \acknowledgment,
%%      capitalised list-environment variants
%% =================================================================

%% \< is a pTeX-era kerning/boundary hint with no luatexja equivalent
%% need; treated as a no-op so existing source text using it still
%% compiles unchanged.
\let\<\relax

%% Full-width colon set to a fixed 1zw width and protected from line
%% breaking before it.
\ifDS@english\else
  \def\：{\nobreak\protect\makebox[1\zw][l]{：}\ignorespaces}
\fi

\def\CaptionType{\def\@captype}

%% --- \figref/\tabref family -----------------------------------------
\def\long@fig{\ifDS@english Figure~\nobreak\else\figurename~\nobreak\fi}
\def\short@fig{\ifDS@english Fig.\,\nobreak\else\figurename~\nobreak\fi}
\def\long@figs{\ifDS@english Figures~\nobreak\else\figurename~\nobreak\fi}
\def\short@figs{\ifDS@english Figs.\,\nobreak\else\figurename~\nobreak\fi}
\def\long@tab{\ifDS@english Table~\else\tablename~\nobreak\fi}
\def\short@tab{\ifDS@english Table~\else\tablename~\nobreak\fi}
\def\long@tabs{\ifDS@english Tables~\else\tablename~\nobreak\fi}
\def\short@tabs{\ifDS@english Tables~\else\tablename~\nobreak\fi}

\def\Figref{\bgroup\let\prefix@figtabref\long@fig\@ifstar\figtabref@star\figtabref@}
\def\figref{\bgroup\let\prefix@figtabref\short@fig\@ifstar\figtabref@star\figtabref@}
\def\Figsref{\bgroup\let\prefix@figtabref\long@figs\@ifstar\figtabref@star\figtabref@}
\def\figsref{\bgroup\let\prefix@figtabref\short@figs\@ifstar\figtabref@star\figtabref@}
\def\Tabref{\bgroup\let\prefix@figtabref\long@tab\@ifstar\figtabref@star\figtabref@}
\def\tabref{\bgroup\let\prefix@figtabref\short@tab\@ifstar\figtabref@star\figtabref@}
\def\Tabsref{\bgroup\let\prefix@figtabref\long@tabs\@ifstar\figtabref@star\figtabref@}
\def\tabsref{\bgroup\let\prefix@figtabref\short@tabs\@ifstar\figtabref@star\figtabref@}

%% The first reference to a given figure/table label is set bold; any
%% later reference to the same label is set in the normal weight.
\def\figtabref@star#1{\prefix@figtabref\ref{#1}\egroup}
\def\figtabref@#1{%
  \let\bf@or@normal\normalfont
  \@ifundefined{ipsj@used@#1}{%
    \expandafter\gdef\csname ipsj@used@#1\endcsname{1}%
    %% Japanese "図"/"表" has no real Mincho-Bold in the original
    %% toolchain (see CLAUDE.md); English "Fig./Table" keeps its
    %% ordinary (Latin) bold.
    \ifDS@english\let\bf@or@normal\bfseries\else\def\bf@or@normal{\gtfamily\bfseries}\fi}{}%
  \bf@or@normal\prefix@figtabref\ref{#1}\egroup}

%% --- Editor-in-charge (TOD/TBIO/CVA/SLDM) -----------------------------
\def\Ediname{\csname ipsj@ediname@\@iptype\endcsname}
\def\ipsj@ediname@DAM{\ifDS@english Editor in Charge:\else 担当編集委員\fi}
\def\ipsj@ediname@TBIO{Communicated by}
\def\ipsj@ediname@CVA{Communicated by}
\def\ipsj@ediname@SLDM{\ifDS@invited Invited by Editor-in-Chief:%
  \else Recommended by Associate Editor:\fi}
\let\ipsj@ediname@TOD\ipsj@ediname@DAM
\def\Edifont{\normalfont\normalsize}
\def\Editor#1{%
  \vspace{-.5\baselineskip}%
  \ifDS@english
    \noindent\hfill({\Edifont\Ediname})\hskip.5em\textit{#1})%
  \else
    \noindent\hfill（{\Edifont\Ediname}）\hskip1\zw#1）%
  \fi}

%% --- URLs / DOIs / access dates in bibliography entries --------------
\def\urlj{\@ifnextchar[{\ipsj@n@urlj}{\ipsj@@urlj}}
\def\ipsj@n@urlj[#1]#2{\normalfont
  \if#11入手先\\ \fi
  $\langle$\nobreak{#2}\nobreak$\rangle$}
\def\ipsj@@urlj#1{\normalfont 入手先$\langle$\nobreak{#1}\nobreak$\rangle$}
\def\urle{\@ifnextchar[{\ipsj@n@urle}{\ipsj@@urle}}
\def\ipsj@n@urle[#1]#2{\normalfont
  \if#11available\\ from\else\if#12available from\\ \fi\fi
  $\langle$\nobreak{#2}\nobreak$\rangle$}
\def\ipsj@@urle#1{\normalfont available from $\langle$\nobreak{#1}\nobreak$\rangle$}
\def\refdatej#1{\normalfont（参照{#1}）}
\def\refdatee#1{\normalfont(accessed {#1})}
\def\doi#1{\normalfont DOI: #1}

%% --- Editor's recommendation (SLDM etc.) ------------------------------
\newenvironment{recommendation}{%
  \normalsize
  \par\vskip\baselineskip
  \ifDS@english
    \noindent{\bfseries Editor's Recommendation}\par
  \else
    \noindent{\gtfamily\bfseries 推薦文}\par
  \fi}{\par}

%% --- Acknowledgments --------------------------------------------------
%% \end{acknowledgment} looks up \endacknowledgment via \csname, which
%% auto-defines it to \relax when absent -- intentionally not defined.
\def\acknowledgment{\par
  \ifDS@english{\bfseries Acknowledgments}\hskip1em\ignorespaces%
  \else{\gtfamily\bfseries 謝辞}\hskip1\zw\ignorespaces\fi}

%% --- enumerate / itemize / description: IPSJ label & margin style ----
%% The original class overrides these directly (not just the
%% capitalised Enumerate/Itemize/Description variants below): labels
%% are parenthesised, e.g. "(1)" instead of article.cls's "1.", and the
%% label column is a fixed 2\Cwd instead of article.cls's narrower,
%% stretchable defaults.
\renewcommand{\labelenumi}{(\,\theenumi\,)}
\renewcommand{\theenumi}{\arabic{enumi}}
\renewcommand{\labelenumii}{(\,\theenumii\,)}
\renewcommand{\theenumii}{\alph{enumii}}
\renewcommand{\p@enumii}{\theenumi}
\renewcommand{\labelenumiii}{(\,\theenumiii\,)}
\renewcommand{\theenumiii}{\roman{enumiii}}
\renewcommand{\p@enumiii}{\theenumi(\theenumii)}
\renewcommand{\labelenumiv}{(\,\theenumiv\,)}
\renewcommand{\theenumiv}{\Alph{enumiv}}
\renewcommand{\p@enumiv}{\p@enumiii\theenumiii}

\renewenvironment{enumerate}{%
  \ifnum\@enumdepth>3 \@toodeep\else
    \advance\@enumdepth\@ne
    \edef\@enumctr{enum\romannumeral\the\@enumdepth}%
    \list{\csname label\@enumctr\endcsname}{%
      \usecounter{\@enumctr}\def\makelabel##1{##1\hss}%
      \leftmargin2\Cwd \labelwidth2\Cwd \labelsep\z@
      \itemsep\z@\topsep\z@\parsep\z@}%
  \fi}{\endlist}

\renewcommand{\labelitemi}{$\bullet$}
\renewcommand{\labelitemii}{\bfseries--}
\renewcommand{\labelitemiii}{$\ast$}
\renewcommand{\labelitemiv}{$\cdot$}

\renewenvironment{itemize}{%
  \ifnum\@itemdepth>3 \@toodeep\else
    \advance\@itemdepth\@ne
    \edef\@itemitem{labelitem\romannumeral\the\@itemdepth}%
    \list{\csname\@itemitem\endcsname}{%
      \def\makelabel##1{\hss##1\hss}%
      \labelwidth2\Cwd \labelsep\z@
      \itemsep\z@\topsep\z@\parsep\z@}%
  \fi}{\endlist}

\renewenvironment{description}{%
  \list{}{\labelwidth\z@ \labelsep\Cwd
    \itemsep\z@\topsep\z@\parsep\z@
    \itemindent\labelsep \advance\itemindent-\leftmargin
    \def\makelabel##1{\gtfamily\bfseries##1}}}{\endlist}

%% --- Capitalised list-environment variants --------------------------
%% \Enumerate/\Itemize/\Description tighten the trivlist margins so the
%% list sits flush with the surrounding paragraph (no extra indent);
%% the all-caps forms widen them by one extra \Cwd instead; the
%% asterisked forms shift the whole block by \Cwd in the other
%% direction. All three work by temporarily overriding the kernel's
%% \@trivlist -- which \list invokes internally to fix up \leftmargin/
%% \itemindent once the listdepth-specific defaults have already been
%% applied -- around a call to the corresponding plain environment.
\let\latex@trivlist\@trivlist
\def\lst@trivlist#1#2{%
  \itemsep\z@\topsep\z@\parsep\z@
  \leftmargin#1\relax
  \itemindent\labelwidth \advance\itemindent\labelsep
  \advance\itemindent#2\relax
  \let\@trivlist\latex@trivlist \@trivlist}

\def\lst@Trivlist{\def\@trivlist{\lst@trivlist\z@\z@}}
\@namedef{Enumerate}{\lst@Trivlist\enumerate}
\@namedef{endEnumerate}{\endlist}
\@namedef{Itemize}{\lst@Trivlist\itemize}
\@namedef{endItemize}{\endlist}
\@namedef{Description}{\lst@Trivlist\description}
\@namedef{endDescription}{\endlist}

\def\lst@TRIVLIST{\def\@trivlist{\lst@trivlist\z@\Cwd}}
\@namedef{ENUMERATE}{\lst@TRIVLIST\enumerate}
\@namedef{endENUMERATE}{\endlist}
\@namedef{ITEMIZE}{\lst@TRIVLIST\itemize}
\@namedef{endITEMIZE}{\endlist}
\@namedef{DESCRIPTION}{\lst@TRIVLIST\description}
\@namedef{endDESCRIPTION}{\endlist}

\def\lst@strivlist{\def\@trivlist{\lst@trivlist\Cwd{-\Cwd}}}
\@namedef{enumerate*}{\lst@strivlist\enumerate}
\@namedef{endenumerate*}{\endlist}
\@namedef{itemize*}{\lst@strivlist\itemize}
\@namedef{enditemize*}{\endlist}
\@namedef{description*}{\lst@strivlist\description}
\@namedef{enddescription*}{\endlist}

%% --- quote / quotation / verse: indent by \Cwd instead of article.cls's
%% em-based defaults, to match the original's full-width-character feel.
\renewenvironment{verse}{%
  \let\\\@centercr
  \list{}{\itemsep\z@\topsep\z@\parsep\z@
    \itemindent-\Cwd \listparindent\itemindent
    \rightmargin\leftmargin \advance\leftmargin\Cwd}%
  \item[]}{\endlist}

\renewenvironment{quotation}{%
  \list{}{\itemsep\z@\topsep\z@\parsep\z@
    \listparindent\Cwd \itemindent\listparindent
    \rightmargin\leftmargin}%
  \item[]}{\endlist}

\renewenvironment{quote}{%
  \list{}{\itemsep\z@\topsep\z@\parsep\z@
    \rightmargin\leftmargin}%
  \item[]}{\endlist}

%% --- \newtheorem: IPSJ style (theorem number optionally italicised,
%% via a \DESCRIPTION list rather than the kernel's plain trivlist) ----
%% This replaces the kernel's \newtheorem outright: the original
%% intercepts it to record, per theorem environment, whether the
%% counter/heading should be set in \theo@it (italic in English, no-op
%% in Japanese) before delegating to the kernel's own \@othm/\@nthm to
%% parse the remaining (standard) \newtheorem arguments.
\renewcommand{\newtheorem}{\@ifstar
  {\theo@newtheorem{\theo@it}{\ }}{\theo@newtheorem{}{\theo@sp}}}
\def\theo@newtheorem#1#2#3{%
  \@namedef{theo@it@#3}{#1}\@namedef{theo@sp@#3}{#2}%
  \@ifnextchar[{\@othm{#3}}{\@nthm{#3}}}
\def\@begintheorem#1#2{\DESCRIPTION \csname theo@it@\@currenvir\endcsname
  \item[#1\csname theo@sp@\@currenvir\endcsname #2]}
\def\@opargbegintheorem#1#2#3{\DESCRIPTION
  \csname theo@style@\@currenvir\endcsname
  \item[#1\csname theo@sp@\@currenvir\endcsname #2\ (#3)]}
\let\@endtheorem\endlist
\ifDS@english
  \let\theo@it\itshape \let\theo@sp\ %
\else
  \let\theo@it\relax \let\theo@sp\relax
\fi

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

%% \cite{a,b,c} sorts and deduplicates the citation numbers (e.g.
%% \cite{ref5,ref1,ref3} prints "[1, 3, 5]", not "[5, 1, 3]"), unlike
%% the kernel's plain \@citex/\@cite, which preserve typed order. This
%% replaces those two kernel macros and the plain-TeX sorted-list
%% utility macros they're built on; engine-agnostic, ported verbatim.
\def\@cite@itemsep{,\penalty\@m\ }
\def\@cite@firstdelim{}
\def\@cite@lastdelim{}
\def\@cite#1#2{%
   \ifvmode\leavevmode\fi\nobreak
   \if@tempswa\@cite@without@comment{#1}{#2}%
   \else      \@cite@with@comment{#1}%
   \fi}
\def\@cite@without@comment#1#2{%
   \@cite@firstdelim{#1, #2}\@cite@lastdelim}%
\def\@cite@with@comment#1{%
   \@cite@firstdelim{#1}\@cite@lastdelim}
\def\@citex[#1]#2{%
   \let\@cite@reference@list\@empty
   \let\@cite@undefined@reference\@empty
   \@for\@tempa:=#2\do{%
      \edef\@tempa{\expandafter\@firstofone\@tempa\@empty}%
      \if@filesw
         \immediate\write\@auxout{\string\citation{\@tempa}}%
      \fi
      \@ifundefined{b@\@tempa}%
      {\G@refundefinedtrue
          \@latex@warning{Citation `\@tempa' on page
          \thepage \space undefined}%
       \def\@cite@undefined@reference{%
           \@cite@put@itemsep
            \mbox{\reset@font\bfseries ?}}}%
       {\edef\@tempb{{\@nameuse{b@\@tempa}}}%
        \expandafter\@append@list\expandafter
           \@cite@reference@list\@tempb}}%
       \@simplify@list\@cite@reference@list
       \@ascending@sort@list\@cite@reference@list\@compare@num
       \@cite{{\let\@elt\@cite@output@elt
               \def\@cite@put@itemsep{%
                  \def\@cite@put@itemsep{\@cite@itemsep}}%
                \@cite@reference@list
                \@cite@undefined@reference}}%
        {#1}}%
\def\@cite@output@elt#1{%
    \@cite@put@itemsep
    \bgroup[#1]\egroup}
\def\@append@list#1#2{\@addto@macro#1{\@elt{#2}}}%
\def\@addto@macro#1#2{\expandafter\def\expandafter#1\expandafter{#1#2}}
\def\@simplify@list#1{%
   \begingroup
      \let\@templist\@empty
      \loop\ifx#1\@empty\else
         \@pop@list\@firstterm#1%
         \expandafter\@append@list\expandafter\@templist
             \expandafter{\@firstterm}%
         \expandafter\@remove@from@list\expandafter#1%
             \expandafter{\@firstterm}%
      \repeat
      \expandafter\endgroup\expandafter
         \def\expandafter#1\expandafter{\@templist}}
\def\@remove@from@list#1#2{%
    \begingroup
    \let\@templist\@empty
    \def\@to@be@removed{#2}%
    \let\@elt\@remove@from@list@elt
     #1%
    \expandafter\endgroup\expandafter
      \def\expandafter#1\expandafter{\@templist}}
\def\@remove@from@list@elt#1{%
   \def\@tempa{#1}%
   \ifx\@tempa\@to@be@removed\else
      \@append@list\@templist{#1}%
   \fi}%
\def\@pop@list#1#2{%
   \ifx#2\@empty\let#1\@empty
   \else        \expandafter\@pop@list@#2\@nil#1#2%
   \fi}
\def\@pop@list@\@elt#1#2\@nil#3#4{\def#3{#1}\def#4{#2}}
\newcount\@compare@result
\def\@compare@num#1#2{%
    \@compare@result#1\relax
    \advance\@compare@result-#2\relax}
\def\@ascending@sort@list{\@sort@list<}
\def\@descending@sort@list{\@sort@list>}
\def\@sort@list#1#2#3{%
   \begingroup
   \let\@sort@templista\@empty
   \def\@elt##1{%
      \@addto@sorted@list#1\@sort@templista{#3}{##1}}%
   #2%
   \expandafter\endgroup\expandafter
      \def\expandafter#2\expandafter{\@sort@templista}}
\newif\if@ignore@same@item
\def\@addto@sorted@list#1#2#3#4{%
    \begingroup
    \let\@sort@templistb\@empty
    \def\@tempz{\@elt{#4}}%
    \def\@elt##1{%
        #3{##1}{#4}%
        \def\@tempa{\@elt{##1}}%
        \let\@tempb\@empty
        \ifnum\z@#1\@compare@result
           \@csc@t\@tempa\@tempz\@tempa
           \def\@tempb{\@addto@sorted@list@skip}%
        \else
            \ifnum\z@=\@compare@result
                \if@ignore@same@item
                     \def\@tempb{\@addto@sorted@list@skip}%
                \fi
            \fi
        \fi
        \@csc@t\@sort@templistb\@sort@templistb\@tempa
        \@tempb}%
     #2\@addto@sorted@list@{\@elt{#4}}%
     \expandafter\endgroup\expandafter
         \def\expandafter#2\expandafter{\@sort@templistb}}%
\def\@addto@sorted@list@skip#1\@addto@sorted@list@#2{%
    \@addto@sorted@list@{#1}}
\def\@addto@sorted@list@#1{\@addto@macro\@sort@templistb{#1}}
\def\@csc@t#1#2#3{%
   \expandafter\expandafter\expandafter\def
   \expandafter\expandafter\expandafter#1%
   \expandafter\expandafter\expandafter{%
   \expandafter#2#3}}

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

%% In Japanese mode \footnotemark suppresses the small Japanese/Latin
%% inter-character glue before the mark, for a tighter look.
\let\ipsj@footnotemark\footnotemark
\ifDS@english\else
  \def\footnotemark{\inhibitglue\ipsj@footnotemark}
\fi

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

%% A profile entry is built from two independently positioned
%% zero-width ("pushed to the wall") boxes stacked at the same origin:
%% the 25mm x 31mm photo/frame box on the left, and a \hangindent'd
%% text block (name, membership line, then the biography body) that
%% wraps around it for its first few lines. Both live inside an outer
%% one-column-wide minipage so the whole entry behaves as a single
%% paragraph-like unit that \biography can stack vertically.
\ifDS@techrep\else
\ifDS@english
\def\ip@eprofile[#1]#2#3{%
  \noindent\begin{minipage}[t]{\columnwidth}%
  \IfFileExists{#1.eps}{%
    \raisebox{-28mm}{\pushtowall{\resizebox{25mm}{31mm}{\includegraphics{#1.eps}}}}}{%
  \raisebox{2.2mm}{\pushtowall{\begin{minipage}[t]{25mm}
    \hrule\@height.1mm
    \hbox to 25mm{\vrule\@width.1mm\@height31mm\hss\vrule\@width.1mm\@height31mm}%
    \hrule\@height.1mm
  \end{minipage}}}}%
  \pushtowall{\begin{minipage}[t]{\columnwidth}%
    \hangindent30mm\hangafter-8\relax
    \mbox{\fontsize{13\Q}{18\h}\bfseries\selectfont#2}\hskip.5em\@BreakMember
    \baselineskip18\h{\fontsize{13\Q}{18\h}\selectfont#3}%
  \end{minipage}}%
  \end{minipage}\global\let\@BreakMember\relax\par\vskip2\Cvs}
\def\no@eprofile#1#2{%
  \noindent\begin{minipage}[t]{\columnwidth}%
  \raisebox{3mm}{\pushtowall{\begin{minipage}[t]{25mm}
    \hrule\@height.1mm
    \hbox to 25mm{\vrule\@width.1mm\@height31mm\hss\vrule\@width.1mm\@height31mm}%
    \hrule\@height.1mm
  \end{minipage}}}%
  \pushtowall{\begin{minipage}[t]{\columnwidth}%
    \hangindent30mm\hangafter-8\relax
    \mbox{\fontsize{13\Q}{18\h}\bfseries\selectfont#1}\hskip.5em\@BreakMember
    \baselineskip18\h{\fontsize{13\Q}{18\h}\selectfont#2}%
  \end{minipage}}%
  \end{minipage}\global\let\@BreakMember\relax\par\vskip2\Cvs}
\def\n@eprofile#1#2{%
  \noindent\begin{minipage}[t]{\columnwidth}%
  \pushtowall{\begin{minipage}[t]{\columnwidth}%
    \mbox{\fontsize{13\Q}{18\h}\bfseries\selectfont#1}\hskip.5em\@BreakMember
    \baselineskip18\h{\fontsize{13\Q}{18\h}\selectfont#2}%
  \end{minipage}}%
  \end{minipage}\global\let\@BreakMember\relax\par\vskip2\Cvs}
\else
\def\ip@eprofile[#1]#2#3#4{%
  \noindent\begin{minipage}[t]{\columnwidth}%
  \IfFileExists{#1.eps}{%
    \raisebox{-28mm}{\pushtowall{\resizebox{25mm}{31mm}{\includegraphics{#1.eps}}}}}{%
  \raisebox{3mm}{\pushtowall{\begin{minipage}[t]{25mm}
    \hrule\@height.1mm
    \hbox to 25mm{\vrule\@width.1mm\@height31mm\hss\vrule\@width.1mm\@height31mm}%
    \hrule\@height.1mm
  \end{minipage}}}}%
  \pushtowall{\begin{minipage}[t]{\columnwidth}%
    \hangindent30mm\hangafter-7\relax
    \mbox{\fontsize{15\JQ}{0\h}\gtfamily\bfseries\selectfont#3}\hskip1.6\zw\@BreakMember
    \ipsj@setmember{#2}%
    \hangindent30mm{\normalsize\inhibitglue\@@member}\\[.5\Cvs]
    \baselineskip21\h{\fontsize{13\JQ}{21\h}\selectfont#4\@title@member}%
  \end{minipage}}%
  \end{minipage}\global\let\@BreakMember\relax\par\vskip2\Cvs}
\def\no@eprofile#1#2#3{%
  \noindent\begin{minipage}[t]{\columnwidth}%
  \raisebox{3mm}{\pushtowall{\begin{minipage}[t]{25mm}
    \hrule\@height.1mm
    \hbox to 25mm{\vrule\@width.1mm\@height31mm\hss\vrule\@width.1mm\@height31mm}%
    \hrule\@height.1mm
  \end{minipage}}}%
  \pushtowall{\begin{minipage}[t]{\columnwidth}%
    \hangindent30mm\hangafter-7\relax
    \mbox{\fontsize{15\JQ}{0\h}\gtfamily\bfseries\selectfont#2}\hskip1.6\zw\@BreakMember
    \ipsj@setmember{#1}%
    \hangindent30mm{\normalsize\inhibitglue\@@member}\\[.5\Cvs]
    \baselineskip21\h{\fontsize{13\JQ}{21\h}\selectfont#3\@title@member}%
  \end{minipage}}%
  \end{minipage}\global\let\@BreakMember\relax\par\vskip2\Cvs}
\def\n@eprofile#1#2#3{%
  \noindent\begin{minipage}[t]{\columnwidth}%
  \pushtowall{\begin{minipage}[t]{\columnwidth}%
    \mbox{\fontsize{15\JQ}{0\h}\gtfamily\bfseries\selectfont#2}\hskip1.6\zw\@BreakMember
    \ipsj@setmember{#1}%
    {\normalsize\inhibitglue\@@member}\\[.5\Cvs]
    \baselineskip21\h{\fontsize{13\JQ}{21\h}\selectfont#3\@title@member}%
  \end{minipage}}%
  \end{minipage}\global\let\@BreakMember\relax\par\vskip2\Cvs}
\fi
\fi
%% \inhibitglue above is luatexja-core's own command (loaded in Sec.2);
%% it must not be redefined to \relax here, or the calls above
%% (suppressing the Japanese/Latin inter-character glue before the
%% membership-type parenthetical) go silently inert.
\def\@@member{}
\def\@title@member{}
%% #1 = comma-separated membership codes (see \h@member etc. above).
\def\ipsj@setmember#1{%
  \def\@@member{}\def\@title@member{}%
  \@for\@temp:=#1\do{%
    \@ifundefined{\@temp @member}{}{\edef\@@member{（\csname\@temp @member\endcsname）}}%
    \@ifundefined{\@temp @title@member}{}{\edef\@title@member{\csname\@temp @title@member\endcsname．}}}}

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

%% =================================================================
%% 20. Miscellaneous utility macros
%% =================================================================

%% \ruby{base}{furigana}: small reading text stacked above the base
%% text, both centered to whichever is wider.
\def\ruby#1#2{\leavevmode\setbox0=\hbox{#1}\setbox1=\hbox{\tiny#2}%
  \ifdim\wd0>\wd1 \dimen0=\wd0\else\dimen0=\wd1\fi
  \hbox{\ltjsetparameter{kanjiskip={0pt plus 1fill minus 1fill}}%
    \vbox{\hbox to\dimen0{\tiny\hfil#2\hfil}%
      \nointerlineskip\hbox to\dimen0{\hfil#1\hfil}}}}

%% End-of-proof marker ("\Box" flush right at the end of a proof).
\def\QED{{\unskip\nobreak\hfil\penalty50
  \hskip1\zw\hbox{}\nobreak\hfil\hbox{$\Box$\hskip1\zw}
  \parfillskip\z@\finalhyphendemerits\z@\par}}

%% \MARU{n}: the digit(s) n set inside a circle (e.g. circled footnote
%% markers); two-digit numbers are squeezed horizontally to fit.
\def\MARU#1{\raisebox{0.1zh}{{\rm
  \ooalign{\hfil\lower.168ex\hbox{\ifnum#1<10\relax{#1}\else\scalebox{.5}[1]{#1}\fi}%
    \hfil\crcr\mathhexbox20D}}}}

%% \contact{...}: accepted for backward compatibility with old
%% manuscripts; intentionally renders nothing (matches the original).
\long\def\contact#1{}

%% Thicker (0.4mm) table rule, for use inside tabular via \noalign.
\def\Hline{\noalign{\hrule height0.4mm}}

%% Double-em-dash mark (e.g. "same author as above" in a bibliography).
\ifDS@english
  \def\ddash{\leavevmode\raise.1mm\hbox to1.95em{\hfil---\hss---\hfil}}
\else
  \def\ddash{\leavevmode\raise.1zh\hbox to2\zw{---\hss---}}
\fi
\let\doubledash\ddash

%% Reserve blank vertical space for a figure to be physically pasted in
%% later (a holdover from camera-ready paste-up manuscript prep).
\def\dummyfigure#1{\begin{figure}[b]\vspace{#1}\vskip\abovecaptionskip
  \phantom{\box\@dummyfigbox}\par\end{figure}}
\def\dummyfiguret#1{\begin{figure}[t]\vspace{#1}\vskip\abovecaptionskip
  \phantom{\box\@dummyfigbox}\par\end{figure}}

\endinput
