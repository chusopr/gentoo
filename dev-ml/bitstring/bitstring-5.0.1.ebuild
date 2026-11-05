# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit dune

DESCRIPTION="Bitstring matching for OCaml"
HOMEPAGE="https://github.com/xguerin/bitstring"
SRC_URI="https://github.com/xguerin/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="LGPL-2.1-with-linking-exception GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86"

IUSE="+ocamlopt"

DEPEND=">=dev-ml/ppxlib-0.36.0"
