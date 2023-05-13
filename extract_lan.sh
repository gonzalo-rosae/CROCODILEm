#!/usr/bin/env bash
# this is a bash script to bootstart the project including downloading of datasets - setup of additional tools.
# pass a language code as a variable to install a certain language. Defaults to English if no language code given.

################################
# Download Data #
###############################
set -e
path="/home/v976/v976827/crocodile/CROCODILEm"
echo "downloading wikipedia and wikidata dumps..."
mkdir $path/data/$1
wikimapper download $1wiki-latest --dir $path/data/$1/
echo "Create wikidata database"
wikimapper create $1wiki-latest --dumpdir $path/data/$1/ --target $path/data/$1/index_$1wiki-latest.db
echo "Extract abstracts"
python -m wikiextractor.WikiExtractor $path/data/$1/$1wiki-latest-page.sql.gz --links --output $path/text/$1 --templates $path/data/$1/templates.txt
echo "Fix first and last file: "
echo `ls -1 $path/text/$1/**/* | tail -1`
echo "</data>" >> `ls -1 $path/text/$1/**/* | tail -1`
sed -i '$ d' $path/text/$1/AA/wiki_00
echo "</data>" >> $path/text/$1/AA/wiki_00
echo "Create triplets db"
# EN LA LINEA DE ABAJO, LA CARPETA "wikidata" ??
python wikidata-triplets.py --input $path/text/$1/ --output $path/data/$1/wikidata-triples-$1-subj.db --input_triples wikidata/wikidata-triples.csv --format db
echo "Extract triplets to $path/out/$1"
python multicore_run.py --input $path/text/$1/ --output $path//out/$1/ --input_triples $path/data/$1/wikidata-triples-$1-subj.db --language $1
echo "Clean triplets to $path/out_clean/$1"
# python filter_relations.py --folder_input $path/out/$1
python add_filter_relations.py --folder_input $path/out/$1