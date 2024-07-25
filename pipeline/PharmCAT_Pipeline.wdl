version 1.0

task run_pharmcat_pipeline {
    input {
        File vcf_file
        String output_directory
        String optional_params = ""
    }

    command <<<
        set -x -e -o pipefail
        mkdir -p ~{output_directory}
        mkdir -p data
        cp ~{vcf_file} data/
        pharmcat_pipeline data/$(basename ~{vcf_file}) -o data/$(basename ~{output_directory}) ~{optional_params}
    >>>

    output {
        Array[File] results = glob("data/*")
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
        Array[File] results = run_pharmcat.results
    }
}
