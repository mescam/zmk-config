{
  description = "ZMK firmware build environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          west
          pyyaml
          pykwalify
          canopen
          progress
          psutil
          intelhex
          pyelftools
          packaging
        ]);

        buildZmk = shield: pkgs.writeShellApplication {
          name = "build-${shield}";
          runtimeInputs = with pkgs; [
            cmake
            ninja
            dtc
            gperf
            ccache
            gcc-arm-embedded
            pythonEnv
          ];
          text = ''
            export Zephyr_DIR="$PWD/zephyr/share/zephyr-package/cmake"
            export ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
            export GNUARMEMB_TOOLCHAIN_PATH="${pkgs.gcc-arm-embedded}"

            rm -rf "build_${shield}"
            west build -d "build_${shield}" -b nice_nano/nrf52840/zmk zmk/app \
              -- -DSHIELD="${shield}" -DZMK_CONFIG="$PWD/config"

            cp "build_${shield}/zephyr/zmk.uf2" "${shield}.uf2"
            echo "Built: ${shield}.uf2"
          '';
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cmake
            ninja
            dtc
            gperf
            ccache
            gcc-arm-embedded
            pythonEnv
            git
          ];

          shellHook = ''
            export Zephyr_DIR="$PWD/zephyr/share/zephyr-package/cmake"
            export ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
            export GNUARMEMB_TOOLCHAIN_PATH="${pkgs.gcc-arm-embedded}"
            echo "ZMK build environment loaded"
          '';
        };

        packages = {
          build-left = buildZmk "cradio_left";
          build-right = buildZmk "cradio_right";
          build-all = pkgs.writeShellApplication {
            name = "build-all";
            runtimeInputs = [
              (buildZmk "cradio_left")
              (buildZmk "cradio_right")
            ];
            text = ''
              build-cradio_left
              build-cradio_right
              echo "Done! Built cradio_left.uf2 and cradio_right.uf2"
            '';
          };
        };

        apps = {
          build-left = {
            type = "app";
            program = "${self.packages.${system}.build-left}/bin/build-cradio_left";
          };
          build-right = {
            type = "app";
            program = "${self.packages.${system}.build-right}/bin/build-cradio_right";
          };
          build-all = {
            type = "app";
            program = "${self.packages.${system}.build-all}/bin/build-all";
          };
        };
      }
    );
}
