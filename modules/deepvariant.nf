process DEEPVARIANT {

	tag "${meta.sample_id}"

	container 'google/deepvariant:1.5.0'

        publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}/DEEPVARIANT", mode: 'copy'

        input:
        tuple val(meta), path(bam),path(bai)
        path(bed)
	tuple path(fai),path(fastagz),path(gzfai),path(gzi)

        output:
        path(dv_gvcf), emit: gvcf
        tuple val(meta),path(dv_vcf), emit: vcf

        script:
        dv_gvcf = meta.sample_id + "-deepvariant.g.vcf.gz"
        dv_vcf = meta.sample_id + "-deepvariant.vcf.gz"

        """
                /opt/deepvariant/bin/run_deepvariant \
                --model_type=ONT_R104 \
                --ref=$fastagz \
                --reads $bam \
                --output_vcf=$dv_vcf \
                --output_gvcf=$dv_gvcf \
                --regions=$bed \
                --num_shards=${task.cpus} \
        """
}

