# sequential Pattern Mining
We use sequence mining to uncover frequent, interesting patterns from temporal data.

### YouTube tutorial
See my Youtube video for how to understand this code:
https://youtu.be/6orYG5Aqlm8

### sequence_mining.R: 
This R code implements sequential pattern mining using an algorithm called cSPADE. The package name is arulesSequences.
### input_data.csv: 
This shows you what the input data should look like. Since the original file that produced the output is very large, I only uploaded the first few rows to github as an example.
### top_results.csv:
This shows the top sequences (most popular) identified by the algorithm. It's a subset from the file below.
### all_results.csv:
This shows the all sequences (most popular) identified by the algorithm. Any pattern that pass the criteria of being popular enough will show up. You can change the criteria to make it more stringent or loose by changing the support parameter in cspade.

