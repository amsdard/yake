yake
---

yake = **Y**et**A**notherma**K**eclon**E**

simple script to make Your coding simpler via executing long commands using short aliases from local YAML "Yakefile"

## Documentation
* http://yake.amsdard.io 
* `./doc/index.html`

## Contributors
* Chris <krzysztof.kabala@amsterdam-standard.pl>

## Test using docker
```
docker run --rm -it ubuntu bash
apt-get update && apt-get install -y curl sudo build-essential 
curl -sSf https://krzysztof-kabala.github.io/yake-1/install.sh | sudo bash
curl -sSf https://krzysztof-kabala.github.io/yake-1/Yakefile > Yakefile
yake VAR1=xx demo uname -m
```

## Licence
MIT