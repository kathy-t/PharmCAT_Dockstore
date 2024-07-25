version 1.0

task run_pharmcat_pipeline {
    input {
        File vcf_file
        String output_directory
        String sample_ids = ""
        File? sample_file
        Boolean missing_to_ref = false
        Boolean no_gvcf_check = false
        Boolean retain_specific_regions = false
        File? reference_regions
        Boolean run_matcher = false
        Boolean matcher_all_results = false
        Boolean matcher_save_html = false
        String research_mode = ""
        Boolean run_phenotyper = false
        Boolean run_reporter = false
        String reporter_sources = ""
        Boolean reporter_extended = false
        Boolean reporter_save_json = false
        String base_filename = ""
        Boolean delete_intermediate_files = false
        Int max_concurrent_processes = 1
        String max_memory = "4G"
    }

    command <<<
        set -x -e -o pipefail
        mkdir -p ~{output_directory}
        mkdir -p data
        cp ~{vcf_file} data/
        
        pharmcat_pipeline data/$(basename ~{vcf_file}) -o ~{output_directory} \
        ~{if defined(sample_ids) then '-s ' + sample_ids else ''} \
        ~{if defined(sample_file) then '-S ' + sample_file else ''} \
        ~{if missing_to_ref then '-0' else ''} \
        ~{if no_gvcf_check then '-G' else ''} \
        ~{if retain_specific_regions then '-R' else ''} \
        ~{if defined(reference_regions) then '-refRegion ' + reference_regions else ''} \
        ~{if run_matcher then '-matcher' else ''} \
        ~{if matcher_all_results then '-ma' else ''} \
        ~{if matcher_save_html then '-matcherHtml' else ''} \
        ~{if defined(research_mode) then '-research ' + research_mode else ''} \
        ~{if run_phenotyper then '-phenotyper' else ''} \
        ~{if run_reporter then '-reporter' else ''} \
        ~{if defined(reporter_sources) then '-rs ' + reporter_sources else ''} \
        ~{if reporter_extended then '-re' else ''} \
        ~{if reporter_save_json then '-reporterJson' else ''} \
        ~{if defined(base_filename) then '-bf ' + base_filename else ''} \
        ~{if delete_intermediate_files then '-del' else ''} \
        -cp ~{max_concurrent_processes} -cm ~{max_memory}
    >>>

    output {
        Array[File] results = glob("~{output_directory}/*")
    }

    runtime {
        docker: "pgkb/pharmcat:2.13.0"
        memory: "4G"
        cpu: "1"
    }

    meta {
        author: "Andre Rico"
        description: "A tool for running the PharmCAT pipeline on a VCF file"
    }

    parameter_meta {
        vcf_file {
            description: "Path to the VCF file to be processed."
            example: "gs://bucket/path/to/input.vcf"
        }
        output_directory {
            description: "Directory where output files will be saved."
            example: "gs://bucket/path/to/output"
        }
        sample_ids {
            description: "A comma-separated list of sample IDs."
            example: "sample1,sample2"
        }
        sample_file {
            description: "A file containing a list of samples, one sample per line."
            example: "gs://bucket/path/to/samples.txt"
        }
        missing_to_ref {
            description: "Assume genotypes at missing PGx sites are 0/0. Dangerous!"
        }
        no_gvcf_check {
            description: "Bypass the gVCF check for the input VCF. Dangerous!"
        }
        retain_specific_regions {
            description: "Retain the genomic regions specified by -refRegion."
        }
        reference_regions {
            description: "A sorted BED file of specific PGx regions to retain. Must be used with the -R argument."
            example: "gs://bucket/path/to/regions.bed"
        }
        run_matcher {
            description: "Run named allele matcher independently."
        }
        matcher_all_results {
            description: "Return all possible diplotypes, not just top hits."
        }
        matcher_save_html {
            description: "Save named allele matcher results as HTML."
        }
        research_mode {
            description: "Comma-separated list of research features to enable: [cyp2d6, combinations]"
            example: "cyp2d6,combinations"
        }
        run_phenotyper {
            description: "Run phenotyper independently."
        }
        run_reporter {
            description: "Run reporter independently."
        }
        reporter_sources {
            description: "Comma-separated list of sources to limit report to: [CPIC, DPWG]"
            example: "CPIC,DPWG"
        }
        reporter_extended {
            description: "Output extended report."
        }
        reporter_save_json {
            description: "Save reporter results as JSON."
        }
        base_filename {
            description: "Prefix for output files. Defaults to the same base name as the input."
            example: "output_prefix"
        }
        delete_intermediate_files {
            description: "Delete intermediate PharmCAT files (saved by default)."
        }
        max_concurrent_processes {
            description: "The maximum number of processes to use when concurrent mode is enabled."
            example: "4"
        }
        max_memory {
            description: "The maximum memory PharmCAT should use (e.g. '64G'). This is passed on to Java using the -Xmx flag."
            example: "16G"
        }
    }
}

workflow pharmcat_pipeline_workflow {
    input {
        File vcf_file
        String output_directory
        String sample_ids = ""
        File? sample_file
        Boolean missing_to_ref = false
        Boolean no_gvcf_check = false
        Boolean retain_specific_regions = false
        File? reference_regions
        Boolean run_matcher = false
        Boolean matcher_all_results = false
        Boolean matcher_save_html = false
        String research_mode = ""
        Boolean run_phenotyper = false
        Boolean run_reporter = false
        String reporter_sources = ""
        Boolean reporter_extended = false
        Boolean reporter_save_json = false
        String base_filename = ""
        Boolean delete_intermediate_files = false
        Int max_concurrent_processes = 1
        String max_memory = "4G"
    }

    call run_pharmcat_pipeline {
        input:
            vcf_file = vcf_file,
            output_directory = output_directory,
            sample_ids = sample_ids,
            sample_file = sample_file,
            missing_to_ref = missing_to_ref,
            no_gvcf_check = no_gvcf_check,
            retain_specific_regions = retain_specific_regions,
            reference_regions = reference_regions,
            run_matcher = run_matcher,
            matcher_all_results = matcher_all_results,
            matcher_save_html = matcher_save_html,
            research_mode = research_mode,
            run_phenotyper = run_phenotyper,
            run_reporter = run_reporter,
            reporter_sources = reporter_sources,
            reporter_extended = reporter_extended,
            reporter_save_json = reporter_save_json,
            base_filename = base_filename,
            delete_intermediate_files = delete_intermediate_files,
            max_concurrent_processes = max_concurrent_processes,
            max_memory = max_memory
    }

    output {
        Array[File] results = run_pharmcat_pipeline.results
    }

    parameter_meta {
        vcf_file {
            description: "Path to the VCF file to be processed."
            example: "gs://bucket/path/to/input.vcf"
        }
        output_directory {
            description: "Directory where output files will be saved."
            example: "gs://bucket/path/to/output"
        }
        sample_ids {
            description: "A comma-separated list of sample IDs."
            example: "sample1,sample2"
        }
        sample_file {
            description: "A file containing a list of samples, one sample per line."
            example: "gs://bucket/path/to/samples.txt"
        }
        missing_to_ref {
            description: "Assume genotypes at missing PGx sites are 0/0. Dangerous!"
        }
        no_gvcf_check {
            description: "Bypass the gVCF check for the input VCF. Dangerous!"
        }
        retain_specific_regions {
            description: "Retain the genomic regions specified by -refRegion."
        }
        reference_regions {
            description: "A sorted BED file of specific PGx regions to retain. Must be used with the -R argument."
            example: "gs://bucket/path/to/regions.bed"
        }
        run_matcher {
            description: "Run named allele matcher independently."
        }
        matcher_all_results {
            description: "Return all possible diplotypes, not just top hits."
        }
        matcher_save_html {
            description: "Save named allele matcher results as HTML."
        }
        research_mode {
            description: "Comma-separated list of research features to enable: [cyp2d6, combinations]"
            example: "cyp2d6,combinations"
        }
        run_phenotyper {
            description: "Run phenotyper independently."
        }
        run_reporter {
            description: "Run reporter independently."
        }
        reporter_sources {
            description: "Comma-separated list of sources to limit report to: [CPIC, DPWG]"
            example: "CPIC,DPWG"
        }
        reporter_extended {
            description: "Output extended report."
        }
        reporter_save_json {
            description: "Save reporter results as JSON."
        }
        base_filename {
            description: "Prefix for output files. Defaults to the same base name as the input."
            example: "output_prefix"
        }
        delete_intermediate_files {
            description: "Delete intermediate PharmCAT files (saved by default)."
        }
        max_concurrent_processes {
            description: "The maximum number of processes to use when concurrent mode is enabled."
            example: "4"
        }
        max_memory {
            description: "The maximum memory PharmCAT should use (e.g. '64G'). This is passed on to Java using the -Xmx flag."
            example: "16G"
        }
    }
}
