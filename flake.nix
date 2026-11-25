{
  description = "Unreal Editor development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        config = import ./unreal-versions.nix;
        defaultVersion = config.default;

        # Create a list of attributes excluding the default attirbute.
        versions = builtins.removeAttrs config ["default"];

        mkDevShell = versionName:
          import ./unreal.nix {
            inherit pkgs;
            paramVersion = versionName;
          };

        mkEditorApp = versionName: {
          type = "app";
          program = pkgs.lib.getExe (mkDevShell versionName).editor;
          meta.description = "Unreal Editor ${config.${versionName}.version}";
        };
      in {
        devShells = builtins.mapAttrs (name: _: mkDevShell name) versions // {default = mkDevShell defaultVersion;};
        apps = builtins.mapAttrs (name: _: mkEditorApp name) versions // {default = mkEditorApp defaultVersion;};
      }
    );
}
