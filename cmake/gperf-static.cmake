cmake_minimum_required(VERSION 3.2...3.31 FATAL_ERROR)
file(READ ${INPUT_FILENAME} INPUT)
string(REGEX REPLACE "\n(const struct alias )" "\nstatic \\1" INPUT "${INPUT}")
file(WRITE ${OUTPUT_FILENAME} "${INPUT}")
