version 1.0

# It is a single task that runs the PharmCAT pipeline on a VCF file
# as a single task the workflow is just a wrapper for the task and get the same name

# The output is an array of files that are the results of the pipeline save in the plataform where the workflow is running

task pharmcat_pipeline {
  meta {
    author: "ClinPGx"
    email: "pharmcat@pharmgkb.org"
    description: "Workflow to run the PharmCAT pipeline on a VCF file"
  }

  parameter_meta {
    # description for this is intentionally different from pipeline script because it's hard to support a file of files
    # on cloud services
    vcf_file: {
      description: "Path to a VCF file or a directory containing VCF files.",
      category: "required"
    }
    sample_ids: {
      description: "A comma-separated list of sample IDs.  Only applicable if have multiple samples and only want to work on specific ones.",
      category: "input"
    }
    sample_file: {
      description: "A file containing a list of sample IDs, one sample ID per line.  Only applicable if have multiple samples and only want to work on specific ones.",
      category: "input"
    }

    missing_to_ref: {
      description: "Assume genotypes at missing PGx sites are 0/0.  DANGEROUS!",
      category: "preprocessor"
    }
    no_gvcf_check: {
      description: "Bypass check if VCF file is in gVCF format.",
      category: "preprocessor"
    }
    # not including retain_specific_regions and reference_regions

    run_matcher: {
      description: "Run named allele matcher independently.",
      category: "matcher"
    }
    matcher_all_results: {
      description: "Return all possible diplotypes, not just top hits.",
      category: "matcher"
    }
    matcher_save_html: {
      description: "Save named allele matcher results as HTML.'",
      category: "matcher"
    }
    research_mode: {
      description: "Comma-separated list of research features to enable: [cyp2d6, combinations]",
      category: "matcher"
    }

    run_phenotyper: {
      description: "Run phenotyper independently.",
      category: "phenotyper"
    }

    run_reporter: {
      description: "Run reporter independently.",
      category: "reporter"
    }
    reporter_sources: {
      description: "Comma-separated list of sources to limit report to: [CPIC, DPWG, FDA]",
      category: "reporter"
    }
    reporter_extended: {
      description: "Output extended report.",
      category: "reporter"
    }
    reporter_save_json: {
      description: "Save reporter results as JSON.",
      category: "reporter"
    }

    base_filename: {
      description: "Prefix for output files.  Defaults to the same base name as the input.",
      category: "output"
    }
    delete_intermediate_files: {
      description: "Delete intermediate PharmCAT files.  Defaults to saving all files.",
      category: "output"
    }

    max_concurrent_processes: {
      description: "The maximum number of processes to use when concurrent mode is enabled.",
      category: "concurrency"
    }
    max_memory: {
      description: "The maximum memory PharmCAT should use (e.g. '64G').",
      category: "concurrency"
    }
  }

  input {
    File vcf_file
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
    mkdir -p data

    pharmcat_pipeline data/$(basename ~{vcf_file}) \
    ~{if sample_ids != "" then '-s ' + sample_ids else ''} \
    ~{if defined(sample_file) then '-S ' + sample_file else ''} \
    ~{if missing_to_ref then '-0' else ''} \
    ~{if no_gvcf_check then '-G' else ''} \
    ~{if retain_specific_regions then '-R' else ''} \
    ~{if defined(reference_regions) then '-refRegion ' + reference_regions else ''} \
    ~{if run_matcher then '-matcher' else ''} \
    ~{if matcher_all_results then '-ma' else ''} \
    ~{if matcher_save_html then '-matcherHtml' else ''} \
    ~{if research_mode != "" then '-research ' + research_mode else ''} \
    ~{if run_phenotyper then '-phenotyper' else ''} \
    ~{if run_reporter then '-reporter' else ''} \
    ~{if reporter_sources != "" then '-rs ' + reporter_sources else ''} \
    ~{if reporter_extended then '-re' else ''} \
    ~{if reporter_save_json then '-reporterJson' else ''} \
    ~{if base_filename != "" then '-bf ' + base_filename else ''} \
    ~{if delete_intermediate_files then '-del' else ''} \
    -o data -cp ~{max_concurrent_processes} -cm ~{max_memory}
  >>>

  output {
    Array[File] results = glob("data/*")
  }

  runtime {
    docker: "pgkb/pharmcat:2.15.2"
    memory: max_memory
    cpu: max_concurrent_processes
  }
}

workflow pharmcat_pipeline {
  input {
    File vcf_file
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

  call pharmcat_pipeline {
    input:
      vcf_file = vcf_file,
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
    Array[File] results_all = pharmcat_pipeline.results
  }
}
