version 1.0
task pcat_unphased_batch{
    input {
        Array[File]+ single_sample_vcf
        Array[File]+ single_sample_index
    }
    command <<<
        set -x -e -o pipefail
        mkdir output
        for input in ~{sep=" " single_sample_vcf}; do
            file_prefix=$( basename $input ".vcf.gz")
            time /pharmcat/pharmcat_pipeline ${input} -0 -G -o output
            rm output/*.html
        done
    >>>
    output {
        Array[File] preprocessed_vcf = glob("output/*.preprocessed.vcf*")
        Array[File] matcher_json = glob("output/*.match.json")
        Array[File] phenotyper_json = glob("output/*.phenotype.json")
    }
    runtime {
        docker: "dx://pcat_500k_wgs:/PharmCAT/Docker/pcat_dev_2.11.0.tar.gz"
        dx_timeout: "3D"
        dx_instance_type: "mem2_ssd1_v2_x2"
    }
    parameter_meta {
    single_sample_vcf: {
        description: "unphased, single-sample vcf",
        patterns: ["*.vcf.gz"],
        stream: true
    }
    single_sample_index: {
       description: "indices for unphased, single-sample vcf",
       patterns: ["*.vcf.gz.tbi"],
       stream: true
   }
   }
}