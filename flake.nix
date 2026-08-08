{
  description = "A basic flake to with Gleam language";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    devenv.url = "github:cachix/devenv";
    gleam-overlay.url = "github:Comamoca/gleam-overlay";
    gleam2nix.url = "git+https://git.isincredibly.gay/srxl/gleam2nix";
    gleam2nix.inputs.nixpkgs.follows = "nixpkgs";
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    services-flake.url = "github:juspay/services-flake";
  };

  outputs =
    inputs@{
      self,
      systems,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks-nix.flakeModule
        inputs.devenv.flakeModule
        inputs.process-compose-flake.flakeModule
      ];
      systems = import inputs.systems;

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        let
          stdenv = pkgs.stdenv;
	  
          app = pkgs.buildGleamApplication {
            pname = "hello";
            version = "1.0.0";
            src = pkgs.lib.cleanSource ./.;
            gleamNix = import ./gleam.nix { inherit (pkgs) lib; };
            gleam = pkgs.gleam.bin.latest;
          };

          erlangPackages = with pkgs.beamMinimal28Packages; [
            erlang
            rebar3

            # elixir_1_19
          ];

          gleamPackages = with pkgs; [
            gleam2nix
            gleam.bin.latest
          ];
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.gleam-overlay.overlays.default
              inputs.gleam2nix.overlays.default
	      inputs.fenix.overlays.default
            ];
            config = { };
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
            };

            settings.formatter = { };
          };

          pre-commit = {
            check.enable = true;
            settings = {
              hooks = {
                treefmt.enable = true;
                gitleaks = {
                  enable = true;
                  entry = "${pkgs.gitleaks}/bin/gitleaks protect --staged";
                  language = "system";
                };
                gitlint.enable = true;
              };
            };
          };

          process-compose."default-service" = {
            imports = [
              inputs.services-flake.processComposeModules.default
            ];

            services = {
              # redis."r1" = {
              #   enable = true;
              # };
            };
          };

          devShells.default = pkgs.mkShell {
            # To start the service, please run: nix run .#default-service
            inputsFrom = [
              config.process-compose."default-service".services.outputs.devShell
            ];

            packages = with pkgs; [
	      nixd 
              wrangler
            ] ++ erlangPackages
              ++ gleamPackages ;
          };

	  packages.default = app;
        };
    };
}
