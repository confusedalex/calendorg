{
  description = "Flutter environment";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          android_sdk.accept_license = true;
        };
        buildToolsVer = "34.0.0";
        androidEnv = pkgs.androidenv.override { licenseAccepted = true; };
        androidComposition = androidEnv.composeAndroidPackages {
          cmdLineToolsVersion = "8.0";
          toolsVersion = "26.1.1";
          platformToolsVersion = "34.0.4";
          buildToolsVersions = [ buildToolsVer ];
          platformVersions = [ "34" "35" ];
          abiVersions = [ "x86_64" ];

          includeNDK = false;
          systemImageTypes = [
            "google_apis"
            "google_apis_playstore"
          ];
          extraLicenses = [
            "android-googletv-license"
            "android-sdk-arm-dbt-license"
            "android-sdk-license"
            "android-sdk-preview-license"
            "google-gdk-license"
            "intel-android-extra-license"
            "intel-android-sysimage-license"
            "mips-android-sysimage-license"
          ];
        };
        androidSdk = androidComposition.androidsdk;
      in
      {
        devShell =
          with pkgs;
          mkShell {
            ANDROID_EMULATOR_WAIT_TIME_BEFORE_KILL = "1";
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
            ANDROID_AVD_HOME = "$HOME/.android/avd";
            JAVA_HOME = jdk17.home;
            FLUTTER_ROOT = flutter;
            DART_ROOT = "${flutter}/bin/cache/dart-sdk";
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${buildToolsVer}/aapt2";
            QT_QPA_PLATFORM = "wayland;xcb";

            buildInputs = [
              androidSdk
              flutter
              gradle
              jdk17
            ];

            LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [
              vulkan-loader
              libGL
            ]}";

            shellHook = ''
              PS1="\[\e[34m\][flutter@flake:\[\e[35m\]\w\[\e[34m\]]\$\[\e[0m\] "

              if [ -z "$PUB_CACHE" ]; then
                export PATH="$PATH:$HOME/.pub-cache/bin"
              else
                export PATH="$PATH:$PUB_CACHE/bin"
              fi

              ${flutter} config --android-sdk $ANDROID_HOME --jdk-dir $JAVA_HOME > /dev/null 2>&1
            '';
          };
      }
    );
}
