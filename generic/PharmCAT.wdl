version 1.0

task run_pharmcat {
    input {
        File vcf_file
        String pharmcat_command
        String optional_params = "" 
    }

    command <<<
        mkdir -p data
        cp ~{vcf_file} data/
        java -jar pharmcat.jar ~{pharmcat_command} -vcf data/$(basename ~{vcf_file}) ~{optional_params}
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
        description: "A generic tool for running any PharmCAT command on a VCF file"
    }
}

workflow pharmcat_workflow {
    input {
        File vcf_file
        String pharmcat_command
        String optional_params = ""
        String output_directory
    }

    call run_pharmcat {
        input:
            vcf_file = vcf_file,
            pharmcat_command = pharmcat_command,
            optional_params = optional_params
    }

    output {
        Array[File] results = run_pharmcat.results
    }
}
