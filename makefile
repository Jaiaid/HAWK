SHELL := /bin/bash
CPP_FLAG = -lpthread
CPP_FOLDER=cpp/src
CPP_FILE=${CPP_FOLDER}/*.cpp
OBJECT_FILE=${CPP_FOLDER}/*.o

SRA_INPUT=true
JF_VERSION=2
HAWK_NEW=true
COUNTKMER_NEW=true

READ_DIR=.
HAWK_DIR=$(shell pwd)
CUR_DIR=$(shell pwd)

ifeq ($(COUNTKMER_NEW),true)
JF_SCRIPT_NAME_TMP=countKmers_jf$(JF_VERSION)
ifeq ($(SRA_INPUT),true)
JF_SCRIPT_NAME=$(JF_SCRIPT_NAME_TMP)_sra
else
JF_SCRIPT_NAME=$(JF_SCRIPT_NAME_TMP)
endif
ifeq ($(JF_VERSION),2)
JF_TAR_GZ_PREFIX=jellyfish-2.2.10-HAWK
JF_BUILD_RULE=jellyfish-2.2.10
else
JF_TAR_GZ_PREFIX=jellyfish-HAWK
JF_BUILD_RULE=jellyfish-Hawk
endif
else
JF_SCRIPT_NAME=countKmers_old
endif
ifeq ($(HAWK_NEW),true)
HAWK_SCRIPT_NAME=runHawk
KMER_SUMMARY_SCRIPT_NAME=runKmerSummary
else
HAWK_SCRIPT_NAME=runHawk_old
KMER_SUMMARY_SCRIPT_NAME=runKmerSummary_old
endif


INSTALL_RULESET = all EIG6.0.1-Hawk $(JF_BUILD_RULE) 

all: hawk preProcess log_reg_case log_reg_control bonf_fasta\
     kmersearch kmersummary convertToFasta_bf_correction convertToFasta_bh_correction\
	 kmerStats

.PHONY: all clean $(INSTALL_RULESET) install

hawk: hawk.o ${OBJECT_FILE}
	g++ $^ ${CPP_FLAG} -o $@

preProcess: preProcess.o
	g++ $^ -o $@

log_reg_case: log_reg_case.o ${OBJECT_FILE}
	g++ $^  ${CPP_FLAG} -o $@

log_reg_control: log_reg_control.o ${OBJECT_FILE}
	g++ $^ ${CPP_FLAG} -o $@

bonf_fasta: bonf_fasta.o
	g++ $^ -o $@

kmersearch: kmersearch.o
	g++ $^ -o $@

kmersummary: kmersummary.o
	g++ $^ -o $@

convertToFasta_bf_correction: convertToFasta_bf_correction.o
	g++ $^ -o $@

convertToFasta_bh_correction: convertToFasta_bh_correction.o
	g++ $^ -o $@

kmerStats: kmerStats.o
	g++ $^ -o $@

hawk.o: hawk.cpp
	g++ $^ -c -o $@

preProcess.o: preProcess.cpp
	g++ $^ -c -o $@

log_reg_case.o: log_reg_case.cpp
	g++ $^ -c -o $@

log_reg_control.o: log_reg_control.cpp
	g++ $^  -c -o $@

bonf_fasta.o: bonf_fasta.cpp
	g++ $^ -c -o $@

kmersearch.o: kmersearch.cpp
	g++ $^ -c -o $@

kmersummary.o: kmersummary.cpp
	g++ $^ -c -o $@

convertToFasta_bf_correction.o: convertToFasta.cpp
	g++ $^ -c -o $@

convertToFasta_bh_correction.o: convertToFasta_bh_correction.cpp
	g++ $^ -c -o $@

kmerStats.o: kmerStats.cpp
	g++ $^ -c -o $@

${OBJECT_FILE}: ${CPP_FILE}
	@for f in `ls ${CPP_FILE}`;do \
		echo $$f;g++ $$f -c -o $$f.o; \
	done

install: $(INSTALL_RULESET)

# build rule jellyfish-2.2.10
jellyfish-2.2.10: supplements/jellyfish-2.2.10-HAWK.tar.gz
	{ cd supplements && \
	tar -xzvf jellyfish-2.2.10-HAWK.tar.gz -C .. && cd .. && \
	pushd jellyfish-2.2.10 && \
	./configure && $(MAKE) && \
	popd && \
	echo -e "\e[1;32mjellyfish-2.2.10-HAWK BUILD SUCCESSFUL\e[0m"; } || \
	{ echo -e "\e[1;31mjellyfish-2.2.10-HAWK BUILD FAILED\e[0m"; cd $(CUR_DIR); rm -rf jellyfish-2.2.10; exit 1; }

jellyfish-Hawk: supplements/jellyfish-Hawk.tar.gz
	{ cd supplements && \
	tar -xzvf jellyfish-Hawk.tar.gz -C .. && cd .. && \
	touch jellyfish-Hawk/.mod_time_update_mock && rm jellyfish-Hawk/.mod_time_update_mock && \
	echo -e "\e[1;32mjellyfish-Hawk BUILD SUCCESSFUL\e[0m"; } || \
	{ echo -e "\e[1;31mjellyfish-Hawk BUILD FAILED\e[0m"; cd $(CUR_DIR); rm -rf jellyfish-Hawk; exit 1; }

copy: supplements/$(JF_SCRIPT_NAME) supplements/$(HAWK_SCRIPT_NAME) supplements/runAbyss supplements/runBHCorrection supplements/$(KMER_SUMMARY_SCRIPT_NAME)
	cp -v supplements/$(JF_SCRIPT_NAME) \
	supplements/$(HAWK_SCRIPT_NAME) \
	supplements/runAbyss \
	supplements/runBHCorrection \
	supplements/$(KMER_SUMMARY_SCRIPT_NAME) .

EIG6.0.1-Hawk: supplements/EIG6.0.1-Hawk.tar.gz
	{ cd supplements && \
	tar -xzvf EIG6.0.1-Hawk.tar.gz -C .. && cd .. && \
	pushd EIG6.0.1-Hawk/src && \
	$(MAKE) clobber && \
	$(MAKE) install LDLIBS="-llapacke -llapack -lm -lpthread -lgsl" && \
	popd && \
	touch EIG6.0.1-Hawk/.mod_time_update_mock && rm EIG6.0.1-Hawk/.mod_time_update_mock && \
	echo -e "\e[1;32mEIG6.0.1-HAWK BUILD SUCCESSFUL\e[0m"; } || \
	{ echo -e "\e[1;31mEIG6.0.1-HAWK BUILD FAILED\e[0m"; cd $(CUR_DIR); rm -rf EIG6.0.1-Hawk; exit 1; }
	
path_replace: copy
	sed -i "s|dir=|dir=${READ_DIR}|g" $(JF_SCRIPT_NAME)
	sed -i "s|hawkDir=|hawkDir=${HAWK_DIR}|g" $(JF_SCRIPT_NAME)
	sed -i "s|hawkDir=|hawkDir=${HAWK_DIR}|g" $(HAWK_SCRIPT_NAME)
	sed -i "s|hawkDir=|hawkDir=${HAWK_DIR}|g" runBHCorrection
	sed -i "s|hawkDir=|hawkDir=${HAWK_DIR}|g" $(KMER_SUMMARY_SCRIPT_NAME)

clean:
	rm -f *.o
	rm -f ${CPP_FOLDER}/*.o
	rm -rf EIG6.0.1-Hawk
	rm -rf jellyfish-Hawk
	rm -rf jellyfish-2.2.10

#all:
#	g++ hawk.cpp cpp/src/*.cpp -lm -lpthread -o hawk
#	g++ bonf_fasta.cpp -o bonf_fasta
#	g++ kmersearch.cpp -o kmersearch
#	g++ kmersummary.cpp -o kmersummary
#	g++ preProcess.cpp -o preProcess
#	g++ convertToFasta.cpp -o convertToFasta
