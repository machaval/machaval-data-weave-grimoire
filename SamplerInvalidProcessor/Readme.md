# Invalid vs Valid requests

This scripts takes as input the output from the `LogSamplerProcessor`

Caluculates the amount of valid vs invalid request that were made to the server

## Usage

```bash
dw --spell machaval/SamplerInvalidProcessor -i payload output/Samples.json
```

Where `output/Samples.json` is the output of running the `LogSamplerProcessor` spell

Output something like

```json
{
  "valid": 18207,
  "invalid": 14760
}
```

