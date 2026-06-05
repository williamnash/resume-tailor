%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Resume LaTeX Class
% Version 3.1 (April 30, 2026)
%
% Originally based on the LaTeXTemplates "Medium Length Professional CV"
% (Trey Hunner / LaTeXTemplates.com).
% Customized: slate color accent, improved section header styling,
% relaxed bullet spacing. Edit \definecolor{primary}/{accent} below to
% change the accent color.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------------------
%	CLASS CONFIGURATION
%----------------------------------------------------------------------------------------

\ProvidesClass{resume}[2026/04/30 v3.1 Resume class]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\LoadClass{article}

%----------------------------------------------------------------------------------------
%	REQUIRED PACKAGES AND TYPOGRAPHY
%----------------------------------------------------------------------------------------

\usepackage[parfill]{parskip}
\usepackage{array}
\usepackage{ifthen}
\usepackage{graphicx}
\usepackage{xcolor}

% Suppress automatic word-hyphenation (avoid ugly splits like "synchrocy-clotron")
\hyphenpenalty=10000
\exhyphenpenalty=10000
\tolerance=2000
\emergencystretch=2em

\definecolor{primary}{RGB}{38,55,75}     % deep slate-blue for headers, name, links
\definecolor{accent}{RGB}{120,130,150}   % softer slate for rules

% Slightly relaxed table row spacing for skills/award tabulars
\renewcommand{\arraystretch}{1.15}

\pagestyle{empty}

%----------------------------------------------------------------------------------------
%	MARGINS
%----------------------------------------------------------------------------------------

\usepackage{geometry}

\geometry{
	top=0.4in,
	bottom=0.4in,
	left=0.7in,
	right=0.7in,
}

%----------------------------------------------------------------------------------------
%	HYPERLINKS
%----------------------------------------------------------------------------------------

\usepackage[colorlinks=true,linkcolor=primary,urlcolor=primary,citecolor=primary]{hyperref}

%----------------------------------------------------------------------------------------
%	NAME AND ADDRESS COMMANDS
%----------------------------------------------------------------------------------------

\newcommand{\name}[1]{\renewcommand{\name}{#1}}

\newcommand{\addressSep}{$\diamond$}

\let \@addressone \relax
\let \@addresstwo \relax
\let \@addressthree \relax

\newcommand{\address}[1]{
	\@ifundefined{@addressone}{
		\def \@addressone {#1}
	}{
		\@ifundefined{@addresstwo}{
			\def \@addresstwo {#1}
		}{
			\def \@addressthree {#1}
		}%
	}
}

\newcommand{\printaddress}[1]{
	\begingroup
		\def \\ {\addressSep\ }
		\parfillskip=0pt plus 1fil
		\noindent\makebox[\textwidth]{#1}
		\par
	\endgroup
	\smallskip
}

\newcommand{\printname}{
	\begingroup
		\hfil{\color{primary}\MakeUppercase{\huge\bfseries\name}}\hfil
		\smallskip\break
	\endgroup
}

%----------------------------------------------------------------------------------------
%	OUTPUT THE NAME & ADDRESS LINES AUTOMATICALLY
%----------------------------------------------------------------------------------------

\let\ori@document=\document
\renewcommand{\document}{
	\ori@document
	\printname
	\@ifundefined{@addressone}{}{\printaddress{\@addressone}}
	\@ifundefined{@addresstwo}{}{\printaddress{\@addresstwo}}
	\@ifundefined{@addressthree}{}{\printaddress{\@addressthree}}
}

%----------------------------------------------------------------------------------------
%	SECTION FORMATTING
%----------------------------------------------------------------------------------------

\newenvironment{rSection}[1]{
	\vspace{3pt}
	{\color{primary}\textbf{\MakeUppercase{#1}}}
	\vspace{1pt}
	{\color{primary}\hrule height 0.5pt}
	\begin{list}{}{
		\setlength{\leftmargin}{1.5em}
	}
	\item[]
}{
	\end{list}
}

%----------------------------------------------------------------------------------------
%	WORK EXPERIENCE FORMATTING
%----------------------------------------------------------------------------------------

\newenvironment{rSubsection}[4]{
	\textbf{#1} \hfill {#2}
	\ifthenelse{\equal{#3}{}}{}{
		\\
		\textit{#3} \hfill \textit{#4}
	}%
	\smallskip
	\begin{list}{$\cdot$}{\leftmargin=0em}
		\setlength{\itemsep}{-0.5em} \vspace{-0.5em}
}{
	\end{list}
	\vspace{0.2em}
}
