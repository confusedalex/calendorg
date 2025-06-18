{
  pkgs ? import <nixpkgs> {
    config = {
      android_sdk.accept_license = true;
      allowUnfree = true;
    };
  },
}:
pkgs.androidenv.emulateApp {
  name = "emulate-MyAndroidApp";
  platformVersion = "33";
  abiVersion = "x86_64"; # armeabi-v7a, mips, x86_64
  systemImageType = "google_apis_playstore";
}
