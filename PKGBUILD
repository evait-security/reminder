pkgname=reminder-git
_gitname=reminder
pkgver=r4.9df35d4
pkgrel=1
pkgdesc="Uses the notify-send command in combination with a sqlite database and systemd-timers in order to create text based reminders."
arch=("x86_64")
url="https://github.com/evait-security/$_gitname"
license=("unknown")
depends=("git" "crystal" "shards")
source=("git+https://github.com/evait-security/$_gitname")
sha256sums=("SKIP")

pkgver() {
        cd $_gitname
        # NOTE: this can be used once tags/releases are provided upstream
        # git describe --long --tags | sed -e 's/^v//' -e 's/-\([^-]*-g[^-]*\)$/-r\1/' -e 's/-/./g'
        printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

build() {
        cd $_gitname
        shards install
        shards build --release --no-debug --progress --production
}

package() {
        cd $_gitname
        install -D -m 0755 ./bin/$_gitname "${pkgdir}/usr/local/sbin/$_gitname"
}