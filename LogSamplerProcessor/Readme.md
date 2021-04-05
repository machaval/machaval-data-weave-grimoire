# Log Sample Processor


This sample processor takes the logs as inputs and extract only the ones used for Sampling and output a Json DataStructure with 

```
Array<
    {
        success: boolean, // true if it was parsed
        ast?: {}, //With the ast of the script that was parsed interesting to do code analysis and queries
        script: {} // This has the entire content of the script + inputs 
    }
>
```

## Usage 

```
dw --spell machaval/LogSamplerProcessor -i payload search-results-2021-04-05T12_24_08.269-0700.csv  -o output/Samples.json
```