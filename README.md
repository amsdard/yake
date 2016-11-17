yake
---

yake = **Y**et**A**notherma**K**eclon**E**

simple script to make Your coding more efficient by executing long commands using short aliases from local YAML 
"Yakefile"

## Documentation
* http://yake.amsdard.io 
* `./doc/index.html`

## Test using docker
```
docker run --rm -it ubuntu bash
apt-get update && apt-get install -y curl sudo build-essential 
curl -sSf https://amsdard.github.io/yake/install.sh | sudo bash
curl -sSf https://amsdard.github.io/yake/Yakefile > Yakefile
yake VAR1=xx demo uname -m
```

## Licence
MIT