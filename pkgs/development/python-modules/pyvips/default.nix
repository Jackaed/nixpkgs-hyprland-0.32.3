{ stdenv
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, pytestCheckHook
, glib
, vips
, cffi
, pkgconfig  # from pythonPackages
, pkg-config  # from pkgs
, lib }:

buildPythonPackage rec {
  pname = "pyvips";
  version = "2.2.1";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "libvips";
    repo = "pyvips";
    rev = "v${version}";
    hash = "sha256-9S7h3bkm+QP78cpemYS7l3c8t+wXsJ5MUAP2T50R/Mc=";
  };

  nativeBuildInputs = [ pkgconfig pkg-config ];

  buildInputs = [ glib vips ];

  propagatedBuildInputs = [ cffi ];

  nativeCheckInputs = [ pytestCheckHook ];

  postPatch = ''
    substituteInPlace pyvips/__init__.py \
      --replace 'libvips.so.42' '${lib.getLib vips}/lib/libvips${stdenv.hostPlatform.extensions.sharedLibrary}' \
      --replace 'libvips.42.dylib' '${lib.getLib vips}/lib/libvips${stdenv.hostPlatform.extensions.sharedLibrary}' \
      --replace 'libgobject-2.0.so.0' '${glib.out}/lib/libgobject-2.0${stdenv.hostPlatform.extensions.sharedLibrary}' \
      --replace 'libgobject-2.0.dylib' '${glib.out}/lib/libgobject-2.0${stdenv.hostPlatform.extensions.sharedLibrary}' \
  '';

  pythonImportsCheck = [ "pyvips" ];

  meta = with lib; {
    description = "A python wrapper for libvips";
    homepage = "https://github.com/libvips/pyvips";
    changelog = "https://github.com/libvips/pyvips/blob/v${version}/CHANGELOG.rst";
    license = licenses.mit;
    maintainers = with maintainers; [ ccellado anthonyroussel ];
  };
}
