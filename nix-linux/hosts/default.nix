{ hostName, ... }: {
  imports = [ ./${hostName} ./internationalisation ];

}