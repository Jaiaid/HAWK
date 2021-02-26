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


.PHONY: all clean


all: hawk preProcess log_reg_case log_reg_control bonf_fasta\
     kmersearch kmersummary convertToFasta_bf_correction convertToFasta_bh_correction\
	 kmerStats

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
	for f in `ls ${CPP_FILE}`;do echo $$f;g++ $$f -c -o $$f.o; done

install: copy EIG6.0.1-Hawk $(JF_BUILD_RULE)

# build rule jellyfish-2.2.10
jellyfish-2.2.10: supplements/jellyfish-2.2.10-HAWK.tar.gz
	cd supplements && \
	tar -xzvf jellyfish-2.2.10-HAWK.tar.gz -C ..
	pushd jellyfish-2.2.10 && \
	./configure && $(MAKE) && \
	popd

jellyfish-Hawk: supplements/jellyfish-Hawk.tar.gz
	cd supplements && \
	tar -xzvf jellyfish-Hawk.tar.gz -C ..
	touch jellyfish-Hawk/.mod_time_update_mock && rm jellyfish-Hawk/.mod_time_update_mock

copy: supplements/$(JF_SCRIPT_NAME) supplements/$(HAWK_SCRIPT_NAME) supplements/runAbyss supplements/runBHCorrection supplements/$(KMER_SUMMARY_SCRIPT_NAME)
	cp -v supplements/$(JF_SCRIPT_NAME) \
	supplements/$(HAWK_SCRIPT_NAME) \
	supplements/runAbyss \
	supplements/runBHCorrection \
	supplements/$(KMER_SUMMARY_SCRIPT_NAME) .

EIG6.0.1-Hawk: supplements/EIG6.0.1-Hawk.tar.gz
	cd supplements && \
	tar -xzvf EIG6.0.1-Hawk.tar.gz -C ..
	pushd EIG6.0.1-Hawk/src && \
	$(MAKE) clobber && \
	$(MAKE) install LDLIBS="-llapacke -lm -llapack -lpthread -lgsl" && \
	popd && \
	touch EIG6.0.1-Hawk/.mod_time_update_mock && rm EIG6.0.1-Hawk/.mod_time_update_mock
	
path_replace: copy
	sed -i "s|dir=|dir=${READ_DIR}|g" $(JF_SCRIPT_NAME)
	sed -i "s|hawkDir=|hawkDir=${HAWK_DIR}|g" $(JF_SCRIPT_NAME)
	sed -i "s|hawkDir=|hawkDir=${HAWK_DIR}|g" $(HAWK_SCRIPT_NAME)
	sed -i "s|hawkDir=|hawkDir=${HAWK_DIR}|g" runBHCorrection
	sed -i "s|hawkDir=|hawkDir=${HAWK_DIR}|g" $(KMER_SUMMARY_SCRIPT_NAME)

clean:
	rm *.o
	rm ${CPP_FOLDER}/*.o

clean_eigjf:
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
