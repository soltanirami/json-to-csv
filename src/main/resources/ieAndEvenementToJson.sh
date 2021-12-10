#!/bin/bash
set -e

at_exit() {
  local code=$?
  local cmd=$BASH_COMMAND

  if test $code -ne 0; then
    echo "La commande <$cmd> a échouée avec le statut $code!" >&2
  fi

  exit $code
}

trap at_exit EXIT

echo "@@@@@ ------- Connection à la bd-d-nefertari2.info.ratp"
ssh nf2@bd-d-nefertari2.info.ratp bash <<EOF
dbname="nf2"
echo '@@@@@@@@@@@@@@ executing query for investigationEnquete @@@@@@@@@@@@'
mongo $dbname --eval 'db.investigationEnquete.aggregate([
                                 {
                                     $lookup: {
                                       from: "corbeille",
                                       localField: "corbeille.$id",
                                       foreignField: "_id",
                                       as: "corb"
                                     }},
                                    {$addFields:{"corbLib": {$first:"$corb.libelle"}}},
                                    {$project:{"corb":0,"corbeille":0,"piecesJointes":0,"historiques":0}},
                                    {$out : "investigationEnqueteCopy" }
                              ]);' --quiet;

ieJsonFile="/appli/nf2/data/sauvegarde-bd/investigationEnqueteCopy.json"
evenementJsonFile="/appli/nf2/data/sauvegarde-bd/evenementCopy.json"
ieCopyCollection="investigationEnqueteCopy"
evenementCollection="evenement"


mongoexport -d $dbname -c $ieCopyCollection --out=$ieJsonFile --jsonArray --type=json
echo "@@@@@@@@@@@@ the collection $ieCopyCollection was exported to  $ieJsonFile @@@@@@@@@@@@"
mongo $dbname --eval 'db.investigationEnqueteCopy.drop();' --quiet && echo "Collection $ieCopyCollection dropped with success"

mongoexport -d $dbname -c $evenementCollection --out=$evenementJsonFile --jsonArray --type=json
echo "@@@@@@@@@@@@ the collection $evenementCollection was exported to  $evenementJsonFile @@@@@@@@@@@@"
EOF

