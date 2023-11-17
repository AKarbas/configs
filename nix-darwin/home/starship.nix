{...}: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      time = {
        disabled = false;
        utc_time_offset = "0";
        time_format = "%T%.3f";
        format = "[$time]($style)";
      };
    };
  };
}
