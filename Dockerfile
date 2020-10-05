FROM r-base:3.6.2

LABEL maintainer="Jeff G. Du <jeff.g.du@gmail.com>"

## dependencies OS## 
RUN apt-get update && apt-get install -y --no-install-recommends \
                ghostscript \
                lmodern \
                pandoc-citeproc \
                qpdf \
                pandoc \
                r-cran-formatr \
                r-cran-ggplot2 \
                r-cran-knitr \
				r-cran-rmarkdown \
                r-cran-runit \
                r-cran-testthat \
				r-cran-rmysql \
				r-cran-rpostgresql \
                texinfo \
                texlive-fonts-extra \
                texlive-fonts-recommended \
                texlive-latex-extra \
                texlive-latex-recommended \
                texlive-luatex \
                texlive-plain-generic \
                texlive-science \
                texlive-xetex \
				unzip libsqlite3-dev libbz2-dev libssl-dev \
                git libxml2-dev python3 python3-dev python3-pip python3-pandas python3-boto3 wget tree vim sed \
                subversion g++ gcc gfortran libcurl4-openssl-dev curl zlib1g-dev build-essential \
				libffi-dev  libcairo2-dev libxt-dev libhdf5-dev libgsl-dev \
				&& install.r binb linl pinp tint 

### dependencies Py ### 
RUN pip3 install pip
RUN pip3 install -U setuptools
RUN pip3 install multiqc

#### R packages ###
RUN R --slave -e "install.packages(c('BiocManager','devtools', 'gplots', 'R.utils', 'rmarkdown', 'RColorBrewer', 'Cairo','dplyr','tidyr','magrittr','matrixStats','readr','openxlsx','PerformanceAnalytics','pheatmap','gridExtra','dendextend','scales','ggrepel'), dependencies = TRUE, repos='https://cloud.r-project.org')"
RUN R --slave -e "BiocManager::install(c('BiocParallel','GenomicAlignments', 'GenomicRanges','rtracklayer', 'multtest', 'Rsamtools','limma','edgeR','org.Mm.eg.db','org.Hs.eg.db','org.Ce.eg.db','org.Dm.eg.db','ChIPseeker','clusterProfiler','APAlyzer','DESeq2'))"   
RUN R --slave -e "install.packages('Seurat')" 
RUN R --slave -e "BiocManager::install(c('SingleR','SingleCellExperiment','ComplexHeatmap','DropletUtils'))"
RUN R --slave -e "devtools::install_github('Japrin/STARTRAC')" 
RUN R --slave -e "devtools::install_github('ncborcherding/scRepertoire')" 
RUN R --slave -e "devtools::install_github('ebecht/MCPcounter',ref='master', subdir='Source')" 
RUN R --slave -e "remotes::install_github('chris-mcginnis-ucsf/DoubletFinder')"



RUN mkdir -p /nl
RUN mkdir -p /project
RUN mkdir -p /share
RUN mkdir -p /software

### install cell ranger and  atac ###
# RUN cd /software
RUN wget -O cellranger-4.0.0.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-4.0.0.tar.gz?Expires=1601711528&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci00LjAuMC50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2MDE3MTE1Mjh9fX1dfQ__&Signature=WYWbx2jdsBpuAy-4mGOWJwmwG8rPlzMfMPtQDOnbo1Jw7~HTTMMLyeeQRaRQcc3a0wCWBI7WUAaK2X3RhZG1uMtSTA17A8aizgXOhHrC8NA0p99bYCEByBQFPN6ELMu3klfyUBRoqTJ~lSvqTrR6ZNoxGzYRIczy54jeqzONeJuY96aMT6NEFsaxnm22JoCjDyFOASQE-bD297~rWT3PUdu5MD5~IBQEC4twZptI75MmON1oPVMREAHItzY9nOsRafx2ouAzYWNacB3HjbB5R16bLBVgfaDxvJ1RBVaRdVoNvy1sYspmcg7qSt2MS14atAGOa1R7zx09F4-vD-XHFQ__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA"
RUN tar -xzvf cellranger-4.0.0.tar.gz -C /software/
#RUN export PATH=/software/cellranger-3.1.0:$PATH
ENV PATH="/software/cellranger-4.0.0:${PATH}"

RUN wget -O cellranger-atac-1.2.0.tar.gz "https://cf.10xgenomics.com/releases/cell-atac/cellranger-atac-1.2.0.tar.gz?Expires=1601711773&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1hdGFjL2NlbGxyYW5nZXItYXRhYy0xLjIuMC50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2MDE3MTE3NzN9fX1dfQ__&Signature=Ol~HKc3qoBKrqzoREJBQDqT0AHjGc0Qt5jb4E1OxAG-mpqSNbZi1T7G-IFE28Wu2a7x5JM0Yd8-KEMeeNAnIekTeeFr-qPjn3tzE-o~DkzFp6lflu9DhGEg8Aj~5mydH7lIXIVcI4lE9cLIBFPayLSbTwq~RQWLlIUuev1jK278Tizaa4QoX8oeXYSp36tRlX--Pjfe0mzqGf-LcoCSdTXpt2JV5UVy-YP4e9rn2ioHK89-zP5F5XsgyA~OlEnqHBLOmUnLVndO4ShozueNy3cWVTUw8k5W3~tcv-7I7gN1Z76HI2KdPNyMv5c37~nxm~QeJubpIjkodbW3Ri5UbEA__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA"
RUN tar -xzvf cellranger-atac-1.2.0.tar.gz -C /software/
#RUN export PATH=/software/cellranger-atac-1.2.0:$PATH
ENV PATH="/software/cellranger-atac-1.2.0:${PATH}"


### install fastqc ###
RUN apt-get install -y --no-install-recommends fastqc

### END ### 
