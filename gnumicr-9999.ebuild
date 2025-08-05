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
BDEPEND=""

FONTDIR="/usr/share/fonts/opentype/${PN}"
#S="${WORKDIR}/${PN}"  # Correct source directory after git clone
#${PN} expands to just the package name (here: gnumicr).
#${P} expands to the package name and version (so: gnumicr-9999 for a live ebuild).
S="${WORKDIR}/${P}"

src_prepare() {
    einfo "S is set to: ${S}"
    default
}

src_unpack() {
    git-r3_src_unpack
}

src_install() {
    # Install OpenType font(s)
    insinto "${FONTDIR}"
    doins GnuMICR.otf || die "Failed to install GnuMICR.otf"
    #doins GnuMICR.ttf GnuMICR.pfa  GnuMICR.pfb GnuMICR.afm GnuMICR.pfm || die
    doins GnuMICR.otf GnuMICR.ttf GnuMICR.pfa GnuMICR.pfb GnuMICR.afm GnuMICR.pfm || die

    # Install LaTeX style files
    # or auto generate
       # Font definition
    if [[ -f OT1GnuMICR.fd ]]; then
        einfo "Installing OT1GnuMICR.fd"
        insinto /usr/share/texmf-site/tex/latex/${PN}
        doins OT1GnuMICR.fd
        else einfo "No OT1GnuMICR.fd skipping."
    fi

    if [[ -f GnuMICR.sty ]]; then
        einfo "Installing GnuMICR.sty"
        insinto /usr/share/texmf-site/tex/latex/${PN}
        doins GnuMICR.sty
    else   einfo "No GnuMICR.sty skipping."
    fi
    # Install documentation
    #dodoc README.md
    dodoc README
}

pkg_postinst() {
    # Rebuild TeX and font caches
    latex-package_rehash
    mktexlsr # needed?
    fc-cache -f
}
