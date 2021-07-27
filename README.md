# AquilegiaVulgaris
Assembly and analysis of Aquilegia vulgaris genome. <br/>

## Step one: Assemble and Correct 
Calculate genome size <br/>
Assemble the long reads into contigs using Canu <br/>
Correct using long and short reads (PCR free) <br/>

## Step two: Scaffold
Using available genome sequences and the software RagTag <br/>

## Step three: Annotate repeats and mask the genome
Annotate transposable elements using RepeatModeler2 <br/>
Mask the genome assembly using Repeatmasker <br/>

## Step four: Check for missassemblies using HiC
Map HiC reads using Hiccup and convert to juicer input <br/>
Manually examine in Juicebox for missassemblies, fix and repeat Step three and four until no evident missassemblies <br/>
Align the genome to available references to examine synteny using Minimap2 <br/>

## Step five: Annotate genes using correct assembly of A. vulgaris
Map RNA reads to masked genome <br/>
Run gene annotation pipeline <br/>
Check orthology using available genomes <br/>

