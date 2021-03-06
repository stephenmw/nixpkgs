{ fetchurl, stdenv, pkgconfig, gnome3, ibus, intltool, upower, makeWrapper
, libcanberra, libcanberra_gtk3, accountsservice, libpwquality, libpulseaudio, fontconfig
, gdk_pixbuf, hicolor_icon_theme, librsvg, libxkbfile, libnotify
, libxml2, polkit, libxslt, libgtop, libsoup, colord, colord-gtk
, cracklib, python, libkrb5, networkmanagerapplet, networkmanager
, libwacom, samba, shared_mime_info, tzdata, icu, libtool, udev
, docbook_xsl, docbook_xsl_ns, modemmanager, clutter, clutter_gtk }:

# http://ftp.gnome.org/pub/GNOME/teams/releng/3.10.2/gnome-suites-core-3.10.2.modules
# TODO: bluetooth, wacom, printers

stdenv.mkDerivation rec {
  name = "gnome-control-center-${gnome3.version}.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-control-center/${gnome3.version}/${name}.tar.xz";
    sha256 = "07vvmnqjjcc0cblpr6cdmg3693hihpjrq3q30mm3q68pdyfzbjgf";
  };

  propagatedUserEnvPkgs = [ gnome3.gnome_themes_standard gnome3.libgnomekbd ];

  enableParallelBuilding = true;

  buildInputs = with gnome3;
    [ pkgconfig intltool ibus gtk glib upower libcanberra gsettings_desktop_schemas
      libxml2 gnome_desktop gnome_settings_daemon polkit libxslt libgtop gnome-menus
      gnome_online_accounts libsoup colord libpulseaudio fontconfig colord-gtk libpwquality
      accountsservice libkrb5 networkmanagerapplet libwacom samba libnotify libxkbfile
      shared_mime_info icu libtool docbook_xsl docbook_xsl_ns gnome3.grilo
      gdk_pixbuf gnome3.defaultIconTheme librsvg clutter clutter_gtk
      gnome3.vino udev libcanberra_gtk3
      networkmanager modemmanager makeWrapper gnome3.gnome-bluetooth ];

  preBuild = ''
    substituteInPlace tz.h --replace "/usr/share/zoneinfo/zone.tab" "${tzdata}/share/zoneinfo/zone.tab"
    substituteInPlace panels/datetime/tz.h --replace "/usr/share/zoneinfo/zone.tab" "${tzdata}/share/zoneinfo/zone.tab"

    # hack to make test-endianess happy
    mkdir -p $out/share/locale
    substituteInPlace panels/datetime/test-endianess.c --replace "/usr/share/locale/" "$out/share/locale/"
  '';

  patches = [ ./vpn_plugins_path.patch ];

  preFixup = with gnome3; ''
    wrapProgram $out/bin/gnome-control-center \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
      --prefix XDG_DATA_DIRS : "${gnome3.gnome_themes_standard}/share:$out/share:$out/share/gnome-control-center:$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH"
    for i in $out/share/applications/*; do
      substituteInPlace $i --replace "gnome-control-center" "$out/bin/gnome-control-center"
    done
  '';

  meta = with stdenv.lib; {
    description = "Single sign-on framework for GNOME";
    maintainers = with maintainers; [ lethalman ];
    platforms = platforms.linux;
  };

}
