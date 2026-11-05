# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python3_{11..15} )

inherit dune flag-o-matic git-r3 python-any-r1 systemd toolchain-funcs

EGIT_REPO_URI="https://github.com/chusopr/mldonkey5.git"
EGIT_COMMIT="bda781d653eaf53e71d135368838fb546dc47c91"
EGIT_BRANCH="autoconf-options"

DESCRIPTION="Multi-network P2P application written in Ocaml, with Gtk, web & telnet interface"
HOMEPAGE="https://github.com/carlonluca/mldonkey"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86"

IUSE="bittorrent doc fasttrack gnutella +ocamlopt upnp"

RDEPEND="
	acct-user/p2p
	app-arch/brotli
	app-arch/bzip2
	app-arch/zstd
	dev-lang/perl
	dev-libs/crypto++
	dev-libs/libunistring
	dev-libs/openssl
	media-libs/gd:2=[jpeg,png,truetype]
	media-libs/libjpeg-turbo
	media-libs/libpng
	net-dns/c-ares
	net-dns/libidn2
	net-libs/libpsl
	net-libs/nghttp2
	net-misc/curl
	sys-apps/file
	virtual/zlib:=
	upnp? (
		net-libs/libnatpmp
		net-libs/miniupnpc:=
	)
"

DEPEND="${RDEPEND}
	=dev-lang/ocaml-5*
	dev-ml/bitstring
	=dev-ml/camlp4-5*:=
	dev-ml/camlp-streams
	dev-ml/ocurl
	dev-ml/syslog
	dev-ml/uucp
	dev-ml/uutf
	dev-ml/xml-light
	bittorrent? ( dev-ml/num )
"

BDEPEND="${PYTHON_DEPS}"

RESTRICT="!ocamlopt? ( strip )"

pkg_setup() {
	# dev-lang/ocaml creates its own objects but calls gcc for linking, which will
	# results in relocations if gcc wants to create a PIE executable
	if gcc-specs-pie ; then
		append-ldflags -nopie
		ewarn "Ocaml generates its own native asm, you're using a PIE compiler"
		ewarn "We have appended -nopie to ocaml build options"
		ewarn "because linking an executable with pie while the objects are not pic will not work"
	fi

	python-any-r1_pkg_setup
}

src_configure() {
	"${EPYTHON}" autoconf.py \
		$(use_enable bittorrent) \
		$(use_enable fasttrack) \
		$(use_enable gnutella) \
		$(use_enable gnutella gnutella2) \
		$(use_enable upnp upnp-natpmp) || die
}

src_compile() {
	dune-release build --target ./src/mlnet.exe
}

src_install() {
	default

	newbin "_build/default/src/mlnet.exe" "mlnet"

	systemd_dounit "${FILESDIR}/${PN}.service"
	newconfd "${FILESDIR}/mldonkey.confd" mldonkey
	newinitd "${FILESDIR}/mldonkey.initd" mldonkey

	if use doc ; then
		docompress -x "/usr/share/doc/${PF}/scripts" "/usr/share/doc/${PF}/html"

		dodoc distrib/ChangeLog distrib/*.txt docs/*.txt docs/*.tex docs/*.pdf docs/developers/*.{txt,tex}

		docinto scripts
		dodoc distrib/{kill_mldonkey,mldonkey_command,mldonkey_previewer,make_buginfo}

		docinto html
		dodoc docs/*.html

		docinto html/images
		dodoc docs/images/*
	fi
}

pkg_postinst() {
	if [ -f /etc/conf.d/mldonkey ] && grep -qE "^(BASEDIR|SUBDIR|LOW_DOWN|LOW_UP|HIGH_DOWN|HIGH_UP|SERVER|PORT|TELNET_PORT|USERNAME|PASSWORD|MLDONKEY_TIMEOUT)=" /etc/conf.d/mldonkey; then
		ewarn "The following settings are deprecated and will be ignored,"
		ewarn "please remove them from /etc/conf.d/mldonkey:"
		ewarn "LOW_DOWN LOW_UP HIGH_DOWN HIGH_UP SERVER PORT TELNET_PORT USERNAME PASSWORD MLDONKEY_TIMEOUT"
	fi
}
