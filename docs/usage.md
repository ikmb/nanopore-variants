![](../images/ikmb_bfx_logo.png)
# IKMB Nanopore Variant Calling Pipeline

## General information

This pipeline is configured to run on the IKMB MedCluster. 

## Example command

`nextflow run ikmb/nanopore-variants --samplesheet samples.csv `

## --samplesheet

This pipeline accepts input as CSV formatted sample sheet using three columns: sample_id, readgroup_id and R1.

```
sample_id,readgroup_id,R1
MyTest,MyTest-XYZ,/path/to/MyTest-XYZ.fastq.gz
```

If a sample ID occurs multiple times, it is assumed that it was sequenced across multiple runs and that the data should be merged prior to variant calling. In this case, each fastq file is aligned separately and
then merged into one master BAM file with all readgroup information intact.

The readgroup ID is a unique identifier for data that comes from the same run, flowcell and lane (usually: one fastq file). This can be used by some callers to deal with artifacts arising from batch effects etc. 
## --assembly [ default = GRCh38_p14]

By default, this pipeline uses GRCh38 Patch14 as mapping reference. 

* GRCh38_p14
* GRCh38
* hg38
* GRCh37

## --regions [default = chr11:1074875-1094425]

Calling with this pipeline can be limited to a specific region using `--region chr1:1-10000`. To disable this and use the whole genome, set `--regions false`.

