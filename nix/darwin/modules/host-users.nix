{ ... }@args:
let
  hostname = "UNiCORN";
  username = "amin";
in
{
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };
  nix.settings.trusted-users = [ "root" username ];
  system.defaults.smb.NetBIOSName = hostname;
  # Define a user account. Don't forget to set a password with `passwd`.
  system.primaryUser = username;
  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
  };
}
