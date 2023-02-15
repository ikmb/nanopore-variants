process SAMTOOLS_MERGE {

	container 'quay.io/biocontainers/samtools:1.16.1--h6899075_1'

	publishDir "${params.outdir}/Samtools", mode: 'copy'

        tag "${meta.patient_id}|${meta.sample_id}"

        input:
        tuple val(meta), path(aligned_bam_list)

        output:
        tuple val(meta),path(merged_bam), emit: bam

        script:
        merged_bam = meta.sample_id + ".merged.bam"
        merged_bam_index = merged_bam + ".bai"

        """
        samtools merge -@ 4 $merged_bam ${aligned_bam_list.join(' ')}
        """
}

