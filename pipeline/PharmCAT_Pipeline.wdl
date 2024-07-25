version 1.0

task run_pharmcat {
    input {
        File vcf_file
    }

    command <<<
        mkdir -p data
        cp ~{vcf_file} data/
        pharmcat_pipeline data/$(basename ~{vcf_file})
    >>>

    output {
        Array[File] results = glob("data/*")
    }

    runtime {
        docker: "pgkb/pharmcat:2.14.0"
        memory: "4 GB"
        cpu: "1"
    }

    meta {
        author: "Andre Rico"
        description: "A tool for running the PharmCAT pipeline on a VCF file"
    }
}

workflow pharmcat_workflow {
    input {
        File vcf_file
        String output_directory
    }

    call run_pharmcat {
        input:
            vcf_file = vcf_file
    }

    output {
        Array[File] results = run_pharmcat.results
    }
}
