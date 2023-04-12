
fa = params.fasta ?: params.genomes[ params.assembly ].fasta
fai = params.fai ?: params.genomes [ params.assembly ].fai

println "Mapping reference: ${fa}"

ch_fasta = Channel.from([
		file(fa, checkIfExists: true) ,	file(fai, checkIfExists: true) 
	]
)

include { MINIMAP2 } from '../modules/minimap'
include { PEPPER_PIPELINE } from '../modules/pepper_pipeline'
include { SAMTOOLS_MERGE } from '../modules/samtools/merge'
include { SAMTOOLS_INDEX } from '../modules/samtools/index'
include { INPUT_CHECK } from '../modules/input_check'
include { SOFTWARE_VERSIONS } from '../modules/software_versions'
include { MULTIQC } from './../modules/multiqc'
include { DEEPVARIANT } from './../modules/deepvariant'

samplesheet = Channel.fromPath( file(params.samplesheet, checkIfExists: true) )

ch_versions = Channel.from([])
ch_qc = Channel.from([])
ch_reports = Channel.from([])
ch_vcfs = Channel.from([])

params.bed ?: ch_bed = Channel.fromPath(params.bed, checkIfExists: true) : ch_bed = Channel.from([])

workflow NANOPORE_VARIANTS {

	main:
	INPUT_CHECK(samplesheet)

	MINIMAP2(
		INPUT_CHECK.out.reads,
		ch_fasta.collect()
	)

	bam_mapped = MINIMAP2.out.bam.map { meta, bam ->
            new_meta = [:]
            new_meta.sample_id = meta.sample_id
            def groupKey = meta.sample_id
            tuple( groupKey, new_meta, bam)
        }.groupTuple(by: [0,1]).map { g ,new_meta ,bam -> [ new_meta, bam ] }

        bam_mapped.branch {
			single:   it[1].size() == 1
            multiple: it[1].size() > 1
        }.set { bam_to_merge }

        SAMTOOLS_MERGE( bam_to_merge.multiple )
        SAMTOOLS_INDEX(
		SAMTOOLS_MERGE.out.bam.mix( 
			bam_to_merge.single 
		)
	)	

	if (params.ont_R104) {
		DEEPVARIANT(
			SAMTOOLS_INDEX.out.bam,
			ch_bed.collect(),
			ch_fasta.collect()
		)
		ch_vcfs = ch_vcfs.mix(DEEPVARIANT.out.vcf)
	} else {
	
		PEPPER_PIPELINE(
			SAMTOOLS_INDEX.out.bam,
			ch_fasta.collect()
		)
		ch_vcfs = ch_vcfs.mix(PEPPER_PIPELINE.out.vcf)
	}

	SOFTWARE_VERSIONS(
		ch_versions.collect()
	)		

	MULTIQC(
		ch_qc
    	)

	emit:
	report = ch_reports
	
}
