# PharmCAT_Pipeline
PharmCAT_Pipeline v:2.13.0

[PharmCAT Pipeline Documentation](https://pharmcat.org/using/Running-PharmCAT-Pipeline/)

## pharmcat-wdl
Workflow to run the PharmCAT pipeline on a VCF file.

## Purpose
Runs the PharmCAT pipeline on a given VCF file, processing genetic data to provide pharmacogenomic insights.

## Requirements/Expectations
- A VCF file with the genetic data to be processed.

## Inputs
Input arguments:
- `File vcf_file`: 
        The VCF file to be processed.
        Path to a VCF file or a file of paths to VCF files (one file per line), sorted by chromosome position.
- `String sample_ids` (default: `""`): 
        Sample IDs.
        A comma-separated list of sample.
- `File? sample_file` (default: `null`): 
        Optional sample file.
        A file containing a list of samples, one sample per line.

Preprocessor arguments:
- `Boolean missing_to_ref` (default: `false`): 
        Whether to set missing data to reference.
        Assume genotypes at missing PGx sites are 0/0. DANGEROUS!.
- `Boolean no_gvcf_check` (default: `false`): 
        Whether to skip gVCF checks.
        Bypass the gVCF check for the input VCF. DANGEROUS!.
- `Boolean retain_specific_regions` (default: `false`): 
        Whether to retain specific regions.
        Retain the genomic regions specified by `-refRegion`
- `File? reference_regions` (default: `null`): 
        Reference regions file <bed_file>.
        A sorted bed file of specific PGx regions to retain. Must be used with the `-R` argument.

Named allele matcher arguments:
- `Boolean run_matcher` (default: `false`): 
        Whether to run the matcher.
        Run named allele matcher independently.
- `Boolean matcher_all_results` (default: `false`): 
        Whether to output all results from the matcher.
        Return all possible diplotypes, not just top hits.
- `Boolean matcher_save_html` (default: `false`): 
        Whether to save matcher results as HTML.
        Save named allele matcher results as HTML.
- `String research_mode` (default: `""`): 
        Research mode type <type>.
        Comma-separated list of research features to enable: [cyp2d6, combinations]

Phenotyper arguments:
- `Boolean run_phenotyper` (default: `false`): 
        Whether to run the phenotyper.
        Run phenotyper independently.

Reporter arguments:
- `Boolean run_reporter` (default: `false`): 
        Whether to run the reporter.
        Run reporter independently.
- `String reporter_sources` (default: `""`): 
        Sources for the reporter. <sources>
        Comma-separated list of sources to limit report to: [CPIC, DPWG]
- `Boolean reporter_extended` (default: `false`): 
        Whether to run the extended reporter.
        Output extended report.
- `Boolean reporter_save_json` (default: `false`): 
        Whether to save the reporter output as JSON.
        Save reporter results as JSON

Output arguments:
- `String base_filename` (default: `""`): 
        Base filename for the output. <name>
        Prefix for output files. Defaults to the same base name as the input.
- `Boolean delete_intermediate_files` (default: `false`): 
        Whether to delete intermediate files.
        Delete intermediate PharmCAT files (saved by default).

Concurrency/Memory arguments:
- `Int max_concurrent_processes` (default: `1`): 
        Maximum number of concurrent processes. <num processes>
        The maximum number of processes to use when concurrent mode is enabled.
- `String max_memory` (default: `"4G"`): 
        Maximum memory to use. <size>
        The maximum memory PharmCAT should use (e.g. "64G"). This is passed to Java using the -Xmx flag.



## Outputs
- `Array[File] results_all`: The results of the PharmCAT pipeline. These files are saved in the execution directory of the job.

## Usage Example
Here is an example of how to provide the inputs in a JSON file:

```json
{
  "pharmcat_pipeline.vcf_file": "gs://your-bucket/path/to/your.vcf",
  "pharmcat_pipeline.sample_ids": "",
  "pharmcat_pipeline.sample_file": null,
  "pharmcat_pipeline.missing_to_ref": false,
  "pharmcat_pipeline.no_gvcf_check": false,
  "pharmcat_pipeline.retain_specific_regions": false,
  "pharmcat_pipeline.reference_regions": null,
  "pharmcat_pipeline.run_matcher": false,
  "pharmcat_pipeline.matcher_all_results": false,
  "pharmcat_pipeline.matcher_save_html": false,
  "pharmcat_pipeline.research_mode": "",
  "pharmcat_pipeline.run_phenotyper": false,
  "pharmcat_pipeline.run_reporter": false,
  "pharmcat_pipeline.reporter_sources": "",
  "pharmcat_pipeline.reporter_extended": false,
  "pharmcat_pipeline.reporter_save_json": false,
  "pharmcat_pipeline.base_filename": "",
  "pharmcat_pipeline.delete_intermediate_files": false,
  "pharmcat_pipeline.max_concurrent_processes": 1,
  "pharmcat_pipeline.max_memory": "4G"
}
```

## Running the PharmCAT Pipeline
For convenience, the `pharmcat_pipeline` script simplifies the process of running the entire PharmCAT pipeline (the VCF Preprocessor and the core PharmCAT tool). The necessary dependencies are already included in the provided image.

### Prerequisites
The required dependencies (python3, java, bcftools, bgzip) are included in the provided image, so no additional installation is needed.

### Usage
Standard use case:

```sh
# pharmcat_pipeline <vcf_file>
```



## Software Version Notes
### Cromwell Version Support
Successfully tested on v53

### Important Notes
- Runtime parameters are optimized for Google Cloud Platform implementation.
- The provided JSON is a generic ready-to-use example template for the workflow. It is the user’s responsibility to correctly set the reference and resource variables for their own particular test case using the PharmCAT documentation.

## Documentation Links
- [PharmCAT Documentation](https://pharmcat.org/using/Running-PharmCAT-Pipeline/)
- [PharmCAT-Pipeline Documentation](https://pharmcat.org/using/Running-PharmCAT-Pipeline/)

## Contact Us
For any questions or concerns, please direct them to the PharmCAT GitHub Issues or the PharmGKB Forum.

## License
(C) 2024 Your Organization | BSD-3

This script is released under the [WDL open source code license](https://github.com/openwdl/wdl/blob/master/LICENSE) (BSD-3). Note, however, that the programs it calls may be subject to different licenses. Users are responsible for checking that they are authorized to run all programs before running this script.
```

Este README.md consolidado fornece uma descrição clara do workflow do WDL para rodar o PharmCAT Pipeline, juntamente com as instruções de uso simplificadas que já consideram a presença das dependências na imagem.