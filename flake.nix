{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";

    nixpkgs-esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
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
          pkgs.mkShell rec
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
              espflash
              python3
              cargo-espflash
              cmake

              minicom

              esp-idf-esp32c3
            ];
            LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath buildInputs}";
          };
      }
    );
}
