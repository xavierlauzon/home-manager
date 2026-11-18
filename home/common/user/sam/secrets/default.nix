{lib, ...}:
with lib; {
  imports = [
    ./hermes
    ./komodo
    ./git
    ./github
    ./ssh
    ./proton
    ./plane
    ./litellm
    ./superproductivity
  ];
}
