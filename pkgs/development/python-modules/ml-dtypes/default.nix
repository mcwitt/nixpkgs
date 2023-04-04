{ absl-py
, buildPythonPackage
, eigen
, fetchFromGitHub
, lib
, numpy
, pybind11
, pytestCheckHook
, pythonOlder
, setuptools
}:

buildPythonPackage rec {
  pname = "ml-dtypes";
  version = "0.0.4";
  format = "pyproject";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "jax-ml";
    repo = "ml_dtypes";
    rev = "refs/tags/v${version}";
    hash = "sha256-riKxHIkkAsznME2CMFjTJIADdLoUDfsIfXkAdZYz8QA=";
  };

  nativeBuildInputs = [
    pybind11
    setuptools
  ];

  propagatedBuildInputs = [ numpy ];

  nativeCheckInputs = [
    absl-py
    pytestCheckHook
  ];

  postPatch = ''
    for f in ml_dtypes/_src/*.cc ml_dtypes/_src/*.h; do
        substituteInPlace $f --replace "eigen/Eigen" "${eigen}/include/eigen3/Eigen"
    done
  '';

  meta = {
    description = "A stand-alone implementation of several NumPy dtype extensions used in machine learning";
    homepage = "https://github.com/jax-ml/ml_dtypes";
    changelog = "https://github.com/jax-ml/ml_dtypes/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mcwitt ];
  };
}
