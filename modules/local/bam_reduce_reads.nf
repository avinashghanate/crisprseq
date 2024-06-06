process BAM_REDUCE_READS {
    tag "$meta.id"
    label "process_high"

    conda "bioconda::samtools=1.17"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.17--h00cdaf9_0' :
        'biocontainers/samtools:1.17--h00cdaf9_0' }"

    input:
    tuple val(meta), path(bam)
    val unique_read_sgRNA_pair

    output:
    tuple val(meta), path("*.bam"), emit: reduced
    path  "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ""
    def prefix = task.ext.prefix ?: "${meta.id}"

    // By default reduce to only one unique read from a pair,
    // otherwise, for unique read and reference sgRNA ID pairs set this parameter 'unique_read_sgRNA_pair' to true
    def filter_command = unique_read_sgRNA_pair ? '!seen[$1,$3]++' : '!seen[$1]++'
    """
    samtools view -h ${bam} \\
        $args --threads $task.cpus \\
        | awk -F'\\t' '/@.*/ || ${filter_command}' \\
        | samtools view $args2 --threads $task.cpus -o ${prefix}.reduced.bam -

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.reduced.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}