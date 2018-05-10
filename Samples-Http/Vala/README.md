# How to run the sample

## Dependency

On Ubuntu 18.04, need the following:

* `sudo apt install libsoup2.4-dev`
* `sudo add-apt-repository ppa:inizan-yannick/dev && sudo apt install libgxml-0.16-dev`

## Usage

1. Get unified api key for [Free](https://azure.microsoft.com/en-us/try/cognitive-services/?api=speech-services) or [Paid](https://go.microsoft.com/fwlink/?LinkId=872236) and add it to code
1. Compile and run (package versions may vary, change them according to installed ones):

```shell
valac --pkg libsoup-2.4 --pkg gxml-0.16 TTSSample.vala
./TTSSample
```
