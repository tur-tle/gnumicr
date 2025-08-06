# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font git-r3 latex-package

DESCRIPTION="MICR E-13B font for LaTeX and TeX, fork of gnumicr"
HOMEPAGE="https://github.com/tur-tle/gnumicr"
EGIT_REPO_URI="https://github.com/tur-tle/gnumicr.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-texlive/texlive-fontsrecommended"
RDEPEND="${DEPEND}"
BDEPEND="app-text/texlive-core"

FONTDIR="/usr/share/fonts/opentype/${PN}"

#${PN} expands to just the package name (here: gnumicr).
#${P} expands to the package name and version (gnumicr-9999 for a live ebuild).
S="${WORKDIR}/${P}"

src_prepare() {
    einfo "S is set to: ${S}"
    default

    # Generate the .fd file
    cat > OT1GnuMICR.fd <<-EOF || die
        \\ProvidesFile{OT1GnuMICR.fd}[2025/08/05 Font definitions for OT1/GnuMICR]
        \\DeclareFontFamily{OT1}{GnuMICR}{}
        \\DeclareFontShape{OT1}{GnuMICR}{m}{n}{
            <-> GnuMICR
        }{}
EOF

    # Generate the .sty file
    cat > GnuMICR.sty <<-EOF || die
        \\NeedsTeXFormat{LaTeX2e}
        \\ProvidesPackage{micr}[2025/08/05 MICR E-13B font support]

        \\newcommand{\\MICRfont}{%
          \\fontfamily{GnuMICR}\\selectfont
        }

        \\newcommand{\\micr}[1]{{\\MICRfont #1}}
EOF
}

src_compile() {
     einfo "Generating the .tfm (TeX font metric) file ..."
    afm2tfm GnuMICR.afm -T T1-WGL4.enc GnuMICR.tfm || die "afm2tfm failed"
}

src_install() {
     einfo "Installing OpenType fonts ..."
    insinto "${FONTDIR}"
    doins GnuMICR.otf || die "Failed to install GnuMICR.otf"
    doins GnuMICR.{ttf,pfa,pfb,afm,pfm} || die

    # Install TFM into TeX font tree
    insinto /usr/share/texmf-site/fonts/tfm/${PN}
    doins GnuMICR.tfm || ewarn " Failed to install GnuMICR.tfm into TeX font tree at /usr/share/texmf-site/fonts/tfm/${PN}"

    insinto /usr/share/texmf-site/fonts/map/dvips/${PN}
    doins GnuMICR.map || ewarn " Failed to install GnuMICR.map to /usr/share/texmf-site/fonts/map/dvips/${PN}"
    # Install LaTeX style and font definition files
       # Font definition
    if [[ -f OT1GnuMICR.fd ]]; then
        elog "Installing OT1GnuMICR.fd"
    insinto /usr/share/texmf-site/tex/latex/${PN}
        doins OT1GnuMICR.fd
        else ewarn "Warning OT1GnuMICR.fd skipping."
    fi

    if [[ -f GnuMICR.sty ]]; then
        elog "Installing GnuMICR.sty"
        insinto /usr/share/texmf-site/tex/latex/${PN}
        doins GnuMICR.sty
    else  ewarn "Warning GnuMICR.sty skipping."
    fi
    # Install documentation
    dodoc README
}

pkg_postinst() {
    latex-package_rehash
    updmap-sys --enable Map=GnuMICR.map
    mktexlsr
    fc-cache -f
}

pkg_postrm() {
    updmap-sys --disable GnuMICR.map
    latex-package_rehash
    mktexlsr
    fc-cache -f
}
