{ stdenv
, buildPythonPackage
, fetchPypi
, python
}:

buildPythonPackage rec {
  pname = "iniparse";
  version = "0.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "932e5239d526e7acb504017bb707be67019ac428a6932368e6851691093aa842";
  };

  checkPhase = ''
    ${python.interpreter} runtests.py
  '';

  # Does not install tests
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Accessing and Modifying INI files";
    homepage = "https://github.com/candlepin/python-iniparse";
    license = licenses.mit;
    maintainers = with maintainers; [ danbst ];
  };

}
