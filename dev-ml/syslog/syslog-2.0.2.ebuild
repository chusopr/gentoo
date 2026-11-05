# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="ocaml-${PN}"
MY_PV="${MY_PN}-${PV}"

inherit dune

DESCRIPTION="syslog routines for OCaml"
HOMEPAGE="https://github.com/geneanet/ocaml-syslog"
SRC_URI="https://github.com/geneanet/${MY_PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

S="${WORKDIR}/${MY_PV}"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86"

IUSE="+ocamlopt"
