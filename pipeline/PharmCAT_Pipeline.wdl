version 1.0

task run_pharmcat_pipeline {
    input {
        File vcf_file
        String output_directory
        String optional_params = ""  # Option parameters
    }

    command <<<
        set -x -e -o pipefail
        mkdir -p ~{output_directory}
        pharmcat_pipeline ~{vcf_file} -o ~{output_directory} ~{optional_params}
    >>>

    output {
        Array[File] preprocessed_vcf = glob("~{output_directory}/*.preprocessed.vcf*")
        Array[File] matcher_json = glob("~{output_directory}/*.match.json")
        Array[File] phenotyper_json = glob("~{output_directory}/*.phenotype.json")
        Array[File] report_files = glob("~{output_directory}/*.report.*")
    }

    runtime {
        docker: "pgkb/pharmcat:2.13.0"
        memory: "4 GB"
        cpu: "1"
    }

    meta {
        author: "Andre Rico"
        description: "A tool for running the PharmCAT pipeline on a VCF file"
    }
}

workflow pharmcat_pipeline_workflow {
    input {
        File vcf_file
        String output_directory
        String optional_params = ""
    }

    call run_pharmcat_pipeline {
        input:
            vcf_file = vcf_file,
            output_directory = output_directory,
            optional_params = optional_params
    }

    output {
        Array[File] preprocessed_vcf = run_pharmcat_pipeline.preprocessed_vcf
        Array[File] matcher_json = run_pharmcat_pipeline.matcher_json
        Array[File] phenotyper_json = run_pharmcat_pipeline.phenotyper_json
        Array[File] report_files = run_pharmcat_pipeline.report_files
    }
}
