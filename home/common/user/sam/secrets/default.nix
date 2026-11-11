{lib, ...}:
with lib; {
  imports = [
    ./hermes
    ./komodo
    ./git
    ./ssh
    ./proton
    ./plane
    ./superproductivity
  ];
}
