process MINIMAP2 {

	//publishDir "${params.outdir}/Minimap2/${meta.sample_id}", mode: 'copy'

	container 'quay.io/biocontainers/nanovar:1.4.1--py39h38f01e4_0'

	tag "${meta.sample_id}"

	input:
	tuple val(meta),path(reads)
	tuple path(fasta),path(fai)

	output:
	tuple val(meta),path(bam), emit: bam

	script:
	bam = meta.sample_id + "-" + meta.readgroup_id + ".bam"

	"""
	minimap2 -t ${task.cpus} -ax map-ont ${fasta} $reads | samtools addreplacerg -r ID:${meta.readgroup_id} -r SM:${meta.sample_id} - | samtools sort - | samtools view -bh -o $bam
	"""
}



