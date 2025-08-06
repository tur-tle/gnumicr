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

    # Generate font map file
    cat > GnuMICR.map <<-EOF || die
        GnuMICR GnuMICR <GnuMICR.pfb
EOF
}

src_compile() {
    einfo "Generating the .tfm (TeX font metric) file ..."
    afm2tfm GnuMICR.afm -T T1-WGL4.enc GnuMICR.tfm || die "afm2tfm failed"
}

src_install() {
    einfo "Installing OpenType and supporting font formats ..."
    insinto "${FONTDIR}"
    doins GnuMICR.{otf,ttf,pfa,pfb,afm,pfm} || die

    einfo "Installing TFM and map files ..."
    insinto /usr/share/texmf-site/fonts/tfm/${PN}
    doins GnuMICR.tfm || die "Failed to install GnuMICR.tfm"

    insinto /usr/share/texmf-site/fonts/map/dvips/${PN}
    doins GnuMICR.map || die "Failed to install GnuMICR.map"

    einfo "Installing LaTeX .sty and .fd files ..."
    insinto /usr/share/texmf-site/tex/latex/${PN}
    doins OT1GnuMICR.fd GnuMICR.sty || die

    dodoc README
}

pkg_postinst() {
    einfo "Rebuilding TeX and font caches ..."
    latex-package_rehash
    mktexlsr
    fc-cache -f
    updmap-sys --enable Map=GnuMICR.map || ewarn "Failed to enable GnuMICR.map"
}

pkg_postrm() {
    einfo "Cleaning up font map and cache ..."
    updmap-sys --disable GnuMICR.map || ewarn "Failed to disable GnuMICR.map"
    latex-package_rehash
    mktexlsr
    fc-cache -f
}
