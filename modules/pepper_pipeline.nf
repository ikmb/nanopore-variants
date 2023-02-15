process PEPPER_PIPELINE {

	publishDir "${params.outdir}/pepper", mode: 'copy'

	container 'kishwars/pepper_deepvariant:r0.5'

	input:
	tuple val(meta),path(bam),path(bai)
	tuple path(fasta),path(fai)

	output:
	tuple val(meta),path(outdir)

	script:
	outdir = meta.sample_id + "_results"
	def options = ""
	if (params.region) {
		options = "-r ${params.region}"
	}

	"""
		run_pepper_margin_deepvariant call_variant \
		-b $bam \
		--ont \
		-f $fasta \
		-o $outdir \
		-p ${meta.sample_id} \
		-t ${task.cpus} \
		$options
	"""
}
