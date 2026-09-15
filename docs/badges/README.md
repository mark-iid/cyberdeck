# Badges

Vendored so the README renders with no network. The deck is the machine most
likely to be reading it, and it is the machine least likely to be online.

Each file is self-contained: the only `http` string in them is the SVG XML
namespace (an identifier, never fetched), and the three badges with logos carry
those logos inline as base64 `data:` URIs. Nothing here hits the network at
render time.

## Two of these carry live state

`thermal.svg` and `case.svg` assert facts that will go stale. Regenerate them
when the fact changes, a badge is the most visible line in the README and the
easiest to forget.

## Regenerating

Needs internet. From the repo root:

```sh
fetch() { curl -fsS --max-time 20 -o "docs/badges/$1" "https://img.shields.io/badge/$2"; }

fetch platform.svg   'platform-Raspberry%20Pi%205-C51A4A?logo=raspberrypi&logoColor=white'
fetch os.svg         'Raspberry%20Pi%20OS-trixie%20(Debian%2013)-A81D33?logo=debian&logoColor=white'
fetch compositor.svg 'compositor-niri%20v26.04-5A4FCF'
fetch shell.svg      'shell-bash-4EAA25?logo=gnubash&logoColor=white'
fetch install.svg    'install-additive%20%C2%B7%20reversible-2E7D32'
fetch thermal.svg    'thermal-2400%20MHz%20unthrottled-2E7D32'
fetch case.svg       'case-Pelican%201400%20built-2E7D32'
```

Format is `<label>-<message>-<colour>`. URL-encode both text fields: `%20` for
space, `%C2%B7` for the `·` separator. A literal `-` in either field must be
doubled (`--`), and `_` means a space in the shorthand form, which is why every
space here is spelled `%20` instead.

## Why static, and why vendored

Static because there's no CI to report on, provisioning happens on the deck, not
in a runner, so a build-status badge would be reporting on nothing.

Vendored because the deck is the machine most likely to be reading this README
and the machine least likely to be online. A `img.shields.io` URL renders as a
broken-image box in a local markdown viewer with no network, which is precisely
the situation this whole repo exists for. The files here render offline.
