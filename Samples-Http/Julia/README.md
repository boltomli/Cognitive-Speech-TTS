# How to run the sample

## Usage

1. Get unified api key for [Free](https://azure.microsoft.com/en-us/try/cognitive-services/?api=speech-services) or [Paid](https://go.microsoft.com/fwlink/?LinkId=872236)
1. Set environment variables `export MYKEY=mykey; export MYREGION=westus`
1. Run `julia -e 'import Pkg; Pkg.add("HTTP"); Pkg.add("LightXML")'` to install dependencies.
1. Run `julia sample.jl` to get the result
