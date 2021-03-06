%! Suppress = FileNotFound
%%----------------------------------------------------------------------------------------------------------------------
%% Copyright (C) 2019 by Niko Strijbol
%%
%% This file may be distributed and/or modified under the conditions of the LaTeX Project Public License, either
%% version 1.3c of this license or (at your option) any later version. The latest version of this license is in:
%%
%%      http://www.latex-project.org/lppl.txt
%%
%% and version 1.3c or later is part of all distributions of LaTeX version 2006/05/20 or later.
%%----------------------------------------------------------------------------------------------------------------------
%%
%% CLASS_NAME ugent2016
%% Author: Niko Strijbol
%% 18/05/2019
%%
%% Provides a class for Ghent University styles. See the manual for more details.

\NeedsTeXFormat{LaTeX2e}[2017/01/01]
\ProvidesPackage{ugent2016}[2020/05/28 UGent2016 Class]

% Load our stuff at the end of the preamble. This allows the user to override loaded packages.
\RequirePackage{etoolbox}
% Used to parse options for this package.
\RequirePackage{kvoptions}
% Compare strings
\RequirePackage{xstring}

\SetupKeyvalOptions{
    family=ugentcls,
    prefix=ugentcls@
}

% Expose all options of the style package.
\DeclareStringOption[report]{type}
\DeclareStringOption[we]{faculty}
\DeclareStringOption[ugent]{campus}

% Define whether the footer should be shown or not.
\DeclareStringOption[auto]{footer}
% How much of the document we want to style.
\DeclareStringOption[titlefont]{layout}
% Define the underlying class
\DeclareStringOption[auto]{baseclass}
% Define whether the titles should be underlined or not.
% This is on by default; the underlining has some issues with thickness and spacing.
\DeclareBoolOption[false]{underline}
% Define whether the titles should be forced to uppercase or not.
% This is on by default; there should be no issues.
\DeclareBoolOption[true]{uppercase}

% Options for the title pages.
% Define whether the titles should be underlined or not.
% This is on by default; the underlining has some issues with thickness and spacing.
\DeclareBoolOption[true]{titleUnderline}
% Define whether the titles should be forced to uppercase or not.
% This is on by default; there should be no issues.
\DeclareBoolOption[true]{titleUppercase}

% Define if spacing should be applied to text, titles, etc.
\DeclareBoolOption{spacing}

% Other options are passed to the underlying class, allowing it to be configured as well.
\ProcessKeyvalOptions*

% Utility to check if a string is in a list of strings.
\providecommand*{\IfStringInList}[2]{\IfSubStr{,#2,}{,#1,}}

% Validate the class.
\IfStringInList{\ugentcls@baseclass}{scrreprt,scrartcl,scrbook,auto}{}{%
    \PackageError{\@currname}{Unknown underlying base class provided: \ugentcls@baseclass}{%
        The class must be one of [scrreprt,scrartcl,scrbook,auto].
    }
}

% If the baseclass option equals "auto", determine it from the type.
% We map course => book, report => report, notes => article.
% By default, set the class to the provided value.
\newcommand*{\ugentcls@class}{\ugentcls@baseclass}
% Redefine if auto
\IfStrEq{\ugentcls@baseclass}{auto}{%
    \IfStrEqCase{\ugentcls@type}{%
        {report}{\renewcommand*{\ugentcls@class}{scrreprt}}%
        {course}{\renewcommand*{\ugentcls@class}{scrbook}}%
        {notes}{\renewcommand*{\ugentcls@class}{scrartcl}}%
    }[\PackageError{\@currname}{Undefined option to type: \ugentcls@type}{}]
}{}

\PackageInfo{\@currname}{Passing options to \ugentcls@class class: \@unusedoptionlist}

% Pass the options to and load the base class.
\PassOptionsToClass{\@unusedoptionlist}{\ugentcls@class}
\LoadClass{\ugentcls@class}

% Provide whether the footer should be shown or not.
\newtoggle{showfooter}
\IfStrEq{\ugentcls@footer}{auto}{%
    \IfStrEq{\ugentcls@type}{notes}{%
        \toggletrue{showfooter}
    }{%
        \togglefalse{showfooter}
    }
}{}
\IfStrEq{\ugentcls@footer}{false}{%
    \togglefalse{showfooter}
}{}
\IfStrEq{\ugentcls@footer}{true}{%
    \toggletrue{showfooter}
}{}

% Pass styling options
\ifbool{ugentcls@titleUnderline}{%
    \PassOptionsToPackage{underline=true}{ugent2016-title}%
}{%
    \PassOptionsToPackage{underline=false}{ugent2016-title}%
}

% Load our style package with the required options.
\RequirePackage[
    type=\ugentcls@type,
    faculty=\ugentcls@faculty,
    campus=\ugentcls@campus,
    uppercase=\ifbool{ugentcls@titleUppercase}{true}{false}
]{ugent2016-title}


% Load packages at the end of the preamble, allowing overrides.
\AtEndPreamble{
    \RequirePackage{xstring}
    \RequirePackage{scrlayer-scrpage}
    \RequirePackage{textcase}
    % Load this as the last package to prevent issues.
    \RequirePackage{hyperref}
}

% Change settings once we are in the document.
\AtBeginDocument{

    \newcommand*{\ugentcls@maybeUnderline}[1]{%
        \ifbool{ugentcls@underline}{%
            \uline{#1}%
        }{%
            #1%
        }%
    }

    \newcommand*{\ugentcls@maybeUppercase}[1]{%
        \ifbool{ugentcls@uppercase}{%
            \MakeUppercase{#1}%
        }{%
            #1%
        }
    }

    % Applied when the user wants the margins to be set, but nothing else.
    \IfStringInList{\ugentcls@layout}{margins,colours,titlestyle,titlefont}{
        \iftoggle{showfooter}{
            \newgeometry{margin=2\smallblock,bottom=2.3\smallblock}
        }{
            \newgeometry{margin=2\smallblock,bottom=2\smallblock,foot=1.2\smallblock}
        }
    }{}

    % Applied when the user wants the titles in the correct colours, but nothing else.
    \IfStringInList{\ugentcls@layout}{colours,titlestyle,titlefont}{
        \ifcsdef{chapter}{%
            \addtokomafont{chapter}{\color{ugent-blue}}
        }{%
            \addtokomafont{section}{\color{ugent-blue}}
        }
    }{}

    \IfStringInList{\ugentcls@layout}{titlestyle,titlefont}{
        \renewcommand\partlineswithprefixformat[3]{#2{\ugentcls@maybeUppercase{#3}}}
        \ifcsdef{chapter}{%
            \renewcommand\chapterlineswithprefixformat[3]{#2{\ugentcls@maybeUppercase{\ugentcls@maybeUnderline{#3}}}}
            \renewcommand{\chapterlinesformat}[3]{\@hangfrom{#2}{\ugentcls@maybeUppercase{\ugentcls@maybeUnderline{#3}}}}
        }{}
        \addtokomafont{section}{\bfseries}
        \addtokomafont{subsection}{\bfseries}
        \addtokomafont{subsubsection}{\bfseries}
    }{}

    % This block is applied when the user wants the titles in UGent style, but not the main text.
    % Format the titles according to the UGent style (fonts and text decorations)
    % Sizes are not set, allowing for more flexibility for the user.
    \IfStringInList{\ugentcls@layout}{titlefont}{
        \addtokomafont{disposition}{\panno}
        \newcommand*\tocentryformat[1]{{\panno#1}}
        \RedeclareSectionCommands[tocentryformat=\tocentryformat, tocpagenumberformat=\tocentryformat]
            {section,subsection,subsubsection,paragraph,subparagraph}
    }{}


    % Set the size and spacing of the titles.
    \ifbool{ugentcls@spacing}{%
        \ifcsdef{chapter}{%
            \RedeclareSectionCommand[
                beforeskip=20pt,
                afterskip=22pt,
                afterindent=false% <- added
            ]{chapter}
        }{}
    }{}

    \NewTranslationFallback{title}{Titel}
    \NewTranslation{english}{title}{Title}
    \NewTranslationFallback{date}{Datum}
    \NewTranslation{english}{date}{Date}
    \NewTranslationFallback{page}{Pagina}
    \NewTranslation{english}{page}{Page}

    % These need to be defined outside of cfoot, otherwise GetTranslation is expanded too early.
    \newcommand*{\foot@title}{\GetTranslation{title}}
    \newcommand*{\foot@date}{\GetTranslation{date}}
    \newcommand*{\foot@page}{\GetTranslation{page}}

    % If enabled, add the footer. This is only enabled by default when using style=notes,
    % but can be overridden.
    \iftoggle{showfooter}{
        \RequirePackage{lastpage} % Only needed if we use this

        \setkomafont{pagefoot}{\normalfont} % No italics please
        \setkomafont{pagenumber}{} % Nothing please
        \ifoot*{} % Empty the inner footer.
        \cfoot*{
            \begin{tikzpicture}[remember picture,overlay,every node/.style={inner sep=0,outer sep=0}]
                \node[anchor=north west] (footer) at ([shift={(1.5\smallblock,2.4\smallblock)}]current page.south west) {
                    \includegraphics[height=2\smallblock]{\@campusimage}
                };
                \node[anchor=north west, align=left] (title) at ([shift={(5\smallblock,2\smallblock)}]current page.south west) {
                    \begin{minipage}[c][1\smallblock][s]{7\smallblock}
                        \raggedright
                        {\fontsize{8pt}{10pt}\bfseries\panno\color{ugent-blue}\MakeTextUppercase{\foot@title}} \\
                        {\fontsize{10pt}{15pt}\bfseries\panno\@subtitle}
                    \end{minipage}
                };
                \node[anchor=north west, align=left] (title) at ([shift={(13\smallblock,2\smallblock)}]current page.south west) {
                    \begin{minipage}[c][1\smallblock][s]{3\smallblock}
                        \raggedright
                        {\fontsize{8pt}{10pt}\bfseries\panno\color{ugent-blue}\MakeTextUppercase{\foot@date}} \\
                        {\fontsize{10pt}{15pt}\panno\@date}
                    \end{minipage}
                };
                \node[anchor=north west, align=left] (title) at ([shift={(17\smallblock,2\smallblock)}]current page.south west) {
                    \begin{minipage}[c][1\smallblock][s]{1\smallblock}
                        \raggedright
                        {\fontsize{8pt}{10pt}\bfseries\panno\color{ugent-blue}\MakeTextUppercase{\foot@page}} \\
                        {\fontsize{10pt}{15pt}\panno\pagemark/\pageref*{LastPage}}
                    \end{minipage}
                };
            \end{tikzpicture}
        }
        \ofoot*{} % Empty the outer footer.
    }{}
}

\endinput
