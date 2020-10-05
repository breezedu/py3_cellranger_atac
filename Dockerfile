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
RUN wget -O cellranger-4.0.0.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-4.0.0.tar.gz?Expires=1601970469&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci00LjAuMC50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2MDE5NzA0Njl9fX1dfQ__&Signature=EQzRXDsvKO7K9cv6TJ244vGG2Of~lal82EmND~MnacqpGQNAFc6bee8wE3y-m1T8JW2g7Brt4KfzjOMozKKKfx9beO5X~1aoykzPNSo652jyHeNLZThB9wzVPYJUhrDpU9PzgdKhHNd09yRiql8SPaONQURZzWOfFfpTS2-LtZOzaDpiIuK5TXSTxsoRcZj5AZImxIlE81ABQX49Tt1gxHb71ZevzTpObWBR7rYkPtDTIiDTyxcwv~gZGIk2r7itEE0o5oNS0Mal-0jeoiWwWXl2Xc2ufOg0d4WSj0TrCXEs53eidvR-BrO81HeDSSjLypD9Q0eFdOd3rSVZbygWsQ__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA"
RUN tar -xzvf cellranger-4.0.0.tar.gz -C /software/
#RUN export PATH=/software/cellranger-3.1.0:$PATH
ENV PATH="/software/cellranger-4.0.0:${PATH}"

RUN wget -O cellranger-atac-1.2.0.tar.gz "https://cf.10xgenomics.com/releases/cell-atac/cellranger-atac-1.2.0.tar.gz?Expires=1601970257&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1hdGFjL2NlbGxyYW5nZXItYXRhYy0xLjIuMC50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2MDE5NzAyNTd9fX1dfQ__&Signature=GqMzRjojm2wzwknAZf4H58iaT1J6rvvkLUenf0fDqJ0ln2SRbC4ykYkWMjZ0SQ4IQH-9quO7A5b46sXEY5Z7KQOw46kr9iTEUjdU8MEX4VE5ctX3THqlmNGLV6TMAs0R6LH95LKbiHmwUDlMCzUUK5lUT2B~6mbHFFV4D51Hd0UlW7-~yti3IeUuAEyx-CvvtaMh-rocW7iu1mTekHxCmoA-Fd~IJKTrskYBhfMWNI3PvoVmMeRi-CMmbezbBjt2Jzo16EZUYD1LX42pdEQzc9M6QPT~b4I8XO0vkn~2QoCi5wAH7AXXLx69lV~~22o64VcT9sgCQgcI4dM~LfsYiw__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA"
RUN tar -xzvf cellranger-atac-1.2.0.tar.gz -C /software/
#RUN export PATH=/software/cellranger-atac-1.2.0:$PATH
ENV PATH="/software/cellranger-atac-1.2.0:${PATH}"


### install fastqc ###
RUN apt-get install -y --no-install-recommends fastqc

### END ### 
