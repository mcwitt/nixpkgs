{ stdenv
, lib
, autoPatchelfHook
, curl
, dpkg
, fetchurl
, gtk3
, icu
, kerberos
, libredirect
, lttng-ust
, wrapGAppsHook
, zlib
}:

stdenv.mkDerivation rec {
  name = "aws-client-vpn-${version}";
  version = "1.0.0";

  src = fetchurl {
    url = "https://d20adtppz83p9s.cloudfront.net/GTK/${version}/awsvpnclient_amd64.deb";
    sha256 = "0nxmx83wbzgx648fcw5rqbdzi6v93qkpcnbb6qf1z6zzpg17c4br";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    wrapGAppsHook
  ];

  buildInputs = [
    curl
    gtk3
    icu
    kerberos
    lttng-ust
    stdenv.cc.cc.lib
    zlib
  ];

  unpackPhase = ''
    dpkg -x $src .
  '';

  installPhase = ''
    mkdir -p $out
    cp -av etc opt/awsvpnclient usr/share $out
    mkdir -p $out/bin
    ln -s "$out/awsvpnclient/AWS VPN Client" "$out/bin/AWS VPN Client"
    ln -s "$out/awsvpnclient/Service/ACVC.GTK.Service" "$out/bin/ACVC.GTK.Service"
  '';

  dontWrapGApps = true; # need to wrap manually to add redirects

  postFixup = ''
    patchelf --add-needed libgdk-3.so "$out/awsvpnclient/AWS VPN Client"
    patchelf --add-needed libicuuc.so $out/awsvpnclient/System.Globalization.Native.so
    patchelf --add-needed libicuuc.so $out/awsvpnclient/Service/System.Globalization.Native.so

    for file in $out/bin/*; do
      wrapProgram "$file" \
        --set LD_PRELOAD "${libredirect}/lib/libredirect.so" \
        --set NIX_REDIRECTS /opt/awsvpnclient=$out/awsvpnclient \
        "''${gappsWrapperArgs[@]}"
    done
  '';

  meta = with lib; {
    homepage = https://docs.aws.amazon.com/vpn/latest/clientvpn-user/client-vpn-user-what-is.html;
    description = "Managed client-based VPN service";
    platforms = platforms.linux;
    maintainers = with maintainers; [ mcwitt ];
  };
}
