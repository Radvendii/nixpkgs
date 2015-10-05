{stdenv, fetchurl, unzip, lib }:
let
  fonts = {
    aegean = { version = "8.00"; file = "Aegean.zip"; sha256 = "09pmazcpxhkx3l8h4gxiixihi1c49pli5gvlcm1b6sbf4xvf9kwm";
               description = "Scripts and symbols of the Aegean world"; };
    textfonts = { version = "6.00"; file = "Textfonts.zip"; sha256 = "10m6kpyj8cc0b4qxxi78akiyjxcbhxj2wmbicdcfh008jibbaxsz";
                  description = "Fonts based on early Greek editions"; };
    symbola = { version = "8.00"; file = "Symbola.zip"; sha256 = "1lfs2j816332ysvpb5ibj2gwpmyqyispqdl7skkshf2gra18hmhd";
                description = "Basic Latin, Greek, Cyrillic and many Symbol blocks of Unicode"; };
    aegyptus = { version = "6.00"; file = "Aegyptus.zip"; sha256 = "092vci45wp9x0yky6dcfky4bs4avaxn6xpai3bs74gxskd2j9s3q";
                 description = "Egyptian Hieroglyphs, Coptic, Meroitic"; };
    akkadian = { version = "7.13"; file = "Akkadian.zip"; sha256 = "1xwlify1jdsjfgbpl48gcdv7m2apa9avsyxy17q2zg6lngx1ic8a";
                 description = "Sumero-Akkadian Cuneiform"; };
    anatolian = { version = "5.02"; file = "Anatolian.zip"; sha256 = "0arm58sijzk0bqmfb70k1sjvq79wgw16hx3j2g4l8qz4sv05bp8l";
                  description = "Anatolian Hieroglyphs"; };
    maya = { version = "4.14"; file = "Maya.zip"; sha256 = "0l97racgncrhb96mfbsx8dr5n4j289iy0nnwhxf9b21ns58a9x4f";
             description = "Maya Hieroglyphs"; };
    unidings = { version = "8.00"; file = "Unidings.zip"; sha256 = "0r5n5jgxcf71x4zfizf1jk9jffyr6waxym8dlmh82bcpjpkx0pl0";
                 description = "Glyphs and Icons for blocks of The Unicode Standard"; };
    musica = { version = "3.12"; file = "Musica.zip"; sha256 = "079vyb0mpxvlcf81d5pqh9dijkcvidfbcyvpbgjpmgzzrrj0q210";
               description = "Musical Notation"; };
    analecta = { version = "5.00"; file = "Analecta.zip"; sha256 = "0rphylnz42fqm1zpx5jx60k294kax3sid8r2hx3cbxfdf8fnpb1f";
                 description = "Coptic, Gothic, Deseret"; };
  };
  mkpkg = name_: {version, file, sha256, description}:
    stdenv.mkDerivation rec {
      name = "${name_}-${version}";

      src = fetchurl {
        url = "http://users.teilar.gr/~g1951d/${file}";
        inherit sha256;
      };

      buildInputs = [ unzip ];

      sourceRoot = ".";

      installPhase = ''
        mkdir -p $out/share/fonts/truetype
        cp -v *.ttf $out/share/fonts/truetype/

        mkdir -p "$out/doc/${name}"
        cp -v *.docx *.pdf *.xlsx "$out/doc/${name}/"
      '';

      meta = {
        inherit description;
        # In lieu of a license:
        # Fonts in this site are offered free for any use;
        # they may be installed, embedded, opened, edited, modified, regenerated, posted, packaged and redistributed.
        license = stdenv.lib.licenses.free;
        homepage = http://users.teilar.gr/~g1951d/;
      };
    };

in
lib.mapAttrs mkpkg fonts
