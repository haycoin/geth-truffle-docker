printf "\n\n"

read -n1 -p "/// Start docker in Truffle testing / Geth live mode [T/g]? " doit
case $doit in
    t|T)        ENVT="Truffle [[ Testing ]]";         ENVI="truffle";;
    g|G)        ENVT="Geth    [[ LIVE ]]   ";               ENVI="geth";;
    *)          ENVT="Truffle [[ Testing ]]";         ENVI="truffle";;
esac

printf "\n\n--- $ENVT mode is loading                              ---\n";
printf "\n--- Your node name is $GETH_NODE, type exit to terminate               ---\n"
printf "\nLoading ...\n"
docker-compose up -d;
docker exec -it $ENVI sh
