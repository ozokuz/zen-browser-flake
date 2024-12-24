# Zen Browser

This is a flake for the Zen browser.

Just add it to your NixOS `flake.nix` or home-manager:

```nix
inputs = {
  zen-browser.url = "github:fufexan/zen-browser-flake";
  ...
}
```

## Packages

Only one package (`zen`) is provided for either `aarch64-linux` or `x86_64-linux`.

In the `configuration.nix` in the `environment.systemPackages` add:

```nix
inputs.zen-browser.packages."${system}".default
```

```shell
$ sudo nixos-rebuild switch
$ zen
```

## 1Password

Zen has to be manually added to the list of browsers that 1Password will communicate with. See [this wiki article](https://nixos.wiki/wiki/1Password) for more information. To enable 1Password integration, you need to add the line `.zen-wrapped` to the file `/etc/1password/custom_allowed_browsers`.
