process LIBRARY_REFERENCE {
    tag "library"
    label 'process_medium'

    input:
    tuple val(meta), path(library)

    output:
    tuple val(meta), path("*.fasta"), emit: reference

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def libPrefix = "${library}".split(".txt")[0]
    """
    cat "${library}" \\
        | sed '1d' \\
        | awk '{ printf ">%s\\n%s\\n", \$1, \$2 }' \\
        > "${libPrefix}.fasta"
    """
}