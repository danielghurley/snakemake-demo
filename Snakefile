samples = ["A", "B"]


rule all:
    input:
        "calls/all.vcf",
        "plots/quals.svg"


rule bwa:
    input:
        "data/genome.fa",
        "data/samples/{sample}.fastq"
    output:
        temp("mapped/{sample}.bam")
    conda:
        "envs/mapping.yaml"
    threads: 8
    shell:
        "bwa mem -t {threads} {input} | samtools view -Sb - > {output}"


rule sort:
    input:
        "mapped/{sample}.bam"
    output:
        "mapped/{sample}.sorted.bam"
    conda:
        "envs/mapping.yaml"
    shell:
        "samtools sort -o {output} {input}"



rule call:
    input:
        fa="data/genome.fa",
        bam=expand("mapped/{sample}.sorted.bam", sample=samples)
    output:
        "calls/all.vcf"
    conda:
        "envs/calling.yaml"
    shell:
        "samtools mpileup -g -f {input.fa} {input.bam} | "
        "bcftools call -mv - > {output}"

rule stats:
    input:
        "calls/all.vcf"
    output:
        report("plots/quals.svg", caption="report/calling.rst")
    conda:
        "envs/stats.yaml"
    script:
        "scripts/plot-quals.py"