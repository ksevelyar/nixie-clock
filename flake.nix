{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
    nixpkgs-esp-dev.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    rust-overlay,
    nixpkgs-esp-dev,
    ...
  }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [rust-overlay.overlays.default nixpkgs-esp-dev.overlays.default];
        };
      in {
        devShell =
          pkgs.mkShell
          {
            LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
            buildInputs = with pkgs; [
              (
                rust-bin.nightly.latest.default.override {
                  extensions = ["rust-src"];
                }
              )
              rust-analyzer
              cargo-generate
              ldproxy
              espup
              python3
              espflash
              cmake

              minicom

              esp-idf-esp32c3
            ];

            SSID = "ssid";
            PASS = "pass";
          };
      }
    );
}
